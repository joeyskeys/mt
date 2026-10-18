#include <metal_stdlib>

using namespace metal;

struct MTLightClusterBounds {
    float minX;
    float minY;
    float minZ;
    float maxX;
    float maxY;
    float maxZ;
};

struct MTLightClusterAssignment {
    uint lightOffset;
    uint lightCount;
    uint overflow;
    uint reserved;
};

struct MTLightClusterLight {
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

kernel void mt_light_cluster_kernel(
    const device MTLightClusterBounds *bounds [[buffer(0)]],
    const device MTLightClusterLight *lights [[buffer(1)]],
    device MTLightClusterAssignment *assignments [[buffer(2)]],
    device uint *lightIndices [[buffer(3)]],
    uint clusterIndex [[thread_position_in_grid]]
) {
    MTLightClusterBounds cluster = bounds[clusterIndex];
    uint lightIndex = 0;
    bool inside = lights[lightIndex].positionX >= cluster.minX &&
        lights[lightIndex].positionX <= cluster.maxX &&
        lights[lightIndex].positionY >= cluster.minY &&
        lights[lightIndex].positionY <= cluster.maxY &&
        lights[lightIndex].positionZ >= cluster.minZ &&
        lights[lightIndex].positionZ <= cluster.maxZ;
    assignments[clusterIndex].lightOffset = clusterIndex;
    assignments[clusterIndex].lightCount = inside ? 1 : 0;
    assignments[clusterIndex].overflow = 0;
    assignments[clusterIndex].reserved = 0;
    if (inside) {
        lightIndices[clusterIndex] = lightIndex;
    }
}
