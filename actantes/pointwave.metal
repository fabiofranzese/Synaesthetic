#include <metal_stdlib>
using namespace metal;

// Permutation polynomial: (34x^2 + x) mod 289
float4 permute(float4 x) {
    return fmod((34.0 * x + 1.0) * x, 289.0);
}

// Cellular noise function
float2 cellular2x2(float2 P) {
    constexpr float K = 0.142857142857; // 1/7
    constexpr float K2 = 0.0714285714285; // K/2
    constexpr float jitter = 0.8;

    float2 Pi = fmod(floor(P), 289.0);
    float2 Pf = fract(P);

    float4 Pfx = Pf.x + float4(-0.5, -1.5, -0.5, -1.5);
    float4 Pfy = Pf.y + float4(-0.5, -0.5, -1.5, -1.5);

    float4 p = permute(Pi.x + float4(0.0, 1.0, 0.0, 1.0));
    p = permute(p + Pi.y + float4(0.0, 0.0, 1.0, 1.0));

    float4 ox = fmod(p, 7.0) * K + K2;
    float4 oy = fmod(floor(p * K), 7.0) * K + K2;

    float4 dx = Pfx + jitter * ox;
    float4 dy = Pfy + jitter * oy;

    float4 d = dx * dx + dy * dy;

    d.xy = (d.x < d.y) ? d.xy : d.yx;
    d.xz = (d.x < d.z) ? d.xz : d.zx;
    d.xw = (d.x < d.w) ? d.xw : d.wx;

    d.y = min(d.y, min(d.z, d.w));
    return sqrt(d.xy);
}

// Random color generator based on seed
float3 randomColor(float seed) {
    return float3(
        0.5 + 0.5 * sin(seed * 6.2831),
        0.5 + 0.5 * sin(seed * 6.2831 + 2.094),
        0.5 + 0.5 * sin(seed * 6.2831 + 4.188)
    );
}

// Stippling shader
[[stitchable]] half4 stippling(
    float2 pos, half4 color, float2 size, float time,
    float sub, float low, float mid, float hi, float treble
) {
    // Normalize UV coordinates and center the origin
    float2 uv = (pos / size) - 0.5;

    // Correct aspect ratio to ensure circular shapes
    uv.x *= size.x / size.y;

    // Zoom out effect: Adjust the scaling factor for UV coordinates
    float zoom = 60.0; // Larger value for more compact dots
    float2 F = cellular2x2(uv * zoom);

    // Audio speed modulation: adjust animation speed by 4% when audio is active
    float audioSpeedFactor = 1.0 + (mid * 0.04);
    float animatedTime = time * audioSpeedFactor;

    // Circular wave effect
    float a = dot(uv, uv) - animatedTime * 0.1;
    float wave = abs(sin(a * 3.1415 * 5.0));

    // Stippling threshold
    float n = step(wave, F.x * 2.0);

    // Final black-and-white output
    return half4(half3(n), half(1.0));
}
