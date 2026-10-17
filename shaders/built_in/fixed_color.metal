#include <metal_stdlib>

using namespace metal;

struct MTFixedColorFrame {
    float4x4 modelViewProjection;
};

struct MTFixedColorMaterial {
    float4 color;
};

struct MTFixedColorVertex {
    packed_float3 position;
    packed_float3 normal;
    packed_float2 texcoord;
};

struct MTFixedColorOutput {
    float4 position [[position]];
};

vertex MTFixedColorOutput mt_fixed_color_vertex(
    const device MTFixedColorVertex *vertices [[buffer(0)]],
    constant MTFixedColorFrame &frame [[buffer(1)]],
    uint vertexID [[vertex_id]]
) {
    MTFixedColorOutput output;
    output.position = frame.modelViewProjection *
        float4(vertices[vertexID].position, 1.0);
    return output;
}

fragment float4 mt_fixed_color_fragment(
    constant MTFixedColorMaterial &material [[buffer(2)]]
) {
    return material.color;
}

