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
CBUFFER_END

// IO structures
struct VertexInput
{
    float4 position : POSITION;
    float4 normal : NORMAL;
};

struct VertexOutput
{
    float4 posClip : SV_POSITION;
    half3 normal : NORMAL;
    float3 posWorld : TANGENT;
    half3 diffuseColor : COLOR0;
    half3 specularColor : COLOR1;
    DECLARE_SHADOW_COORD(7)
};

// Vertex shader
VertexOutput VertexShaderMain(VertexInput v)
{
    VertexOutput o = (VertexOutput)0;
    Light mainLight = GetMainLight();

    float3 posWorld = TransformObjectToWorld(v.position.xyz);
    o.posWorld = posWorld;

    half ndotl = saturate(dot(v.normal.xyz, mainLight.direction));
    o.diffuseColor = _DiffuseColor.rgb * ndotl;
    
    
    o.posClip = TransformWorldToHClip(posWorld);
    o.normal = v.normal.xyz;
    
    half3 cameraDirection = normalize(_WorldSpaceCameraPos - posWorld);
    half3 lightDirection = mainLight.direction;
    half3 blinnNormal = normalize(cameraDirection + lightDirection);
    half specular = pow(saturate(dot(blinnNormal, normalize(o.normal))), _SpecularPower);

    half3 specularColor = _SpecularColor * specular;
    o.specularColor = specularColor;

    INIT_SHADOW_COORD(o, posWorld);
    return o;
}

// Fragment shader
half4 FragmentShaderMain(VertexOutput v) : SV_Target
{
    Light mainLight = GetMainLight();
    half attenuation = CALCULATE_SHADOW_ATTENUATION(v, v.posWorld, mainLight.shadowAttenuation);

    half3 finalColor = mainLight.color * saturate(attenuation) * (v.diffuseColor + v.specularColor);
    return half4(finalColor, 1);
}
#endif
