//
// AvatarWorld Ltd
// QQ群:756607706
// 官网 http://www.avatarworld.cn/
// Connect 社区 https://connect.unity.com/t/5af3e7ad32b3060018fb9fba
// 

// Surface texture blend with blend 
// Specular - workflow
// Two texture Layers
// Albedo Normal Specular(A:Smoothness) Displacement

Shader "AvatarWorld/SurfaceBlend_With_Mask_Displacement" 
{
	Properties 
	{
		_Mask("Mask", 2D) = "black"{}
		// Albedo Color Texture Map
		_MainTexLayer01("Albedo Layer01 (RGB)", 2D) = "white" {}
		_MainTexLayer02 ("Albedo Layer02 (RGB)", 2D) = "white" {}

		// Normal Map
		_NormapLayer01("Normal Map Layer01", 2D) = "bump"{}
		_NormapLayer02("Normal Map Layer02", 2D) = "bump"{}

		// Specular (A:Smoothness)
 		_SpecGlossMapLayer01 ("Specular Map Layer01", 2D) = "white"{}
 		_SpecGlossMapLayer02 ("Specular Map Layer02", 2D) = "white"{}

		// Displace Map
		_DisplacementLayer01("Displacement Map Layer01", 2D) = "gray"{}
		_DisplacementLayer02("Displacement Map Layer02", 2D) = "gray"{}

		_Tess("Tessellation", Range(1,32)) = 32
		_maxDist("Tess Fade Distance", Range(0, 500.0)) = 25.0

		_Displacement("Displacement", Range(0, 10.0)) = 0.3
		_DispOffset("Disp Offset", Range(0, 1)) = 0.5
		_DispPhong("Disp Phong", Range(0, 1)) = 0
		
		// Smoothness value
		_SmoothnessLayer01 ("Smoothness Layer01", Range(0,1)) = 1
		_SmoothnessLayer02 ("Smoothness Layer02", Range(0,1)) = 1
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		// 使用Specular的工作流 StandardSpecular
		// surface shader support displacement and tessllate
		// #pragma surface surf StandardSpecular fullforwardshadows addshadow
		#pragma surface surf StandardSpecular fullforwardshadows addshadow vertex:disp tessellate:tessFixed

		// gles 无法编译该shader
		// exclude compile platform
		// #pragma exclude_renderers gles
		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 4.6
		#include "UnityCG.cginc"

		float _DispPhong;
		float _Tess;
		float _maxDist;
		
		struct Input {
			fixed4 color : COLOR;
			float2 uv_MainTexLayer01;
			float2 uv_MainTexLayer02;
		};

		struct appdata
		{
			float4 vertex : POSITION;
			float4 tangent : TANGENT;
			float3 normal : NORMAL;
			float2 texcoord : TEXCOORD0;
			float2 texcoord1 : TEXCOORD1;
			float2 texcoord2 : TEXCOORD2;

			fixed4 color : COLOR;
		};

		float tessFixed()
		{
			return _Tess;
		}

		sampler2D _Mask;
		uniform float4 _Mask_ST;

		sampler2D _DisplacementLayer01;
		uniform float4 _DisplacementLayer01_ST;

		sampler2D _DisplacementLayer02;
		uniform float4 _DisplacementLayer02_ST;

		sampler2D _MainTexLayer01;
		sampler2D _MainTexLayer02;

		sampler2D _NormapLayer01;
		sampler2D _NormapLayer02;

		sampler2D _SpecGlossMapLayer01;
		sampler2D _SpecGlossMapLayer02;


		float _SmoothnessLayer01;
		float _SmoothnessLayer02;

		float _Displacement;
		float _DispOffset;

		void disp(inout appdata v)
		{
			const float fadeOut= saturate((_maxDist - distance(mul(unity_ObjectToWorld, v.vertex), _WorldSpaceCameraPos)) / (_maxDist * 0.7f));
            float d1 = tex2Dlod(_DisplacementLayer01, float4(v.texcoord.xy * _DisplacementLayer01_ST.xy + _DisplacementLayer01_ST.zw, 0, 0)).r;// * _Displacement;
            float d2 = tex2Dlod(_DisplacementLayer02, float4(v.texcoord.xy * _DisplacementLayer02_ST.xy + _DisplacementLayer02_ST.zw, 0, 0)).r;
			// Using tex2D in the Vertex Shader. This is not valid, because UV derivatives don’t exist in the vertex Shader. You need to sample an explicit mip level instead; 
			// for example, use tex2Dlod (tex, float4(uv,0,0)). 
			// You also need to add #pragma target 3.0 as tex2Dlod is a Shader model 3.0 feature.
			float blend = tex2Dlod(_Mask, float4(v.texcoord.xy * _Mask_ST.xy + _Mask_ST.zw, 0, 0)).a;
            float d = lerp(d1, d2, blend) * _Displacement;
			// d = d1 * _Displacement;
            d = d * 0.5 - 0.5 +_DispOffset;
            v.vertex.xyz += v.normal * d;
			v.color = float4(v.texcoord, 0, 0);
		}

		void surf (Input IN, inout SurfaceOutputStandardSpecular o) 
		{
			float2 uv = TRANSFORM_TEX(IN.color.xy, _Mask);
			fixed blend = tex2D(_Mask, uv).a;

			// fixed blend = 1;
			fixed4 albedo1 = tex2D(_MainTexLayer01, IN.uv_MainTexLayer01);
			fixed4 spec1	= tex2D(_SpecGlossMapLayer01, IN.uv_MainTexLayer01);
		 	fixed3 normal1 = UnpackNormal (tex2D (_NormapLayer01, IN.uv_MainTexLayer01));

			fixed4 albedo2 = tex2D(_MainTexLayer02, IN.uv_MainTexLayer02);
			fixed4 spec2 = tex2D(_SpecGlossMapLayer02, IN.uv_MainTexLayer02);
		 	fixed3 normal2 = UnpackNormal (tex2D (_NormapLayer02, IN.uv_MainTexLayer02));

		 	// blend specular map
		 	fixed4 specSmoothness = lerp (spec1, spec2, blend);

		 	// blend smoothness with defined factor
		 	float smoothness = lerp(spec1.a * _SmoothnessLayer01, spec2.a * _SmoothnessLayer02, blend);

			o.Albedo 		= lerp (albedo1, albedo2, blend);
		 	o.Specular 		= specSmoothness.rgb;
			o.Smoothness 	= smoothness;
		  	o.Normal 		= lerp (normal1, normal2, blend);
		}
		ENDCG
	}
	FallBack "Diffuse"
	CustomEditor "SurfaceBlend_With_Mask_DisplacementGUI"
}
