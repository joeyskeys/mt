#include <metal_stdlib>

using namespace metal;

struct MTTextFrame {
    float4x4 modelViewProjection;
};

struct MTTextMaterial {
    float4 color;
    float4 outlineColor;
    float outlineWidth;
    float edgeSoftness;
    float2 reserved;
};

struct MTTextVertex {
    packed_float3 position;
    packed_float3 normal;
    packed_float2 texcoord;
};

struct MTTextOutput {
    float4 position [[position]];
    float2 texcoord;
};

vertex MTTextOutput mt_text_vertex(
    const device MTTextVertex *vertices [[buffer(0)]],
    constant MTTextFrame &frame [[buffer(1)]],
    uint vertexID [[vertex_id]]
) {
    MTTextOutput output;
    output.position = frame.modelViewProjection *
        float4(vertices[vertexID].position, 1.0);
    output.texcoord = vertices[vertexID].texcoord;
    return output;
}

fragment float4 mt_text_fragment(
    MTTextOutput input [[stage_in]],
    constant MTTextMaterial &material [[buffer(2)]]
) {
    float glyphCoverage = smoothstep(
        0.5 - material.edgeSoftness,
        0.5 + material.edgeSoftness,
        input.texcoord.x
    );
    float4 color = mix(
        material.outlineColor,
        material.color,
        glyphCoverage
    );
    return float4(color.rgb, color.a);
}
