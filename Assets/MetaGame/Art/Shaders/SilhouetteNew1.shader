Shader "Custom/SilhouetteNew1"
{
    Properties
    {
        _SilhouetteColor("_SilhouetteColor", Color) = (0, 0, 0, 0)
        _FillAmount("_FillAmount", Float) = 0.61
        _YBounds("_YBounds", Vector) = (-0.5, 0.5, 0, 0)
        _Color("_Color", Color) = (1, 1, 1, 0)
        [NoScaleOffset]_MainTex("_MainTex", 2D) = "white" {}
        _BandColour("_BandColour", Color) = (0, 0.5713506, 1, 0)
        _BandWidth("_BandWidth", Float) = 0.09
        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
        SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Opaque"
            "UniversalMaterialType" = "Lit"
            "Queue" = "Geometry"
            "ShaderGraphShader" = "true"
            "ShaderGraphTargetId" = "UniversalLitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

        // Render State
        Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _LIGHT_LAYERS
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_fragment _ _LIGHT_COOKIES
        #pragma multi_compile _ _CLUSTERED_RENDERING
        // GraphKeywords: <None>

        // Defines

        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        #define _FOG_FRAGMENT 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
             float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float3 WorldSpacePosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float4 interp3 : INTERP3;
             float3 interp4 : INTERP4;
             float2 interp5 : INTERP5;
             float2 interp6 : INTERP6;
             float3 interp7 : INTERP7;
             float4 interp8 : INTERP8;
             float4 interp9 : INTERP9;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

        PackedVaryings PackVaryings(Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz = input.positionWS;
            output.interp1.xyz = input.normalWS;
            output.interp2.xyzw = input.tangentWS;
            output.interp3.xyzw = input.texCoord0;
            output.interp4.xyz = input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp5.xy = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.interp6.xy = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp7.xyz = input.sh;
            #endif
            output.interp8.xyzw = input.fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.interp9.xyzw = input.shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

        Varyings UnpackVaryings(PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.viewDirectionWS = input.interp4.xyz;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.interp5.xy;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.interp6.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp7.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp8.xyzw;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.interp9.xyzw;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }


        // --------------------------------------------------
        // Graph

        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _SilhouetteColor;
        float _FillAmount;
        float2 _YBounds;
        float4 _Color;
        float4 _MainTex_TexelSize;
        float4 _BandColour;
        float _BandWidth;
        CBUFFER_END

            // Object and Global properties
            SAMPLER(SamplerState_Linear_Repeat);
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            // Graph Includes
            // GraphIncludes: <None>

            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif

            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif

            // Graph Functions

            void Unity_InverseLerp_float(float A, float B, float T, out float Out)
            {
                Out = (T - A) / (B - A);
            }

            void Unity_Clamp_float(float In, float Min, float Max, out float Out)
            {
                Out = clamp(In, Min, Max);
            }

            void Unity_OneMinus_float(float In, out float Out)
            {
                Out = 1 - In;
            }

            void Unity_Comparison_LessOrEqual_float(float A, float B, out float Out)
            {
                Out = A <= B ? 1 : 0;
            }

            void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
            {
                Out = Predicate ? True : False;
            }

            void Unity_Subtract_float(float A, float B, out float Out)
            {
                Out = A - B;
            }

            void Unity_Comparison_GreaterOrEqual_float(float A, float B, out float Out)
            {
                Out = A >= B ? 1 : 0;
            }

            void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
            {
                Out = A * B;
            }

            void Unity_OneMinus_float4(float4 In, out float4 Out)
            {
                Out = 1 - In;
            }

            void Unity_Add_float4(float4 A, float4 B, out float4 Out)
            {
                Out = A + B;
            }

            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

            // Graph Vertex
            struct VertexDescription
            {
                float3 Position;
                float3 Normal;
                float3 Tangent;
            };

            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                description.Position = IN.ObjectSpacePosition;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }

            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif

            // Graph Pixel
            struct SurfaceDescription
            {
                float3 BaseColor;
                float3 NormalTS;
                float3 Emission;
                float Metallic;
                float Smoothness;
                float Occlusion;
            };

            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                float2 _Property_0b4e504a5c134a12bffe4e99027c07fd_Out_0 = _YBounds;
                float _Swizzle_8918e71ab58c48c385adfdce3517a5c1_Out_1 = _Property_0b4e504a5c134a12bffe4e99027c07fd_Out_0.y;
                float _Swizzle_c1acb2fe87c442a78bcdefb08d7b0cdd_Out_1 = _Property_0b4e504a5c134a12bffe4e99027c07fd_Out_0.x;
                float _Swizzle_c206262ecebe4fdba18ddd36ad5598c0_Out_1 = IN.WorldSpacePosition.y;
                float _InverseLerp_ea18fe2319fe4c66b2253b5a34d8a5fd_Out_3;
                Unity_InverseLerp_float(_Swizzle_8918e71ab58c48c385adfdce3517a5c1_Out_1, _Swizzle_c1acb2fe87c442a78bcdefb08d7b0cdd_Out_1, _Swizzle_c206262ecebe4fdba18ddd36ad5598c0_Out_1, _InverseLerp_ea18fe2319fe4c66b2253b5a34d8a5fd_Out_3);
                float _Clamp_c290813c4e624385b85d86cc7c10e4d6_Out_3;
                Unity_Clamp_float(_InverseLerp_ea18fe2319fe4c66b2253b5a34d8a5fd_Out_3, 0, 1, _Clamp_c290813c4e624385b85d86cc7c10e4d6_Out_3);
                float _OneMinus_dd9197a7d62f4634bbd451af30c476bf_Out_1;
                Unity_OneMinus_float(_Clamp_c290813c4e624385b85d86cc7c10e4d6_Out_3, _OneMinus_dd9197a7d62f4634bbd451af30c476bf_Out_1);
                float _Property_16dd2c1c35774d9c9bbdda71653a43f6_Out_0 = _FillAmount;
                float _Comparison_dcea135e70a444c5aa73a81b84a98e02_Out_2;
                Unity_Comparison_LessOrEqual_float(_OneMinus_dd9197a7d62f4634bbd451af30c476bf_Out_1, _Property_16dd2c1c35774d9c9bbdda71653a43f6_Out_0, _Comparison_dcea135e70a444c5aa73a81b84a98e02_Out_2);
                float4 _Property_94bf0d4982514359b26405a57f6e228e_Out_0 = _Color;
                float4 _Property_b930a03aaff4459dad251a909414afb2_Out_0 = _SilhouetteColor;
                float4 _Branch_fe9c129de18844e9ba1dafcf701fc1f5_Out_3;
                Unity_Branch_float4(_Comparison_dcea135e70a444c5aa73a81b84a98e02_Out_2, _Property_94bf0d4982514359b26405a57f6e228e_Out_0, _Property_b930a03aaff4459dad251a909414afb2_Out_0, _Branch_fe9c129de18844e9ba1dafcf701fc1f5_Out_3);
                float _Property_b647961b6a5e41e3b128e7d138d26bbf_Out_0 = _BandWidth;
                float _Subtract_d83f2f4283004dbb8ef2976ad239dcbb_Out_2;
                Unity_Subtract_float(_Property_16dd2c1c35774d9c9bbdda71653a43f6_Out_0, _Property_b647961b6a5e41e3b128e7d138d26bbf_Out_0, _Subtract_d83f2f4283004dbb8ef2976ad239dcbb_Out_2);
                float _Comparison_6c3528b2e67742458dcad2c1d9123206_Out_2;
                Unity_Comparison_GreaterOrEqual_float(_OneMinus_dd9197a7d62f4634bbd451af30c476bf_Out_1, _Subtract_d83f2f4283004dbb8ef2976ad239dcbb_Out_2, _Comparison_6c3528b2e67742458dcad2c1d9123206_Out_2);
                float4 _Branch_37b2d57601fd44fd9d02a5eecafa4598_Out_3;
                Unity_Branch_float4(_Comparison_6c3528b2e67742458dcad2c1d9123206_Out_2, _Property_94bf0d4982514359b26405a57f6e228e_Out_0, float4(0, 0, 0, 0), _Branch_37b2d57601fd44fd9d02a5eecafa4598_Out_3);
                float4 _Multiply_8f6eca7a3a004e1bb7bb5bc8b02dc8cb_Out_2;
                Unity_Multiply_float4_float4(_Branch_fe9c129de18844e9ba1dafcf701fc1f5_Out_3, _Branch_37b2d57601fd44fd9d02a5eecafa4598_Out_3, _Multiply_8f6eca7a3a004e1bb7bb5bc8b02dc8cb_Out_2);
                float4 _Property_665c2bda7053418092ddc78c9b230846_Out_0 = _BandColour;
                float4 _Multiply_80f3f98c40c747cfac316465edd63a2f_Out_2;
                Unity_Multiply_float4_float4(_Multiply_8f6eca7a3a004e1bb7bb5bc8b02dc8cb_Out_2, _Property_665c2bda7053418092ddc78c9b230846_Out_0, _Multiply_80f3f98c40c747cfac316465edd63a2f_Out_2);
                float4 _OneMinus_9b0bae6729ce46b1bd920238dc7a064e_Out_1;
                Unity_OneMinus_float4(_Branch_37b2d57601fd44fd9d02a5eecafa4598_Out_3, _OneMinus_9b0bae6729ce46b1bd920238dc7a064e_Out_1);
                float4 _Add_a846e3cc418140c3bf1b27f660cd7ba4_Out_2;
                Unity_Add_float4(_Multiply_80f3f98c40c747cfac316465edd63a2f_Out_2, _OneMinus_9b0bae6729ce46b1bd920238dc7a064e_Out_1, _Add_a846e3cc418140c3bf1b27f660cd7ba4_Out_2);
                UnityTexture2D _Property_0c7380d416f643088cd6f223277a1d87_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
                float4 _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_RGBA_0 = SAMPLE_TEXTURE2D(_Property_0c7380d416f643088cd6f223277a1d87_Out_0.tex, _Property_0c7380d416f643088cd6f223277a1d87_Out_0.samplerstate, _Property_0c7380d416f643088cd6f223277a1d87_Out_0.GetTransformedUV(IN.uv0.xy));
                float _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_R_4 = _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_RGBA_0.r;
                float _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_G_5 = _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_RGBA_0.g;
                float _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_B_6 = _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_RGBA_0.b;
                float _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_A_7 = _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_RGBA_0.a;
                float4 _Multiply_d2e9657dc3154f43a0fe0f8d33b46f14_Out_2;
                Unity_Multiply_float4_float4(_SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_RGBA_0, _OneMinus_9b0bae6729ce46b1bd920238dc7a064e_Out_1, _Multiply_d2e9657dc3154f43a0fe0f8d33b46f14_Out_2);
                float4 _OneMinus_d702c615cb6a4d93a374d272c8ad4b87_Out_1;
                Unity_OneMinus_float4(_OneMinus_9b0bae6729ce46b1bd920238dc7a064e_Out_1, _OneMinus_d702c615cb6a4d93a374d272c8ad4b87_Out_1);
                float4 _Add_1eaa704a333b4ebdbaf364697a0bec42_Out_2;
                Unity_Add_float4(_Multiply_d2e9657dc3154f43a0fe0f8d33b46f14_Out_2, _OneMinus_d702c615cb6a4d93a374d272c8ad4b87_Out_1, _Add_1eaa704a333b4ebdbaf364697a0bec42_Out_2);
                float4 _Multiply_0702241a7980465bb8edf3998a7bbf1b_Out_2;
                Unity_Multiply_float4_float4(_Add_a846e3cc418140c3bf1b27f660cd7ba4_Out_2, _Add_1eaa704a333b4ebdbaf364697a0bec42_Out_2, _Multiply_0702241a7980465bb8edf3998a7bbf1b_Out_2);
                surface.BaseColor = (_Multiply_0702241a7980465bb8edf3998a7bbf1b_Out_2.xyz);
                surface.NormalTS = IN.TangentSpaceNormal;
                surface.Emission = float3(0, 0, 0);
                surface.Metallic = 0;
                surface.Smoothness = 0.5;
                surface.Occlusion = 1;
                return surface;
            }

            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                output.ObjectSpaceNormal = input.normalOS;
                output.ObjectSpaceTangent = input.tangentOS.xyz;
                output.ObjectSpacePosition = input.positionOS;

                return output;
            }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

            #ifdef HAVE_VFX_MODIFICATION
                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

            #endif





                output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                output.WorldSpacePosition = input.positionWS;
                output.uv0 = input.texCoord0;
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
            #else
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            #endif
            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                    return output;
            }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif

            ENDHLSL
            }
            Pass
            {
                Name "GBuffer"
                Tags
                {
                    "LightMode" = "UniversalGBuffer"
                }

                // Render State
                Cull Back
                Blend One Zero
                ZTest LEqual
                ZWrite On

                // Debug
                // <None>

                // --------------------------------------------------
                // Pass

                HLSLPROGRAM

                // Pragmas
                #pragma target 4.5
                #pragma exclude_renderers gles gles3 glcore
                #pragma multi_compile_instancing
                #pragma multi_compile_fog
                #pragma instancing_options renderinglayer
                #pragma multi_compile _ DOTS_INSTANCING_ON
                #pragma vertex vert
                #pragma fragment frag

                // DotsInstancingOptions: <None>
                // HybridV1InjectedBuiltinProperties: <None>

                // Keywords
                #pragma multi_compile _ LIGHTMAP_ON
                #pragma multi_compile _ DYNAMICLIGHTMAP_ON
                #pragma multi_compile _ DIRLIGHTMAP_COMBINED
                #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
                #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
                #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
                #pragma multi_compile_fragment _ _SHADOWS_SOFT
                #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
                #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
                #pragma multi_compile _ SHADOWS_SHADOWMASK
                #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
                #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
                #pragma multi_compile_fragment _ _LIGHT_LAYERS
                #pragma multi_compile_fragment _ _RENDER_PASS_ENABLED
                #pragma multi_compile_fragment _ DEBUG_DISPLAY
                // GraphKeywords: <None>

                // Defines

                #define _NORMALMAP 1
                #define _NORMAL_DROPOFF_TS 1
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define ATTRIBUTES_NEED_TEXCOORD0
                #define ATTRIBUTES_NEED_TEXCOORD1
                #define ATTRIBUTES_NEED_TEXCOORD2
                #define VARYINGS_NEED_POSITION_WS
                #define VARYINGS_NEED_NORMAL_WS
                #define VARYINGS_NEED_TANGENT_WS
                #define VARYINGS_NEED_TEXCOORD0
                #define VARYINGS_NEED_VIEWDIRECTION_WS
                #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                #define VARYINGS_NEED_SHADOW_COORD
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_GBUFFER
                #define _FOG_FRAGMENT 1
                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                // custom interpolator pre-include
                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                // --------------------------------------------------
                // Structs and Packing

                // custom interpolators pre packing
                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                struct Attributes
                {
                     float3 positionOS : POSITION;
                     float3 normalOS : NORMAL;
                     float4 tangentOS : TANGENT;
                     float4 uv0 : TEXCOORD0;
                     float4 uv1 : TEXCOORD1;
                     float4 uv2 : TEXCOORD2;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
                     float3 positionWS;
                     float3 normalWS;
                     float4 tangentWS;
                     float4 texCoord0;
                     float3 viewDirectionWS;
                    #if defined(LIGHTMAP_ON)
                     float2 staticLightmapUV;
                    #endif
                    #if defined(DYNAMICLIGHTMAP_ON)
                     float2 dynamicLightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                     float3 sh;
                    #endif
                     float4 fogFactorAndVertexLight;
                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                     float4 shadowCoord;
                    #endif
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                     float3 TangentSpaceNormal;
                     float3 WorldSpacePosition;
                     float4 uv0;
                };
                struct VertexDescriptionInputs
                {
                     float3 ObjectSpaceNormal;
                     float3 ObjectSpaceTangent;
                     float3 ObjectSpacePosition;
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
                     float3 interp0 : INTERP0;
                     float3 interp1 : INTERP1;
                     float4 interp2 : INTERP2;
                     float4 interp3 : INTERP3;
                     float3 interp4 : INTERP4;
                     float2 interp5 : INTERP5;
                     float2 interp6 : INTERP6;
                     float3 interp7 : INTERP7;
                     float4 interp8 : INTERP8;
                     float4 interp9 : INTERP9;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };

                PackedVaryings PackVaryings(Varyings input)
                {
                    PackedVaryings output;
                    ZERO_INITIALIZE(PackedVaryings, output);
                    output.positionCS = input.positionCS;
                    output.interp0.xyz = input.positionWS;
                    output.interp1.xyz = input.normalWS;
                    output.interp2.xyzw = input.tangentWS;
                    output.interp3.xyzw = input.texCoord0;
                    output.interp4.xyz = input.viewDirectionWS;
                    #if defined(LIGHTMAP_ON)
                    output.interp5.xy = input.staticLightmapUV;
                    #endif
                    #if defined(DYNAMICLIGHTMAP_ON)
                    output.interp6.xy = input.dynamicLightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    output.interp7.xyz = input.sh;
                    #endif
                    output.interp8.xyzw = input.fogFactorAndVertexLight;
                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    output.interp9.xyzw = input.shadowCoord;
                    #endif
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }

                Varyings UnpackVaryings(PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.positionWS = input.interp0.xyz;
                    output.normalWS = input.interp1.xyz;
                    output.tangentWS = input.interp2.xyzw;
                    output.texCoord0 = input.interp3.xyzw;
                    output.viewDirectionWS = input.interp4.xyz;
                    #if defined(LIGHTMAP_ON)
                    output.staticLightmapUV = input.interp5.xy;
                    #endif
                    #if defined(DYNAMICLIGHTMAP_ON)
                    output.dynamicLightmapUV = input.interp6.xy;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    output.sh = input.interp7.xyz;
                    #endif
                    output.fogFactorAndVertexLight = input.interp8.xyzw;
                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    output.shadowCoord = input.interp9.xyzw;
                    #endif
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }


                // --------------------------------------------------
                // Graph

                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float4 _SilhouetteColor;
                float _FillAmount;
                float2 _YBounds;
                float4 _Color;
                float4 _MainTex_TexelSize;
                float4 _BandColour;
                float _BandWidth;
                CBUFFER_END

                    // Object and Global properties
                    SAMPLER(SamplerState_Linear_Repeat);
                    TEXTURE2D(_MainTex);
                    SAMPLER(sampler_MainTex);

                    // Graph Includes
                    // GraphIncludes: <None>

                    // -- Property used by ScenePickingPass
                    #ifdef SCENEPICKINGPASS
                    float4 _SelectionID;
                    #endif

                    // -- Properties used by SceneSelectionPass
                    #ifdef SCENESELECTIONPASS
                    int _ObjectId;
                    int _PassValue;
                    #endif

                    // Graph Functions

                    void Unity_InverseLerp_float(float A, float B, float T, out float Out)
                    {
                        Out = (T - A) / (B - A);
                    }

                    void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                    {
                        Out = clamp(In, Min, Max);
                    }

                    void Unity_OneMinus_float(float In, out float Out)
                    {
                        Out = 1 - In;
                    }

                    void Unity_Comparison_LessOrEqual_float(float A, float B, out float Out)
                    {
                        Out = A <= B ? 1 : 0;
                    }

                    void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
                    {
                        Out = Predicate ? True : False;
                    }

                    void Unity_Subtract_float(float A, float B, out float Out)
                    {
                        Out = A - B;
                    }

                    void Unity_Comparison_GreaterOrEqual_float(float A, float B, out float Out)
                    {
                        Out = A >= B ? 1 : 0;
                    }

                    void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                    {
                        Out = A * B;
                    }

                    void Unity_OneMinus_float4(float4 In, out float4 Out)
                    {
                        Out = 1 - In;
                    }

                    void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                    {
                        Out = A + B;
                    }

                    // Custom interpolators pre vertex
                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                    // Graph Vertex
                    struct VertexDescription
                    {
                        float3 Position;
                        float3 Normal;
                        float3 Tangent;
                    };

                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                    {
                        VertexDescription description = (VertexDescription)0;
                        description.Position = IN.ObjectSpacePosition;
                        description.Normal = IN.ObjectSpaceNormal;
                        description.Tangent = IN.ObjectSpaceTangent;
                        return description;
                    }

                    // Custom interpolators, pre surface
                    #ifdef FEATURES_GRAPH_VERTEX
                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                    {
                    return output;
                    }
                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                    #endif

                    // Graph Pixel
                    struct SurfaceDescription
                    {
                        float3 BaseColor;
                        float3 NormalTS;
                        float3 Emission;
                        float Metallic;
                        float Smoothness;
                        float Occlusion;
                    };

                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                    {
                        SurfaceDescription surface = (SurfaceDescription)0;
                        float2 _Property_0b4e504a5c134a12bffe4e99027c07fd_Out_0 = _YBounds;
                        float _Swizzle_8918e71ab58c48c385adfdce3517a5c1_Out_1 = _Property_0b4e504a5c134a12bffe4e99027c07fd_Out_0.y;
                        float _Swizzle_c1acb2fe87c442a78bcdefb08d7b0cdd_Out_1 = _Property_0b4e504a5c134a12bffe4e99027c07fd_Out_0.x;
                        float _Swizzle_c206262ecebe4fdba18ddd36ad5598c0_Out_1 = IN.WorldSpacePosition.y;
                        float _InverseLerp_ea18fe2319fe4c66b2253b5a34d8a5fd_Out_3;
                        Unity_InverseLerp_float(_Swizzle_8918e71ab58c48c385adfdce3517a5c1_Out_1, _Swizzle_c1acb2fe87c442a78bcdefb08d7b0cdd_Out_1, _Swizzle_c206262ecebe4fdba18ddd36ad5598c0_Out_1, _InverseLerp_ea18fe2319fe4c66b2253b5a34d8a5fd_Out_3);
                        float _Clamp_c290813c4e624385b85d86cc7c10e4d6_Out_3;
                        Unity_Clamp_float(_InverseLerp_ea18fe2319fe4c66b2253b5a34d8a5fd_Out_3, 0, 1, _Clamp_c290813c4e624385b85d86cc7c10e4d6_Out_3);
                        float _OneMinus_dd9197a7d62f4634bbd451af30c476bf_Out_1;
                        Unity_OneMinus_float(_Clamp_c290813c4e624385b85d86cc7c10e4d6_Out_3, _OneMinus_dd9197a7d62f4634bbd451af30c476bf_Out_1);
                        float _Property_16dd2c1c35774d9c9bbdda71653a43f6_Out_0 = _FillAmount;
                        float _Comparison_dcea135e70a444c5aa73a81b84a98e02_Out_2;
                        Unity_Comparison_LessOrEqual_float(_OneMinus_dd9197a7d62f4634bbd451af30c476bf_Out_1, _Property_16dd2c1c35774d9c9bbdda71653a43f6_Out_0, _Comparison_dcea135e70a444c5aa73a81b84a98e02_Out_2);
                        float4 _Property_94bf0d4982514359b26405a57f6e228e_Out_0 = _Color;
                        float4 _Property_b930a03aaff4459dad251a909414afb2_Out_0 = _SilhouetteColor;
                        float4 _Branch_fe9c129de18844e9ba1dafcf701fc1f5_Out_3;
                        Unity_Branch_float4(_Comparison_dcea135e70a444c5aa73a81b84a98e02_Out_2, _Property_94bf0d4982514359b26405a57f6e228e_Out_0, _Property_b930a03aaff4459dad251a909414afb2_Out_0, _Branch_fe9c129de18844e9ba1dafcf701fc1f5_Out_3);
                        float _Property_b647961b6a5e41e3b128e7d138d26bbf_Out_0 = _BandWidth;
                        float _Subtract_d83f2f4283004dbb8ef2976ad239dcbb_Out_2;
                        Unity_Subtract_float(_Property_16dd2c1c35774d9c9bbdda71653a43f6_Out_0, _Property_b647961b6a5e41e3b128e7d138d26bbf_Out_0, _Subtract_d83f2f4283004dbb8ef2976ad239dcbb_Out_2);
                        float _Comparison_6c3528b2e67742458dcad2c1d9123206_Out_2;
                        Unity_Comparison_GreaterOrEqual_float(_OneMinus_dd9197a7d62f4634bbd451af30c476bf_Out_1, _Subtract_d83f2f4283004dbb8ef2976ad239dcbb_Out_2, _Comparison_6c3528b2e67742458dcad2c1d9123206_Out_2);
                        float4 _Branch_37b2d57601fd44fd9d02a5eecafa4598_Out_3;
                        Unity_Branch_float4(_Comparison_6c3528b2e67742458dcad2c1d9123206_Out_2, _Property_94bf0d4982514359b26405a57f6e228e_Out_0, float4(0, 0, 0, 0), _Branch_37b2d57601fd44fd9d02a5eecafa4598_Out_3);
                        float4 _Multiply_8f6eca7a3a004e1bb7bb5bc8b02dc8cb_Out_2;
                        Unity_Multiply_float4_float4(_Branch_fe9c129de18844e9ba1dafcf701fc1f5_Out_3, _Branch_37b2d57601fd44fd9d02a5eecafa4598_Out_3, _Multiply_8f6eca7a3a004e1bb7bb5bc8b02dc8cb_Out_2);
                        float4 _Property_665c2bda7053418092ddc78c9b230846_Out_0 = _BandColour;
                        float4 _Multiply_80f3f98c40c747cfac316465edd63a2f_Out_2;
                        Unity_Multiply_float4_float4(_Multiply_8f6eca7a3a004e1bb7bb5bc8b02dc8cb_Out_2, _Property_665c2bda7053418092ddc78c9b230846_Out_0, _Multiply_80f3f98c40c747cfac316465edd63a2f_Out_2);
                        float4 _OneMinus_9b0bae6729ce46b1bd920238dc7a064e_Out_1;
                        Unity_OneMinus_float4(_Branch_37b2d57601fd44fd9d02a5eecafa4598_Out_3, _OneMinus_9b0bae6729ce46b1bd920238dc7a064e_Out_1);
                        float4 _Add_a846e3cc418140c3bf1b27f660cd7ba4_Out_2;
                        Unity_Add_float4(_Multiply_80f3f98c40c747cfac316465edd63a2f_Out_2, _OneMinus_9b0bae6729ce46b1bd920238dc7a064e_Out_1, _Add_a846e3cc418140c3bf1b27f660cd7ba4_Out_2);
                        UnityTexture2D _Property_0c7380d416f643088cd6f223277a1d87_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
                        float4 _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_RGBA_0 = SAMPLE_TEXTURE2D(_Property_0c7380d416f643088cd6f223277a1d87_Out_0.tex, _Property_0c7380d416f643088cd6f223277a1d87_Out_0.samplerstate, _Property_0c7380d416f643088cd6f223277a1d87_Out_0.GetTransformedUV(IN.uv0.xy));
                        float _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_R_4 = _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_RGBA_0.r;
                        float _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_G_5 = _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_RGBA_0.g;
                        float _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_B_6 = _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_RGBA_0.b;
                        float _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_A_7 = _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_RGBA_0.a;
                        float4 _Multiply_d2e9657dc3154f43a0fe0f8d33b46f14_Out_2;
                        Unity_Multiply_float4_float4(_SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_RGBA_0, _OneMinus_9b0bae6729ce46b1bd920238dc7a064e_Out_1, _Multiply_d2e9657dc3154f43a0fe0f8d33b46f14_Out_2);
                        float4 _OneMinus_d702c615cb6a4d93a374d272c8ad4b87_Out_1;
                        Unity_OneMinus_float4(_OneMinus_9b0bae6729ce46b1bd920238dc7a064e_Out_1, _OneMinus_d702c615cb6a4d93a374d272c8ad4b87_Out_1);
                        float4 _Add_1eaa704a333b4ebdbaf364697a0bec42_Out_2;
                        Unity_Add_float4(_Multiply_d2e9657dc3154f43a0fe0f8d33b46f14_Out_2, _OneMinus_d702c615cb6a4d93a374d272c8ad4b87_Out_1, _Add_1eaa704a333b4ebdbaf364697a0bec42_Out_2);
                        float4 _Multiply_0702241a7980465bb8edf3998a7bbf1b_Out_2;
                        Unity_Multiply_float4_float4(_Add_a846e3cc418140c3bf1b27f660cd7ba4_Out_2, _Add_1eaa704a333b4ebdbaf364697a0bec42_Out_2, _Multiply_0702241a7980465bb8edf3998a7bbf1b_Out_2);
                        surface.BaseColor = (_Multiply_0702241a7980465bb8edf3998a7bbf1b_Out_2.xyz);
                        surface.NormalTS = IN.TangentSpaceNormal;
                        surface.Emission = float3(0, 0, 0);
                        surface.Metallic = 0;
                        surface.Smoothness = 0.5;
                        surface.Occlusion = 1;
                        return surface;
                    }

                    // --------------------------------------------------
                    // Build Graph Inputs
                    #ifdef HAVE_VFX_MODIFICATION
                    #define VFX_SRP_ATTRIBUTES Attributes
                    #define VFX_SRP_VARYINGS Varyings
                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                    #endif
                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                    {
                        VertexDescriptionInputs output;
                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                        output.ObjectSpaceNormal = input.normalOS;
                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                        output.ObjectSpacePosition = input.positionOS;

                        return output;
                    }
                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                    {
                        SurfaceDescriptionInputs output;
                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                    #ifdef HAVE_VFX_MODIFICATION
                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                    #endif





                        output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                        output.WorldSpacePosition = input.positionWS;
                        output.uv0 = input.texCoord0;
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                    #else
                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                    #endif
                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                            return output;
                    }

                    // --------------------------------------------------
                    // Main

                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"

                    // --------------------------------------------------
                    // Visual Effect Vertex Invocations
                    #ifdef HAVE_VFX_MODIFICATION
                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                    #endif

                    ENDHLSL
                    }
                    Pass
                    {
                        Name "ShadowCaster"
                        Tags
                        {
                            "LightMode" = "ShadowCaster"
                        }

                        // Render State
                        Cull Back
                        ZTest LEqual
                        ZWrite On
                        ColorMask 0

                        // Debug
                        // <None>

                        // --------------------------------------------------
                        // Pass

                        HLSLPROGRAM

                        // Pragmas
                        #pragma target 4.5
                        #pragma exclude_renderers gles gles3 glcore
                        #pragma multi_compile_instancing
                        #pragma multi_compile _ DOTS_INSTANCING_ON
                        #pragma vertex vert
                        #pragma fragment frag

                        // DotsInstancingOptions: <None>
                        // HybridV1InjectedBuiltinProperties: <None>

                        // Keywords
                        #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
                        // GraphKeywords: <None>

                        // Defines

                        #define _NORMALMAP 1
                        #define _NORMAL_DROPOFF_TS 1
                        #define ATTRIBUTES_NEED_NORMAL
                        #define ATTRIBUTES_NEED_TANGENT
                        #define VARYINGS_NEED_NORMAL_WS
                        #define FEATURES_GRAPH_VERTEX
                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                        #define SHADERPASS SHADERPASS_SHADOWCASTER
                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                        // custom interpolator pre-include
                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                        // Includes
                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                        // --------------------------------------------------
                        // Structs and Packing

                        // custom interpolators pre packing
                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                        struct Attributes
                        {
                             float3 positionOS : POSITION;
                             float3 normalOS : NORMAL;
                             float4 tangentOS : TANGENT;
                            #if UNITY_ANY_INSTANCING_ENABLED
                             uint instanceID : INSTANCEID_SEMANTIC;
                            #endif
                        };
                        struct Varyings
                        {
                             float4 positionCS : SV_POSITION;
                             float3 normalWS;
                            #if UNITY_ANY_INSTANCING_ENABLED
                             uint instanceID : CUSTOM_INSTANCE_ID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                            #endif
                        };
                        struct SurfaceDescriptionInputs
                        {
                        };
                        struct VertexDescriptionInputs
                        {
                             float3 ObjectSpaceNormal;
                             float3 ObjectSpaceTangent;
                             float3 ObjectSpacePosition;
                        };
                        struct PackedVaryings
                        {
                             float4 positionCS : SV_POSITION;
                             float3 interp0 : INTERP0;
                            #if UNITY_ANY_INSTANCING_ENABLED
                             uint instanceID : CUSTOM_INSTANCE_ID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                            #endif
                        };

                        PackedVaryings PackVaryings(Varyings input)
                        {
                            PackedVaryings output;
                            ZERO_INITIALIZE(PackedVaryings, output);
                            output.positionCS = input.positionCS;
                            output.interp0.xyz = input.normalWS;
                            #if UNITY_ANY_INSTANCING_ENABLED
                            output.instanceID = input.instanceID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                            output.cullFace = input.cullFace;
                            #endif
                            return output;
                        }

                        Varyings UnpackVaryings(PackedVaryings input)
                        {
                            Varyings output;
                            output.positionCS = input.positionCS;
                            output.normalWS = input.interp0.xyz;
                            #if UNITY_ANY_INSTANCING_ENABLED
                            output.instanceID = input.instanceID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                            output.cullFace = input.cullFace;
                            #endif
                            return output;
                        }


                        // --------------------------------------------------
                        // Graph

                        // Graph Properties
                        CBUFFER_START(UnityPerMaterial)
                        float4 _SilhouetteColor;
                        float _FillAmount;
                        float2 _YBounds;
                        float4 _Color;
                        float4 _MainTex_TexelSize;
                        float4 _BandColour;
                        float _BandWidth;
                        CBUFFER_END

                            // Object and Global properties
                            SAMPLER(SamplerState_Linear_Repeat);
                            TEXTURE2D(_MainTex);
                            SAMPLER(sampler_MainTex);

                            // Graph Includes
                            // GraphIncludes: <None>

                            // -- Property used by ScenePickingPass
                            #ifdef SCENEPICKINGPASS
                            float4 _SelectionID;
                            #endif

                            // -- Properties used by SceneSelectionPass
                            #ifdef SCENESELECTIONPASS
                            int _ObjectId;
                            int _PassValue;
                            #endif

                            // Graph Functions
                            // GraphFunctions: <None>

                            // Custom interpolators pre vertex
                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                            // Graph Vertex
                            struct VertexDescription
                            {
                                float3 Position;
                                float3 Normal;
                                float3 Tangent;
                            };

                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                            {
                                VertexDescription description = (VertexDescription)0;
                                description.Position = IN.ObjectSpacePosition;
                                description.Normal = IN.ObjectSpaceNormal;
                                description.Tangent = IN.ObjectSpaceTangent;
                                return description;
                            }

                            // Custom interpolators, pre surface
                            #ifdef FEATURES_GRAPH_VERTEX
                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                            {
                            return output;
                            }
                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                            #endif

                            // Graph Pixel
                            struct SurfaceDescription
                            {
                            };

                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                            {
                                SurfaceDescription surface = (SurfaceDescription)0;
                                return surface;
                            }

                            // --------------------------------------------------
                            // Build Graph Inputs
                            #ifdef HAVE_VFX_MODIFICATION
                            #define VFX_SRP_ATTRIBUTES Attributes
                            #define VFX_SRP_VARYINGS Varyings
                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                            #endif
                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                            {
                                VertexDescriptionInputs output;
                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                output.ObjectSpaceNormal = input.normalOS;
                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                output.ObjectSpacePosition = input.positionOS;

                                return output;
                            }
                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                            {
                                SurfaceDescriptionInputs output;
                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                            #ifdef HAVE_VFX_MODIFICATION
                                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                            #endif







                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                            #else
                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                            #endif
                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                    return output;
                            }

                            // --------------------------------------------------
                            // Main

                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

                            // --------------------------------------------------
                            // Visual Effect Vertex Invocations
                            #ifdef HAVE_VFX_MODIFICATION
                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                            #endif

                            ENDHLSL
                            }
                            Pass
                            {
                                Name "DepthOnly"
                                Tags
                                {
                                    "LightMode" = "DepthOnly"
                                }

                                // Render State
                                Cull Back
                                ZTest LEqual
                                ZWrite On
                                ColorMask 0

                                // Debug
                                // <None>

                                // --------------------------------------------------
                                // Pass

                                HLSLPROGRAM

                                // Pragmas
                                #pragma target 4.5
                                #pragma exclude_renderers gles gles3 glcore
                                #pragma multi_compile_instancing
                                #pragma multi_compile _ DOTS_INSTANCING_ON
                                #pragma vertex vert
                                #pragma fragment frag

                                // DotsInstancingOptions: <None>
                                // HybridV1InjectedBuiltinProperties: <None>

                                // Keywords
                                // PassKeywords: <None>
                                // GraphKeywords: <None>

                                // Defines

                                #define _NORMALMAP 1
                                #define _NORMAL_DROPOFF_TS 1
                                #define ATTRIBUTES_NEED_NORMAL
                                #define ATTRIBUTES_NEED_TANGENT
                                #define FEATURES_GRAPH_VERTEX
                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                #define SHADERPASS SHADERPASS_DEPTHONLY
                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                // custom interpolator pre-include
                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                // Includes
                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                // --------------------------------------------------
                                // Structs and Packing

                                // custom interpolators pre packing
                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                struct Attributes
                                {
                                     float3 positionOS : POSITION;
                                     float3 normalOS : NORMAL;
                                     float4 tangentOS : TANGENT;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                     uint instanceID : INSTANCEID_SEMANTIC;
                                    #endif
                                };
                                struct Varyings
                                {
                                     float4 positionCS : SV_POSITION;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                    #endif
                                };
                                struct SurfaceDescriptionInputs
                                {
                                };
                                struct VertexDescriptionInputs
                                {
                                     float3 ObjectSpaceNormal;
                                     float3 ObjectSpaceTangent;
                                     float3 ObjectSpacePosition;
                                };
                                struct PackedVaryings
                                {
                                     float4 positionCS : SV_POSITION;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                    #endif
                                };

                                PackedVaryings PackVaryings(Varyings input)
                                {
                                    PackedVaryings output;
                                    ZERO_INITIALIZE(PackedVaryings, output);
                                    output.positionCS = input.positionCS;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                    output.instanceID = input.instanceID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                    output.cullFace = input.cullFace;
                                    #endif
                                    return output;
                                }

                                Varyings UnpackVaryings(PackedVaryings input)
                                {
                                    Varyings output;
                                    output.positionCS = input.positionCS;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                    output.instanceID = input.instanceID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                    output.cullFace = input.cullFace;
                                    #endif
                                    return output;
                                }


                                // --------------------------------------------------
                                // Graph

                                // Graph Properties
                                CBUFFER_START(UnityPerMaterial)
                                float4 _SilhouetteColor;
                                float _FillAmount;
                                float2 _YBounds;
                                float4 _Color;
                                float4 _MainTex_TexelSize;
                                float4 _BandColour;
                                float _BandWidth;
                                CBUFFER_END

                                    // Object and Global properties
                                    SAMPLER(SamplerState_Linear_Repeat);
                                    TEXTURE2D(_MainTex);
                                    SAMPLER(sampler_MainTex);

                                    // Graph Includes
                                    // GraphIncludes: <None>

                                    // -- Property used by ScenePickingPass
                                    #ifdef SCENEPICKINGPASS
                                    float4 _SelectionID;
                                    #endif

                                    // -- Properties used by SceneSelectionPass
                                    #ifdef SCENESELECTIONPASS
                                    int _ObjectId;
                                    int _PassValue;
                                    #endif

                                    // Graph Functions
                                    // GraphFunctions: <None>

                                    // Custom interpolators pre vertex
                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                    // Graph Vertex
                                    struct VertexDescription
                                    {
                                        float3 Position;
                                        float3 Normal;
                                        float3 Tangent;
                                    };

                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                    {
                                        VertexDescription description = (VertexDescription)0;
                                        description.Position = IN.ObjectSpacePosition;
                                        description.Normal = IN.ObjectSpaceNormal;
                                        description.Tangent = IN.ObjectSpaceTangent;
                                        return description;
                                    }

                                    // Custom interpolators, pre surface
                                    #ifdef FEATURES_GRAPH_VERTEX
                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                    {
                                    return output;
                                    }
                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                    #endif

                                    // Graph Pixel
                                    struct SurfaceDescription
                                    {
                                    };

                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                    {
                                        SurfaceDescription surface = (SurfaceDescription)0;
                                        return surface;
                                    }

                                    // --------------------------------------------------
                                    // Build Graph Inputs
                                    #ifdef HAVE_VFX_MODIFICATION
                                    #define VFX_SRP_ATTRIBUTES Attributes
                                    #define VFX_SRP_VARYINGS Varyings
                                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                    #endif
                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                    {
                                        VertexDescriptionInputs output;
                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                        output.ObjectSpaceNormal = input.normalOS;
                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                        output.ObjectSpacePosition = input.positionOS;

                                        return output;
                                    }
                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                    {
                                        SurfaceDescriptionInputs output;
                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                    #ifdef HAVE_VFX_MODIFICATION
                                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                    #endif







                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                    #else
                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                    #endif
                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                            return output;
                                    }

                                    // --------------------------------------------------
                                    // Main

                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

                                    // --------------------------------------------------
                                    // Visual Effect Vertex Invocations
                                    #ifdef HAVE_VFX_MODIFICATION
                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                    #endif

                                    ENDHLSL
                                    }
                                    Pass
                                    {
                                        Name "DepthNormals"
                                        Tags
                                        {
                                            "LightMode" = "DepthNormals"
                                        }

                                        // Render State
                                        Cull Back
                                        ZTest LEqual
                                        ZWrite On

                                        // Debug
                                        // <None>

                                        // --------------------------------------------------
                                        // Pass

                                        HLSLPROGRAM

                                        // Pragmas
                                        #pragma target 4.5
                                        #pragma exclude_renderers gles gles3 glcore
                                        #pragma multi_compile_instancing
                                        #pragma multi_compile _ DOTS_INSTANCING_ON
                                        #pragma vertex vert
                                        #pragma fragment frag

                                        // DotsInstancingOptions: <None>
                                        // HybridV1InjectedBuiltinProperties: <None>

                                        // Keywords
                                        // PassKeywords: <None>
                                        // GraphKeywords: <None>

                                        // Defines

                                        #define _NORMALMAP 1
                                        #define _NORMAL_DROPOFF_TS 1
                                        #define ATTRIBUTES_NEED_NORMAL
                                        #define ATTRIBUTES_NEED_TANGENT
                                        #define ATTRIBUTES_NEED_TEXCOORD1
                                        #define VARYINGS_NEED_NORMAL_WS
                                        #define VARYINGS_NEED_TANGENT_WS
                                        #define FEATURES_GRAPH_VERTEX
                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                        #define SHADERPASS SHADERPASS_DEPTHNORMALS
                                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                        // custom interpolator pre-include
                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                        // Includes
                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                        // --------------------------------------------------
                                        // Structs and Packing

                                        // custom interpolators pre packing
                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                        struct Attributes
                                        {
                                             float3 positionOS : POSITION;
                                             float3 normalOS : NORMAL;
                                             float4 tangentOS : TANGENT;
                                             float4 uv1 : TEXCOORD1;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                             uint instanceID : INSTANCEID_SEMANTIC;
                                            #endif
                                        };
                                        struct Varyings
                                        {
                                             float4 positionCS : SV_POSITION;
                                             float3 normalWS;
                                             float4 tangentWS;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                            #endif
                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                            #endif
                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                            #endif
                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                            #endif
                                        };
                                        struct SurfaceDescriptionInputs
                                        {
                                             float3 TangentSpaceNormal;
                                        };
                                        struct VertexDescriptionInputs
                                        {
                                             float3 ObjectSpaceNormal;
                                             float3 ObjectSpaceTangent;
                                             float3 ObjectSpacePosition;
                                        };
                                        struct PackedVaryings
                                        {
                                             float4 positionCS : SV_POSITION;
                                             float3 interp0 : INTERP0;
                                             float4 interp1 : INTERP1;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                            #endif
                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                            #endif
                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                            #endif
                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                            #endif
                                        };

                                        PackedVaryings PackVaryings(Varyings input)
                                        {
                                            PackedVaryings output;
                                            ZERO_INITIALIZE(PackedVaryings, output);
                                            output.positionCS = input.positionCS;
                                            output.interp0.xyz = input.normalWS;
                                            output.interp1.xyzw = input.tangentWS;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                            output.instanceID = input.instanceID;
                                            #endif
                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                            #endif
                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                            #endif
                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                            output.cullFace = input.cullFace;
                                            #endif
                                            return output;
                                        }

                                        Varyings UnpackVaryings(PackedVaryings input)
                                        {
                                            Varyings output;
                                            output.positionCS = input.positionCS;
                                            output.normalWS = input.interp0.xyz;
                                            output.tangentWS = input.interp1.xyzw;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                            output.instanceID = input.instanceID;
                                            #endif
                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                            #endif
                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                            #endif
                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                            output.cullFace = input.cullFace;
                                            #endif
                                            return output;
                                        }


                                        // --------------------------------------------------
                                        // Graph

                                        // Graph Properties
                                        CBUFFER_START(UnityPerMaterial)
                                        float4 _SilhouetteColor;
                                        float _FillAmount;
                                        float2 _YBounds;
                                        float4 _Color;
                                        float4 _MainTex_TexelSize;
                                        float4 _BandColour;
                                        float _BandWidth;
                                        CBUFFER_END

                                            // Object and Global properties
                                            SAMPLER(SamplerState_Linear_Repeat);
                                            TEXTURE2D(_MainTex);
                                            SAMPLER(sampler_MainTex);

                                            // Graph Includes
                                            // GraphIncludes: <None>

                                            // -- Property used by ScenePickingPass
                                            #ifdef SCENEPICKINGPASS
                                            float4 _SelectionID;
                                            #endif

                                            // -- Properties used by SceneSelectionPass
                                            #ifdef SCENESELECTIONPASS
                                            int _ObjectId;
                                            int _PassValue;
                                            #endif

                                            // Graph Functions
                                            // GraphFunctions: <None>

                                            // Custom interpolators pre vertex
                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                            // Graph Vertex
                                            struct VertexDescription
                                            {
                                                float3 Position;
                                                float3 Normal;
                                                float3 Tangent;
                                            };

                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                            {
                                                VertexDescription description = (VertexDescription)0;
                                                description.Position = IN.ObjectSpacePosition;
                                                description.Normal = IN.ObjectSpaceNormal;
                                                description.Tangent = IN.ObjectSpaceTangent;
                                                return description;
                                            }

                                            // Custom interpolators, pre surface
                                            #ifdef FEATURES_GRAPH_VERTEX
                                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                            {
                                            return output;
                                            }
                                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                            #endif

                                            // Graph Pixel
                                            struct SurfaceDescription
                                            {
                                                float3 NormalTS;
                                            };

                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                            {
                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                surface.NormalTS = IN.TangentSpaceNormal;
                                                return surface;
                                            }

                                            // --------------------------------------------------
                                            // Build Graph Inputs
                                            #ifdef HAVE_VFX_MODIFICATION
                                            #define VFX_SRP_ATTRIBUTES Attributes
                                            #define VFX_SRP_VARYINGS Varyings
                                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                            #endif
                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                            {
                                                VertexDescriptionInputs output;
                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                output.ObjectSpaceNormal = input.normalOS;
                                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                output.ObjectSpacePosition = input.positionOS;

                                                return output;
                                            }
                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                            {
                                                SurfaceDescriptionInputs output;
                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                            #ifdef HAVE_VFX_MODIFICATION
                                                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                            #endif





                                                output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                            #else
                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                            #endif
                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                    return output;
                                            }

                                            // --------------------------------------------------
                                            // Main

                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

                                            // --------------------------------------------------
                                            // Visual Effect Vertex Invocations
                                            #ifdef HAVE_VFX_MODIFICATION
                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                            #endif

                                            ENDHLSL
                                            }
                                            Pass
                                            {
                                                Name "Meta"
                                                Tags
                                                {
                                                    "LightMode" = "Meta"
                                                }

                                                // Render State
                                                Cull Off

                                                // Debug
                                                // <None>

                                                // --------------------------------------------------
                                                // Pass

                                                HLSLPROGRAM

                                                // Pragmas
                                                #pragma target 4.5
                                                #pragma exclude_renderers gles gles3 glcore
                                                #pragma vertex vert
                                                #pragma fragment frag

                                                // DotsInstancingOptions: <None>
                                                // HybridV1InjectedBuiltinProperties: <None>

                                                // Keywords
                                                #pragma shader_feature _ EDITOR_VISUALIZATION
                                                // GraphKeywords: <None>

                                                // Defines

                                                #define _NORMALMAP 1
                                                #define _NORMAL_DROPOFF_TS 1
                                                #define ATTRIBUTES_NEED_NORMAL
                                                #define ATTRIBUTES_NEED_TANGENT
                                                #define ATTRIBUTES_NEED_TEXCOORD0
                                                #define ATTRIBUTES_NEED_TEXCOORD1
                                                #define ATTRIBUTES_NEED_TEXCOORD2
                                                #define VARYINGS_NEED_POSITION_WS
                                                #define VARYINGS_NEED_TEXCOORD0
                                                #define VARYINGS_NEED_TEXCOORD1
                                                #define VARYINGS_NEED_TEXCOORD2
                                                #define FEATURES_GRAPH_VERTEX
                                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                #define SHADERPASS SHADERPASS_META
                                                #define _FOG_FRAGMENT 1
                                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                // custom interpolator pre-include
                                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                // Includes
                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                // --------------------------------------------------
                                                // Structs and Packing

                                                // custom interpolators pre packing
                                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                struct Attributes
                                                {
                                                     float3 positionOS : POSITION;
                                                     float3 normalOS : NORMAL;
                                                     float4 tangentOS : TANGENT;
                                                     float4 uv0 : TEXCOORD0;
                                                     float4 uv1 : TEXCOORD1;
                                                     float4 uv2 : TEXCOORD2;
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                     uint instanceID : INSTANCEID_SEMANTIC;
                                                    #endif
                                                };
                                                struct Varyings
                                                {
                                                     float4 positionCS : SV_POSITION;
                                                     float3 positionWS;
                                                     float4 texCoord0;
                                                     float4 texCoord1;
                                                     float4 texCoord2;
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                    #endif
                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                    #endif
                                                };
                                                struct SurfaceDescriptionInputs
                                                {
                                                     float3 WorldSpacePosition;
                                                     float4 uv0;
                                                };
                                                struct VertexDescriptionInputs
                                                {
                                                     float3 ObjectSpaceNormal;
                                                     float3 ObjectSpaceTangent;
                                                     float3 ObjectSpacePosition;
                                                };
                                                struct PackedVaryings
                                                {
                                                     float4 positionCS : SV_POSITION;
                                                     float3 interp0 : INTERP0;
                                                     float4 interp1 : INTERP1;
                                                     float4 interp2 : INTERP2;
                                                     float4 interp3 : INTERP3;
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                    #endif
                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                    #endif
                                                };

                                                PackedVaryings PackVaryings(Varyings input)
                                                {
                                                    PackedVaryings output;
                                                    ZERO_INITIALIZE(PackedVaryings, output);
                                                    output.positionCS = input.positionCS;
                                                    output.interp0.xyz = input.positionWS;
                                                    output.interp1.xyzw = input.texCoord0;
                                                    output.interp2.xyzw = input.texCoord1;
                                                    output.interp3.xyzw = input.texCoord2;
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                    output.instanceID = input.instanceID;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                    #endif
                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                    output.cullFace = input.cullFace;
                                                    #endif
                                                    return output;
                                                }

                                                Varyings UnpackVaryings(PackedVaryings input)
                                                {
                                                    Varyings output;
                                                    output.positionCS = input.positionCS;
                                                    output.positionWS = input.interp0.xyz;
                                                    output.texCoord0 = input.interp1.xyzw;
                                                    output.texCoord1 = input.interp2.xyzw;
                                                    output.texCoord2 = input.interp3.xyzw;
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                    output.instanceID = input.instanceID;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                    #endif
                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                    output.cullFace = input.cullFace;
                                                    #endif
                                                    return output;
                                                }


                                                // --------------------------------------------------
                                                // Graph

                                                // Graph Properties
                                                CBUFFER_START(UnityPerMaterial)
                                                float4 _SilhouetteColor;
                                                float _FillAmount;
                                                float2 _YBounds;
                                                float4 _Color;
                                                float4 _MainTex_TexelSize;
                                                float4 _BandColour;
                                                float _BandWidth;
                                                CBUFFER_END

                                                    // Object and Global properties
                                                    SAMPLER(SamplerState_Linear_Repeat);
                                                    TEXTURE2D(_MainTex);
                                                    SAMPLER(sampler_MainTex);

                                                    // Graph Includes
                                                    // GraphIncludes: <None>

                                                    // -- Property used by ScenePickingPass
                                                    #ifdef SCENEPICKINGPASS
                                                    float4 _SelectionID;
                                                    #endif

                                                    // -- Properties used by SceneSelectionPass
                                                    #ifdef SCENESELECTIONPASS
                                                    int _ObjectId;
                                                    int _PassValue;
                                                    #endif

                                                    // Graph Functions

                                                    void Unity_InverseLerp_float(float A, float B, float T, out float Out)
                                                    {
                                                        Out = (T - A) / (B - A);
                                                    }

                                                    void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                                                    {
                                                        Out = clamp(In, Min, Max);
                                                    }

                                                    void Unity_OneMinus_float(float In, out float Out)
                                                    {
                                                        Out = 1 - In;
                                                    }

                                                    void Unity_Comparison_LessOrEqual_float(float A, float B, out float Out)
                                                    {
                                                        Out = A <= B ? 1 : 0;
                                                    }

                                                    void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
                                                    {
                                                        Out = Predicate ? True : False;
                                                    }

                                                    void Unity_Subtract_float(float A, float B, out float Out)
                                                    {
                                                        Out = A - B;
                                                    }

                                                    void Unity_Comparison_GreaterOrEqual_float(float A, float B, out float Out)
                                                    {
                                                        Out = A >= B ? 1 : 0;
                                                    }

                                                    void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                                                    {
                                                        Out = A * B;
                                                    }

                                                    void Unity_OneMinus_float4(float4 In, out float4 Out)
                                                    {
                                                        Out = 1 - In;
                                                    }

                                                    void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                                                    {
                                                        Out = A + B;
                                                    }

                                                    // Custom interpolators pre vertex
                                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                    // Graph Vertex
                                                    struct VertexDescription
                                                    {
                                                        float3 Position;
                                                        float3 Normal;
                                                        float3 Tangent;
                                                    };

                                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                    {
                                                        VertexDescription description = (VertexDescription)0;
                                                        description.Position = IN.ObjectSpacePosition;
                                                        description.Normal = IN.ObjectSpaceNormal;
                                                        description.Tangent = IN.ObjectSpaceTangent;
                                                        return description;
                                                    }

                                                    // Custom interpolators, pre surface
                                                    #ifdef FEATURES_GRAPH_VERTEX
                                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                    {
                                                    return output;
                                                    }
                                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                    #endif

                                                    // Graph Pixel
                                                    struct SurfaceDescription
                                                    {
                                                        float3 BaseColor;
                                                        float3 Emission;
                                                    };

                                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                    {
                                                        SurfaceDescription surface = (SurfaceDescription)0;
                                                        float2 _Property_0b4e504a5c134a12bffe4e99027c07fd_Out_0 = _YBounds;
                                                        float _Swizzle_8918e71ab58c48c385adfdce3517a5c1_Out_1 = _Property_0b4e504a5c134a12bffe4e99027c07fd_Out_0.y;
                                                        float _Swizzle_c1acb2fe87c442a78bcdefb08d7b0cdd_Out_1 = _Property_0b4e504a5c134a12bffe4e99027c07fd_Out_0.x;
                                                        float _Swizzle_c206262ecebe4fdba18ddd36ad5598c0_Out_1 = IN.WorldSpacePosition.y;
                                                        float _InverseLerp_ea18fe2319fe4c66b2253b5a34d8a5fd_Out_3;
                                                        Unity_InverseLerp_float(_Swizzle_8918e71ab58c48c385adfdce3517a5c1_Out_1, _Swizzle_c1acb2fe87c442a78bcdefb08d7b0cdd_Out_1, _Swizzle_c206262ecebe4fdba18ddd36ad5598c0_Out_1, _InverseLerp_ea18fe2319fe4c66b2253b5a34d8a5fd_Out_3);
                                                        float _Clamp_c290813c4e624385b85d86cc7c10e4d6_Out_3;
                                                        Unity_Clamp_float(_InverseLerp_ea18fe2319fe4c66b2253b5a34d8a5fd_Out_3, 0, 1, _Clamp_c290813c4e624385b85d86cc7c10e4d6_Out_3);
                                                        float _OneMinus_dd9197a7d62f4634bbd451af30c476bf_Out_1;
                                                        Unity_OneMinus_float(_Clamp_c290813c4e624385b85d86cc7c10e4d6_Out_3, _OneMinus_dd9197a7d62f4634bbd451af30c476bf_Out_1);
                                                        float _Property_16dd2c1c35774d9c9bbdda71653a43f6_Out_0 = _FillAmount;
                                                        float _Comparison_dcea135e70a444c5aa73a81b84a98e02_Out_2;
                                                        Unity_Comparison_LessOrEqual_float(_OneMinus_dd9197a7d62f4634bbd451af30c476bf_Out_1, _Property_16dd2c1c35774d9c9bbdda71653a43f6_Out_0, _Comparison_dcea135e70a444c5aa73a81b84a98e02_Out_2);
                                                        float4 _Property_94bf0d4982514359b26405a57f6e228e_Out_0 = _Color;
                                                        float4 _Property_b930a03aaff4459dad251a909414afb2_Out_0 = _SilhouetteColor;
                                                        float4 _Branch_fe9c129de18844e9ba1dafcf701fc1f5_Out_3;
                                                        Unity_Branch_float4(_Comparison_dcea135e70a444c5aa73a81b84a98e02_Out_2, _Property_94bf0d4982514359b26405a57f6e228e_Out_0, _Property_b930a03aaff4459dad251a909414afb2_Out_0, _Branch_fe9c129de18844e9ba1dafcf701fc1f5_Out_3);
                                                        float _Property_b647961b6a5e41e3b128e7d138d26bbf_Out_0 = _BandWidth;
                                                        float _Subtract_d83f2f4283004dbb8ef2976ad239dcbb_Out_2;
                                                        Unity_Subtract_float(_Property_16dd2c1c35774d9c9bbdda71653a43f6_Out_0, _Property_b647961b6a5e41e3b128e7d138d26bbf_Out_0, _Subtract_d83f2f4283004dbb8ef2976ad239dcbb_Out_2);
                                                        float _Comparison_6c3528b2e67742458dcad2c1d9123206_Out_2;
                                                        Unity_Comparison_GreaterOrEqual_float(_OneMinus_dd9197a7d62f4634bbd451af30c476bf_Out_1, _Subtract_d83f2f4283004dbb8ef2976ad239dcbb_Out_2, _Comparison_6c3528b2e67742458dcad2c1d9123206_Out_2);
                                                        float4 _Branch_37b2d57601fd44fd9d02a5eecafa4598_Out_3;
                                                        Unity_Branch_float4(_Comparison_6c3528b2e67742458dcad2c1d9123206_Out_2, _Property_94bf0d4982514359b26405a57f6e228e_Out_0, float4(0, 0, 0, 0), _Branch_37b2d57601fd44fd9d02a5eecafa4598_Out_3);
                                                        float4 _Multiply_8f6eca7a3a004e1bb7bb5bc8b02dc8cb_Out_2;
                                                        Unity_Multiply_float4_float4(_Branch_fe9c129de18844e9ba1dafcf701fc1f5_Out_3, _Branch_37b2d57601fd44fd9d02a5eecafa4598_Out_3, _Multiply_8f6eca7a3a004e1bb7bb5bc8b02dc8cb_Out_2);
                                                        float4 _Property_665c2bda7053418092ddc78c9b230846_Out_0 = _BandColour;
                                                        float4 _Multiply_80f3f98c40c747cfac316465edd63a2f_Out_2;
                                                        Unity_Multiply_float4_float4(_Multiply_8f6eca7a3a004e1bb7bb5bc8b02dc8cb_Out_2, _Property_665c2bda7053418092ddc78c9b230846_Out_0, _Multiply_80f3f98c40c747cfac316465edd63a2f_Out_2);
                                                        float4 _OneMinus_9b0bae6729ce46b1bd920238dc7a064e_Out_1;
                                                        Unity_OneMinus_float4(_Branch_37b2d57601fd44fd9d02a5eecafa4598_Out_3, _OneMinus_9b0bae6729ce46b1bd920238dc7a064e_Out_1);
                                                        float4 _Add_a846e3cc418140c3bf1b27f660cd7ba4_Out_2;
                                                        Unity_Add_float4(_Multiply_80f3f98c40c747cfac316465edd63a2f_Out_2, _OneMinus_9b0bae6729ce46b1bd920238dc7a064e_Out_1, _Add_a846e3cc418140c3bf1b27f660cd7ba4_Out_2);
                                                        UnityTexture2D _Property_0c7380d416f643088cd6f223277a1d87_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
                                                        float4 _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_RGBA_0 = SAMPLE_TEXTURE2D(_Property_0c7380d416f643088cd6f223277a1d87_Out_0.tex, _Property_0c7380d416f643088cd6f223277a1d87_Out_0.samplerstate, _Property_0c7380d416f643088cd6f223277a1d87_Out_0.GetTransformedUV(IN.uv0.xy));
                                                        float _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_R_4 = _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_RGBA_0.r;
                                                        float _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_G_5 = _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_RGBA_0.g;
                                                        float _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_B_6 = _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_RGBA_0.b;
                                                        float _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_A_7 = _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_RGBA_0.a;
                                                        float4 _Multiply_d2e9657dc3154f43a0fe0f8d33b46f14_Out_2;
                                                        Unity_Multiply_float4_float4(_SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_RGBA_0, _OneMinus_9b0bae6729ce46b1bd920238dc7a064e_Out_1, _Multiply_d2e9657dc3154f43a0fe0f8d33b46f14_Out_2);
                                                        float4 _OneMinus_d702c615cb6a4d93a374d272c8ad4b87_Out_1;
                                                        Unity_OneMinus_float4(_OneMinus_9b0bae6729ce46b1bd920238dc7a064e_Out_1, _OneMinus_d702c615cb6a4d93a374d272c8ad4b87_Out_1);
                                                        float4 _Add_1eaa704a333b4ebdbaf364697a0bec42_Out_2;
                                                        Unity_Add_float4(_Multiply_d2e9657dc3154f43a0fe0f8d33b46f14_Out_2, _OneMinus_d702c615cb6a4d93a374d272c8ad4b87_Out_1, _Add_1eaa704a333b4ebdbaf364697a0bec42_Out_2);
                                                        float4 _Multiply_0702241a7980465bb8edf3998a7bbf1b_Out_2;
                                                        Unity_Multiply_float4_float4(_Add_a846e3cc418140c3bf1b27f660cd7ba4_Out_2, _Add_1eaa704a333b4ebdbaf364697a0bec42_Out_2, _Multiply_0702241a7980465bb8edf3998a7bbf1b_Out_2);
                                                        surface.BaseColor = (_Multiply_0702241a7980465bb8edf3998a7bbf1b_Out_2.xyz);
                                                        surface.Emission = float3(0, 0, 0);
                                                        return surface;
                                                    }

                                                    // --------------------------------------------------
                                                    // Build Graph Inputs
                                                    #ifdef HAVE_VFX_MODIFICATION
                                                    #define VFX_SRP_ATTRIBUTES Attributes
                                                    #define VFX_SRP_VARYINGS Varyings
                                                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                    #endif
                                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                    {
                                                        VertexDescriptionInputs output;
                                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                        output.ObjectSpaceNormal = input.normalOS;
                                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                        output.ObjectSpacePosition = input.positionOS;

                                                        return output;
                                                    }
                                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                    {
                                                        SurfaceDescriptionInputs output;
                                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                    #ifdef HAVE_VFX_MODIFICATION
                                                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                    #endif







                                                        output.WorldSpacePosition = input.positionWS;
                                                        output.uv0 = input.texCoord0;
                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                    #else
                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                    #endif
                                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                            return output;
                                                    }

                                                    // --------------------------------------------------
                                                    // Main

                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

                                                    // --------------------------------------------------
                                                    // Visual Effect Vertex Invocations
                                                    #ifdef HAVE_VFX_MODIFICATION
                                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                    #endif

                                                    ENDHLSL
                                                    }
                                                    Pass
                                                    {
                                                        Name "SceneSelectionPass"
                                                        Tags
                                                        {
                                                            "LightMode" = "SceneSelectionPass"
                                                        }

                                                        // Render State
                                                        Cull Off

                                                        // Debug
                                                        // <None>

                                                        // --------------------------------------------------
                                                        // Pass

                                                        HLSLPROGRAM

                                                        // Pragmas
                                                        #pragma target 4.5
                                                        #pragma exclude_renderers gles gles3 glcore
                                                        #pragma vertex vert
                                                        #pragma fragment frag

                                                        // DotsInstancingOptions: <None>
                                                        // HybridV1InjectedBuiltinProperties: <None>

                                                        // Keywords
                                                        // PassKeywords: <None>
                                                        // GraphKeywords: <None>

                                                        // Defines

                                                        #define _NORMALMAP 1
                                                        #define _NORMAL_DROPOFF_TS 1
                                                        #define ATTRIBUTES_NEED_NORMAL
                                                        #define ATTRIBUTES_NEED_TANGENT
                                                        #define FEATURES_GRAPH_VERTEX
                                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                        #define SHADERPASS SHADERPASS_DEPTHONLY
                                                        #define SCENESELECTIONPASS 1
                                                        #define ALPHA_CLIP_THRESHOLD 1
                                                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                        // custom interpolator pre-include
                                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                        // Includes
                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                        // --------------------------------------------------
                                                        // Structs and Packing

                                                        // custom interpolators pre packing
                                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                        struct Attributes
                                                        {
                                                             float3 positionOS : POSITION;
                                                             float3 normalOS : NORMAL;
                                                             float4 tangentOS : TANGENT;
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                             uint instanceID : INSTANCEID_SEMANTIC;
                                                            #endif
                                                        };
                                                        struct Varyings
                                                        {
                                                             float4 positionCS : SV_POSITION;
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                            #endif
                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                            #endif
                                                        };
                                                        struct SurfaceDescriptionInputs
                                                        {
                                                        };
                                                        struct VertexDescriptionInputs
                                                        {
                                                             float3 ObjectSpaceNormal;
                                                             float3 ObjectSpaceTangent;
                                                             float3 ObjectSpacePosition;
                                                        };
                                                        struct PackedVaryings
                                                        {
                                                             float4 positionCS : SV_POSITION;
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                            #endif
                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                            #endif
                                                        };

                                                        PackedVaryings PackVaryings(Varyings input)
                                                        {
                                                            PackedVaryings output;
                                                            ZERO_INITIALIZE(PackedVaryings, output);
                                                            output.positionCS = input.positionCS;
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                            output.instanceID = input.instanceID;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                            #endif
                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                            output.cullFace = input.cullFace;
                                                            #endif
                                                            return output;
                                                        }

                                                        Varyings UnpackVaryings(PackedVaryings input)
                                                        {
                                                            Varyings output;
                                                            output.positionCS = input.positionCS;
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                            output.instanceID = input.instanceID;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                            #endif
                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                            output.cullFace = input.cullFace;
                                                            #endif
                                                            return output;
                                                        }


                                                        // --------------------------------------------------
                                                        // Graph

                                                        // Graph Properties
                                                        CBUFFER_START(UnityPerMaterial)
                                                        float4 _SilhouetteColor;
                                                        float _FillAmount;
                                                        float2 _YBounds;
                                                        float4 _Color;
                                                        float4 _MainTex_TexelSize;
                                                        float4 _BandColour;
                                                        float _BandWidth;
                                                        CBUFFER_END

                                                            // Object and Global properties
                                                            SAMPLER(SamplerState_Linear_Repeat);
                                                            TEXTURE2D(_MainTex);
                                                            SAMPLER(sampler_MainTex);

                                                            // Graph Includes
                                                            // GraphIncludes: <None>

                                                            // -- Property used by ScenePickingPass
                                                            #ifdef SCENEPICKINGPASS
                                                            float4 _SelectionID;
                                                            #endif

                                                            // -- Properties used by SceneSelectionPass
                                                            #ifdef SCENESELECTIONPASS
                                                            int _ObjectId;
                                                            int _PassValue;
                                                            #endif

                                                            // Graph Functions
                                                            // GraphFunctions: <None>

                                                            // Custom interpolators pre vertex
                                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                            // Graph Vertex
                                                            struct VertexDescription
                                                            {
                                                                float3 Position;
                                                                float3 Normal;
                                                                float3 Tangent;
                                                            };

                                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                            {
                                                                VertexDescription description = (VertexDescription)0;
                                                                description.Position = IN.ObjectSpacePosition;
                                                                description.Normal = IN.ObjectSpaceNormal;
                                                                description.Tangent = IN.ObjectSpaceTangent;
                                                                return description;
                                                            }

                                                            // Custom interpolators, pre surface
                                                            #ifdef FEATURES_GRAPH_VERTEX
                                                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                            {
                                                            return output;
                                                            }
                                                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                            #endif

                                                            // Graph Pixel
                                                            struct SurfaceDescription
                                                            {
                                                            };

                                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                            {
                                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                                return surface;
                                                            }

                                                            // --------------------------------------------------
                                                            // Build Graph Inputs
                                                            #ifdef HAVE_VFX_MODIFICATION
                                                            #define VFX_SRP_ATTRIBUTES Attributes
                                                            #define VFX_SRP_VARYINGS Varyings
                                                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                            #endif
                                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                            {
                                                                VertexDescriptionInputs output;
                                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                output.ObjectSpaceNormal = input.normalOS;
                                                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                output.ObjectSpacePosition = input.positionOS;

                                                                return output;
                                                            }
                                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                            {
                                                                SurfaceDescriptionInputs output;
                                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                            #endif







                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                            #else
                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                            #endif
                                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                    return output;
                                                            }

                                                            // --------------------------------------------------
                                                            // Main

                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

                                                            // --------------------------------------------------
                                                            // Visual Effect Vertex Invocations
                                                            #ifdef HAVE_VFX_MODIFICATION
                                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                            #endif

                                                            ENDHLSL
                                                            }
                                                            Pass
                                                            {
                                                                Name "ScenePickingPass"
                                                                Tags
                                                                {
                                                                    "LightMode" = "Picking"
                                                                }

                                                                // Render State
                                                                Cull Back

                                                                // Debug
                                                                // <None>

                                                                // --------------------------------------------------
                                                                // Pass

                                                                HLSLPROGRAM

                                                                // Pragmas
                                                                #pragma target 4.5
                                                                #pragma exclude_renderers gles gles3 glcore
                                                                #pragma vertex vert
                                                                #pragma fragment frag

                                                                // DotsInstancingOptions: <None>
                                                                // HybridV1InjectedBuiltinProperties: <None>

                                                                // Keywords
                                                                // PassKeywords: <None>
                                                                // GraphKeywords: <None>

                                                                // Defines

                                                                #define _NORMALMAP 1
                                                                #define _NORMAL_DROPOFF_TS 1
                                                                #define ATTRIBUTES_NEED_NORMAL
                                                                #define ATTRIBUTES_NEED_TANGENT
                                                                #define FEATURES_GRAPH_VERTEX
                                                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                #define SHADERPASS SHADERPASS_DEPTHONLY
                                                                #define SCENEPICKINGPASS 1
                                                                #define ALPHA_CLIP_THRESHOLD 1
                                                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                // custom interpolator pre-include
                                                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                // Includes
                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                // --------------------------------------------------
                                                                // Structs and Packing

                                                                // custom interpolators pre packing
                                                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                struct Attributes
                                                                {
                                                                     float3 positionOS : POSITION;
                                                                     float3 normalOS : NORMAL;
                                                                     float4 tangentOS : TANGENT;
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                     uint instanceID : INSTANCEID_SEMANTIC;
                                                                    #endif
                                                                };
                                                                struct Varyings
                                                                {
                                                                     float4 positionCS : SV_POSITION;
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                    #endif
                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                    #endif
                                                                };
                                                                struct SurfaceDescriptionInputs
                                                                {
                                                                };
                                                                struct VertexDescriptionInputs
                                                                {
                                                                     float3 ObjectSpaceNormal;
                                                                     float3 ObjectSpaceTangent;
                                                                     float3 ObjectSpacePosition;
                                                                };
                                                                struct PackedVaryings
                                                                {
                                                                     float4 positionCS : SV_POSITION;
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                    #endif
                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                    #endif
                                                                };

                                                                PackedVaryings PackVaryings(Varyings input)
                                                                {
                                                                    PackedVaryings output;
                                                                    ZERO_INITIALIZE(PackedVaryings, output);
                                                                    output.positionCS = input.positionCS;
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                    output.instanceID = input.instanceID;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                    #endif
                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                    output.cullFace = input.cullFace;
                                                                    #endif
                                                                    return output;
                                                                }

                                                                Varyings UnpackVaryings(PackedVaryings input)
                                                                {
                                                                    Varyings output;
                                                                    output.positionCS = input.positionCS;
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                    output.instanceID = input.instanceID;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                    #endif
                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                    output.cullFace = input.cullFace;
                                                                    #endif
                                                                    return output;
                                                                }


                                                                // --------------------------------------------------
                                                                // Graph

                                                                // Graph Properties
                                                                CBUFFER_START(UnityPerMaterial)
                                                                float4 _SilhouetteColor;
                                                                float _FillAmount;
                                                                float2 _YBounds;
                                                                float4 _Color;
                                                                float4 _MainTex_TexelSize;
                                                                float4 _BandColour;
                                                                float _BandWidth;
                                                                CBUFFER_END

                                                                    // Object and Global properties
                                                                    SAMPLER(SamplerState_Linear_Repeat);
                                                                    TEXTURE2D(_MainTex);
                                                                    SAMPLER(sampler_MainTex);

                                                                    // Graph Includes
                                                                    // GraphIncludes: <None>

                                                                    // -- Property used by ScenePickingPass
                                                                    #ifdef SCENEPICKINGPASS
                                                                    float4 _SelectionID;
                                                                    #endif

                                                                    // -- Properties used by SceneSelectionPass
                                                                    #ifdef SCENESELECTIONPASS
                                                                    int _ObjectId;
                                                                    int _PassValue;
                                                                    #endif

                                                                    // Graph Functions
                                                                    // GraphFunctions: <None>

                                                                    // Custom interpolators pre vertex
                                                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                    // Graph Vertex
                                                                    struct VertexDescription
                                                                    {
                                                                        float3 Position;
                                                                        float3 Normal;
                                                                        float3 Tangent;
                                                                    };

                                                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                    {
                                                                        VertexDescription description = (VertexDescription)0;
                                                                        description.Position = IN.ObjectSpacePosition;
                                                                        description.Normal = IN.ObjectSpaceNormal;
                                                                        description.Tangent = IN.ObjectSpaceTangent;
                                                                        return description;
                                                                    }

                                                                    // Custom interpolators, pre surface
                                                                    #ifdef FEATURES_GRAPH_VERTEX
                                                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                    {
                                                                    return output;
                                                                    }
                                                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                    #endif

                                                                    // Graph Pixel
                                                                    struct SurfaceDescription
                                                                    {
                                                                    };

                                                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                    {
                                                                        SurfaceDescription surface = (SurfaceDescription)0;
                                                                        return surface;
                                                                    }

                                                                    // --------------------------------------------------
                                                                    // Build Graph Inputs
                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                    #define VFX_SRP_ATTRIBUTES Attributes
                                                                    #define VFX_SRP_VARYINGS Varyings
                                                                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                    #endif
                                                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                    {
                                                                        VertexDescriptionInputs output;
                                                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                        output.ObjectSpaceNormal = input.normalOS;
                                                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                        output.ObjectSpacePosition = input.positionOS;

                                                                        return output;
                                                                    }
                                                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                    {
                                                                        SurfaceDescriptionInputs output;
                                                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                    #endif







                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                    #else
                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                    #endif
                                                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                            return output;
                                                                    }

                                                                    // --------------------------------------------------
                                                                    // Main

                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

                                                                    // --------------------------------------------------
                                                                    // Visual Effect Vertex Invocations
                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                    #endif

                                                                    ENDHLSL
                                                                    }
                                                                    Pass
                                                                    {
                                                                        // Name: <None>
                                                                        Tags
                                                                        {
                                                                            "LightMode" = "Universal2D"
                                                                        }

                                                                        // Render State
                                                                        Cull Back
                                                                        Blend One Zero
                                                                        ZTest LEqual
                                                                        ZWrite On

                                                                        // Debug
                                                                        // <None>

                                                                        // --------------------------------------------------
                                                                        // Pass

                                                                        HLSLPROGRAM

                                                                        // Pragmas
                                                                        #pragma target 4.5
                                                                        #pragma exclude_renderers gles gles3 glcore
                                                                        #pragma vertex vert
                                                                        #pragma fragment frag

                                                                        // DotsInstancingOptions: <None>
                                                                        // HybridV1InjectedBuiltinProperties: <None>

                                                                        // Keywords
                                                                        // PassKeywords: <None>
                                                                        // GraphKeywords: <None>

                                                                        // Defines

                                                                        #define _NORMALMAP 1
                                                                        #define _NORMAL_DROPOFF_TS 1
                                                                        #define ATTRIBUTES_NEED_NORMAL
                                                                        #define ATTRIBUTES_NEED_TANGENT
                                                                        #define ATTRIBUTES_NEED_TEXCOORD0
                                                                        #define VARYINGS_NEED_POSITION_WS
                                                                        #define VARYINGS_NEED_TEXCOORD0
                                                                        #define FEATURES_GRAPH_VERTEX
                                                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                        #define SHADERPASS SHADERPASS_2D
                                                                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                        // custom interpolator pre-include
                                                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                        // Includes
                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                        // --------------------------------------------------
                                                                        // Structs and Packing

                                                                        // custom interpolators pre packing
                                                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                        struct Attributes
                                                                        {
                                                                             float3 positionOS : POSITION;
                                                                             float3 normalOS : NORMAL;
                                                                             float4 tangentOS : TANGENT;
                                                                             float4 uv0 : TEXCOORD0;
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                             uint instanceID : INSTANCEID_SEMANTIC;
                                                                            #endif
                                                                        };
                                                                        struct Varyings
                                                                        {
                                                                             float4 positionCS : SV_POSITION;
                                                                             float3 positionWS;
                                                                             float4 texCoord0;
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                            #endif
                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                            #endif
                                                                        };
                                                                        struct SurfaceDescriptionInputs
                                                                        {
                                                                             float3 WorldSpacePosition;
                                                                             float4 uv0;
                                                                        };
                                                                        struct VertexDescriptionInputs
                                                                        {
                                                                             float3 ObjectSpaceNormal;
                                                                             float3 ObjectSpaceTangent;
                                                                             float3 ObjectSpacePosition;
                                                                        };
                                                                        struct PackedVaryings
                                                                        {
                                                                             float4 positionCS : SV_POSITION;
                                                                             float3 interp0 : INTERP0;
                                                                             float4 interp1 : INTERP1;
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                            #endif
                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                            #endif
                                                                        };

                                                                        PackedVaryings PackVaryings(Varyings input)
                                                                        {
                                                                            PackedVaryings output;
                                                                            ZERO_INITIALIZE(PackedVaryings, output);
                                                                            output.positionCS = input.positionCS;
                                                                            output.interp0.xyz = input.positionWS;
                                                                            output.interp1.xyzw = input.texCoord0;
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                            output.instanceID = input.instanceID;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                            #endif
                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                            output.cullFace = input.cullFace;
                                                                            #endif
                                                                            return output;
                                                                        }

                                                                        Varyings UnpackVaryings(PackedVaryings input)
                                                                        {
                                                                            Varyings output;
                                                                            output.positionCS = input.positionCS;
                                                                            output.positionWS = input.interp0.xyz;
                                                                            output.texCoord0 = input.interp1.xyzw;
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                            output.instanceID = input.instanceID;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                            #endif
                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                            output.cullFace = input.cullFace;
                                                                            #endif
                                                                            return output;
                                                                        }


                                                                        // --------------------------------------------------
                                                                        // Graph

                                                                        // Graph Properties
                                                                        CBUFFER_START(UnityPerMaterial)
                                                                        float4 _SilhouetteColor;
                                                                        float _FillAmount;
                                                                        float2 _YBounds;
                                                                        float4 _Color;
                                                                        float4 _MainTex_TexelSize;
                                                                        float4 _BandColour;
                                                                        float _BandWidth;
                                                                        CBUFFER_END

                                                                            // Object and Global properties
                                                                            SAMPLER(SamplerState_Linear_Repeat);
                                                                            TEXTURE2D(_MainTex);
                                                                            SAMPLER(sampler_MainTex);

                                                                            // Graph Includes
                                                                            // GraphIncludes: <None>

                                                                            // -- Property used by ScenePickingPass
                                                                            #ifdef SCENEPICKINGPASS
                                                                            float4 _SelectionID;
                                                                            #endif

                                                                            // -- Properties used by SceneSelectionPass
                                                                            #ifdef SCENESELECTIONPASS
                                                                            int _ObjectId;
                                                                            int _PassValue;
                                                                            #endif

                                                                            // Graph Functions

                                                                            void Unity_InverseLerp_float(float A, float B, float T, out float Out)
                                                                            {
                                                                                Out = (T - A) / (B - A);
                                                                            }

                                                                            void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                                                                            {
                                                                                Out = clamp(In, Min, Max);
                                                                            }

                                                                            void Unity_OneMinus_float(float In, out float Out)
                                                                            {
                                                                                Out = 1 - In;
                                                                            }

                                                                            void Unity_Comparison_LessOrEqual_float(float A, float B, out float Out)
                                                                            {
                                                                                Out = A <= B ? 1 : 0;
                                                                            }

                                                                            void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
                                                                            {
                                                                                Out = Predicate ? True : False;
                                                                            }

                                                                            void Unity_Subtract_float(float A, float B, out float Out)
                                                                            {
                                                                                Out = A - B;
                                                                            }

                                                                            void Unity_Comparison_GreaterOrEqual_float(float A, float B, out float Out)
                                                                            {
                                                                                Out = A >= B ? 1 : 0;
                                                                            }

                                                                            void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                                                                            {
                                                                                Out = A * B;
                                                                            }

                                                                            void Unity_OneMinus_float4(float4 In, out float4 Out)
                                                                            {
                                                                                Out = 1 - In;
                                                                            }

                                                                            void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                                                                            {
                                                                                Out = A + B;
                                                                            }

                                                                            // Custom interpolators pre vertex
                                                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                            // Graph Vertex
                                                                            struct VertexDescription
                                                                            {
                                                                                float3 Position;
                                                                                float3 Normal;
                                                                                float3 Tangent;
                                                                            };

                                                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                            {
                                                                                VertexDescription description = (VertexDescription)0;
                                                                                description.Position = IN.ObjectSpacePosition;
                                                                                description.Normal = IN.ObjectSpaceNormal;
                                                                                description.Tangent = IN.ObjectSpaceTangent;
                                                                                return description;
                                                                            }

                                                                            // Custom interpolators, pre surface
                                                                            #ifdef FEATURES_GRAPH_VERTEX
                                                                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                            {
                                                                            return output;
                                                                            }
                                                                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                            #endif

                                                                            // Graph Pixel
                                                                            struct SurfaceDescription
                                                                            {
                                                                                float3 BaseColor;
                                                                            };

                                                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                            {
                                                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                                                float2 _Property_0b4e504a5c134a12bffe4e99027c07fd_Out_0 = _YBounds;
                                                                                float _Swizzle_8918e71ab58c48c385adfdce3517a5c1_Out_1 = _Property_0b4e504a5c134a12bffe4e99027c07fd_Out_0.y;
                                                                                float _Swizzle_c1acb2fe87c442a78bcdefb08d7b0cdd_Out_1 = _Property_0b4e504a5c134a12bffe4e99027c07fd_Out_0.x;
                                                                                float _Swizzle_c206262ecebe4fdba18ddd36ad5598c0_Out_1 = IN.WorldSpacePosition.y;
                                                                                float _InverseLerp_ea18fe2319fe4c66b2253b5a34d8a5fd_Out_3;
                                                                                Unity_InverseLerp_float(_Swizzle_8918e71ab58c48c385adfdce3517a5c1_Out_1, _Swizzle_c1acb2fe87c442a78bcdefb08d7b0cdd_Out_1, _Swizzle_c206262ecebe4fdba18ddd36ad5598c0_Out_1, _InverseLerp_ea18fe2319fe4c66b2253b5a34d8a5fd_Out_3);
                                                                                float _Clamp_c290813c4e624385b85d86cc7c10e4d6_Out_3;
                                                                                Unity_Clamp_float(_InverseLerp_ea18fe2319fe4c66b2253b5a34d8a5fd_Out_3, 0, 1, _Clamp_c290813c4e624385b85d86cc7c10e4d6_Out_3);
                                                                                float _OneMinus_dd9197a7d62f4634bbd451af30c476bf_Out_1;
                                                                                Unity_OneMinus_float(_Clamp_c290813c4e624385b85d86cc7c10e4d6_Out_3, _OneMinus_dd9197a7d62f4634bbd451af30c476bf_Out_1);
                                                                                float _Property_16dd2c1c35774d9c9bbdda71653a43f6_Out_0 = _FillAmount;
                                                                                float _Comparison_dcea135e70a444c5aa73a81b84a98e02_Out_2;
                                                                                Unity_Comparison_LessOrEqual_float(_OneMinus_dd9197a7d62f4634bbd451af30c476bf_Out_1, _Property_16dd2c1c35774d9c9bbdda71653a43f6_Out_0, _Comparison_dcea135e70a444c5aa73a81b84a98e02_Out_2);
                                                                                float4 _Property_94bf0d4982514359b26405a57f6e228e_Out_0 = _Color;
                                                                                float4 _Property_b930a03aaff4459dad251a909414afb2_Out_0 = _SilhouetteColor;
                                                                                float4 _Branch_fe9c129de18844e9ba1dafcf701fc1f5_Out_3;
                                                                                Unity_Branch_float4(_Comparison_dcea135e70a444c5aa73a81b84a98e02_Out_2, _Property_94bf0d4982514359b26405a57f6e228e_Out_0, _Property_b930a03aaff4459dad251a909414afb2_Out_0, _Branch_fe9c129de18844e9ba1dafcf701fc1f5_Out_3);
                                                                                float _Property_b647961b6a5e41e3b128e7d138d26bbf_Out_0 = _BandWidth;
                                                                                float _Subtract_d83f2f4283004dbb8ef2976ad239dcbb_Out_2;
                                                                                Unity_Subtract_float(_Property_16dd2c1c35774d9c9bbdda71653a43f6_Out_0, _Property_b647961b6a5e41e3b128e7d138d26bbf_Out_0, _Subtract_d83f2f4283004dbb8ef2976ad239dcbb_Out_2);
                                                                                float _Comparison_6c3528b2e67742458dcad2c1d9123206_Out_2;
                                                                                Unity_Comparison_GreaterOrEqual_float(_OneMinus_dd9197a7d62f4634bbd451af30c476bf_Out_1, _Subtract_d83f2f4283004dbb8ef2976ad239dcbb_Out_2, _Comparison_6c3528b2e67742458dcad2c1d9123206_Out_2);
                                                                                float4 _Branch_37b2d57601fd44fd9d02a5eecafa4598_Out_3;
                                                                                Unity_Branch_float4(_Comparison_6c3528b2e67742458dcad2c1d9123206_Out_2, _Property_94bf0d4982514359b26405a57f6e228e_Out_0, float4(0, 0, 0, 0), _Branch_37b2d57601fd44fd9d02a5eecafa4598_Out_3);
                                                                                float4 _Multiply_8f6eca7a3a004e1bb7bb5bc8b02dc8cb_Out_2;
                                                                                Unity_Multiply_float4_float4(_Branch_fe9c129de18844e9ba1dafcf701fc1f5_Out_3, _Branch_37b2d57601fd44fd9d02a5eecafa4598_Out_3, _Multiply_8f6eca7a3a004e1bb7bb5bc8b02dc8cb_Out_2);
                                                                                float4 _Property_665c2bda7053418092ddc78c9b230846_Out_0 = _BandColour;
                                                                                float4 _Multiply_80f3f98c40c747cfac316465edd63a2f_Out_2;
                                                                                Unity_Multiply_float4_float4(_Multiply_8f6eca7a3a004e1bb7bb5bc8b02dc8cb_Out_2, _Property_665c2bda7053418092ddc78c9b230846_Out_0, _Multiply_80f3f98c40c747cfac316465edd63a2f_Out_2);
                                                                                float4 _OneMinus_9b0bae6729ce46b1bd920238dc7a064e_Out_1;
                                                                                Unity_OneMinus_float4(_Branch_37b2d57601fd44fd9d02a5eecafa4598_Out_3, _OneMinus_9b0bae6729ce46b1bd920238dc7a064e_Out_1);
                                                                                float4 _Add_a846e3cc418140c3bf1b27f660cd7ba4_Out_2;
                                                                                Unity_Add_float4(_Multiply_80f3f98c40c747cfac316465edd63a2f_Out_2, _OneMinus_9b0bae6729ce46b1bd920238dc7a064e_Out_1, _Add_a846e3cc418140c3bf1b27f660cd7ba4_Out_2);
                                                                                UnityTexture2D _Property_0c7380d416f643088cd6f223277a1d87_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
                                                                                float4 _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_RGBA_0 = SAMPLE_TEXTURE2D(_Property_0c7380d416f643088cd6f223277a1d87_Out_0.tex, _Property_0c7380d416f643088cd6f223277a1d87_Out_0.samplerstate, _Property_0c7380d416f643088cd6f223277a1d87_Out_0.GetTransformedUV(IN.uv0.xy));
                                                                                float _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_R_4 = _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_RGBA_0.r;
                                                                                float _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_G_5 = _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_RGBA_0.g;
                                                                                float _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_B_6 = _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_RGBA_0.b;
                                                                                float _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_A_7 = _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_RGBA_0.a;
                                                                                float4 _Multiply_d2e9657dc3154f43a0fe0f8d33b46f14_Out_2;
                                                                                Unity_Multiply_float4_float4(_SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_RGBA_0, _OneMinus_9b0bae6729ce46b1bd920238dc7a064e_Out_1, _Multiply_d2e9657dc3154f43a0fe0f8d33b46f14_Out_2);
                                                                                float4 _OneMinus_d702c615cb6a4d93a374d272c8ad4b87_Out_1;
                                                                                Unity_OneMinus_float4(_OneMinus_9b0bae6729ce46b1bd920238dc7a064e_Out_1, _OneMinus_d702c615cb6a4d93a374d272c8ad4b87_Out_1);
                                                                                float4 _Add_1eaa704a333b4ebdbaf364697a0bec42_Out_2;
                                                                                Unity_Add_float4(_Multiply_d2e9657dc3154f43a0fe0f8d33b46f14_Out_2, _OneMinus_d702c615cb6a4d93a374d272c8ad4b87_Out_1, _Add_1eaa704a333b4ebdbaf364697a0bec42_Out_2);
                                                                                float4 _Multiply_0702241a7980465bb8edf3998a7bbf1b_Out_2;
                                                                                Unity_Multiply_float4_float4(_Add_a846e3cc418140c3bf1b27f660cd7ba4_Out_2, _Add_1eaa704a333b4ebdbaf364697a0bec42_Out_2, _Multiply_0702241a7980465bb8edf3998a7bbf1b_Out_2);
                                                                                surface.BaseColor = (_Multiply_0702241a7980465bb8edf3998a7bbf1b_Out_2.xyz);
                                                                                return surface;
                                                                            }

                                                                            // --------------------------------------------------
                                                                            // Build Graph Inputs
                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                            #define VFX_SRP_ATTRIBUTES Attributes
                                                                            #define VFX_SRP_VARYINGS Varyings
                                                                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                            #endif
                                                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                            {
                                                                                VertexDescriptionInputs output;
                                                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                output.ObjectSpaceNormal = input.normalOS;
                                                                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                output.ObjectSpacePosition = input.positionOS;

                                                                                return output;
                                                                            }
                                                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                            {
                                                                                SurfaceDescriptionInputs output;
                                                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                            #endif







                                                                                output.WorldSpacePosition = input.positionWS;
                                                                                output.uv0 = input.texCoord0;
                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                            #else
                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                            #endif
                                                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                    return output;
                                                                            }

                                                                            // --------------------------------------------------
                                                                            // Main

                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

                                                                            // --------------------------------------------------
                                                                            // Visual Effect Vertex Invocations
                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                            #endif

                                                                            ENDHLSL
                                                                            }
    }
        SubShader
                                                                            {
                                                                                Tags
                                                                                {
                                                                                    "RenderPipeline" = "UniversalPipeline"
                                                                                    "RenderType" = "Opaque"
                                                                                    "UniversalMaterialType" = "Lit"
                                                                                    "Queue" = "Geometry"
                                                                                    "ShaderGraphShader" = "true"
                                                                                    "ShaderGraphTargetId" = "UniversalLitSubTarget"
                                                                                }
                                                                                Pass
                                                                                {
                                                                                    Name "Universal Forward"
                                                                                    Tags
                                                                                    {
                                                                                        "LightMode" = "UniversalForward"
                                                                                    }

                                                                                // Render State
                                                                                Cull Back
                                                                                Blend One Zero
                                                                                ZTest LEqual
                                                                                ZWrite On

                                                                                // Debug
                                                                                // <None>

                                                                                // --------------------------------------------------
                                                                                // Pass

                                                                                HLSLPROGRAM

                                                                                // Pragmas
                                                                                #pragma target 2.0
                                                                                #pragma only_renderers gles gles3 glcore d3d11
                                                                                #pragma multi_compile_instancing
                                                                                #pragma multi_compile_fog
                                                                                #pragma instancing_options renderinglayer
                                                                                #pragma vertex vert
                                                                                #pragma fragment frag

                                                                                // DotsInstancingOptions: <None>
                                                                                // HybridV1InjectedBuiltinProperties: <None>

                                                                                // Keywords
                                                                                #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
                                                                                #pragma multi_compile _ LIGHTMAP_ON
                                                                                #pragma multi_compile _ DYNAMICLIGHTMAP_ON
                                                                                #pragma multi_compile _ DIRLIGHTMAP_COMBINED
                                                                                #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
                                                                                #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
                                                                                #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
                                                                                #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
                                                                                #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
                                                                                #pragma multi_compile_fragment _ _SHADOWS_SOFT
                                                                                #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
                                                                                #pragma multi_compile _ SHADOWS_SHADOWMASK
                                                                                #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
                                                                                #pragma multi_compile_fragment _ _LIGHT_LAYERS
                                                                                #pragma multi_compile_fragment _ DEBUG_DISPLAY
                                                                                #pragma multi_compile_fragment _ _LIGHT_COOKIES
                                                                                #pragma multi_compile _ _CLUSTERED_RENDERING
                                                                                // GraphKeywords: <None>

                                                                                // Defines

                                                                                #define _NORMALMAP 1
                                                                                #define _NORMAL_DROPOFF_TS 1
                                                                                #define ATTRIBUTES_NEED_NORMAL
                                                                                #define ATTRIBUTES_NEED_TANGENT
                                                                                #define ATTRIBUTES_NEED_TEXCOORD0
                                                                                #define ATTRIBUTES_NEED_TEXCOORD1
                                                                                #define ATTRIBUTES_NEED_TEXCOORD2
                                                                                #define VARYINGS_NEED_POSITION_WS
                                                                                #define VARYINGS_NEED_NORMAL_WS
                                                                                #define VARYINGS_NEED_TANGENT_WS
                                                                                #define VARYINGS_NEED_TEXCOORD0
                                                                                #define VARYINGS_NEED_VIEWDIRECTION_WS
                                                                                #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                                                                #define VARYINGS_NEED_SHADOW_COORD
                                                                                #define FEATURES_GRAPH_VERTEX
                                                                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                                #define SHADERPASS SHADERPASS_FORWARD
                                                                                #define _FOG_FRAGMENT 1
                                                                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                                // custom interpolator pre-include
                                                                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                                // Includes
                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
                                                                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                                // --------------------------------------------------
                                                                                // Structs and Packing

                                                                                // custom interpolators pre packing
                                                                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                                struct Attributes
                                                                                {
                                                                                     float3 positionOS : POSITION;
                                                                                     float3 normalOS : NORMAL;
                                                                                     float4 tangentOS : TANGENT;
                                                                                     float4 uv0 : TEXCOORD0;
                                                                                     float4 uv1 : TEXCOORD1;
                                                                                     float4 uv2 : TEXCOORD2;
                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                     uint instanceID : INSTANCEID_SEMANTIC;
                                                                                    #endif
                                                                                };
                                                                                struct Varyings
                                                                                {
                                                                                     float4 positionCS : SV_POSITION;
                                                                                     float3 positionWS;
                                                                                     float3 normalWS;
                                                                                     float4 tangentWS;
                                                                                     float4 texCoord0;
                                                                                     float3 viewDirectionWS;
                                                                                    #if defined(LIGHTMAP_ON)
                                                                                     float2 staticLightmapUV;
                                                                                    #endif
                                                                                    #if defined(DYNAMICLIGHTMAP_ON)
                                                                                     float2 dynamicLightmapUV;
                                                                                    #endif
                                                                                    #if !defined(LIGHTMAP_ON)
                                                                                     float3 sh;
                                                                                    #endif
                                                                                     float4 fogFactorAndVertexLight;
                                                                                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                                                                                     float4 shadowCoord;
                                                                                    #endif
                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                    #endif
                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                    #endif
                                                                                };
                                                                                struct SurfaceDescriptionInputs
                                                                                {
                                                                                     float3 TangentSpaceNormal;
                                                                                     float3 WorldSpacePosition;
                                                                                     float4 uv0;
                                                                                };
                                                                                struct VertexDescriptionInputs
                                                                                {
                                                                                     float3 ObjectSpaceNormal;
                                                                                     float3 ObjectSpaceTangent;
                                                                                     float3 ObjectSpacePosition;
                                                                                };
                                                                                struct PackedVaryings
                                                                                {
                                                                                     float4 positionCS : SV_POSITION;
                                                                                     float3 interp0 : INTERP0;
                                                                                     float3 interp1 : INTERP1;
                                                                                     float4 interp2 : INTERP2;
                                                                                     float4 interp3 : INTERP3;
                                                                                     float3 interp4 : INTERP4;
                                                                                     float2 interp5 : INTERP5;
                                                                                     float2 interp6 : INTERP6;
                                                                                     float3 interp7 : INTERP7;
                                                                                     float4 interp8 : INTERP8;
                                                                                     float4 interp9 : INTERP9;
                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                    #endif
                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                    #endif
                                                                                };

                                                                                PackedVaryings PackVaryings(Varyings input)
                                                                                {
                                                                                    PackedVaryings output;
                                                                                    ZERO_INITIALIZE(PackedVaryings, output);
                                                                                    output.positionCS = input.positionCS;
                                                                                    output.interp0.xyz = input.positionWS;
                                                                                    output.interp1.xyz = input.normalWS;
                                                                                    output.interp2.xyzw = input.tangentWS;
                                                                                    output.interp3.xyzw = input.texCoord0;
                                                                                    output.interp4.xyz = input.viewDirectionWS;
                                                                                    #if defined(LIGHTMAP_ON)
                                                                                    output.interp5.xy = input.staticLightmapUV;
                                                                                    #endif
                                                                                    #if defined(DYNAMICLIGHTMAP_ON)
                                                                                    output.interp6.xy = input.dynamicLightmapUV;
                                                                                    #endif
                                                                                    #if !defined(LIGHTMAP_ON)
                                                                                    output.interp7.xyz = input.sh;
                                                                                    #endif
                                                                                    output.interp8.xyzw = input.fogFactorAndVertexLight;
                                                                                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                                                                                    output.interp9.xyzw = input.shadowCoord;
                                                                                    #endif
                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                    output.instanceID = input.instanceID;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                    #endif
                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                    output.cullFace = input.cullFace;
                                                                                    #endif
                                                                                    return output;
                                                                                }

                                                                                Varyings UnpackVaryings(PackedVaryings input)
                                                                                {
                                                                                    Varyings output;
                                                                                    output.positionCS = input.positionCS;
                                                                                    output.positionWS = input.interp0.xyz;
                                                                                    output.normalWS = input.interp1.xyz;
                                                                                    output.tangentWS = input.interp2.xyzw;
                                                                                    output.texCoord0 = input.interp3.xyzw;
                                                                                    output.viewDirectionWS = input.interp4.xyz;
                                                                                    #if defined(LIGHTMAP_ON)
                                                                                    output.staticLightmapUV = input.interp5.xy;
                                                                                    #endif
                                                                                    #if defined(DYNAMICLIGHTMAP_ON)
                                                                                    output.dynamicLightmapUV = input.interp6.xy;
                                                                                    #endif
                                                                                    #if !defined(LIGHTMAP_ON)
                                                                                    output.sh = input.interp7.xyz;
                                                                                    #endif
                                                                                    output.fogFactorAndVertexLight = input.interp8.xyzw;
                                                                                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                                                                                    output.shadowCoord = input.interp9.xyzw;
                                                                                    #endif
                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                    output.instanceID = input.instanceID;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                    #endif
                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                    output.cullFace = input.cullFace;
                                                                                    #endif
                                                                                    return output;
                                                                                }


                                                                                // --------------------------------------------------
                                                                                // Graph

                                                                                // Graph Properties
                                                                                CBUFFER_START(UnityPerMaterial)
                                                                                float4 _SilhouetteColor;
                                                                                float _FillAmount;
                                                                                float2 _YBounds;
                                                                                float4 _Color;
                                                                                float4 _MainTex_TexelSize;
                                                                                float4 _BandColour;
                                                                                float _BandWidth;
                                                                                CBUFFER_END

                                                                                    // Object and Global properties
                                                                                    SAMPLER(SamplerState_Linear_Repeat);
                                                                                    TEXTURE2D(_MainTex);
                                                                                    SAMPLER(sampler_MainTex);

                                                                                    // Graph Includes
                                                                                    // GraphIncludes: <None>

                                                                                    // -- Property used by ScenePickingPass
                                                                                    #ifdef SCENEPICKINGPASS
                                                                                    float4 _SelectionID;
                                                                                    #endif

                                                                                    // -- Properties used by SceneSelectionPass
                                                                                    #ifdef SCENESELECTIONPASS
                                                                                    int _ObjectId;
                                                                                    int _PassValue;
                                                                                    #endif

                                                                                    // Graph Functions

                                                                                    void Unity_InverseLerp_float(float A, float B, float T, out float Out)
                                                                                    {
                                                                                        Out = (T - A) / (B - A);
                                                                                    }

                                                                                    void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                                                                                    {
                                                                                        Out = clamp(In, Min, Max);
                                                                                    }

                                                                                    void Unity_OneMinus_float(float In, out float Out)
                                                                                    {
                                                                                        Out = 1 - In;
                                                                                    }

                                                                                    void Unity_Comparison_LessOrEqual_float(float A, float B, out float Out)
                                                                                    {
                                                                                        Out = A <= B ? 1 : 0;
                                                                                    }

                                                                                    void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
                                                                                    {
                                                                                        Out = Predicate ? True : False;
                                                                                    }

                                                                                    void Unity_Subtract_float(float A, float B, out float Out)
                                                                                    {
                                                                                        Out = A - B;
                                                                                    }

                                                                                    void Unity_Comparison_GreaterOrEqual_float(float A, float B, out float Out)
                                                                                    {
                                                                                        Out = A >= B ? 1 : 0;
                                                                                    }

                                                                                    void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                                                                                    {
                                                                                        Out = A * B;
                                                                                    }

                                                                                    void Unity_OneMinus_float4(float4 In, out float4 Out)
                                                                                    {
                                                                                        Out = 1 - In;
                                                                                    }

                                                                                    void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                                                                                    {
                                                                                        Out = A + B;
                                                                                    }

                                                                                    // Custom interpolators pre vertex
                                                                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                                    // Graph Vertex
                                                                                    struct VertexDescription
                                                                                    {
                                                                                        float3 Position;
                                                                                        float3 Normal;
                                                                                        float3 Tangent;
                                                                                    };

                                                                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                                    {
                                                                                        VertexDescription description = (VertexDescription)0;
                                                                                        description.Position = IN.ObjectSpacePosition;
                                                                                        description.Normal = IN.ObjectSpaceNormal;
                                                                                        description.Tangent = IN.ObjectSpaceTangent;
                                                                                        return description;
                                                                                    }

                                                                                    // Custom interpolators, pre surface
                                                                                    #ifdef FEATURES_GRAPH_VERTEX
                                                                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                                    {
                                                                                    return output;
                                                                                    }
                                                                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                                    #endif

                                                                                    // Graph Pixel
                                                                                    struct SurfaceDescription
                                                                                    {
                                                                                        float3 BaseColor;
                                                                                        float3 NormalTS;
                                                                                        float3 Emission;
                                                                                        float Metallic;
                                                                                        float Smoothness;
                                                                                        float Occlusion;
                                                                                    };

                                                                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                                    {
                                                                                        SurfaceDescription surface = (SurfaceDescription)0;
                                                                                        float2 _Property_0b4e504a5c134a12bffe4e99027c07fd_Out_0 = _YBounds;
                                                                                        float _Swizzle_8918e71ab58c48c385adfdce3517a5c1_Out_1 = _Property_0b4e504a5c134a12bffe4e99027c07fd_Out_0.y;
                                                                                        float _Swizzle_c1acb2fe87c442a78bcdefb08d7b0cdd_Out_1 = _Property_0b4e504a5c134a12bffe4e99027c07fd_Out_0.x;
                                                                                        float _Swizzle_c206262ecebe4fdba18ddd36ad5598c0_Out_1 = IN.WorldSpacePosition.y;
                                                                                        float _InverseLerp_ea18fe2319fe4c66b2253b5a34d8a5fd_Out_3;
                                                                                        Unity_InverseLerp_float(_Swizzle_8918e71ab58c48c385adfdce3517a5c1_Out_1, _Swizzle_c1acb2fe87c442a78bcdefb08d7b0cdd_Out_1, _Swizzle_c206262ecebe4fdba18ddd36ad5598c0_Out_1, _InverseLerp_ea18fe2319fe4c66b2253b5a34d8a5fd_Out_3);
                                                                                        float _Clamp_c290813c4e624385b85d86cc7c10e4d6_Out_3;
                                                                                        Unity_Clamp_float(_InverseLerp_ea18fe2319fe4c66b2253b5a34d8a5fd_Out_3, 0, 1, _Clamp_c290813c4e624385b85d86cc7c10e4d6_Out_3);
                                                                                        float _OneMinus_dd9197a7d62f4634bbd451af30c476bf_Out_1;
                                                                                        Unity_OneMinus_float(_Clamp_c290813c4e624385b85d86cc7c10e4d6_Out_3, _OneMinus_dd9197a7d62f4634bbd451af30c476bf_Out_1);
                                                                                        float _Property_16dd2c1c35774d9c9bbdda71653a43f6_Out_0 = _FillAmount;
                                                                                        float _Comparison_dcea135e70a444c5aa73a81b84a98e02_Out_2;
                                                                                        Unity_Comparison_LessOrEqual_float(_OneMinus_dd9197a7d62f4634bbd451af30c476bf_Out_1, _Property_16dd2c1c35774d9c9bbdda71653a43f6_Out_0, _Comparison_dcea135e70a444c5aa73a81b84a98e02_Out_2);
                                                                                        float4 _Property_94bf0d4982514359b26405a57f6e228e_Out_0 = _Color;
                                                                                        float4 _Property_b930a03aaff4459dad251a909414afb2_Out_0 = _SilhouetteColor;
                                                                                        float4 _Branch_fe9c129de18844e9ba1dafcf701fc1f5_Out_3;
                                                                                        Unity_Branch_float4(_Comparison_dcea135e70a444c5aa73a81b84a98e02_Out_2, _Property_94bf0d4982514359b26405a57f6e228e_Out_0, _Property_b930a03aaff4459dad251a909414afb2_Out_0, _Branch_fe9c129de18844e9ba1dafcf701fc1f5_Out_3);
                                                                                        float _Property_b647961b6a5e41e3b128e7d138d26bbf_Out_0 = _BandWidth;
                                                                                        float _Subtract_d83f2f4283004dbb8ef2976ad239dcbb_Out_2;
                                                                                        Unity_Subtract_float(_Property_16dd2c1c35774d9c9bbdda71653a43f6_Out_0, _Property_b647961b6a5e41e3b128e7d138d26bbf_Out_0, _Subtract_d83f2f4283004dbb8ef2976ad239dcbb_Out_2);
                                                                                        float _Comparison_6c3528b2e67742458dcad2c1d9123206_Out_2;
                                                                                        Unity_Comparison_GreaterOrEqual_float(_OneMinus_dd9197a7d62f4634bbd451af30c476bf_Out_1, _Subtract_d83f2f4283004dbb8ef2976ad239dcbb_Out_2, _Comparison_6c3528b2e67742458dcad2c1d9123206_Out_2);
                                                                                        float4 _Branch_37b2d57601fd44fd9d02a5eecafa4598_Out_3;
                                                                                        Unity_Branch_float4(_Comparison_6c3528b2e67742458dcad2c1d9123206_Out_2, _Property_94bf0d4982514359b26405a57f6e228e_Out_0, float4(0, 0, 0, 0), _Branch_37b2d57601fd44fd9d02a5eecafa4598_Out_3);
                                                                                        float4 _Multiply_8f6eca7a3a004e1bb7bb5bc8b02dc8cb_Out_2;
                                                                                        Unity_Multiply_float4_float4(_Branch_fe9c129de18844e9ba1dafcf701fc1f5_Out_3, _Branch_37b2d57601fd44fd9d02a5eecafa4598_Out_3, _Multiply_8f6eca7a3a004e1bb7bb5bc8b02dc8cb_Out_2);
                                                                                        float4 _Property_665c2bda7053418092ddc78c9b230846_Out_0 = _BandColour;
                                                                                        float4 _Multiply_80f3f98c40c747cfac316465edd63a2f_Out_2;
                                                                                        Unity_Multiply_float4_float4(_Multiply_8f6eca7a3a004e1bb7bb5bc8b02dc8cb_Out_2, _Property_665c2bda7053418092ddc78c9b230846_Out_0, _Multiply_80f3f98c40c747cfac316465edd63a2f_Out_2);
                                                                                        float4 _OneMinus_9b0bae6729ce46b1bd920238dc7a064e_Out_1;
                                                                                        Unity_OneMinus_float4(_Branch_37b2d57601fd44fd9d02a5eecafa4598_Out_3, _OneMinus_9b0bae6729ce46b1bd920238dc7a064e_Out_1);
                                                                                        float4 _Add_a846e3cc418140c3bf1b27f660cd7ba4_Out_2;
                                                                                        Unity_Add_float4(_Multiply_80f3f98c40c747cfac316465edd63a2f_Out_2, _OneMinus_9b0bae6729ce46b1bd920238dc7a064e_Out_1, _Add_a846e3cc418140c3bf1b27f660cd7ba4_Out_2);
                                                                                        UnityTexture2D _Property_0c7380d416f643088cd6f223277a1d87_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
                                                                                        float4 _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_RGBA_0 = SAMPLE_TEXTURE2D(_Property_0c7380d416f643088cd6f223277a1d87_Out_0.tex, _Property_0c7380d416f643088cd6f223277a1d87_Out_0.samplerstate, _Property_0c7380d416f643088cd6f223277a1d87_Out_0.GetTransformedUV(IN.uv0.xy));
                                                                                        float _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_R_4 = _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_RGBA_0.r;
                                                                                        float _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_G_5 = _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_RGBA_0.g;
                                                                                        float _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_B_6 = _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_RGBA_0.b;
                                                                                        float _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_A_7 = _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_RGBA_0.a;
                                                                                        float4 _Multiply_d2e9657dc3154f43a0fe0f8d33b46f14_Out_2;
                                                                                        Unity_Multiply_float4_float4(_SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_RGBA_0, _OneMinus_9b0bae6729ce46b1bd920238dc7a064e_Out_1, _Multiply_d2e9657dc3154f43a0fe0f8d33b46f14_Out_2);
                                                                                        float4 _OneMinus_d702c615cb6a4d93a374d272c8ad4b87_Out_1;
                                                                                        Unity_OneMinus_float4(_OneMinus_9b0bae6729ce46b1bd920238dc7a064e_Out_1, _OneMinus_d702c615cb6a4d93a374d272c8ad4b87_Out_1);
                                                                                        float4 _Add_1eaa704a333b4ebdbaf364697a0bec42_Out_2;
                                                                                        Unity_Add_float4(_Multiply_d2e9657dc3154f43a0fe0f8d33b46f14_Out_2, _OneMinus_d702c615cb6a4d93a374d272c8ad4b87_Out_1, _Add_1eaa704a333b4ebdbaf364697a0bec42_Out_2);
                                                                                        float4 _Multiply_0702241a7980465bb8edf3998a7bbf1b_Out_2;
                                                                                        Unity_Multiply_float4_float4(_Add_a846e3cc418140c3bf1b27f660cd7ba4_Out_2, _Add_1eaa704a333b4ebdbaf364697a0bec42_Out_2, _Multiply_0702241a7980465bb8edf3998a7bbf1b_Out_2);
                                                                                        surface.BaseColor = (_Multiply_0702241a7980465bb8edf3998a7bbf1b_Out_2.xyz);
                                                                                        surface.NormalTS = IN.TangentSpaceNormal;
                                                                                        surface.Emission = float3(0, 0, 0);
                                                                                        surface.Metallic = 0;
                                                                                        surface.Smoothness = 0.5;
                                                                                        surface.Occlusion = 1;
                                                                                        return surface;
                                                                                    }

                                                                                    // --------------------------------------------------
                                                                                    // Build Graph Inputs
                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                    #define VFX_SRP_ATTRIBUTES Attributes
                                                                                    #define VFX_SRP_VARYINGS Varyings
                                                                                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                                    #endif
                                                                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                                    {
                                                                                        VertexDescriptionInputs output;
                                                                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                        output.ObjectSpaceNormal = input.normalOS;
                                                                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                        output.ObjectSpacePosition = input.positionOS;

                                                                                        return output;
                                                                                    }
                                                                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                    {
                                                                                        SurfaceDescriptionInputs output;
                                                                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                                    #endif





                                                                                        output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                                                                                        output.WorldSpacePosition = input.positionWS;
                                                                                        output.uv0 = input.texCoord0;
                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                                    #else
                                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                                    #endif
                                                                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                            return output;
                                                                                    }

                                                                                    // --------------------------------------------------
                                                                                    // Main

                                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

                                                                                    // --------------------------------------------------
                                                                                    // Visual Effect Vertex Invocations
                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                                    #endif

                                                                                    ENDHLSL
                                                                                    }
                                                                                    Pass
                                                                                    {
                                                                                        Name "ShadowCaster"
                                                                                        Tags
                                                                                        {
                                                                                            "LightMode" = "ShadowCaster"
                                                                                        }

                                                                                        // Render State
                                                                                        Cull Back
                                                                                        ZTest LEqual
                                                                                        ZWrite On
                                                                                        ColorMask 0

                                                                                        // Debug
                                                                                        // <None>

                                                                                        // --------------------------------------------------
                                                                                        // Pass

                                                                                        HLSLPROGRAM

                                                                                        // Pragmas
                                                                                        #pragma target 2.0
                                                                                        #pragma only_renderers gles gles3 glcore d3d11
                                                                                        #pragma multi_compile_instancing
                                                                                        #pragma vertex vert
                                                                                        #pragma fragment frag

                                                                                        // DotsInstancingOptions: <None>
                                                                                        // HybridV1InjectedBuiltinProperties: <None>

                                                                                        // Keywords
                                                                                        #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
                                                                                        // GraphKeywords: <None>

                                                                                        // Defines

                                                                                        #define _NORMALMAP 1
                                                                                        #define _NORMAL_DROPOFF_TS 1
                                                                                        #define ATTRIBUTES_NEED_NORMAL
                                                                                        #define ATTRIBUTES_NEED_TANGENT
                                                                                        #define VARYINGS_NEED_NORMAL_WS
                                                                                        #define FEATURES_GRAPH_VERTEX
                                                                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                                        #define SHADERPASS SHADERPASS_SHADOWCASTER
                                                                                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                                        // custom interpolator pre-include
                                                                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                                        // Includes
                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                                        // --------------------------------------------------
                                                                                        // Structs and Packing

                                                                                        // custom interpolators pre packing
                                                                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                                        struct Attributes
                                                                                        {
                                                                                             float3 positionOS : POSITION;
                                                                                             float3 normalOS : NORMAL;
                                                                                             float4 tangentOS : TANGENT;
                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                             uint instanceID : INSTANCEID_SEMANTIC;
                                                                                            #endif
                                                                                        };
                                                                                        struct Varyings
                                                                                        {
                                                                                             float4 positionCS : SV_POSITION;
                                                                                             float3 normalWS;
                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                            #endif
                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                            #endif
                                                                                        };
                                                                                        struct SurfaceDescriptionInputs
                                                                                        {
                                                                                        };
                                                                                        struct VertexDescriptionInputs
                                                                                        {
                                                                                             float3 ObjectSpaceNormal;
                                                                                             float3 ObjectSpaceTangent;
                                                                                             float3 ObjectSpacePosition;
                                                                                        };
                                                                                        struct PackedVaryings
                                                                                        {
                                                                                             float4 positionCS : SV_POSITION;
                                                                                             float3 interp0 : INTERP0;
                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                            #endif
                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                            #endif
                                                                                        };

                                                                                        PackedVaryings PackVaryings(Varyings input)
                                                                                        {
                                                                                            PackedVaryings output;
                                                                                            ZERO_INITIALIZE(PackedVaryings, output);
                                                                                            output.positionCS = input.positionCS;
                                                                                            output.interp0.xyz = input.normalWS;
                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                            output.instanceID = input.instanceID;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                            #endif
                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                            output.cullFace = input.cullFace;
                                                                                            #endif
                                                                                            return output;
                                                                                        }

                                                                                        Varyings UnpackVaryings(PackedVaryings input)
                                                                                        {
                                                                                            Varyings output;
                                                                                            output.positionCS = input.positionCS;
                                                                                            output.normalWS = input.interp0.xyz;
                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                            output.instanceID = input.instanceID;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                            #endif
                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                            output.cullFace = input.cullFace;
                                                                                            #endif
                                                                                            return output;
                                                                                        }


                                                                                        // --------------------------------------------------
                                                                                        // Graph

                                                                                        // Graph Properties
                                                                                        CBUFFER_START(UnityPerMaterial)
                                                                                        float4 _SilhouetteColor;
                                                                                        float _FillAmount;
                                                                                        float2 _YBounds;
                                                                                        float4 _Color;
                                                                                        float4 _MainTex_TexelSize;
                                                                                        float4 _BandColour;
                                                                                        float _BandWidth;
                                                                                        CBUFFER_END

                                                                                            // Object and Global properties
                                                                                            SAMPLER(SamplerState_Linear_Repeat);
                                                                                            TEXTURE2D(_MainTex);
                                                                                            SAMPLER(sampler_MainTex);

                                                                                            // Graph Includes
                                                                                            // GraphIncludes: <None>

                                                                                            // -- Property used by ScenePickingPass
                                                                                            #ifdef SCENEPICKINGPASS
                                                                                            float4 _SelectionID;
                                                                                            #endif

                                                                                            // -- Properties used by SceneSelectionPass
                                                                                            #ifdef SCENESELECTIONPASS
                                                                                            int _ObjectId;
                                                                                            int _PassValue;
                                                                                            #endif

                                                                                            // Graph Functions
                                                                                            // GraphFunctions: <None>

                                                                                            // Custom interpolators pre vertex
                                                                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                                            // Graph Vertex
                                                                                            struct VertexDescription
                                                                                            {
                                                                                                float3 Position;
                                                                                                float3 Normal;
                                                                                                float3 Tangent;
                                                                                            };

                                                                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                                            {
                                                                                                VertexDescription description = (VertexDescription)0;
                                                                                                description.Position = IN.ObjectSpacePosition;
                                                                                                description.Normal = IN.ObjectSpaceNormal;
                                                                                                description.Tangent = IN.ObjectSpaceTangent;
                                                                                                return description;
                                                                                            }

                                                                                            // Custom interpolators, pre surface
                                                                                            #ifdef FEATURES_GRAPH_VERTEX
                                                                                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                                            {
                                                                                            return output;
                                                                                            }
                                                                                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                                            #endif

                                                                                            // Graph Pixel
                                                                                            struct SurfaceDescription
                                                                                            {
                                                                                            };

                                                                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                                            {
                                                                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                                                                return surface;
                                                                                            }

                                                                                            // --------------------------------------------------
                                                                                            // Build Graph Inputs
                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                            #define VFX_SRP_ATTRIBUTES Attributes
                                                                                            #define VFX_SRP_VARYINGS Varyings
                                                                                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                                            #endif
                                                                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                                            {
                                                                                                VertexDescriptionInputs output;
                                                                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                                output.ObjectSpaceNormal = input.normalOS;
                                                                                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                                output.ObjectSpacePosition = input.positionOS;

                                                                                                return output;
                                                                                            }
                                                                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                            {
                                                                                                SurfaceDescriptionInputs output;
                                                                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                                            #endif







                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                                            #else
                                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                                            #endif
                                                                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                                    return output;
                                                                                            }

                                                                                            // --------------------------------------------------
                                                                                            // Main

                                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

                                                                                            // --------------------------------------------------
                                                                                            // Visual Effect Vertex Invocations
                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                                            #endif

                                                                                            ENDHLSL
                                                                                            }
                                                                                            Pass
                                                                                            {
                                                                                                Name "DepthOnly"
                                                                                                Tags
                                                                                                {
                                                                                                    "LightMode" = "DepthOnly"
                                                                                                }

                                                                                                // Render State
                                                                                                Cull Back
                                                                                                ZTest LEqual
                                                                                                ZWrite On
                                                                                                ColorMask 0

                                                                                                // Debug
                                                                                                // <None>

                                                                                                // --------------------------------------------------
                                                                                                // Pass

                                                                                                HLSLPROGRAM

                                                                                                // Pragmas
                                                                                                #pragma target 2.0
                                                                                                #pragma only_renderers gles gles3 glcore d3d11
                                                                                                #pragma multi_compile_instancing
                                                                                                #pragma vertex vert
                                                                                                #pragma fragment frag

                                                                                                // DotsInstancingOptions: <None>
                                                                                                // HybridV1InjectedBuiltinProperties: <None>

                                                                                                // Keywords
                                                                                                // PassKeywords: <None>
                                                                                                // GraphKeywords: <None>

                                                                                                // Defines

                                                                                                #define _NORMALMAP 1
                                                                                                #define _NORMAL_DROPOFF_TS 1
                                                                                                #define ATTRIBUTES_NEED_NORMAL
                                                                                                #define ATTRIBUTES_NEED_TANGENT
                                                                                                #define FEATURES_GRAPH_VERTEX
                                                                                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                                                #define SHADERPASS SHADERPASS_DEPTHONLY
                                                                                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                                                // custom interpolator pre-include
                                                                                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                                                // Includes
                                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                                                // --------------------------------------------------
                                                                                                // Structs and Packing

                                                                                                // custom interpolators pre packing
                                                                                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                                                struct Attributes
                                                                                                {
                                                                                                     float3 positionOS : POSITION;
                                                                                                     float3 normalOS : NORMAL;
                                                                                                     float4 tangentOS : TANGENT;
                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                     uint instanceID : INSTANCEID_SEMANTIC;
                                                                                                    #endif
                                                                                                };
                                                                                                struct Varyings
                                                                                                {
                                                                                                     float4 positionCS : SV_POSITION;
                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                    #endif
                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                    #endif
                                                                                                };
                                                                                                struct SurfaceDescriptionInputs
                                                                                                {
                                                                                                };
                                                                                                struct VertexDescriptionInputs
                                                                                                {
                                                                                                     float3 ObjectSpaceNormal;
                                                                                                     float3 ObjectSpaceTangent;
                                                                                                     float3 ObjectSpacePosition;
                                                                                                };
                                                                                                struct PackedVaryings
                                                                                                {
                                                                                                     float4 positionCS : SV_POSITION;
                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                    #endif
                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                    #endif
                                                                                                };

                                                                                                PackedVaryings PackVaryings(Varyings input)
                                                                                                {
                                                                                                    PackedVaryings output;
                                                                                                    ZERO_INITIALIZE(PackedVaryings, output);
                                                                                                    output.positionCS = input.positionCS;
                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                    output.instanceID = input.instanceID;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                    #endif
                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                    output.cullFace = input.cullFace;
                                                                                                    #endif
                                                                                                    return output;
                                                                                                }

                                                                                                Varyings UnpackVaryings(PackedVaryings input)
                                                                                                {
                                                                                                    Varyings output;
                                                                                                    output.positionCS = input.positionCS;
                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                    output.instanceID = input.instanceID;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                    #endif
                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                    output.cullFace = input.cullFace;
                                                                                                    #endif
                                                                                                    return output;
                                                                                                }


                                                                                                // --------------------------------------------------
                                                                                                // Graph

                                                                                                // Graph Properties
                                                                                                CBUFFER_START(UnityPerMaterial)
                                                                                                float4 _SilhouetteColor;
                                                                                                float _FillAmount;
                                                                                                float2 _YBounds;
                                                                                                float4 _Color;
                                                                                                float4 _MainTex_TexelSize;
                                                                                                float4 _BandColour;
                                                                                                float _BandWidth;
                                                                                                CBUFFER_END

                                                                                                    // Object and Global properties
                                                                                                    SAMPLER(SamplerState_Linear_Repeat);
                                                                                                    TEXTURE2D(_MainTex);
                                                                                                    SAMPLER(sampler_MainTex);

                                                                                                    // Graph Includes
                                                                                                    // GraphIncludes: <None>

                                                                                                    // -- Property used by ScenePickingPass
                                                                                                    #ifdef SCENEPICKINGPASS
                                                                                                    float4 _SelectionID;
                                                                                                    #endif

                                                                                                    // -- Properties used by SceneSelectionPass
                                                                                                    #ifdef SCENESELECTIONPASS
                                                                                                    int _ObjectId;
                                                                                                    int _PassValue;
                                                                                                    #endif

                                                                                                    // Graph Functions
                                                                                                    // GraphFunctions: <None>

                                                                                                    // Custom interpolators pre vertex
                                                                                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                                                    // Graph Vertex
                                                                                                    struct VertexDescription
                                                                                                    {
                                                                                                        float3 Position;
                                                                                                        float3 Normal;
                                                                                                        float3 Tangent;
                                                                                                    };

                                                                                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                                                    {
                                                                                                        VertexDescription description = (VertexDescription)0;
                                                                                                        description.Position = IN.ObjectSpacePosition;
                                                                                                        description.Normal = IN.ObjectSpaceNormal;
                                                                                                        description.Tangent = IN.ObjectSpaceTangent;
                                                                                                        return description;
                                                                                                    }

                                                                                                    // Custom interpolators, pre surface
                                                                                                    #ifdef FEATURES_GRAPH_VERTEX
                                                                                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                                                    {
                                                                                                    return output;
                                                                                                    }
                                                                                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                                                    #endif

                                                                                                    // Graph Pixel
                                                                                                    struct SurfaceDescription
                                                                                                    {
                                                                                                    };

                                                                                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                                                    {
                                                                                                        SurfaceDescription surface = (SurfaceDescription)0;
                                                                                                        return surface;
                                                                                                    }

                                                                                                    // --------------------------------------------------
                                                                                                    // Build Graph Inputs
                                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                                    #define VFX_SRP_ATTRIBUTES Attributes
                                                                                                    #define VFX_SRP_VARYINGS Varyings
                                                                                                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                                                    #endif
                                                                                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                                                    {
                                                                                                        VertexDescriptionInputs output;
                                                                                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                                        output.ObjectSpaceNormal = input.normalOS;
                                                                                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                                        output.ObjectSpacePosition = input.positionOS;

                                                                                                        return output;
                                                                                                    }
                                                                                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                                    {
                                                                                                        SurfaceDescriptionInputs output;
                                                                                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                                                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                                                    #endif







                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                                                    #else
                                                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                                                    #endif
                                                                                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                                            return output;
                                                                                                    }

                                                                                                    // --------------------------------------------------
                                                                                                    // Main

                                                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

                                                                                                    // --------------------------------------------------
                                                                                                    // Visual Effect Vertex Invocations
                                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                                                    #endif

                                                                                                    ENDHLSL
                                                                                                    }
                                                                                                    Pass
                                                                                                    {
                                                                                                        Name "DepthNormals"
                                                                                                        Tags
                                                                                                        {
                                                                                                            "LightMode" = "DepthNormals"
                                                                                                        }

                                                                                                        // Render State
                                                                                                        Cull Back
                                                                                                        ZTest LEqual
                                                                                                        ZWrite On

                                                                                                        // Debug
                                                                                                        // <None>

                                                                                                        // --------------------------------------------------
                                                                                                        // Pass

                                                                                                        HLSLPROGRAM

                                                                                                        // Pragmas
                                                                                                        #pragma target 2.0
                                                                                                        #pragma only_renderers gles gles3 glcore d3d11
                                                                                                        #pragma multi_compile_instancing
                                                                                                        #pragma vertex vert
                                                                                                        #pragma fragment frag

                                                                                                        // DotsInstancingOptions: <None>
                                                                                                        // HybridV1InjectedBuiltinProperties: <None>

                                                                                                        // Keywords
                                                                                                        // PassKeywords: <None>
                                                                                                        // GraphKeywords: <None>

                                                                                                        // Defines

                                                                                                        #define _NORMALMAP 1
                                                                                                        #define _NORMAL_DROPOFF_TS 1
                                                                                                        #define ATTRIBUTES_NEED_NORMAL
                                                                                                        #define ATTRIBUTES_NEED_TANGENT
                                                                                                        #define ATTRIBUTES_NEED_TEXCOORD1
                                                                                                        #define VARYINGS_NEED_NORMAL_WS
                                                                                                        #define VARYINGS_NEED_TANGENT_WS
                                                                                                        #define FEATURES_GRAPH_VERTEX
                                                                                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                                                        #define SHADERPASS SHADERPASS_DEPTHNORMALS
                                                                                                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                                                        // custom interpolator pre-include
                                                                                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                                                        // Includes
                                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                                                        // --------------------------------------------------
                                                                                                        // Structs and Packing

                                                                                                        // custom interpolators pre packing
                                                                                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                                                        struct Attributes
                                                                                                        {
                                                                                                             float3 positionOS : POSITION;
                                                                                                             float3 normalOS : NORMAL;
                                                                                                             float4 tangentOS : TANGENT;
                                                                                                             float4 uv1 : TEXCOORD1;
                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                             uint instanceID : INSTANCEID_SEMANTIC;
                                                                                                            #endif
                                                                                                        };
                                                                                                        struct Varyings
                                                                                                        {
                                                                                                             float4 positionCS : SV_POSITION;
                                                                                                             float3 normalWS;
                                                                                                             float4 tangentWS;
                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                            #endif
                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                            #endif
                                                                                                        };
                                                                                                        struct SurfaceDescriptionInputs
                                                                                                        {
                                                                                                             float3 TangentSpaceNormal;
                                                                                                        };
                                                                                                        struct VertexDescriptionInputs
                                                                                                        {
                                                                                                             float3 ObjectSpaceNormal;
                                                                                                             float3 ObjectSpaceTangent;
                                                                                                             float3 ObjectSpacePosition;
                                                                                                        };
                                                                                                        struct PackedVaryings
                                                                                                        {
                                                                                                             float4 positionCS : SV_POSITION;
                                                                                                             float3 interp0 : INTERP0;
                                                                                                             float4 interp1 : INTERP1;
                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                            #endif
                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                            #endif
                                                                                                        };

                                                                                                        PackedVaryings PackVaryings(Varyings input)
                                                                                                        {
                                                                                                            PackedVaryings output;
                                                                                                            ZERO_INITIALIZE(PackedVaryings, output);
                                                                                                            output.positionCS = input.positionCS;
                                                                                                            output.interp0.xyz = input.normalWS;
                                                                                                            output.interp1.xyzw = input.tangentWS;
                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                            output.instanceID = input.instanceID;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                            #endif
                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                            output.cullFace = input.cullFace;
                                                                                                            #endif
                                                                                                            return output;
                                                                                                        }

                                                                                                        Varyings UnpackVaryings(PackedVaryings input)
                                                                                                        {
                                                                                                            Varyings output;
                                                                                                            output.positionCS = input.positionCS;
                                                                                                            output.normalWS = input.interp0.xyz;
                                                                                                            output.tangentWS = input.interp1.xyzw;
                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                            output.instanceID = input.instanceID;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                            #endif
                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                            output.cullFace = input.cullFace;
                                                                                                            #endif
                                                                                                            return output;
                                                                                                        }


                                                                                                        // --------------------------------------------------
                                                                                                        // Graph

                                                                                                        // Graph Properties
                                                                                                        CBUFFER_START(UnityPerMaterial)
                                                                                                        float4 _SilhouetteColor;
                                                                                                        float _FillAmount;
                                                                                                        float2 _YBounds;
                                                                                                        float4 _Color;
                                                                                                        float4 _MainTex_TexelSize;
                                                                                                        float4 _BandColour;
                                                                                                        float _BandWidth;
                                                                                                        CBUFFER_END

                                                                                                            // Object and Global properties
                                                                                                            SAMPLER(SamplerState_Linear_Repeat);
                                                                                                            TEXTURE2D(_MainTex);
                                                                                                            SAMPLER(sampler_MainTex);

                                                                                                            // Graph Includes
                                                                                                            // GraphIncludes: <None>

                                                                                                            // -- Property used by ScenePickingPass
                                                                                                            #ifdef SCENEPICKINGPASS
                                                                                                            float4 _SelectionID;
                                                                                                            #endif

                                                                                                            // -- Properties used by SceneSelectionPass
                                                                                                            #ifdef SCENESELECTIONPASS
                                                                                                            int _ObjectId;
                                                                                                            int _PassValue;
                                                                                                            #endif

                                                                                                            // Graph Functions
                                                                                                            // GraphFunctions: <None>

                                                                                                            // Custom interpolators pre vertex
                                                                                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                                                            // Graph Vertex
                                                                                                            struct VertexDescription
                                                                                                            {
                                                                                                                float3 Position;
                                                                                                                float3 Normal;
                                                                                                                float3 Tangent;
                                                                                                            };

                                                                                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                                                            {
                                                                                                                VertexDescription description = (VertexDescription)0;
                                                                                                                description.Position = IN.ObjectSpacePosition;
                                                                                                                description.Normal = IN.ObjectSpaceNormal;
                                                                                                                description.Tangent = IN.ObjectSpaceTangent;
                                                                                                                return description;
                                                                                                            }

                                                                                                            // Custom interpolators, pre surface
                                                                                                            #ifdef FEATURES_GRAPH_VERTEX
                                                                                                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                                                            {
                                                                                                            return output;
                                                                                                            }
                                                                                                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                                                            #endif

                                                                                                            // Graph Pixel
                                                                                                            struct SurfaceDescription
                                                                                                            {
                                                                                                                float3 NormalTS;
                                                                                                            };

                                                                                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                                                            {
                                                                                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                                                                                surface.NormalTS = IN.TangentSpaceNormal;
                                                                                                                return surface;
                                                                                                            }

                                                                                                            // --------------------------------------------------
                                                                                                            // Build Graph Inputs
                                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                                            #define VFX_SRP_ATTRIBUTES Attributes
                                                                                                            #define VFX_SRP_VARYINGS Varyings
                                                                                                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                                                            #endif
                                                                                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                                                            {
                                                                                                                VertexDescriptionInputs output;
                                                                                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                                                output.ObjectSpaceNormal = input.normalOS;
                                                                                                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                                                output.ObjectSpacePosition = input.positionOS;

                                                                                                                return output;
                                                                                                            }
                                                                                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                                            {
                                                                                                                SurfaceDescriptionInputs output;
                                                                                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                                                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                                                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                                                            #endif





                                                                                                                output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                                                            #else
                                                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                                                            #endif
                                                                                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                                                    return output;
                                                                                                            }

                                                                                                            // --------------------------------------------------
                                                                                                            // Main

                                                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

                                                                                                            // --------------------------------------------------
                                                                                                            // Visual Effect Vertex Invocations
                                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                                                            #endif

                                                                                                            ENDHLSL
                                                                                                            }
                                                                                                            Pass
                                                                                                            {
                                                                                                                Name "Meta"
                                                                                                                Tags
                                                                                                                {
                                                                                                                    "LightMode" = "Meta"
                                                                                                                }

                                                                                                                // Render State
                                                                                                                Cull Off

                                                                                                                // Debug
                                                                                                                // <None>

                                                                                                                // --------------------------------------------------
                                                                                                                // Pass

                                                                                                                HLSLPROGRAM

                                                                                                                // Pragmas
                                                                                                                #pragma target 2.0
                                                                                                                #pragma only_renderers gles gles3 glcore d3d11
                                                                                                                #pragma vertex vert
                                                                                                                #pragma fragment frag

                                                                                                                // DotsInstancingOptions: <None>
                                                                                                                // HybridV1InjectedBuiltinProperties: <None>

                                                                                                                // Keywords
                                                                                                                #pragma shader_feature _ EDITOR_VISUALIZATION
                                                                                                                // GraphKeywords: <None>

                                                                                                                // Defines

                                                                                                                #define _NORMALMAP 1
                                                                                                                #define _NORMAL_DROPOFF_TS 1
                                                                                                                #define ATTRIBUTES_NEED_NORMAL
                                                                                                                #define ATTRIBUTES_NEED_TANGENT
                                                                                                                #define ATTRIBUTES_NEED_TEXCOORD0
                                                                                                                #define ATTRIBUTES_NEED_TEXCOORD1
                                                                                                                #define ATTRIBUTES_NEED_TEXCOORD2
                                                                                                                #define VARYINGS_NEED_POSITION_WS
                                                                                                                #define VARYINGS_NEED_TEXCOORD0
                                                                                                                #define VARYINGS_NEED_TEXCOORD1
                                                                                                                #define VARYINGS_NEED_TEXCOORD2
                                                                                                                #define FEATURES_GRAPH_VERTEX
                                                                                                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                                                                #define SHADERPASS SHADERPASS_META
                                                                                                                #define _FOG_FRAGMENT 1
                                                                                                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                                                                // custom interpolator pre-include
                                                                                                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                                                                // Includes
                                                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
                                                                                                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                                                                // --------------------------------------------------
                                                                                                                // Structs and Packing

                                                                                                                // custom interpolators pre packing
                                                                                                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                                                                struct Attributes
                                                                                                                {
                                                                                                                     float3 positionOS : POSITION;
                                                                                                                     float3 normalOS : NORMAL;
                                                                                                                     float4 tangentOS : TANGENT;
                                                                                                                     float4 uv0 : TEXCOORD0;
                                                                                                                     float4 uv1 : TEXCOORD1;
                                                                                                                     float4 uv2 : TEXCOORD2;
                                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                     uint instanceID : INSTANCEID_SEMANTIC;
                                                                                                                    #endif
                                                                                                                };
                                                                                                                struct Varyings
                                                                                                                {
                                                                                                                     float4 positionCS : SV_POSITION;
                                                                                                                     float3 positionWS;
                                                                                                                     float4 texCoord0;
                                                                                                                     float4 texCoord1;
                                                                                                                     float4 texCoord2;
                                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                                    #endif
                                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                                    #endif
                                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                                    #endif
                                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                                    #endif
                                                                                                                };
                                                                                                                struct SurfaceDescriptionInputs
                                                                                                                {
                                                                                                                     float3 WorldSpacePosition;
                                                                                                                     float4 uv0;
                                                                                                                };
                                                                                                                struct VertexDescriptionInputs
                                                                                                                {
                                                                                                                     float3 ObjectSpaceNormal;
                                                                                                                     float3 ObjectSpaceTangent;
                                                                                                                     float3 ObjectSpacePosition;
                                                                                                                };
                                                                                                                struct PackedVaryings
                                                                                                                {
                                                                                                                     float4 positionCS : SV_POSITION;
                                                                                                                     float3 interp0 : INTERP0;
                                                                                                                     float4 interp1 : INTERP1;
                                                                                                                     float4 interp2 : INTERP2;
                                                                                                                     float4 interp3 : INTERP3;
                                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                                    #endif
                                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                                    #endif
                                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                                    #endif
                                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                                    #endif
                                                                                                                };

                                                                                                                PackedVaryings PackVaryings(Varyings input)
                                                                                                                {
                                                                                                                    PackedVaryings output;
                                                                                                                    ZERO_INITIALIZE(PackedVaryings, output);
                                                                                                                    output.positionCS = input.positionCS;
                                                                                                                    output.interp0.xyz = input.positionWS;
                                                                                                                    output.interp1.xyzw = input.texCoord0;
                                                                                                                    output.interp2.xyzw = input.texCoord1;
                                                                                                                    output.interp3.xyzw = input.texCoord2;
                                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                    output.instanceID = input.instanceID;
                                                                                                                    #endif
                                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                                    #endif
                                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                                    #endif
                                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                    output.cullFace = input.cullFace;
                                                                                                                    #endif
                                                                                                                    return output;
                                                                                                                }

                                                                                                                Varyings UnpackVaryings(PackedVaryings input)
                                                                                                                {
                                                                                                                    Varyings output;
                                                                                                                    output.positionCS = input.positionCS;
                                                                                                                    output.positionWS = input.interp0.xyz;
                                                                                                                    output.texCoord0 = input.interp1.xyzw;
                                                                                                                    output.texCoord1 = input.interp2.xyzw;
                                                                                                                    output.texCoord2 = input.interp3.xyzw;
                                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                    output.instanceID = input.instanceID;
                                                                                                                    #endif
                                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                                    #endif
                                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                                    #endif
                                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                    output.cullFace = input.cullFace;
                                                                                                                    #endif
                                                                                                                    return output;
                                                                                                                }


                                                                                                                // --------------------------------------------------
                                                                                                                // Graph

                                                                                                                // Graph Properties
                                                                                                                CBUFFER_START(UnityPerMaterial)
                                                                                                                float4 _SilhouetteColor;
                                                                                                                float _FillAmount;
                                                                                                                float2 _YBounds;
                                                                                                                float4 _Color;
                                                                                                                float4 _MainTex_TexelSize;
                                                                                                                float4 _BandColour;
                                                                                                                float _BandWidth;
                                                                                                                CBUFFER_END

                                                                                                                    // Object and Global properties
                                                                                                                    SAMPLER(SamplerState_Linear_Repeat);
                                                                                                                    TEXTURE2D(_MainTex);
                                                                                                                    SAMPLER(sampler_MainTex);

                                                                                                                    // Graph Includes
                                                                                                                    // GraphIncludes: <None>

                                                                                                                    // -- Property used by ScenePickingPass
                                                                                                                    #ifdef SCENEPICKINGPASS
                                                                                                                    float4 _SelectionID;
                                                                                                                    #endif

                                                                                                                    // -- Properties used by SceneSelectionPass
                                                                                                                    #ifdef SCENESELECTIONPASS
                                                                                                                    int _ObjectId;
                                                                                                                    int _PassValue;
                                                                                                                    #endif

                                                                                                                    // Graph Functions

                                                                                                                    void Unity_InverseLerp_float(float A, float B, float T, out float Out)
                                                                                                                    {
                                                                                                                        Out = (T - A) / (B - A);
                                                                                                                    }

                                                                                                                    void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                                                                                                                    {
                                                                                                                        Out = clamp(In, Min, Max);
                                                                                                                    }

                                                                                                                    void Unity_OneMinus_float(float In, out float Out)
                                                                                                                    {
                                                                                                                        Out = 1 - In;
                                                                                                                    }

                                                                                                                    void Unity_Comparison_LessOrEqual_float(float A, float B, out float Out)
                                                                                                                    {
                                                                                                                        Out = A <= B ? 1 : 0;
                                                                                                                    }

                                                                                                                    void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
                                                                                                                    {
                                                                                                                        Out = Predicate ? True : False;
                                                                                                                    }

                                                                                                                    void Unity_Subtract_float(float A, float B, out float Out)
                                                                                                                    {
                                                                                                                        Out = A - B;
                                                                                                                    }

                                                                                                                    void Unity_Comparison_GreaterOrEqual_float(float A, float B, out float Out)
                                                                                                                    {
                                                                                                                        Out = A >= B ? 1 : 0;
                                                                                                                    }

                                                                                                                    void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                                                                                                                    {
                                                                                                                        Out = A * B;
                                                                                                                    }

                                                                                                                    void Unity_OneMinus_float4(float4 In, out float4 Out)
                                                                                                                    {
                                                                                                                        Out = 1 - In;
                                                                                                                    }

                                                                                                                    void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                                                                                                                    {
                                                                                                                        Out = A + B;
                                                                                                                    }

                                                                                                                    // Custom interpolators pre vertex
                                                                                                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                                                                    // Graph Vertex
                                                                                                                    struct VertexDescription
                                                                                                                    {
                                                                                                                        float3 Position;
                                                                                                                        float3 Normal;
                                                                                                                        float3 Tangent;
                                                                                                                    };

                                                                                                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                                                                    {
                                                                                                                        VertexDescription description = (VertexDescription)0;
                                                                                                                        description.Position = IN.ObjectSpacePosition;
                                                                                                                        description.Normal = IN.ObjectSpaceNormal;
                                                                                                                        description.Tangent = IN.ObjectSpaceTangent;
                                                                                                                        return description;
                                                                                                                    }

                                                                                                                    // Custom interpolators, pre surface
                                                                                                                    #ifdef FEATURES_GRAPH_VERTEX
                                                                                                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                                                                    {
                                                                                                                    return output;
                                                                                                                    }
                                                                                                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                                                                    #endif

                                                                                                                    // Graph Pixel
                                                                                                                    struct SurfaceDescription
                                                                                                                    {
                                                                                                                        float3 BaseColor;
                                                                                                                        float3 Emission;
                                                                                                                    };

                                                                                                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                                                                    {
                                                                                                                        SurfaceDescription surface = (SurfaceDescription)0;
                                                                                                                        float2 _Property_0b4e504a5c134a12bffe4e99027c07fd_Out_0 = _YBounds;
                                                                                                                        float _Swizzle_8918e71ab58c48c385adfdce3517a5c1_Out_1 = _Property_0b4e504a5c134a12bffe4e99027c07fd_Out_0.y;
                                                                                                                        float _Swizzle_c1acb2fe87c442a78bcdefb08d7b0cdd_Out_1 = _Property_0b4e504a5c134a12bffe4e99027c07fd_Out_0.x;
                                                                                                                        float _Swizzle_c206262ecebe4fdba18ddd36ad5598c0_Out_1 = IN.WorldSpacePosition.y;
                                                                                                                        float _InverseLerp_ea18fe2319fe4c66b2253b5a34d8a5fd_Out_3;
                                                                                                                        Unity_InverseLerp_float(_Swizzle_8918e71ab58c48c385adfdce3517a5c1_Out_1, _Swizzle_c1acb2fe87c442a78bcdefb08d7b0cdd_Out_1, _Swizzle_c206262ecebe4fdba18ddd36ad5598c0_Out_1, _InverseLerp_ea18fe2319fe4c66b2253b5a34d8a5fd_Out_3);
                                                                                                                        float _Clamp_c290813c4e624385b85d86cc7c10e4d6_Out_3;
                                                                                                                        Unity_Clamp_float(_InverseLerp_ea18fe2319fe4c66b2253b5a34d8a5fd_Out_3, 0, 1, _Clamp_c290813c4e624385b85d86cc7c10e4d6_Out_3);
                                                                                                                        float _OneMinus_dd9197a7d62f4634bbd451af30c476bf_Out_1;
                                                                                                                        Unity_OneMinus_float(_Clamp_c290813c4e624385b85d86cc7c10e4d6_Out_3, _OneMinus_dd9197a7d62f4634bbd451af30c476bf_Out_1);
                                                                                                                        float _Property_16dd2c1c35774d9c9bbdda71653a43f6_Out_0 = _FillAmount;
                                                                                                                        float _Comparison_dcea135e70a444c5aa73a81b84a98e02_Out_2;
                                                                                                                        Unity_Comparison_LessOrEqual_float(_OneMinus_dd9197a7d62f4634bbd451af30c476bf_Out_1, _Property_16dd2c1c35774d9c9bbdda71653a43f6_Out_0, _Comparison_dcea135e70a444c5aa73a81b84a98e02_Out_2);
                                                                                                                        float4 _Property_94bf0d4982514359b26405a57f6e228e_Out_0 = _Color;
                                                                                                                        float4 _Property_b930a03aaff4459dad251a909414afb2_Out_0 = _SilhouetteColor;
                                                                                                                        float4 _Branch_fe9c129de18844e9ba1dafcf701fc1f5_Out_3;
                                                                                                                        Unity_Branch_float4(_Comparison_dcea135e70a444c5aa73a81b84a98e02_Out_2, _Property_94bf0d4982514359b26405a57f6e228e_Out_0, _Property_b930a03aaff4459dad251a909414afb2_Out_0, _Branch_fe9c129de18844e9ba1dafcf701fc1f5_Out_3);
                                                                                                                        float _Property_b647961b6a5e41e3b128e7d138d26bbf_Out_0 = _BandWidth;
                                                                                                                        float _Subtract_d83f2f4283004dbb8ef2976ad239dcbb_Out_2;
                                                                                                                        Unity_Subtract_float(_Property_16dd2c1c35774d9c9bbdda71653a43f6_Out_0, _Property_b647961b6a5e41e3b128e7d138d26bbf_Out_0, _Subtract_d83f2f4283004dbb8ef2976ad239dcbb_Out_2);
                                                                                                                        float _Comparison_6c3528b2e67742458dcad2c1d9123206_Out_2;
                                                                                                                        Unity_Comparison_GreaterOrEqual_float(_OneMinus_dd9197a7d62f4634bbd451af30c476bf_Out_1, _Subtract_d83f2f4283004dbb8ef2976ad239dcbb_Out_2, _Comparison_6c3528b2e67742458dcad2c1d9123206_Out_2);
                                                                                                                        float4 _Branch_37b2d57601fd44fd9d02a5eecafa4598_Out_3;
                                                                                                                        Unity_Branch_float4(_Comparison_6c3528b2e67742458dcad2c1d9123206_Out_2, _Property_94bf0d4982514359b26405a57f6e228e_Out_0, float4(0, 0, 0, 0), _Branch_37b2d57601fd44fd9d02a5eecafa4598_Out_3);
                                                                                                                        float4 _Multiply_8f6eca7a3a004e1bb7bb5bc8b02dc8cb_Out_2;
                                                                                                                        Unity_Multiply_float4_float4(_Branch_fe9c129de18844e9ba1dafcf701fc1f5_Out_3, _Branch_37b2d57601fd44fd9d02a5eecafa4598_Out_3, _Multiply_8f6eca7a3a004e1bb7bb5bc8b02dc8cb_Out_2);
                                                                                                                        float4 _Property_665c2bda7053418092ddc78c9b230846_Out_0 = _BandColour;
                                                                                                                        float4 _Multiply_80f3f98c40c747cfac316465edd63a2f_Out_2;
                                                                                                                        Unity_Multiply_float4_float4(_Multiply_8f6eca7a3a004e1bb7bb5bc8b02dc8cb_Out_2, _Property_665c2bda7053418092ddc78c9b230846_Out_0, _Multiply_80f3f98c40c747cfac316465edd63a2f_Out_2);
                                                                                                                        float4 _OneMinus_9b0bae6729ce46b1bd920238dc7a064e_Out_1;
                                                                                                                        Unity_OneMinus_float4(_Branch_37b2d57601fd44fd9d02a5eecafa4598_Out_3, _OneMinus_9b0bae6729ce46b1bd920238dc7a064e_Out_1);
                                                                                                                        float4 _Add_a846e3cc418140c3bf1b27f660cd7ba4_Out_2;
                                                                                                                        Unity_Add_float4(_Multiply_80f3f98c40c747cfac316465edd63a2f_Out_2, _OneMinus_9b0bae6729ce46b1bd920238dc7a064e_Out_1, _Add_a846e3cc418140c3bf1b27f660cd7ba4_Out_2);
                                                                                                                        UnityTexture2D _Property_0c7380d416f643088cd6f223277a1d87_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
                                                                                                                        float4 _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_RGBA_0 = SAMPLE_TEXTURE2D(_Property_0c7380d416f643088cd6f223277a1d87_Out_0.tex, _Property_0c7380d416f643088cd6f223277a1d87_Out_0.samplerstate, _Property_0c7380d416f643088cd6f223277a1d87_Out_0.GetTransformedUV(IN.uv0.xy));
                                                                                                                        float _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_R_4 = _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_RGBA_0.r;
                                                                                                                        float _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_G_5 = _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_RGBA_0.g;
                                                                                                                        float _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_B_6 = _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_RGBA_0.b;
                                                                                                                        float _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_A_7 = _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_RGBA_0.a;
                                                                                                                        float4 _Multiply_d2e9657dc3154f43a0fe0f8d33b46f14_Out_2;
                                                                                                                        Unity_Multiply_float4_float4(_SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_RGBA_0, _OneMinus_9b0bae6729ce46b1bd920238dc7a064e_Out_1, _Multiply_d2e9657dc3154f43a0fe0f8d33b46f14_Out_2);
                                                                                                                        float4 _OneMinus_d702c615cb6a4d93a374d272c8ad4b87_Out_1;
                                                                                                                        Unity_OneMinus_float4(_OneMinus_9b0bae6729ce46b1bd920238dc7a064e_Out_1, _OneMinus_d702c615cb6a4d93a374d272c8ad4b87_Out_1);
                                                                                                                        float4 _Add_1eaa704a333b4ebdbaf364697a0bec42_Out_2;
                                                                                                                        Unity_Add_float4(_Multiply_d2e9657dc3154f43a0fe0f8d33b46f14_Out_2, _OneMinus_d702c615cb6a4d93a374d272c8ad4b87_Out_1, _Add_1eaa704a333b4ebdbaf364697a0bec42_Out_2);
                                                                                                                        float4 _Multiply_0702241a7980465bb8edf3998a7bbf1b_Out_2;
                                                                                                                        Unity_Multiply_float4_float4(_Add_a846e3cc418140c3bf1b27f660cd7ba4_Out_2, _Add_1eaa704a333b4ebdbaf364697a0bec42_Out_2, _Multiply_0702241a7980465bb8edf3998a7bbf1b_Out_2);
                                                                                                                        surface.BaseColor = (_Multiply_0702241a7980465bb8edf3998a7bbf1b_Out_2.xyz);
                                                                                                                        surface.Emission = float3(0, 0, 0);
                                                                                                                        return surface;
                                                                                                                    }

                                                                                                                    // --------------------------------------------------
                                                                                                                    // Build Graph Inputs
                                                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                                                    #define VFX_SRP_ATTRIBUTES Attributes
                                                                                                                    #define VFX_SRP_VARYINGS Varyings
                                                                                                                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                                                                    #endif
                                                                                                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                                                                    {
                                                                                                                        VertexDescriptionInputs output;
                                                                                                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                                                        output.ObjectSpaceNormal = input.normalOS;
                                                                                                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                                                        output.ObjectSpacePosition = input.positionOS;

                                                                                                                        return output;
                                                                                                                    }
                                                                                                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                                                    {
                                                                                                                        SurfaceDescriptionInputs output;
                                                                                                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                                                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                                                                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                                                                    #endif







                                                                                                                        output.WorldSpacePosition = input.positionWS;
                                                                                                                        output.uv0 = input.texCoord0;
                                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                                                                    #else
                                                                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                                                                    #endif
                                                                                                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                                                            return output;
                                                                                                                    }

                                                                                                                    // --------------------------------------------------
                                                                                                                    // Main

                                                                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

                                                                                                                    // --------------------------------------------------
                                                                                                                    // Visual Effect Vertex Invocations
                                                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                                                                    #endif

                                                                                                                    ENDHLSL
                                                                                                                    }
                                                                                                                    Pass
                                                                                                                    {
                                                                                                                        Name "SceneSelectionPass"
                                                                                                                        Tags
                                                                                                                        {
                                                                                                                            "LightMode" = "SceneSelectionPass"
                                                                                                                        }

                                                                                                                        // Render State
                                                                                                                        Cull Off

                                                                                                                        // Debug
                                                                                                                        // <None>

                                                                                                                        // --------------------------------------------------
                                                                                                                        // Pass

                                                                                                                        HLSLPROGRAM

                                                                                                                        // Pragmas
                                                                                                                        #pragma target 2.0
                                                                                                                        #pragma only_renderers gles gles3 glcore d3d11
                                                                                                                        #pragma multi_compile_instancing
                                                                                                                        #pragma vertex vert
                                                                                                                        #pragma fragment frag

                                                                                                                        // DotsInstancingOptions: <None>
                                                                                                                        // HybridV1InjectedBuiltinProperties: <None>

                                                                                                                        // Keywords
                                                                                                                        // PassKeywords: <None>
                                                                                                                        // GraphKeywords: <None>

                                                                                                                        // Defines

                                                                                                                        #define _NORMALMAP 1
                                                                                                                        #define _NORMAL_DROPOFF_TS 1
                                                                                                                        #define ATTRIBUTES_NEED_NORMAL
                                                                                                                        #define ATTRIBUTES_NEED_TANGENT
                                                                                                                        #define FEATURES_GRAPH_VERTEX
                                                                                                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                                                                        #define SHADERPASS SHADERPASS_DEPTHONLY
                                                                                                                        #define SCENESELECTIONPASS 1
                                                                                                                        #define ALPHA_CLIP_THRESHOLD 1
                                                                                                                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                                                                        // custom interpolator pre-include
                                                                                                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                                                                        // Includes
                                                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                                                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                                                                        // --------------------------------------------------
                                                                                                                        // Structs and Packing

                                                                                                                        // custom interpolators pre packing
                                                                                                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                                                                        struct Attributes
                                                                                                                        {
                                                                                                                             float3 positionOS : POSITION;
                                                                                                                             float3 normalOS : NORMAL;
                                                                                                                             float4 tangentOS : TANGENT;
                                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                             uint instanceID : INSTANCEID_SEMANTIC;
                                                                                                                            #endif
                                                                                                                        };
                                                                                                                        struct Varyings
                                                                                                                        {
                                                                                                                             float4 positionCS : SV_POSITION;
                                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                                            #endif
                                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                                            #endif
                                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                                            #endif
                                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                                            #endif
                                                                                                                        };
                                                                                                                        struct SurfaceDescriptionInputs
                                                                                                                        {
                                                                                                                        };
                                                                                                                        struct VertexDescriptionInputs
                                                                                                                        {
                                                                                                                             float3 ObjectSpaceNormal;
                                                                                                                             float3 ObjectSpaceTangent;
                                                                                                                             float3 ObjectSpacePosition;
                                                                                                                        };
                                                                                                                        struct PackedVaryings
                                                                                                                        {
                                                                                                                             float4 positionCS : SV_POSITION;
                                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                                            #endif
                                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                                            #endif
                                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                                            #endif
                                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                                            #endif
                                                                                                                        };

                                                                                                                        PackedVaryings PackVaryings(Varyings input)
                                                                                                                        {
                                                                                                                            PackedVaryings output;
                                                                                                                            ZERO_INITIALIZE(PackedVaryings, output);
                                                                                                                            output.positionCS = input.positionCS;
                                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                            output.instanceID = input.instanceID;
                                                                                                                            #endif
                                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                                            #endif
                                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                                            #endif
                                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                            output.cullFace = input.cullFace;
                                                                                                                            #endif
                                                                                                                            return output;
                                                                                                                        }

                                                                                                                        Varyings UnpackVaryings(PackedVaryings input)
                                                                                                                        {
                                                                                                                            Varyings output;
                                                                                                                            output.positionCS = input.positionCS;
                                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                            output.instanceID = input.instanceID;
                                                                                                                            #endif
                                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                                            #endif
                                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                                            #endif
                                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                            output.cullFace = input.cullFace;
                                                                                                                            #endif
                                                                                                                            return output;
                                                                                                                        }


                                                                                                                        // --------------------------------------------------
                                                                                                                        // Graph

                                                                                                                        // Graph Properties
                                                                                                                        CBUFFER_START(UnityPerMaterial)
                                                                                                                        float4 _SilhouetteColor;
                                                                                                                        float _FillAmount;
                                                                                                                        float2 _YBounds;
                                                                                                                        float4 _Color;
                                                                                                                        float4 _MainTex_TexelSize;
                                                                                                                        float4 _BandColour;
                                                                                                                        float _BandWidth;
                                                                                                                        CBUFFER_END

                                                                                                                            // Object and Global properties
                                                                                                                            SAMPLER(SamplerState_Linear_Repeat);
                                                                                                                            TEXTURE2D(_MainTex);
                                                                                                                            SAMPLER(sampler_MainTex);

                                                                                                                            // Graph Includes
                                                                                                                            // GraphIncludes: <None>

                                                                                                                            // -- Property used by ScenePickingPass
                                                                                                                            #ifdef SCENEPICKINGPASS
                                                                                                                            float4 _SelectionID;
                                                                                                                            #endif

                                                                                                                            // -- Properties used by SceneSelectionPass
                                                                                                                            #ifdef SCENESELECTIONPASS
                                                                                                                            int _ObjectId;
                                                                                                                            int _PassValue;
                                                                                                                            #endif

                                                                                                                            // Graph Functions
                                                                                                                            // GraphFunctions: <None>

                                                                                                                            // Custom interpolators pre vertex
                                                                                                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                                                                            // Graph Vertex
                                                                                                                            struct VertexDescription
                                                                                                                            {
                                                                                                                                float3 Position;
                                                                                                                                float3 Normal;
                                                                                                                                float3 Tangent;
                                                                                                                            };

                                                                                                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                                                                            {
                                                                                                                                VertexDescription description = (VertexDescription)0;
                                                                                                                                description.Position = IN.ObjectSpacePosition;
                                                                                                                                description.Normal = IN.ObjectSpaceNormal;
                                                                                                                                description.Tangent = IN.ObjectSpaceTangent;
                                                                                                                                return description;
                                                                                                                            }

                                                                                                                            // Custom interpolators, pre surface
                                                                                                                            #ifdef FEATURES_GRAPH_VERTEX
                                                                                                                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                                                                            {
                                                                                                                            return output;
                                                                                                                            }
                                                                                                                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                                                                            #endif

                                                                                                                            // Graph Pixel
                                                                                                                            struct SurfaceDescription
                                                                                                                            {
                                                                                                                            };

                                                                                                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                                                                            {
                                                                                                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                                                                                                return surface;
                                                                                                                            }

                                                                                                                            // --------------------------------------------------
                                                                                                                            // Build Graph Inputs
                                                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                                                            #define VFX_SRP_ATTRIBUTES Attributes
                                                                                                                            #define VFX_SRP_VARYINGS Varyings
                                                                                                                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                                                                            #endif
                                                                                                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                                                                            {
                                                                                                                                VertexDescriptionInputs output;
                                                                                                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                                                                output.ObjectSpaceNormal = input.normalOS;
                                                                                                                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                                                                output.ObjectSpacePosition = input.positionOS;

                                                                                                                                return output;
                                                                                                                            }
                                                                                                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                                                            {
                                                                                                                                SurfaceDescriptionInputs output;
                                                                                                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                                                                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                                                                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                                                                            #endif







                                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                                                                            #else
                                                                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                                                                            #endif
                                                                                                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                                                                    return output;
                                                                                                                            }

                                                                                                                            // --------------------------------------------------
                                                                                                                            // Main

                                                                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

                                                                                                                            // --------------------------------------------------
                                                                                                                            // Visual Effect Vertex Invocations
                                                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                                                                            #endif

                                                                                                                            ENDHLSL
                                                                                                                            }
                                                                                                                            Pass
                                                                                                                            {
                                                                                                                                Name "ScenePickingPass"
                                                                                                                                Tags
                                                                                                                                {
                                                                                                                                    "LightMode" = "Picking"
                                                                                                                                }

                                                                                                                                // Render State
                                                                                                                                Cull Back

                                                                                                                                // Debug
                                                                                                                                // <None>

                                                                                                                                // --------------------------------------------------
                                                                                                                                // Pass

                                                                                                                                HLSLPROGRAM

                                                                                                                                // Pragmas
                                                                                                                                #pragma target 2.0
                                                                                                                                #pragma only_renderers gles gles3 glcore d3d11
                                                                                                                                #pragma multi_compile_instancing
                                                                                                                                #pragma vertex vert
                                                                                                                                #pragma fragment frag

                                                                                                                                // DotsInstancingOptions: <None>
                                                                                                                                // HybridV1InjectedBuiltinProperties: <None>

                                                                                                                                // Keywords
                                                                                                                                // PassKeywords: <None>
                                                                                                                                // GraphKeywords: <None>

                                                                                                                                // Defines

                                                                                                                                #define _NORMALMAP 1
                                                                                                                                #define _NORMAL_DROPOFF_TS 1
                                                                                                                                #define ATTRIBUTES_NEED_NORMAL
                                                                                                                                #define ATTRIBUTES_NEED_TANGENT
                                                                                                                                #define FEATURES_GRAPH_VERTEX
                                                                                                                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                                                                                #define SHADERPASS SHADERPASS_DEPTHONLY
                                                                                                                                #define SCENEPICKINGPASS 1
                                                                                                                                #define ALPHA_CLIP_THRESHOLD 1
                                                                                                                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                                                                                // custom interpolator pre-include
                                                                                                                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                                                                                // Includes
                                                                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                                                                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                                                                                // --------------------------------------------------
                                                                                                                                // Structs and Packing

                                                                                                                                // custom interpolators pre packing
                                                                                                                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                                                                                struct Attributes
                                                                                                                                {
                                                                                                                                     float3 positionOS : POSITION;
                                                                                                                                     float3 normalOS : NORMAL;
                                                                                                                                     float4 tangentOS : TANGENT;
                                                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                                     uint instanceID : INSTANCEID_SEMANTIC;
                                                                                                                                    #endif
                                                                                                                                };
                                                                                                                                struct Varyings
                                                                                                                                {
                                                                                                                                     float4 positionCS : SV_POSITION;
                                                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                                                    #endif
                                                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                                                    #endif
                                                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                                                    #endif
                                                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                                                    #endif
                                                                                                                                };
                                                                                                                                struct SurfaceDescriptionInputs
                                                                                                                                {
                                                                                                                                };
                                                                                                                                struct VertexDescriptionInputs
                                                                                                                                {
                                                                                                                                     float3 ObjectSpaceNormal;
                                                                                                                                     float3 ObjectSpaceTangent;
                                                                                                                                     float3 ObjectSpacePosition;
                                                                                                                                };
                                                                                                                                struct PackedVaryings
                                                                                                                                {
                                                                                                                                     float4 positionCS : SV_POSITION;
                                                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                                                    #endif
                                                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                                                    #endif
                                                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                                                    #endif
                                                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                                                    #endif
                                                                                                                                };

                                                                                                                                PackedVaryings PackVaryings(Varyings input)
                                                                                                                                {
                                                                                                                                    PackedVaryings output;
                                                                                                                                    ZERO_INITIALIZE(PackedVaryings, output);
                                                                                                                                    output.positionCS = input.positionCS;
                                                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                                    output.instanceID = input.instanceID;
                                                                                                                                    #endif
                                                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                                                    #endif
                                                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                                                    #endif
                                                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                                    output.cullFace = input.cullFace;
                                                                                                                                    #endif
                                                                                                                                    return output;
                                                                                                                                }

                                                                                                                                Varyings UnpackVaryings(PackedVaryings input)
                                                                                                                                {
                                                                                                                                    Varyings output;
                                                                                                                                    output.positionCS = input.positionCS;
                                                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                                    output.instanceID = input.instanceID;
                                                                                                                                    #endif
                                                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                                                    #endif
                                                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                                                    #endif
                                                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                                    output.cullFace = input.cullFace;
                                                                                                                                    #endif
                                                                                                                                    return output;
                                                                                                                                }


                                                                                                                                // --------------------------------------------------
                                                                                                                                // Graph

                                                                                                                                // Graph Properties
                                                                                                                                CBUFFER_START(UnityPerMaterial)
                                                                                                                                float4 _SilhouetteColor;
                                                                                                                                float _FillAmount;
                                                                                                                                float2 _YBounds;
                                                                                                                                float4 _Color;
                                                                                                                                float4 _MainTex_TexelSize;
                                                                                                                                float4 _BandColour;
                                                                                                                                float _BandWidth;
                                                                                                                                CBUFFER_END

                                                                                                                                    // Object and Global properties
                                                                                                                                    SAMPLER(SamplerState_Linear_Repeat);
                                                                                                                                    TEXTURE2D(_MainTex);
                                                                                                                                    SAMPLER(sampler_MainTex);

                                                                                                                                    // Graph Includes
                                                                                                                                    // GraphIncludes: <None>

                                                                                                                                    // -- Property used by ScenePickingPass
                                                                                                                                    #ifdef SCENEPICKINGPASS
                                                                                                                                    float4 _SelectionID;
                                                                                                                                    #endif

                                                                                                                                    // -- Properties used by SceneSelectionPass
                                                                                                                                    #ifdef SCENESELECTIONPASS
                                                                                                                                    int _ObjectId;
                                                                                                                                    int _PassValue;
                                                                                                                                    #endif

                                                                                                                                    // Graph Functions
                                                                                                                                    // GraphFunctions: <None>

                                                                                                                                    // Custom interpolators pre vertex
                                                                                                                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                                                                                    // Graph Vertex
                                                                                                                                    struct VertexDescription
                                                                                                                                    {
                                                                                                                                        float3 Position;
                                                                                                                                        float3 Normal;
                                                                                                                                        float3 Tangent;
                                                                                                                                    };

                                                                                                                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                                                                                    {
                                                                                                                                        VertexDescription description = (VertexDescription)0;
                                                                                                                                        description.Position = IN.ObjectSpacePosition;
                                                                                                                                        description.Normal = IN.ObjectSpaceNormal;
                                                                                                                                        description.Tangent = IN.ObjectSpaceTangent;
                                                                                                                                        return description;
                                                                                                                                    }

                                                                                                                                    // Custom interpolators, pre surface
                                                                                                                                    #ifdef FEATURES_GRAPH_VERTEX
                                                                                                                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                                                                                    {
                                                                                                                                    return output;
                                                                                                                                    }
                                                                                                                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                                                                                    #endif

                                                                                                                                    // Graph Pixel
                                                                                                                                    struct SurfaceDescription
                                                                                                                                    {
                                                                                                                                    };

                                                                                                                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                                                                                    {
                                                                                                                                        SurfaceDescription surface = (SurfaceDescription)0;
                                                                                                                                        return surface;
                                                                                                                                    }

                                                                                                                                    // --------------------------------------------------
                                                                                                                                    // Build Graph Inputs
                                                                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                                                                    #define VFX_SRP_ATTRIBUTES Attributes
                                                                                                                                    #define VFX_SRP_VARYINGS Varyings
                                                                                                                                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                                                                                    #endif
                                                                                                                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                                                                                    {
                                                                                                                                        VertexDescriptionInputs output;
                                                                                                                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                                                                        output.ObjectSpaceNormal = input.normalOS;
                                                                                                                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                                                                        output.ObjectSpacePosition = input.positionOS;

                                                                                                                                        return output;
                                                                                                                                    }
                                                                                                                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                                                                    {
                                                                                                                                        SurfaceDescriptionInputs output;
                                                                                                                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                                                                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                                                                                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                                                                                    #endif







                                                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                                                                                    #else
                                                                                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                                                                                    #endif
                                                                                                                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                                                                            return output;
                                                                                                                                    }

                                                                                                                                    // --------------------------------------------------
                                                                                                                                    // Main

                                                                                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

                                                                                                                                    // --------------------------------------------------
                                                                                                                                    // Visual Effect Vertex Invocations
                                                                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                                                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                                                                                    #endif

                                                                                                                                    ENDHLSL
                                                                                                                                    }
                                                                                                                                    Pass
                                                                                                                                    {
                                                                                                                                        // Name: <None>
                                                                                                                                        Tags
                                                                                                                                        {
                                                                                                                                            "LightMode" = "Universal2D"
                                                                                                                                        }

                                                                                                                                        // Render State
                                                                                                                                        Cull Back
                                                                                                                                        Blend One Zero
                                                                                                                                        ZTest LEqual
                                                                                                                                        ZWrite On

                                                                                                                                        // Debug
                                                                                                                                        // <None>

                                                                                                                                        // --------------------------------------------------
                                                                                                                                        // Pass

                                                                                                                                        HLSLPROGRAM

                                                                                                                                        // Pragmas
                                                                                                                                        #pragma target 2.0
                                                                                                                                        #pragma only_renderers gles gles3 glcore d3d11
                                                                                                                                        #pragma multi_compile_instancing
                                                                                                                                        #pragma vertex vert
                                                                                                                                        #pragma fragment frag

                                                                                                                                        // DotsInstancingOptions: <None>
                                                                                                                                        // HybridV1InjectedBuiltinProperties: <None>

                                                                                                                                        // Keywords
                                                                                                                                        // PassKeywords: <None>
                                                                                                                                        // GraphKeywords: <None>

                                                                                                                                        // Defines

                                                                                                                                        #define _NORMALMAP 1
                                                                                                                                        #define _NORMAL_DROPOFF_TS 1
                                                                                                                                        #define ATTRIBUTES_NEED_NORMAL
                                                                                                                                        #define ATTRIBUTES_NEED_TANGENT
                                                                                                                                        #define ATTRIBUTES_NEED_TEXCOORD0
                                                                                                                                        #define VARYINGS_NEED_POSITION_WS
                                                                                                                                        #define VARYINGS_NEED_TEXCOORD0
                                                                                                                                        #define FEATURES_GRAPH_VERTEX
                                                                                                                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                                                                                        #define SHADERPASS SHADERPASS_2D
                                                                                                                                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                                                                                        // custom interpolator pre-include
                                                                                                                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                                                                                        // Includes
                                                                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                                                                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                                                                                        // --------------------------------------------------
                                                                                                                                        // Structs and Packing

                                                                                                                                        // custom interpolators pre packing
                                                                                                                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                                                                                        struct Attributes
                                                                                                                                        {
                                                                                                                                             float3 positionOS : POSITION;
                                                                                                                                             float3 normalOS : NORMAL;
                                                                                                                                             float4 tangentOS : TANGENT;
                                                                                                                                             float4 uv0 : TEXCOORD0;
                                                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                                             uint instanceID : INSTANCEID_SEMANTIC;
                                                                                                                                            #endif
                                                                                                                                        };
                                                                                                                                        struct Varyings
                                                                                                                                        {
                                                                                                                                             float4 positionCS : SV_POSITION;
                                                                                                                                             float3 positionWS;
                                                                                                                                             float4 texCoord0;
                                                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                                                            #endif
                                                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                                                            #endif
                                                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                                                            #endif
                                                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                                                            #endif
                                                                                                                                        };
                                                                                                                                        struct SurfaceDescriptionInputs
                                                                                                                                        {
                                                                                                                                             float3 WorldSpacePosition;
                                                                                                                                             float4 uv0;
                                                                                                                                        };
                                                                                                                                        struct VertexDescriptionInputs
                                                                                                                                        {
                                                                                                                                             float3 ObjectSpaceNormal;
                                                                                                                                             float3 ObjectSpaceTangent;
                                                                                                                                             float3 ObjectSpacePosition;
                                                                                                                                        };
                                                                                                                                        struct PackedVaryings
                                                                                                                                        {
                                                                                                                                             float4 positionCS : SV_POSITION;
                                                                                                                                             float3 interp0 : INTERP0;
                                                                                                                                             float4 interp1 : INTERP1;
                                                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                                                            #endif
                                                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                                                            #endif
                                                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                                                            #endif
                                                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                                                            #endif
                                                                                                                                        };

                                                                                                                                        PackedVaryings PackVaryings(Varyings input)
                                                                                                                                        {
                                                                                                                                            PackedVaryings output;
                                                                                                                                            ZERO_INITIALIZE(PackedVaryings, output);
                                                                                                                                            output.positionCS = input.positionCS;
                                                                                                                                            output.interp0.xyz = input.positionWS;
                                                                                                                                            output.interp1.xyzw = input.texCoord0;
                                                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                                            output.instanceID = input.instanceID;
                                                                                                                                            #endif
                                                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                                                            #endif
                                                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                                                            #endif
                                                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                                            output.cullFace = input.cullFace;
                                                                                                                                            #endif
                                                                                                                                            return output;
                                                                                                                                        }

                                                                                                                                        Varyings UnpackVaryings(PackedVaryings input)
                                                                                                                                        {
                                                                                                                                            Varyings output;
                                                                                                                                            output.positionCS = input.positionCS;
                                                                                                                                            output.positionWS = input.interp0.xyz;
                                                                                                                                            output.texCoord0 = input.interp1.xyzw;
                                                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                                            output.instanceID = input.instanceID;
                                                                                                                                            #endif
                                                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                                                            #endif
                                                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                                                            #endif
                                                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                                            output.cullFace = input.cullFace;
                                                                                                                                            #endif
                                                                                                                                            return output;
                                                                                                                                        }


                                                                                                                                        // --------------------------------------------------
                                                                                                                                        // Graph

                                                                                                                                        // Graph Properties
                                                                                                                                        CBUFFER_START(UnityPerMaterial)
                                                                                                                                        float4 _SilhouetteColor;
                                                                                                                                        float _FillAmount;
                                                                                                                                        float2 _YBounds;
                                                                                                                                        float4 _Color;
                                                                                                                                        float4 _MainTex_TexelSize;
                                                                                                                                        float4 _BandColour;
                                                                                                                                        float _BandWidth;
                                                                                                                                        CBUFFER_END

                                                                                                                                            // Object and Global properties
                                                                                                                                            SAMPLER(SamplerState_Linear_Repeat);
                                                                                                                                            TEXTURE2D(_MainTex);
                                                                                                                                            SAMPLER(sampler_MainTex);

                                                                                                                                            // Graph Includes
                                                                                                                                            // GraphIncludes: <None>

                                                                                                                                            // -- Property used by ScenePickingPass
                                                                                                                                            #ifdef SCENEPICKINGPASS
                                                                                                                                            float4 _SelectionID;
                                                                                                                                            #endif

                                                                                                                                            // -- Properties used by SceneSelectionPass
                                                                                                                                            #ifdef SCENESELECTIONPASS
                                                                                                                                            int _ObjectId;
                                                                                                                                            int _PassValue;
                                                                                                                                            #endif

                                                                                                                                            // Graph Functions

                                                                                                                                            void Unity_InverseLerp_float(float A, float B, float T, out float Out)
                                                                                                                                            {
                                                                                                                                                Out = (T - A) / (B - A);
                                                                                                                                            }

                                                                                                                                            void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                                                                                                                                            {
                                                                                                                                                Out = clamp(In, Min, Max);
                                                                                                                                            }

                                                                                                                                            void Unity_OneMinus_float(float In, out float Out)
                                                                                                                                            {
                                                                                                                                                Out = 1 - In;
                                                                                                                                            }

                                                                                                                                            void Unity_Comparison_LessOrEqual_float(float A, float B, out float Out)
                                                                                                                                            {
                                                                                                                                                Out = A <= B ? 1 : 0;
                                                                                                                                            }

                                                                                                                                            void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
                                                                                                                                            {
                                                                                                                                                Out = Predicate ? True : False;
                                                                                                                                            }

                                                                                                                                            void Unity_Subtract_float(float A, float B, out float Out)
                                                                                                                                            {
                                                                                                                                                Out = A - B;
                                                                                                                                            }

                                                                                                                                            void Unity_Comparison_GreaterOrEqual_float(float A, float B, out float Out)
                                                                                                                                            {
                                                                                                                                                Out = A >= B ? 1 : 0;
                                                                                                                                            }

                                                                                                                                            void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                                                                                                                                            {
                                                                                                                                                Out = A * B;
                                                                                                                                            }

                                                                                                                                            void Unity_OneMinus_float4(float4 In, out float4 Out)
                                                                                                                                            {
                                                                                                                                                Out = 1 - In;
                                                                                                                                            }

                                                                                                                                            void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                                                                                                                                            {
                                                                                                                                                Out = A + B;
                                                                                                                                            }

                                                                                                                                            // Custom interpolators pre vertex
                                                                                                                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                                                                                            // Graph Vertex
                                                                                                                                            struct VertexDescription
                                                                                                                                            {
                                                                                                                                                float3 Position;
                                                                                                                                                float3 Normal;
                                                                                                                                                float3 Tangent;
                                                                                                                                            };

                                                                                                                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                                                                                            {
                                                                                                                                                VertexDescription description = (VertexDescription)0;
                                                                                                                                                description.Position = IN.ObjectSpacePosition;
                                                                                                                                                description.Normal = IN.ObjectSpaceNormal;
                                                                                                                                                description.Tangent = IN.ObjectSpaceTangent;
                                                                                                                                                return description;
                                                                                                                                            }

                                                                                                                                            // Custom interpolators, pre surface
                                                                                                                                            #ifdef FEATURES_GRAPH_VERTEX
                                                                                                                                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                                                                                            {
                                                                                                                                            return output;
                                                                                                                                            }
                                                                                                                                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                                                                                            #endif

                                                                                                                                            // Graph Pixel
                                                                                                                                            struct SurfaceDescription
                                                                                                                                            {
                                                                                                                                                float3 BaseColor;
                                                                                                                                            };

                                                                                                                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                                                                                            {
                                                                                                                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                                                                                                                float2 _Property_0b4e504a5c134a12bffe4e99027c07fd_Out_0 = _YBounds;
                                                                                                                                                float _Swizzle_8918e71ab58c48c385adfdce3517a5c1_Out_1 = _Property_0b4e504a5c134a12bffe4e99027c07fd_Out_0.y;
                                                                                                                                                float _Swizzle_c1acb2fe87c442a78bcdefb08d7b0cdd_Out_1 = _Property_0b4e504a5c134a12bffe4e99027c07fd_Out_0.x;
                                                                                                                                                float _Swizzle_c206262ecebe4fdba18ddd36ad5598c0_Out_1 = IN.WorldSpacePosition.y;
                                                                                                                                                float _InverseLerp_ea18fe2319fe4c66b2253b5a34d8a5fd_Out_3;
                                                                                                                                                Unity_InverseLerp_float(_Swizzle_8918e71ab58c48c385adfdce3517a5c1_Out_1, _Swizzle_c1acb2fe87c442a78bcdefb08d7b0cdd_Out_1, _Swizzle_c206262ecebe4fdba18ddd36ad5598c0_Out_1, _InverseLerp_ea18fe2319fe4c66b2253b5a34d8a5fd_Out_3);
                                                                                                                                                float _Clamp_c290813c4e624385b85d86cc7c10e4d6_Out_3;
                                                                                                                                                Unity_Clamp_float(_InverseLerp_ea18fe2319fe4c66b2253b5a34d8a5fd_Out_3, 0, 1, _Clamp_c290813c4e624385b85d86cc7c10e4d6_Out_3);
                                                                                                                                                float _OneMinus_dd9197a7d62f4634bbd451af30c476bf_Out_1;
                                                                                                                                                Unity_OneMinus_float(_Clamp_c290813c4e624385b85d86cc7c10e4d6_Out_3, _OneMinus_dd9197a7d62f4634bbd451af30c476bf_Out_1);
                                                                                                                                                float _Property_16dd2c1c35774d9c9bbdda71653a43f6_Out_0 = _FillAmount;
                                                                                                                                                float _Comparison_dcea135e70a444c5aa73a81b84a98e02_Out_2;
                                                                                                                                                Unity_Comparison_LessOrEqual_float(_OneMinus_dd9197a7d62f4634bbd451af30c476bf_Out_1, _Property_16dd2c1c35774d9c9bbdda71653a43f6_Out_0, _Comparison_dcea135e70a444c5aa73a81b84a98e02_Out_2);
                                                                                                                                                float4 _Property_94bf0d4982514359b26405a57f6e228e_Out_0 = _Color;
                                                                                                                                                float4 _Property_b930a03aaff4459dad251a909414afb2_Out_0 = _SilhouetteColor;
                                                                                                                                                float4 _Branch_fe9c129de18844e9ba1dafcf701fc1f5_Out_3;
                                                                                                                                                Unity_Branch_float4(_Comparison_dcea135e70a444c5aa73a81b84a98e02_Out_2, _Property_94bf0d4982514359b26405a57f6e228e_Out_0, _Property_b930a03aaff4459dad251a909414afb2_Out_0, _Branch_fe9c129de18844e9ba1dafcf701fc1f5_Out_3);
                                                                                                                                                float _Property_b647961b6a5e41e3b128e7d138d26bbf_Out_0 = _BandWidth;
                                                                                                                                                float _Subtract_d83f2f4283004dbb8ef2976ad239dcbb_Out_2;
                                                                                                                                                Unity_Subtract_float(_Property_16dd2c1c35774d9c9bbdda71653a43f6_Out_0, _Property_b647961b6a5e41e3b128e7d138d26bbf_Out_0, _Subtract_d83f2f4283004dbb8ef2976ad239dcbb_Out_2);
                                                                                                                                                float _Comparison_6c3528b2e67742458dcad2c1d9123206_Out_2;
                                                                                                                                                Unity_Comparison_GreaterOrEqual_float(_OneMinus_dd9197a7d62f4634bbd451af30c476bf_Out_1, _Subtract_d83f2f4283004dbb8ef2976ad239dcbb_Out_2, _Comparison_6c3528b2e67742458dcad2c1d9123206_Out_2);
                                                                                                                                                float4 _Branch_37b2d57601fd44fd9d02a5eecafa4598_Out_3;
                                                                                                                                                Unity_Branch_float4(_Comparison_6c3528b2e67742458dcad2c1d9123206_Out_2, _Property_94bf0d4982514359b26405a57f6e228e_Out_0, float4(0, 0, 0, 0), _Branch_37b2d57601fd44fd9d02a5eecafa4598_Out_3);
                                                                                                                                                float4 _Multiply_8f6eca7a3a004e1bb7bb5bc8b02dc8cb_Out_2;
                                                                                                                                                Unity_Multiply_float4_float4(_Branch_fe9c129de18844e9ba1dafcf701fc1f5_Out_3, _Branch_37b2d57601fd44fd9d02a5eecafa4598_Out_3, _Multiply_8f6eca7a3a004e1bb7bb5bc8b02dc8cb_Out_2);
                                                                                                                                                float4 _Property_665c2bda7053418092ddc78c9b230846_Out_0 = _BandColour;
                                                                                                                                                float4 _Multiply_80f3f98c40c747cfac316465edd63a2f_Out_2;
                                                                                                                                                Unity_Multiply_float4_float4(_Multiply_8f6eca7a3a004e1bb7bb5bc8b02dc8cb_Out_2, _Property_665c2bda7053418092ddc78c9b230846_Out_0, _Multiply_80f3f98c40c747cfac316465edd63a2f_Out_2);
                                                                                                                                                float4 _OneMinus_9b0bae6729ce46b1bd920238dc7a064e_Out_1;
                                                                                                                                                Unity_OneMinus_float4(_Branch_37b2d57601fd44fd9d02a5eecafa4598_Out_3, _OneMinus_9b0bae6729ce46b1bd920238dc7a064e_Out_1);
                                                                                                                                                float4 _Add_a846e3cc418140c3bf1b27f660cd7ba4_Out_2;
                                                                                                                                                Unity_Add_float4(_Multiply_80f3f98c40c747cfac316465edd63a2f_Out_2, _OneMinus_9b0bae6729ce46b1bd920238dc7a064e_Out_1, _Add_a846e3cc418140c3bf1b27f660cd7ba4_Out_2);
                                                                                                                                                UnityTexture2D _Property_0c7380d416f643088cd6f223277a1d87_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
                                                                                                                                                float4 _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_RGBA_0 = SAMPLE_TEXTURE2D(_Property_0c7380d416f643088cd6f223277a1d87_Out_0.tex, _Property_0c7380d416f643088cd6f223277a1d87_Out_0.samplerstate, _Property_0c7380d416f643088cd6f223277a1d87_Out_0.GetTransformedUV(IN.uv0.xy));
                                                                                                                                                float _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_R_4 = _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_RGBA_0.r;
                                                                                                                                                float _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_G_5 = _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_RGBA_0.g;
                                                                                                                                                float _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_B_6 = _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_RGBA_0.b;
                                                                                                                                                float _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_A_7 = _SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_RGBA_0.a;
                                                                                                                                                float4 _Multiply_d2e9657dc3154f43a0fe0f8d33b46f14_Out_2;
                                                                                                                                                Unity_Multiply_float4_float4(_SampleTexture2D_eb78ea4047a04eb19ef3a642ff3e8d21_RGBA_0, _OneMinus_9b0bae6729ce46b1bd920238dc7a064e_Out_1, _Multiply_d2e9657dc3154f43a0fe0f8d33b46f14_Out_2);
                                                                                                                                                float4 _OneMinus_d702c615cb6a4d93a374d272c8ad4b87_Out_1;
                                                                                                                                                Unity_OneMinus_float4(_OneMinus_9b0bae6729ce46b1bd920238dc7a064e_Out_1, _OneMinus_d702c615cb6a4d93a374d272c8ad4b87_Out_1);
                                                                                                                                                float4 _Add_1eaa704a333b4ebdbaf364697a0bec42_Out_2;
                                                                                                                                                Unity_Add_float4(_Multiply_d2e9657dc3154f43a0fe0f8d33b46f14_Out_2, _OneMinus_d702c615cb6a4d93a374d272c8ad4b87_Out_1, _Add_1eaa704a333b4ebdbaf364697a0bec42_Out_2);
                                                                                                                                                float4 _Multiply_0702241a7980465bb8edf3998a7bbf1b_Out_2;
                                                                                                                                                Unity_Multiply_float4_float4(_Add_a846e3cc418140c3bf1b27f660cd7ba4_Out_2, _Add_1eaa704a333b4ebdbaf364697a0bec42_Out_2, _Multiply_0702241a7980465bb8edf3998a7bbf1b_Out_2);
                                                                                                                                                surface.BaseColor = (_Multiply_0702241a7980465bb8edf3998a7bbf1b_Out_2.xyz);
                                                                                                                                                return surface;
                                                                                                                                            }

                                                                                                                                            // --------------------------------------------------
                                                                                                                                            // Build Graph Inputs
                                                                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                                                                            #define VFX_SRP_ATTRIBUTES Attributes
                                                                                                                                            #define VFX_SRP_VARYINGS Varyings
                                                                                                                                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                                                                                            #endif
                                                                                                                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                                                                                            {
                                                                                                                                                VertexDescriptionInputs output;
                                                                                                                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                                                                                output.ObjectSpaceNormal = input.normalOS;
                                                                                                                                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                                                                                output.ObjectSpacePosition = input.positionOS;

                                                                                                                                                return output;
                                                                                                                                            }
                                                                                                                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                                                                            {
                                                                                                                                                SurfaceDescriptionInputs output;
                                                                                                                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                                                                                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                                                                                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                                                                                            #endif







                                                                                                                                                output.WorldSpacePosition = input.positionWS;
                                                                                                                                                output.uv0 = input.texCoord0;
                                                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                                                                                            #else
                                                                                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                                                                                            #endif
                                                                                                                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                                                                                    return output;
                                                                                                                                            }

                                                                                                                                            // --------------------------------------------------
                                                                                                                                            // Main

                                                                                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

                                                                                                                                            // --------------------------------------------------
                                                                                                                                            // Visual Effect Vertex Invocations
                                                                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                                                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                                                                                            #endif

                                                                                                                                            ENDHLSL
                                                                                                                                            }
                                                                            }
                                                                                CustomEditorForRenderPipeline "UnityEditor.ShaderGraphLitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
                                                                                                                                                CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
                                                                                                                                                FallBack "Hidden/Shader Graph/FallbackError"
}