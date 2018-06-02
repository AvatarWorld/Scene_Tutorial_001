//
// AvatarWorld Ltd
// QQ群:756607706
// 官网 http://www.avatarworld.cn/
// Connect 社区 https://connect.unity.com/t/5af3e7ad32b3060018fb9fba
// 


//
// Blend4Layer Demo只用了最简单的线性差值进行融合各个贴图并不是最完美的融合策略
// 比如normal Map，AO，Displacement等贴图的融合，更好的策略可能不是线性差值
// tess用的是fixed，需要自己编写tess策略

Shader "AvatarWorld/Blend4Layer" {
	Properties{

		// Albedo Color Texture Map
		_MainTexLayer01("Albedo Layer01 (RGB)", 2D) = "white" {}
	_MainTexLayer02("Albedo Layer02 (RGB)", 2D) = "white" {}
	_MainTexLayer03("Albedo Layer03 (RGB)", 2D) = "white" {}
	_MainTexLayer04("Albedo Layer04 (RGB)", 2D) = "white" {}

	// Normal Map
	_NormapLayer01("Normal Map Layer01", 2D) = "bump"{}
	_NormapLayer02("Normal Map Layer02", 2D) = "bump"{}
	_NormapLayer03("Normal Map Layer03", 2D) = "bump"{}
	_NormapLayer04("Normal Map Layer04", 2D) = "bump"{}

	// Specular Map
	// 正常情况下，我们会用RGB来存放高光的颜色，Demo里面只用了R来存储高光贴图，只是为了演示如何去做融合
	_SpecGlossMapLayer01("Specular Map Layer01 R(Specular) G(Smoothness) B(Displacement)", 2D) = "white"{}
	_SpecGlossMapLayer02("Specular Map Layer02 R(Specular) G(Smoothness) B(Displacement)", 2D) = "white"{}
	_SpecGlossMapLayer03("Specular Map Layer03 R(Specular) G(Smoothness) B(Displacement)", 2D) = "white"{}
	_SpecGlossMapLayer04("Specular Map Layer04 R(Specular) G(Smoothness) B(Displacement) ", 2D) = "white"{}

	// Smoothness value
	_SmoothnessLayer01("Smoothness Layer01", Range(0,1)) = 1
		_SmoothnessLayer02("Smoothness Layer02", Range(0,1)) = 1
		_SmoothnessLayer03("Smoothness Layer03", Range(0,1)) = 1
		_SmoothnessLayer04("Smoothness Layer04", Range(0,1)) = 1

		// we use fixed tessellation
		_Tess("Tessellation", Range(1,32)) = 32
		_Displacement("Displacement", Range(0, 2.0)) = 0.3
		_DispOffset("Disp Offset", Range(0, 1)) = 0.5
	}

		SubShader{
		Tags{ "RenderType" = "Opaque" }
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		// Physically based Standard lighting model, and enable shadows on all light types
		// 使用Specular的工作流 StandardSpecular
		// surface shader support displacement and tessllate
		// #pragma surface surf StandardSpecular fullforwardshadows addshadow
#pragma surface surf StandardSpecular fullforwardshadows addshadow vertex:disp tessellate:tessFixed

		// Use shader model 3.0 target, to get nicer looking lighting
#pragma target 4.6
#include "UnityCG.cginc"

		struct appdata
	{
		float4 vertex : POSITION;
		float4 tangent : TANGENT;
		float3 normal : NORMAL;
		float2 texcoord : TEXCOORD0;
		float2 texcoord1 : TEXCOORD1;
		float2 texcoord2 : TEXCOORD2;

		float4 color : COLOR;

	};

	float _Tess;

	float tessFixed()
	{
		return _Tess;
	}

	struct Input {
		float2 uv_MainTexLayer01;
		float2 uv_MainTexLayer02;
		float2 uv_MainTexLayer03;
		float2 uv_MainTexLayer04;
		float4 color : COLOR;
	};

	// value define
	sampler2D _MainTexLayer01;
	sampler2D _MainTexLayer02;
	sampler2D _MainTexLayer03;
	sampler2D _MainTexLayer04;

	sampler2D _NormapLayer01;
	sampler2D _NormapLayer02;
	sampler2D _NormapLayer03;
	sampler2D _NormapLayer04;

	sampler2D _SpecGlossMapLayer01;
	uniform float4 _SpecGlossMapLayer01_ST;
	sampler2D _SpecGlossMapLayer02;
	uniform float4 _SpecGlossMapLayer02_ST;
	sampler2D _SpecGlossMapLayer03;
	uniform float4 _SpecGlossMapLayer03_ST;
	sampler2D _SpecGlossMapLayer04;
	uniform float4 _SpecGlossMapLayer04_ST;

	float _SmoothnessLayer01;
	float _SmoothnessLayer02;
	float _SmoothnessLayer03;
	float _SmoothnessLayer04;

	float _Displacement;
	float _DispOffset;

	void disp(inout appdata v)
	{
		float d1 = tex2Dlod(_SpecGlossMapLayer01, float4(v.texcoord.xy * _SpecGlossMapLayer01_ST.xy + _SpecGlossMapLayer01_ST.zw, 0, 0)).b;// * _Displacement;
		float d2 = tex2Dlod(_SpecGlossMapLayer02, float4(v.texcoord.xy * _SpecGlossMapLayer02_ST.xy + _SpecGlossMapLayer02_ST.zw, 0, 0)).b;
		float d3 = tex2Dlod(_SpecGlossMapLayer03, float4(v.texcoord.xy * _SpecGlossMapLayer03_ST.xy + _SpecGlossMapLayer03_ST.zw, 0, 0)).b;
		float d4 = tex2Dlod(_SpecGlossMapLayer04, float4(v.texcoord.xy * _SpecGlossMapLayer04_ST.xy + _SpecGlossMapLayer04_ST.zw, 0, 0)).b;

		// Using tex2D in the Vertex Shader. This is not valid, because UV derivatives don’t exist in the vertex Shader. You need to sample an explicit mip level instead; 
		// for example, use tex2Dlod (tex, float4(uv,0,0)). 
		// You also need to add #pragma target 3.0 as tex2Dlod is a Shader model 3.0 feature.
		// float blend = tex2Dlod(_Mask, float4(v.texcoord.xy * _Mask_ST.xy + _Mask_ST.zw, 0, 0)).a;
		float b1 = v.color.r;
		float b2 = v.color.g;
		float b3 = v.color.b;

		float d = lerp(d1, d2, b1);
		d = lerp(d, d3, b2);
		d = lerp(d, d4, b3);
		d = d * _Displacement;

		// d = d1 * _Displacement;
		d = d * 0.5 - 0.5 + _DispOffset;
		v.vertex.xyz += v.normal * d;
	}

	// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
	// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
	// #pragma instancing_options assumeuniformscaling
	UNITY_INSTANCING_BUFFER_START(Props)
		// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

		void surf(Input IN, inout SurfaceOutputStandardSpecular o) {
		// float2 uv = TRANSFORM_TEX(IN.color.xy, _Mask);
		// fixed blend = tex2D(_Mask, uv).a;

		float b1 = IN.color.r;
		float b2 = IN.color.g;
		float b3 = IN.color.b;

		fixed4 albedo1 = tex2D(_MainTexLayer01, IN.uv_MainTexLayer01);
		fixed4 spec1 = tex2D(_SpecGlossMapLayer01, IN.uv_MainTexLayer01);
		fixed3 normal1 = UnpackNormal(tex2D(_NormapLayer01, IN.uv_MainTexLayer01));

		fixed4 albedo2 = tex2D(_MainTexLayer02, IN.uv_MainTexLayer02);
		fixed4 spec2 = tex2D(_SpecGlossMapLayer02, IN.uv_MainTexLayer02);
		fixed3 normal2 = UnpackNormal(tex2D(_NormapLayer02, IN.uv_MainTexLayer02));

		fixed4 albedo3 = tex2D(_MainTexLayer03, IN.uv_MainTexLayer03);
		fixed4 spec3 = tex2D(_SpecGlossMapLayer03, IN.uv_MainTexLayer03);
		fixed3 normal3 = UnpackNormal(tex2D(_NormapLayer03, IN.uv_MainTexLayer03));

		fixed4 albedo4 = tex2D(_MainTexLayer04, IN.uv_MainTexLayer04);
		fixed4 spec4 = tex2D(_SpecGlossMapLayer04, IN.uv_MainTexLayer04);
		fixed3 normal4 = UnpackNormal(tex2D(_NormapLayer04, IN.uv_MainTexLayer04));
		// blend specular map
		fixed4 specSmoothness = lerp(spec1, spec2, b1);
		specSmoothness = lerp(specSmoothness, spec3, b2);
		specSmoothness = lerp(specSmoothness, spec4, b3);

		// blend smoothness with defined factor
		float smoothness = lerp(spec1.g * _SmoothnessLayer01, spec2.g * _SmoothnessLayer02, b1);
		smoothness = lerp(smoothness, spec3.g * _SmoothnessLayer03, b2);
		smoothness = lerp(smoothness, spec4.g * _SmoothnessLayer04, b3);

		fixed4 albedo = lerp(albedo1, albedo2, b1);
		albedo = lerp(albedo, albedo3, b2);
		albedo = lerp(albedo, albedo4, b3);

		fixed3 normal = lerp(normal1, normal2, b1);
		normal = lerp(normal, normal3, b2);
		normal = lerp(normal, normal4, b3);

		o.Albedo = albedo;
		o.Specular = specSmoothness.r;
		o.Smoothness = smoothness;
		o.Normal = normal;
	}
	ENDCG
	}
		FallBack "Diffuse"
		CustomEditor "Blend4LayerGUI"
}