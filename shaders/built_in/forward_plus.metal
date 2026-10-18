#include <metal_stdlib>

using namespace metal;

struct MTForwardPlusFrame {
    float4x4 modelViewProjection;
};

struct MTForwardPlusMaterial {
    float4 baseColor;
    float4 specularColor;
    float shininess;
    float reserved0;
    float reserved1;
    float reserved2;
};

struct MTForwardPlusVertex {
    packed_float3 position;
    packed_float3 normal;
    packed_float2 texcoord;
};

struct MTForwardPlusOutput {
    float4 position [[position]];
    float3 normal;
};

struct MTForwardPlusLight {
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

vertex MTForwardPlusOutput mt_forward_plus_vertex(
    const device MTForwardPlusVertex *vertices [[buffer(0)]],
    constant MTForwardPlusFrame &frame [[buffer(1)]],
    uint vertexID [[vertex_id]]
) {
    MTForwardPlusOutput output;
    output.position = frame.modelViewProjection *
        float4(vertices[vertexID].position, 1.0);
    output.normal = vertices[vertexID].normal;
    return output;
}

fragment float4 mt_forward_plus_fragment(
    MTForwardPlusOutput input [[stage_in]],
    constant MTForwardPlusMaterial &material [[buffer(2)]],
    const device MTForwardPlusLight *lights [[buffer(3)]],
    const device uint *clusterLightIndices [[buffer(4)]],
    const device uint *clusterAssignments [[buffer(5)]]
) {
    float3 normal = normalize(input.normal);
    uint lightIndex = clusterLightIndices[clusterAssignments[0]];
    MTForwardPlusLight light = lights[lightIndex];
    float3 lightDirection = normalize(float3(
        light.positionX,
        light.positionY,
        light.positionZ
    ));
    float diffuse = max(dot(normal, lightDirection), 0.0);
    float3 color = material.baseColor.rgb *
        (0.1 + diffuse * light.intensity) +
        material.specularColor.rgb * pow(diffuse, material.shininess);
    return float4(color, material.baseColor.a);
}
