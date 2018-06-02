// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 


//
// 可以用ASE Shader 打开进行再次编辑
//

Shader "AvatarWorld/VegetationShader_Animation"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_Albedo("Albedo", 2D) = "white" {}
		_AlbedoColor("AlbedoColor", Color) = (1,1,1,0)
		_Normal("Normal", 2D) = "bump" {}
		_Mask("Mask", 2D) = "white" {}
		_AOContent("AOContent", Range( -2 , 2)) = 0
		_Smoothness("Smoothness", Range( -2 , 2)) = 0
		_Thickness("Thickness", 2D) = "white" {}
		[Header(Translucency)]
		_Translucency("Strength", Range( 0 , 50)) = 1
		_TransNormalDistortion("Normal Distortion", Range( 0 , 1)) = 0.1
		_TransScattering("Scaterring Falloff", Range( 1 , 50)) = 2
		_TransDirect("Direct", Range( 0 , 1)) = 1
		_TransAmbient("Ambient", Range( 0 , 1)) = 0.2
		_Random("Random", Float) = 0
		_TransShadow("Shadow", Range( 0 , 1)) = 0.9
		_Intensity("Intensity", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "AlphaTest+0" }
		Cull Off
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#pragma target 4.6
		#pragma surface surf StandardCustom keepalpha addshadow fullforwardshadows exclude_path:deferred vertex:vertexDataFunc 
		struct Input
		{
			float2 uv_texcoord;
		};

		struct SurfaceOutputStandardCustom
		{
			fixed3 Albedo;
			fixed3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			fixed Alpha;
			fixed3 Translucency;
		};

		uniform float _Intensity;
		uniform float _Random;
		uniform sampler2D _Normal;
		uniform float4 _Normal_ST;
		uniform float4 _AlbedoColor;
		uniform sampler2D _Albedo;
		uniform float4 _Albedo_ST;
		uniform sampler2D _Mask;
		uniform float4 _Mask_ST;
		uniform float _Smoothness;
		uniform float _AOContent;
		uniform half _Translucency;
		uniform half _TransNormalDistortion;
		uniform half _TransScattering;
		uniform half _TransDirect;
		uniform half _TransAmbient;
		uniform half _TransShadow;
		uniform sampler2D _Thickness;
		uniform float4 _Thickness_ST;
		uniform float _Cutoff = 0.5;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertex3Pos = v.vertex.xyz;
			float3 temp_output_38_0 = ( sin( ase_vertex3Pos ) * ( _Intensity * ( ( 1.0 - v.texcoord.xy.x ) * cos( ( _Random * _Time.y ) ) ) ) );
			float3 appendResult39 = (float3(temp_output_38_0.x , 0.0 , temp_output_38_0.x));
			v.vertex.xyz += ( v.color.r * appendResult39 );
		}

		inline half4 LightingStandardCustom(SurfaceOutputStandardCustom s, half3 viewDir, UnityGI gi )
		{
			#if !DIRECTIONAL
			float3 lightAtten = gi.light.color;
			#else
			float3 lightAtten = lerp( _LightColor0.rgb, gi.light.color, _TransShadow );
			#endif
			half3 lightDir = gi.light.dir + s.Normal * _TransNormalDistortion;
			half transVdotL = pow( saturate( dot( viewDir, -lightDir ) ), _TransScattering );
			half3 translucency = lightAtten * (transVdotL * _TransDirect + gi.indirect.diffuse * _TransAmbient) * s.Translucency;
			half4 c = half4( s.Albedo * translucency * _Translucency, 0 );

			SurfaceOutputStandard r;
			r.Albedo = s.Albedo;
			r.Normal = s.Normal;
			r.Emission = s.Emission;
			r.Metallic = s.Metallic;
			r.Smoothness = s.Smoothness;
			r.Occlusion = s.Occlusion;
			r.Alpha = s.Alpha;
			return LightingStandard (r, viewDir, gi) + c;
		}

		inline void LightingStandardCustom_GI(SurfaceOutputStandardCustom s, UnityGIInput data, inout UnityGI gi )
		{
			#if defined(UNITY_PASS_DEFERRED) && UNITY_ENABLE_REFLECTION_BUFFERS
				gi = UnityGlobalIllumination(data, s.Occlusion, s.Normal);
			#else
				UNITY_GLOSSY_ENV_FROM_SURFACE( g, s, data );
				gi = UnityGlobalIllumination( data, s.Occlusion, s.Normal, g );
			#endif
		}

		void surf( Input i , inout SurfaceOutputStandardCustom o )
		{
			float2 uv_Normal = i.uv_texcoord * _Normal_ST.xy + _Normal_ST.zw;
			o.Normal = UnpackNormal( tex2D( _Normal, uv_Normal ) );
			float2 uv_Albedo = i.uv_texcoord * _Albedo_ST.xy + _Albedo_ST.zw;
			float4 tex2DNode1 = tex2D( _Albedo, uv_Albedo );
			o.Albedo = ( _AlbedoColor * tex2DNode1 ).rgb;
			float2 uv_Mask = i.uv_texcoord * _Mask_ST.xy + _Mask_ST.zw;
			float4 tex2DNode3 = tex2D( _Mask, uv_Mask );
			o.Metallic = tex2DNode3.r;
			o.Smoothness = ( tex2DNode3.a * _Smoothness );
			o.Occlusion = ( tex2DNode3.g * _AOContent );
			float2 uv_Thickness = i.uv_texcoord * _Thickness_ST.xy + _Thickness_ST.zw;
			o.Translucency = tex2D( _Thickness, uv_Thickness ).rgb;
			o.Alpha = 1;
			clip( tex2DNode1.a - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15301
2140;133;1598;863;932.6115;-812.0718;1.3;True;True
Node;AmplifyShaderEditor.RangedFloatNode;52;-313.8118,1657.07;Float;False;Property;_Random;Random;14;0;Create;True;0;0;False;0;0;0.89;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;32;-441.513,1474.909;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;53;16.38813,1599.871;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;29;-508.9405,1165.882;Float;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;30;-124.1406,1220.582;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CosOpNode;33;83.58702,1433.911;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;35;179.2867,1072.012;Float;False;Property;_Intensity;Intensity;15;0;Create;True;0;0;False;0;0;0.09;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;27;-100.6723,924.6403;Float;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;265.587,1221.31;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;523.2869,1082.911;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;37;241.2869,914.7111;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;692.2869,991.9109;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;40;648.2869,1271.911;Float;False;Constant;_yIntensity;yIntensity;14;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;41;917.5452,921.4151;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;12;325.4591,-331.3857;Float;False;Property;_AlbedoColor;AlbedoColor;2;0;Create;True;0;0;False;0;1,1,1,0;1,1,1,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;3;200.04,414.985;Float;True;Property;_Mask;Mask;4;0;Create;True;0;0;False;0;2a997ae7e6808934e9504e38164a2b87;2b92a80f7ac80de4bb0fadc8842bb168;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1;170,-9;Float;True;Property;_Albedo;Albedo;1;0;Create;True;0;0;False;0;8fc1699121e3fbb46ba0f6d177f7bb23;ea56dbfeebb787942a7e3ec575a4ae51;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;9;240.7008,770.2808;Float;False;Property;_AOContent;AOContent;5;0;Create;True;0;0;False;0;0;0;-2;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;239.3644,655.4551;Float;False;Property;_Smoothness;Smoothness;6;0;Create;True;0;0;False;0;0;0;-2;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;39;920.2869,1105.911;Float;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;11;639.9598,752.9145;Float;True;Property;_Thickness;Thickness;7;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;743.7006,560.4811;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;1269.488,918.0112;Float;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;710.3644,431.4551;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;180,205;Float;True;Property;_Normal;Normal;3;0;Create;True;0;0;False;0;153f529032dd69b40a70501e58d9a7ae;99f34f8ccd56b324f9fc4a4b66797e4a;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;684.2584,-229.9859;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1313,64;Float;False;True;6;Float;ASEMaterialInspector;0;0;Standard;HuaYanVegetationShader_Animation;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;0;False;0;Masked;0.5;True;True;0;False;TransparentCutout;;AlphaTest;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;-1;False;-1;-1;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;8;-1;-1;0;0;0;False;0;0;0;False;-1;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;53;0;52;0
WireConnection;53;1;32;0
WireConnection;30;0;29;1
WireConnection;33;0;53;0
WireConnection;31;0;30;0
WireConnection;31;1;33;0
WireConnection;34;0;35;0
WireConnection;34;1;31;0
WireConnection;37;0;27;0
WireConnection;38;0;37;0
WireConnection;38;1;34;0
WireConnection;39;0;38;0
WireConnection;39;1;40;0
WireConnection;39;2;38;0
WireConnection;8;0;3;2
WireConnection;8;1;9;0
WireConnection;42;0;41;1
WireConnection;42;1;39;0
WireConnection;5;0;3;4
WireConnection;5;1;7;0
WireConnection;13;0;12;0
WireConnection;13;1;1;0
WireConnection;0;0;13;0
WireConnection;0;1;2;0
WireConnection;0;3;3;1
WireConnection;0;4;5;0
WireConnection;0;5;8;0
WireConnection;0;7;11;0
WireConnection;0;10;1;4
WireConnection;0;11;42;0
ASEEND*/
//CHKSM=240B8E9CB6AE10AE3312C0FB997F174C709F9A23