#include <metal_stdlib>

using namespace metal;

// This fixture intentionally uses Metal's native object/mesh stages.  It is
// selected only on devices that advertise mesh shader support; the regular
// vertex path remains the portable built-in path.
#if __METAL_VERSION__ >= 300

struct MTMeshObjectPayload {
    uint objectIndex;
};

struct MTMeshVertex {
    float4 position [[position]];
};

[[object]]
void mt_mesh_object(
    object_data MTMeshObjectPayload &payload [[payload]],
    uint objectIndex [[thread_position_in_grid]],
    uint threadIndex [[thread_index_in_threadgroup]],
    mesh_grid_properties grid
) {
    if (threadIndex == 0) {
        payload.objectIndex = objectIndex;
        grid.set_threadgroups_per_grid(uint3(1, 1, 1));
    }
}

[[mesh]]
void mt_mesh_mesh(
    const object_data MTMeshObjectPayload &payload [[payload]],
    mesh<MTMeshVertex, void, 3, 1, topology::triangle> outputMesh,
    uint threadIndex [[thread_index_in_threadgroup]]
) {
    if (threadIndex == 0) {
        outputMesh.set_vertex(
            0,
            MTMeshVertex{float4(-0.5, -0.5, 0.0, 1.0)}
        );
        outputMesh.set_vertex(
            1,
            MTMeshVertex{float4(0.5, -0.5, 0.0, 1.0)}
        );
        outputMesh.set_vertex(
            2,
            MTMeshVertex{float4(0.0, 0.5, 0.0, 1.0)}
        );
        outputMesh.set_primitive_count(1);
        outputMesh.set_index(0, 0);
        outputMesh.set_index(1, 1);
        outputMesh.set_index(2, 2);
    }
}

fragment float4 mt_mesh_fragment() {
    return float4(1.0, 1.0, 1.0, 1.0);
}

#endif
