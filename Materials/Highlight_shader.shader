// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ASESampleShaders/Community/TFHC/Highlight Animated"
{
	Properties
	{
		_Albedo("Albedo", 2D) = "white" {}
		_Emission("Emission", 2D) = "black" {}
		_Normal("Normal", 2D) = "bump" {}
		_Oclussion("Oclussion", 2D) = "white" {}
		_HighlightColor("Highlight Color", Color) = (0.7065311,0.9705882,0.9596617,1)
		_MinHighLightLevel("MinHighLightLevel", Range( 0 , 1)) = 0.8
		_MaxHighLightLevel("MaxHighLightLevel", Range( 0 , 1)) = 0.9
		_HighlightSpeed("Highlight Speed", Range( 0 , 200)) = 60
		[Toggle]_Highlighted("Highlighted", Float) = 1
		_Highlightedvalue("Highlightedvalue", Range( 0 , 1)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityStandardUtils.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) fixed3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float3 viewDir;
			INTERNAL_DATA
		};

		uniform sampler2D _Albedo;
		uniform float _Highlighted;
		uniform sampler2D _Emission;
		uniform sampler2D _Normal;
		uniform float _HighlightSpeed;
		uniform float _MinHighLightLevel;
		uniform float _MaxHighLightLevel;
		uniform float4 _HighlightColor;
		uniform float _Highlightedvalue;
		uniform sampler2D _Oclussion;

		void surf( Input i , inout SurfaceOutputStandardSpecular o )
		{
			o.Normal = float3(0,0,1);
			float2 uv_TexCoord51 = i.uv_texcoord * float2( 1,1 ) + float2( 0,0 );
			float4 Albedo65 = tex2D( _Albedo, uv_TexCoord51 );
			o.Albedo = Albedo65.rgb;
			float4 Emision75 = tex2D( _Emission, uv_TexCoord51 );
			float3 Normal67 = UnpackScaleNormal( tex2D( _Normal, uv_TexCoord51 ) ,10.0 );
			float3 normalizeResult78 = normalize( i.viewDir );
			float dotResult79 = dot( Normal67 , normalizeResult78 );
			float mulTime138 = _Time.y * 0.05;
			float Highlight_Level87 = (_MinHighLightLevel + (sin( ( mulTime138 * _HighlightSpeed ) ) - -1) * (_MaxHighLightLevel - _MinHighLightLevel) / (1 - -1));
			float4 Highlight_Color95 = _HighlightColor;
			float4 Highlight_Rim94 = ( pow( ( 1.0 - saturate( dotResult79 ) ) , (10.0 + (Highlight_Level87 - 0.0) * (0.0 - 10.0) / (1.0 - 0.0)) ) * Highlight_Color95 );
			float4 Final_Emision114 = lerp(Emision75,( Emision75 + Highlight_Rim94 ),_Highlighted);
			o.Emission = ( Final_Emision114 * _Highlightedvalue ).rgb;
			float4 Oclussion86 = tex2D( _Oclussion, uv_TexCoord51 );
			o.Occlusion = Oclussion86.r;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardSpecular keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				fixed3 worldNormal = UnityObjectToWorldNormal( v.normal );
				fixed3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				fixed3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			fixed4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				fixed3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.viewDir = IN.tSpace0.xyz * worldViewDir.x + IN.tSpace1.xyz * worldViewDir.y + IN.tSpace2.xyz * worldViewDir.z;
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputStandardSpecular o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandardSpecular, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=14401
529;491;1278;545;1613.779;864.1011;1.611978;True;False
Node;AmplifyShaderEditor.RangedFloatNode;128;-1740.517,-840.847;Float;False;Property;_HighlightSpeed;Highlight Speed;7;0;Create;True;60;0;0;200;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;138;-1656.213,-989.2999;Float;False;1;0;FLOAT;0.05;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;51;-3035.496,-514.7198;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;137;-3085.496,-1114.421;Float;False;1244.203;1368.811;Comment;2;67;58;Textures;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;122;-1774.419,-357.309;Float;False;1900.698;589.5023;Comment;3;90;98;94;Highlight (Rim);1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;58;-2625.094,-649.5204;Float;True;Property;_Normal;Normal;2;0;Create;True;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;10.0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;127;-1387.964,-913.8461;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;77;-1724.419,-184.7088;Float;False;Tangent;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;67;-2229.994,-607.2198;Float;False;Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;90;-1467.52,-313.0073;Float;False;67;0;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;78;-1464.018,-113.7087;Float;False;1;0;FLOAT3;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;125;-1448.898,-649.0879;Float;False;Property;_MaxHighLightLevel;MaxHighLightLevel;6;0;Create;True;0.9;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;124;-1435.846,-772.2491;Float;False;Property;_MinHighLightLevel;MinHighLightLevel;5;0;Create;True;0.8;0.09;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;129;-1201.411,-905.735;Float;False;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;134;-1770.517,-1095.495;Float;False;1262.517;561.4071;Comment;1;87;Highlight Level (Ping pong animation);1,1,1,1;0;0
Node;AmplifyShaderEditor.TFHCRemapNode;132;-990.9387,-870.037;Float;False;5;0;FLOAT;0.0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0.0;False;4;FLOAT;1.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;79;-1195.62,-254.209;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0.0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;80;-1019.619,-276.509;Float;False;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;87;-776,-868.525;Float;False;Highlight_Level;-1;True;1;0;FLOAT;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;98;-1710.627,47.19332;Float;False;87;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;55;-3003.912,380.0851;Float;False;Property;_HighlightColor;Highlight Color;4;0;Create;True;0.7065311,0.9705882,0.9596617,1;0,0.7766571,1,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;81;-819.4186,-243.509;Float;False;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;99;-1080.725,-4.707439;Float;False;5;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;1.0;False;3;FLOAT;10.0;False;4;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;95;-2678.313,386.3863;Float;False;Highlight_Color;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;97;-568.021,-54.00653;Float;False;95;0;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;82;-546.6185,-307.309;Float;False;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;74;-2613.095,-439.5192;Float;True;Property;_Emission;Emission;1;0;Create;True;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;83;-298.6189,-199.5089;Float;False;2;2;0;FLOAT;0.0;False;1;COLOR;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;120;-2305.992,331.5047;Float;False;987.1003;293;Comment;4;111;114;113;115;Emission Mix & Highlight Switching;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;94;-68.9873,-215.5623;Float;False;Highlight_Rim;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;75;-2224.695,-405.8194;Float;False;Emision;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;115;-2258.862,536.0378;Float;False;94;0;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;113;-2260.741,368.6549;Float;False;75;0;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;116;-2007.652,491.5049;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0.0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ToggleSwitchNode;111;-1809.132,380.7312;Float;False;Property;_Highlighted;Highlighted;8;1;[Toggle];Create;True;1;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;85;-2608.594,-217.0179;Float;True;Property;_Oclussion;Oclussion;3;0;Create;True;None;0000000000000000f000000000000000;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;70;-361.5474,-762.6461;Float;False;114;0;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;139;-470.5134,-646.5037;Float;False;Property;_Highlightedvalue;Highlightedvalue;9;0;Create;True;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;52;-2613.794,-868.2204;Float;True;Property;_Albedo;Albedo;0;0;Create;True;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;114;-1507.891,392.5044;Float;False;Final_Emision;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;76;-355.5938,-450.9861;Float;False;86;0;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;65;-2075.293,-902.6206;Float;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;86;-2233.594,-167.0179;Float;False;Oclussion;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;68;-349.5197,-1040.513;Float;False;65;0;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;69;-336.4087,-902.9017;Float;False;67;0;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;140;1054.045,-485.2861;Float;False;2;2;0;COLOR;0.0;False;1;FLOAT;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-3.219753,-841.6202;Float;False;True;2;Float;ASEMaterialInspector;0;0;StandardSpecular;ASESampleShaders/Community/TFHC/Highlight Animated;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;0;False;0;0;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;False;0;255;255;0;0;0;0;0;0;0;0;False;0;4;10;25;False;0.5;True;0;Zero;Zero;0;Zero;Zero;Add;Add;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;0;False;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0.0;False;5;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;FLOAT;0.0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.CommentaryNode;133;-3053.912,330.0851;Float;False;642.599;257;Comment;0;Highlight Color;1,1,1,1;0;0
WireConnection;58;1;51;0
WireConnection;127;0;138;0
WireConnection;127;1;128;0
WireConnection;67;0;58;0
WireConnection;78;0;77;0
WireConnection;129;0;127;0
WireConnection;132;0;129;0
WireConnection;132;3;124;0
WireConnection;132;4;125;0
WireConnection;79;0;90;0
WireConnection;79;1;78;0
WireConnection;80;0;79;0
WireConnection;87;0;132;0
WireConnection;81;0;80;0
WireConnection;99;0;98;0
WireConnection;95;0;55;0
WireConnection;82;0;81;0
WireConnection;82;1;99;0
WireConnection;74;1;51;0
WireConnection;83;0;82;0
WireConnection;83;1;97;0
WireConnection;94;0;83;0
WireConnection;75;0;74;0
WireConnection;116;0;113;0
WireConnection;116;1;115;0
WireConnection;111;0;113;0
WireConnection;111;1;116;0
WireConnection;85;1;51;0
WireConnection;52;1;51;0
WireConnection;114;0;111;0
WireConnection;65;0;52;0
WireConnection;86;0;85;0
WireConnection;140;0;70;0
WireConnection;140;1;139;0
WireConnection;0;0;68;0
WireConnection;0;2;140;0
WireConnection;0;5;76;0
ASEEND*/
//CHKSM=CD5257B3CBB04224A3CF4CA4CA6256A9E42E311B