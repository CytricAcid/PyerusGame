// Upgrade NOTE: replaced '_Projector' with 'unity_Projector'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/ProjectorFinal" {            
   Properties {
 	_MainTex ("Albedo", 2D) = "white" { }
      
 	_AmbientColor ("AmbientColor", Color) = (255,1,1,255)
   }
      
   
   SubShader {
      Pass {      
		Tags {"Queue"="Transparent"}
         ZWrite on // don't write to depth buffer 
            // in order not to occlude other objects
         Blend SrcAlpha OneMinusSrcAlpha 
         Offset -1, -1 // avoid depth fighting
              Lighting On
             SeparateSpecular On
             
         CGPROGRAM
 
         #pragma vertex vert  
         #pragma fragment frag 
 
         // User-specified properties
         uniform sampler2D _MainTex; 
         
         float4 _AmbientColor;
 
 		uniform float4 _LightColor0;
 		 		
 
         // Projector-specific uniforms
         uniform float4x4 unity_Projector; // transformation matrix 
          // from object space to projector space 
 
          struct vertexInput {
            float4 vertex : POSITION;
            float3 normal : NORMAL;
         };
         struct vertexOutput {
            float4 pos : SV_POSITION;
            float4 posProj : TEXCOORD0;
               // position in projector space
         };
 
         vertexOutput vert(vertexInput input) 
         {
            vertexOutput output;
 
            output.posProj = mul(unity_Projector, input.vertex);
            output.pos = UnityObjectToClipPos(input.vertex);
                 
            return output;
         }
  
         float4 frag(vertexOutput input) : COLOR
         {
            if (input.posProj.w > 0.0) // in front of projector?
            {             
               return _AmbientColor*tex2D(_MainTex, input.posProj.xy / input.posProj.w);
            }
            else // behind projector
            {
               return float4(0.0, 0.0, 0.0, 0.0);
            }
         }
 
         ENDCG
      }
   }  
}
 