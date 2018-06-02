
//
// AvatarWorld Ltd
// QQ群:756607706
// Connect 社区 https://connect.unity.com/t/5af3e7ad32b3060018fb9fba
// 

// Surface texture blend with blend mask
// Specular - workflow
// Two texture Layers
// Albedo Normal Specular(A:Smoothness)

Shader "AvatarWorld/SurfaceBlend_With_Mask" {
	Properties {
		_BlendMask("Mask", 2D) = "black"{}
		
		// Albedo Color Texture Map
		_MainTexLayer01("Albedo Layer01 (RGB)", 2D) = "white" {}
		_MainTexLayer02 ("Albedo Layer02 (RGB)", 2D) = "white" {}

		// Normal Map
		_NormapLayer01("Normal Map Layer01", 2D) = "bump"{}
		_NormapLayer02("Normal Map Layer02", 2D) = "bump"{}

		// Specular (A:Smoothness)
 		_SpecGlossMapLayer01 ("Specular Map Layer01", 2D) = "white"{}
 		_SpecGlossMapLayer02 ("Specular Map Layer02", 2D) = "white"{}
		
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
		#pragma surface surf StandardSpecular fullforwardshadows addshadow

		// gles 无法编译该shader
		// exclude compile platform
		#pragma exclude_renderers gles

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;

		struct Input {
			float4 color;
			float2 uv_MainTexLayer01;
			float2 uv_MainTexLayer02;
			float2 uv_BlendMask;
		};

		sampler2D _MainTexLayer01;
		sampler2D _MainTexLayer02;

		sampler2D _NormapLayer01;
		sampler2D _NormapLayer02;

		sampler2D _SpecGlossMapLayer01;
		sampler2D _SpecGlossMapLayer02;

		sampler2D _BlendMask;

		float _SmoothnessLayer01;
		float _SmoothnessLayer02;

		void surf (Input IN, inout SurfaceOutputStandardSpecular o) 
		{
			fixed blend = tex2D(_BlendMask, IN.uv_BlendMask).a;
	
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
	CustomEditor "SurfaceBlend_With_MaskGUI"
}
