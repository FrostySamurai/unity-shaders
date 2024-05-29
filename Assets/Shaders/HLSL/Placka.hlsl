#ifndef DEFAULT_PASS
#define DEFAULT_PASS

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "IncludeLWRPUnityShadows.hlsl"

//======================================================
// constants
CBUFFER_START(UnityPerMaterial)
    half4 _DiffuseColor;
    half4 _SpecularColor;
    half _SpecularPower;

    TEXTURE2D(_MainTex);
    SAMPLER(sampler_MainTex);
    float4 _MainTex_ST;

    TEXTURE2D(_WaveTex);
    SAMPLER(sampler_WaveTex);
    float4 _WaveTex_ST;

    TEXTURE2D(_SecondaryTex);
    SAMPLER(sampler_SecondaryTex);
    float4 _SecondaryTex_ST;
CBUFFER_END

// IO structures
struct VertexInput
{
    float4 position : POSITION;
    float4 normal : NORMAL;
    float2 uv : TEXCOORD0;
};

struct VertexOutput
{
    float4 posClip : SV_POSITION;
    half3 normal : NORMAL;
    float3 posWorld : TANGENT;
    float2 uv : TEXCOORD0;
    DECLARE_SHADOW_COORD(7)
};

// Vertex shader
VertexOutput VertexShaderMain(VertexInput v)
{
    VertexOutput o = (VertexOutput)0;

    float3 posWorld = TransformObjectToWorld(v.position.xyz);
    
    half4 sample = SAMPLE_TEXTURE2D_LOD(_WaveTex, sampler_WaveTex, v.uv * _WaveTex_ST.xy + _WaveTex_ST.zw, 0);
    posWorld.y += (sin(frac(posWorld.z + _Time.z) * PI * 2) + 1) * (sample.g - sample.r);
    posWorld.y += (cos(frac(posWorld.x + _Time.y) * PI * 2)) * (sample.r - sample.g);
    // posWorld.y += sin(posWorld.z);

    o.posClip = TransformWorldToHClip(posWorld);
    o.posWorld = posWorld;
    o.normal = v.normal.xyz;
    o.uv = v.uv;

    //o.uv.x += frac(_Time.y);
    
    INIT_SHADOW_COORD(o, posWorld);
    return o;
}

// Fragment shader
half4 FragmentShaderMain(VertexOutput v) : SV_Target
{
    // sample surface color from texture
    half4 surfaceColor;
    if (v.posWorld.y < 0)
    {
        surfaceColor = SAMPLE_TEXTURE2D(_SecondaryTex, sampler_SecondaryTex, v.uv * _SecondaryTex_ST.xy + _SecondaryTex_ST.zw);
    }
    else
    {
        surfaceColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, v.uv * _MainTex_ST.xy + _MainTex_ST.zw);
    }
    
    
    // main light
    Light mainLight = GetMainLight();
    half attenuation = CALCULATE_SHADOW_ATTENUATION(v, v.posWorld, mainLight.shadowAttenuation);

    // Lambertian lighting
    half ndotl = saturate(dot(v.normal.xyz, mainLight.direction));

    // Blinn-Phong specular lighting
    half3 cameraDirection = normalize(_WorldSpaceCameraPos - v.posWorld);
    half3 lightDirection = mainLight.direction;
    half3 blinnNormal = normalize(cameraDirection + lightDirection);
    half specular = pow(saturate(dot(blinnNormal, normalize(v.normal))), _SpecularPower);

    // calculate final color
    half3 diffuseColor = surfaceColor * _DiffuseColor.rgb * ndotl;
    half3 specularColor = _SpecularColor * specular;
    half3 finalColor = mainLight.color * saturate(attenuation) * (diffuseColor + specularColor);

    // final color
    return half4(finalColor, 1);
}
#endif
