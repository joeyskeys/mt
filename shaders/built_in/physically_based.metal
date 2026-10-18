#include <metal_stdlib>

using namespace metal;

struct MTPBRFrame {
    float4x4 modelViewProjection;
};

struct MTPBRMaterial {
    float4 baseColor;
    float4 emissiveColor;
    float metallic;
    float roughness;
    float normalScale;
    float occlusionStrength;
};

struct MTPBRVertex {
    packed_float3 position;
    packed_float3 normal;
    packed_float2 texcoord;
};

struct MTPBROutput {
    float4 position [[position]];
    float3 normal;
};

struct MTPBRLight {
    float positionX;
    float positionY;
    float positionZ;
    float range;
    float directionX;
    float directionY;
    float directionZ;
    float innerConeAngle;
    float colorR;
    float colorG;
    float colorB;
    float intensity;
    int kind;
    uint flags;
    float outerConeAngle;
    float reserved;
};

vertex MTPBROutput mt_pbr_vertex(
    const device MTPBRVertex *vertices [[buffer(0)]],
    constant MTPBRFrame &frame [[buffer(1)]],
    uint vertexID [[vertex_id]]
) {
    MTPBROutput output;
    output.position = frame.modelViewProjection *
        float4(vertices[vertexID].position, 1.0);
    output.normal = vertices[vertexID].normal;
    return output;
}

fragment float4 mt_pbr_fragment(
    MTPBROutput input [[stage_in]],
    constant MTPBRMaterial &material [[buffer(2)]],
    const device MTPBRLight *lights [[buffer(3)]]
) {
    float3 normal = normalize(input.normal);
    float3 lightDirection = normalize(float3(
        lights[0].positionX,
        lights[0].positionY,
        lights[0].positionZ
    ));
    float diffuse = max(dot(normal, lightDirection), 0.0);
    float roughness = clamp(material.roughness, 0.04, 1.0);
    float energy = (1.0 - material.metallic) *
        (0.25 + 0.75 * diffuse) / roughness;
    float3 color = material.baseColor.rgb * energy +
        material.emissiveColor.rgb;
    return float4(color, material.baseColor.a);
}
