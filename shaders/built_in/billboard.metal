#include <metal_stdlib>

using namespace metal;

struct MTBillboardFrame {
    float4x4 modelViewProjection;
};

struct MTBillboardMaterial {
    float4 color;
    float2 size;
    float2 pivot;
};

struct MTBillboardVertex {
    packed_float3 position;
    packed_float3 normal;
    packed_float2 texcoord;
};

struct MTBillboardOutput {
    float4 position [[position]];
    float2 texcoord;
};

vertex MTBillboardOutput mt_billboard_vertex(
    const device MTBillboardVertex *vertices [[buffer(0)]],
    constant MTBillboardFrame &frame [[buffer(1)]],
    constant MTBillboardMaterial &material [[buffer(2)]],
    uint vertexID [[vertex_id]]
) {
    MTBillboardOutput output;
    float3 position = vertices[vertexID].position;
    position.xy = (position.xy - material.pivot) * material.size;
    output.position = frame.modelViewProjection * float4(position, 1.0);
    output.texcoord = vertices[vertexID].texcoord;
    return output;
}

fragment float4 mt_billboard_fragment(
    MTBillboardOutput input [[stage_in]],
    constant MTBillboardMaterial &material [[buffer(2)]]
) {
    float alpha = step(0.0, input.texcoord.x) *
        step(0.0, input.texcoord.y);
    return float4(material.color.rgb, material.color.a * alpha);
}
