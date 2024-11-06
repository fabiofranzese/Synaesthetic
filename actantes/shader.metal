#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
};

vertex VertexOut vertex_main(uint vertexID [[vertex_id]]) {
    float4 positions[6] = {
        float4(-1.0, -1.0, 0.0, 1.0),
        float4( 1.0, -1.0, 0.0, 1.0),
        float4(-1.0,  1.0, 0.0, 1.0),
        float4(-1.0,  1.0, 0.0, 1.0),
        float4( 1.0, -1.0, 0.0, 1.0),
        float4( 1.0,  1.0, 0.0, 1.0)
    };
    VertexOut out;
    out.position = positions[vertexID];
    return out;
}

float random(float2 st) {
    return fract(sin(dot(st, float2(12.9898, 78.233))) * 43758.5453123);
}

float noise(float2 st) {
    float2 i = floor(st);
    float2 f = fract(st);

    float a = random(i);
    float b = random(i + float2(1.0, 0.0));
    float c = random(i + float2(0.0, 1.0));
    float d = random(i + float2(1.0, 1.0));

    float2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

#define NUM_OCTAVES 5

float fbm(float2 st) {
    float v = 0.0;
    float a = 0.5;
    float2 shift = float2(100.0, 100.0);
    float2x2 rot = float2x2(cos(0.5), sin(0.5), -sin(0.5), cos(0.5));
    
    for (int i = 0; i < NUM_OCTAVES; ++i) {
        v += a * noise(st);
        st = rot * st * 2.0 + shift;
        a *= 0.5;
    }
    return v;
}

// Function to convert hue to RGB color and cover full RGB spectrum
float3 hueToRGB(float hue) {
    hue = fract(hue); // Ensure hue wraps between 0 and 1
    float3 color = clamp(abs(fract(hue + float3(0.0, 0.333, 0.666)) * 6.0 - 3.0) - 1.0, 0.0, 1.0);
    return color;
}

fragment float4 fragment_main(float4 fragCoord [[position]],
                              constant float2 &u_resolution [[buffer(0)]],
                              constant float &u_time [[buffer(1)]],
                              constant float &lastHue [[buffer(2)]]) {
    float2 st = fragCoord.xy / u_resolution * 3.0;

    // Use last hue to cycle through the full RGB spectrum
    float hue = lastHue; // Use the hue passed from the touch duration
    float3 baseColor = hueToRGB(hue);

    float2 q = float2(0.0);
    q.x = fbm(st + 0.00 * u_time);
    q.y = fbm(st + float2(1.0));

    float2 r = float2(0.0);
    r.x = fbm(st + 1.0 * q + float2(1.7, 9.2) + 0.15 * u_time);
    r.y = fbm(st + 1.0 * q + float2(8.3, 2.8) + 0.126 * u_time);

    float f = fbm(st + r);

    // Use the base color with added depth for visual complexity
    float3 color = mix(baseColor, float3(0.0, 0.0, 0.164706), clamp((f * f) * 4.0, 0.0, 1.0));
    color = mix(color, float3(0.666667, 1.0, 1.0), clamp(metal::length(float2(r.x, 0.0)), 0.0, 1.0));

    return float4((f * f * f + 0.6 * f * f + 0.5 * f) * color, 1.0);
}
