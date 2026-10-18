#include <metal_stdlib>

using namespace metal;

struct MTPhongFrame {
    float4x4 modelViewProjection;
};

struct MTPhongMaterial {
    float4 baseColor;
    float4 specularColor;
    float shininess;
    float reserved0;
    float reserved1;
    float reserved2;
};

struct MTPhongVertex {
    packed_float3 position;
    packed_float3 normal;
    packed_float2 texcoord;
};

struct MTPhongOutput {
    float4 position [[position]];
    float3 normal;
};

struct MTPhongLight {
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

vertex MTPhongOutput mt_phong_vertex(
    const device MTPhongVertex *vertices [[buffer(0)]],
    constant MTPhongFrame &frame [[buffer(1)]],
    uint vertexID [[vertex_id]]
) {
    MTPhongOutput output;
    output.position = frame.modelViewProjection *
        float4(vertices[vertexID].position, 1.0);
    output.normal = vertices[vertexID].normal;
    return output;
}

fragment float4 mt_phong_fragment(
    MTPhongOutput input [[stage_in]],
    constant MTPhongMaterial &material [[buffer(2)]],
    const device MTPhongLight *lights [[buffer(3)]]
) {
    float3 normal = normalize(input.normal);
    float3 lightDirection = normalize(float3(
        lights[0].positionX,
        lights[0].positionY,
        lights[0].positionZ
    ));
    float diffuse = max(dot(normal, lightDirection), 0.0);
    float3 color = material.baseColor.rgb *
        (0.1 + diffuse * lights[0].intensity) +
        material.specularColor.rgb * pow(diffuse, material.shininess);
    return float4(color, material.baseColor.a);
}
