﻿// Toony Colors Pro+Mobile 2
// (c) 2014-2017 Jean Moreno

Shader "Toony Colors Pro 2/User/My TCP2 Shader"
{
	Properties
	{
	[TCP2HeaderHelp(BASE, Base Properties)]
		//TOONY COLORS
		_Color ("Color", Color) = (0.5,0.5,0.5,1.0)
		_HColor ("Highlight Color", Color) = (0.6,0.6,0.6,1.0)
		_SColor ("Shadow Color", Color) = (0.3,0.3,0.3,1.0)
		
		//DIFFUSE
		_MainTex ("Main Texture (RGB)", 2D) = "white" {}
	[TCP2Separator]
		
		//TOONY COLORS RAMP
		[TCP2Gradient] _Ramp ("Toon Ramp (RGB)", 2D) = "gray" {}
	[TCP2Separator]
	
	[Header(Masks)]
		[NoScaleOffset]
		_Mask1 ("Mask 1 (Emission)", 2D) = "black" {}
	[TCP2Separator]
	
	[TCP2HeaderHelp(EMISSION, Emission)]
		[HDR] _EmissionColor ("Emission Color", Color) = (1,1,1,1.0)
	[TCP2Separator]
	
	[TCP2HeaderHelp(RIM, Rim)]
		//RIM LIGHT
		_RimColor ("Rim Color", Color) = (0.8,0.8,0.8,0.6)
		_RimMin ("Rim Min", Range(0,1)) = 0.5
		_RimMax ("Rim Max", Range(0,1)) = 1.0
	[TCP2Separator]
	
	[TCP2HeaderHelp(TRANSPARENCY)]
		//Blending
		[Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendTCP2 ("Blending Source", Float) = 5
		[Enum(UnityEngine.Rendering.BlendMode)] _DstBlendTCP2 ("Blending Dest", Float) = 10
		
		//Avoid compile error if the properties are ending with a drawer
		[HideInInspector] __dummy__ ("unused", Float) = 0
	}
	
	SubShader
	{
		Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
		Blend [_SrcBlendTCP2] [_DstBlendTCP2]
		
		CGPROGRAM
		
		#pragma surface surf ToonyColorsCustom keepalpha
		#pragma target 3.0
		#pragma multi_compile TCP2_RAMPTEXT
		
		//================================================================
		// VARIABLES
		
		fixed4 _Color;
		sampler2D _MainTex;
		sampler2D _Mask1;
		half4 _EmissionColor;
		fixed4 _RimColor;
		fixed _RimMin;
		fixed _RimMax;
		float4 _RimDir;
		
		struct Input
		{
			half2 uv_MainTex;
			float3 viewDir;
		};
		
		//================================================================
		// CUSTOM LIGHTING
		
		//Lighting-related variables
		fixed4 _HColor;
		fixed4 _SColor;
		sampler2D _Ramp;
		
		//Custom SurfaceOutput
		struct SurfaceOutputCustom
		{
			fixed3 Albedo;
			fixed3 Normal;
			fixed3 Emission;
			half Specular;
			fixed Gloss;
			fixed Alpha;
		};
		
		inline half4 LightingToonyColorsCustom (inout SurfaceOutputCustom s, half3 lightDir, half3 viewDir, half atten)
		{
			s.Normal = normalize(s.Normal);
			fixed ndl = max(0, dot(s.Normal, lightDir));
			fixed3 ramp = tex2D(_Ramp, fixed2(ndl,ndl));
		#if !(POINT) && !(SPOT)
			ramp *= atten;
		#endif
			_SColor = lerp(_HColor, _SColor, _SColor.a);	//Shadows intensity through alpha
			ramp = lerp(_SColor.rgb, _HColor.rgb, ramp);
			fixed4 c;
			c.rgb = s.Albedo * _LightColor0.rgb * ramp;
			c.a = s.Alpha;
		#if (POINT || SPOT)
			c.rgb *= atten;
		#endif
			return c;
		}

		//================================================================
		// SURFACE FUNCTION

		void surf(Input IN, inout SurfaceOutputCustom o)
		{
			fixed4 mainTex = tex2D(_MainTex, IN.uv_MainTex);
			
			//Masks
			fixed4 mask1 = tex2D(_Mask1, IN.uv_MainTex);
			
			o.Albedo = mainTex.rgb * _Color.rgb;
			o.Alpha = mainTex.a * _Color.a;
			
			//Rim
			float3 viewDir = normalize(IN.viewDir);
			half rim = 1.0f - saturate( dot(viewDir, o.Normal) );
			rim = smoothstep(_RimMin, _RimMax, rim);
			rim *= mainTex.a;
			o.Emission += (_RimColor.rgb * rim) * _RimColor.a;
			
			//Emission
			o.Emission += mainTex.rgb * (mask1.a * _EmissionColor.a) * _EmissionColor.rgb;
		}
		
		ENDCG
	}
	
	Fallback "Diffuse"
	CustomEditor "TCP2_MaterialInspector_SG"
}
