Shader "Custom/RadialFill_SetupThroughScript" {
    Properties {
        [PerRendererData]_MainTex ("MainTex", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _OpacityRotator ("Opacity Rotator", Range(-360, 360)) = -360 // два полных оборота
        _TextureRotator ("Texture Rotator", Range(0, 360)) = 360
        [MaterialToggle] _FillClockwise ("Fill Clockwise", int ) = 1
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
        [MaterialToggle] PixelSnap ("Pixel snap", Float) = 0			
		[HideInInspector] _CutoffRightBottomLeftTop ("cRBLT", Float) = 1.0
		[HideInInspector] _OpRightBottomLeftTop ("oRBLT", Float) = 1.0	
		[HideInInspector] _OpVector ("OpVector", Vector) = (1, -1, 0, 0)
		[HideInInspector] _ReverseMaskCoords ("_ReverseMaskCoords", int) = 0 
    }

    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
            "CanUseSpriteAtlas"="True"
            "PreviewType"="Plane"
        }

        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }

            Blend One OneMinusSrcAlpha
            Cull Off
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #pragma multi_compile _ PIXELSNAP_ON
			
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma exclude_renderers gles3 metal d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            #pragma target 3.0

            static const float TAU = float(6.283185); // это 2 * PI

            uniform sampler2D _MainTex; 
			uniform float4 _MainTex_ST;
            uniform float4 _Color;
            uniform float _OpacityRotator;
            uniform float _TextureRotator;
            uniform fixed _FillClockwise;		
			uniform fixed _CutoffRightBottomLeftTop;
			uniform fixed _OpRightBottomLeftTop;
			uniform float2 _OpVector;
			uniform int _ReverseMaskCoords;
            	
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 texcoord0 : TEXCOORD0;
            };

            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                float3 tangentDir : TEXCOORD3;
                float3 bitangentDir : TEXCOORD4;
            };

            // rotation matrix
            float2x2 getMatrix(float angle) {								
                float r_cos = cos(angle);
                float r_sin = sin(angle);                
				return float2x2(r_cos, -r_sin, r_sin, r_cos);
			}

			// mask generating
			float2x2 getMask(float oAtan2MaskNormalized, float rotator, int isRotatorSubtract) {							
				float oAtan2MaskRotatable = isRotatorSubtract ? oAtan2MaskNormalized - rotator : rotator - oAtan2MaskNormalized;
				return ceil(oAtan2MaskRotatable);
			}

			float getNormalizedAtanMask(float2 maskChannels, int reverseMaskCoords) {
				float atan2var = reverseMaskCoords ? atan2(maskChannels.r, maskChannels.g) : atan2(maskChannels.g, maskChannels.r);
				return (atan2var / TAU) + 0.5;
			}

            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.tangentDir = normalize(mul(_Object2World, float4(v.tangent.xyz, 0.0)).xyz);
                o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
                o.posWorld = mul(_Object2World, v.vertex);
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex );
                #ifdef PIXELSNAP_ON
                    o.pos = UnityPixelSnap(o.pos);
                #endif

                return o;
            }

            float4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);                
                float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex));                

				/*** common start for "opacity" and "cutoff" BEGIN ***/
				// float2(1, -1) - clockwise, float2(1, 1) - counter clock
				float2 clockCounterDirection = _FillClockwise ? float2(1, -1) : float2(1, 1); 
				// set the start on the right side				
				float2 CommonStartAndSwitcher = (-1 * (i.uv0 - 0.5)) * clockCounterDirection;
				/*** common start for "opacity" and "cutoff" END ***/
			

			    /*** cutoff section ***/
			    float tRotatorNormalized = _TextureRotator / 360.0; 				
				float cutoffRotator_ang = _CutoffRightBottomLeftTop * -TAU;
				float2x2 cutoffRotationMatrix = getMatrix(cutoffRotator_ang); 
				float2 cutoffRotator = mul(CommonStartAndSwitcher, cutoffRotationMatrix);
				float whiteToBlackMask = getMask(getNormalizedAtanMask(cutoffRotator, 0), tRotatorNormalized, 1);
				
				float finalMask = 1.0 - whiteToBlackMask;
                clip(finalMask - 0.5);


				/*** opacity section ***/
				float oRotatorNormalized = _OpacityRotator / 360.0;
				float2 oVector = float2(_OpVector);

				float oRotator_ang = _OpRightBottomLeftTop * (oRotatorNormalized * -TAU);				
				float2x2 oRotationMatrix = getMatrix(oRotator_ang); 			
				float2 oRotator = mul(oVector * CommonStartAndSwitcher, oRotationMatrix);
				float oWhiteToBlackMask = getMask(getNormalizedAtanMask(oRotator, _ReverseMaskCoords), oRotatorNormalized, 0);																	
				 
                float oFinalMultiply = _MainTex_var.a * max(getNormalizedAtanMask(oRotator, _ReverseMaskCoords), ceil(oWhiteToBlackMask)); 


				/*** Emissive ***/				
                float3 finalColor = _MainTex_var.rgb * _Color.rgb * oFinalMultiply;				
                return fixed4(finalColor, oFinalMultiply);
            }

            ENDCG
        }		
    }

    FallBack "Diffuse"    
}
