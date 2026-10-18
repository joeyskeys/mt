#include <metal_stdlib>

using namespace metal;

struct MTMeshVisualizationFrame {
    float4x4 modelViewProjection;
};

struct MTMeshVisualizationMaterial {
    float4 color;
    uint mode;
    float lineWidth;
    float opacity;
    float reserved;
};

struct MTMeshVisualizationVertex {
    packed_float3 position;
    packed_float3 normal;
    packed_float2 texcoord;
};

struct MTMeshVisualizationOutput {
    float4 position [[position]];
    float3 normal;
};

vertex MTMeshVisualizationOutput mt_mesh_visualization_vertex(
    const device MTMeshVisualizationVertex *vertices [[buffer(0)]],
    constant MTMeshVisualizationFrame &frame [[buffer(1)]],
    uint vertexID [[vertex_id]]
) {
    MTMeshVisualizationOutput output;
    output.position = frame.modelViewProjection *
        float4(vertices[vertexID].position, 1.0);
    output.normal = vertices[vertexID].normal;
    return output;
}

fragment float4 mt_mesh_visualization_fragment(
    MTMeshVisualizationOutput input [[stage_in]],
    constant MTMeshVisualizationMaterial &material [[buffer(2)]]
) {
    float normalFactor = material.mode == 0
        ? 1.0
        : 0.5 + 0.5 * abs(input.normal.z);
    return float4(
        material.color.rgb * normalFactor,
        material.color.a * material.opacity
    );
}
