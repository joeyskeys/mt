#include <metal_stdlib>

using namespace metal;

struct MTDirectionalShadowFrame {
    float4x4 modelViewProjection;
};

struct MTDirectionalShadowMaterial {
    float4x4 lightViewProjection;
    float depthBias;
    float normalBias;
    float2 reserved;
};

struct MTDirectionalShadowVertex {
    packed_float3 position;
    packed_float3 normal;
    packed_float2 texcoord;
};

struct MTDirectionalShadowOutput {
    float4 position [[position]];
};

vertex MTDirectionalShadowOutput mt_directional_shadow_vertex(
    const device MTDirectionalShadowVertex *vertices [[buffer(0)]],
    constant MTDirectionalShadowFrame &frame [[buffer(1)]],
    constant MTDirectionalShadowMaterial &material [[buffer(2)]],
    uint vertexID [[vertex_id]]
) {
    MTDirectionalShadowOutput output;
    float4 worldPosition = float4(vertices[vertexID].position, 1.0);
    output.position = material.lightViewProjection * worldPosition;
    return output;
}

fragment float4 mt_directional_shadow_fragment() {
    return float4(1.0);
}
