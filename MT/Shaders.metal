#include <metal_stdlib>
#include <metal_mesh>

using namespace metal;

struct Vertex {
    float3 position;
};

struct Uniforms {
    float4x4 mvp;
};

struct VertexData {
    float4 position [[position]];
};

struct ObjectPayload {
    uint meshIndex;
};

using TriangleMesh = metal::mesh<
    VertexData,
    void,
    3,
    1,
    topology::triangle
>;

[[object]]
void object_main(object_data ObjectPayload &payload [[payload]],
                 mesh_grid_properties outGrid,
                 uint tid [[thread_position_in_threadgroup]]) {
    if (tid == 0) {
        payload.meshIndex = 0;
        outGrid.set_threadgroups_per_grid(uint3(1, 1, 1));
    }
}

[[mesh]]
void mesh_main(TriangleMesh outMesh,
               object_data ObjectPayload const &object [[payload]],
               device const Vertex *vertices [[buffer(0)]],
               constant Uniforms &uniforms [[buffer(1)]],
               uint tid [[thread_position_in_threadgroup]]) {
    if (tid < 3) {
        VertexData v;
        v.position = uniforms.mvp * float4(vertices[tid].position, 1.0);
        outMesh.set_vertex(tid, v);
    }

    if (tid == 0) {
        outMesh.set_index(0, 0);
        outMesh.set_index(1, 1);
        outMesh.set_index(2, 2);
        outMesh.set_primitive_count(1);
    }
}

fragment float4 fragment_main(VertexData in [[stage_in]],
                              constant float4 &color [[buffer(0)]]) {
    return color;
}
