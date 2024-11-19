#include <metal_stdlib>
using namespace metal;

// Hash function to generate pseudo-random values
float hash(float2 p) {
    p = fract(p * 0.6180339887);
    p *= 25.0;
    return fract(p.x * p.y * (p.x + p.y));
}

// Noise function for generating smooth random noise, now modulated by mid frequency
float noise(float2 x, float mid) {
    float2 p = floor(x);
    float2 f = fract(x);
    // Using mid frequency to modulate the smoothing factor between 0.5 and 20
    f = f * f * ((0.5 + 3 * mid) - 2.0 * f);

    float a = hash(p + float2(0.0, 0.0));
    float b = hash(p + float2(1.0, 0.0));
    float c = hash(p + float2(0.0, 1.0));
    float d = hash(p + float2(1.0, 1.0));

    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

// Fractal Brownian Motion (FBM) with 4 octaves, now modulated by low frequency
float fbm4(float2 p, float low) {
    float f = 0.0;
    // Using low frequency to modulate the amplitude between 0.5 and 20
    float amplitude = 0.5 + 19.5 * low;
    float2 mtx = float2(0.80, 0.60);

    for (int i = 0; i < 4; i++) {
        f += amplitude * (-1.0 + 2.0 * noise(p, low));
        p = float2(mtx.x, -mtx.y) * p * 2.02;
        amplitude *= 0.5;
    }
    return f / 0.9375;
}

// Fractal Brownian Motion (FBM) with 6 octaves, also modulated by low frequency
float fbm6(float2 p, float low) {
    float f = 0.0;
    float amplitude = 0.5 + 19.5 * low;
    float2 mtx = float2(0.80, 0.60);

    for (int i = 0; i < 6; i++) {
        f += amplitude * noise(p, low);
        p = float2(mtx.x, -mtx.y) * p * 2.02;
        amplitude *= 0.5;
    }
    return f / 0.96875;
}

// Composite FBM functions
float2 fbm4_2(float2 p, float low) {
    return float2(fbm4(p + float2(1.0), low), fbm4(p + float2(6.2), low));
}

float2 fbm6_2(float2 p, float low) {
    return float2(fbm6(p + float2(9.2), low), fbm6(p + float2(5.7), low));
}

// Main function to generate the fluid effect
float func(float2 q, thread float2 &o, thread float2 &n, float time, float sub, float low) {
    // Using sub frequency to modulate movement speed
    q += (0.05 + 0.1 * sub) * sin(float2(0.11, 0.13) * time + length(q) * 4.0);
    q *= 0.7 + 0.2 * cos(0.05 * time);

    o = 0.5 + 0.5 * fbm4_2(q, low);
    o += 0.02 * sin(float2(0.13, 0.11) * time * length(o));

    n = fbm6_2(4.0 * o, low);

    float2 p = q + 2.0 * n + 1.0;
    float f = 0.5 + 0.5 * fbm4(2.0 * p, low);

    f = mix(f, f * f * f * 3.5, f * abs(n.x));
    f *= 1.0 - 0.5 * pow(0.5 + 0.5 * sin(8.0 * p.x) * sin(8.0 * p.y), 8.0);

    return f;
}

// Updated stitchable shader function with audio frequency parameters
[[stitchable]] half4 fluidTexture(float2 pos, half4 color, float2 size, float time, float sub, float low, float mid, float hi, float treble) {
    float2 uv = pos / size;
    uv = uv * 2.0 - 1.0;
    uv *= 2.0;

    float2 o, n;
    float f = func(uv, o, n, time, sub, low);

    // Enhanced color mixing using high and treble frequencies
    float3 baseColor = float3(0.2 + 0.3 * hi, 0.1, 0.4 + 0.3 * treble);
    float3 accentColor = float3(0.3 + 0.4 * treble, 0.05, 0.05 + 0.3 * hi);
    
    float3 col = mix(baseColor, accentColor, f);
    col = mix(col, float3(0.9, 0.9, 0.9), dot(n, n));
    col = mix(col, float3(0.5, 0.2, 0.2), 0.5 * o.y * o.y);
    col = mix(col, float3(0.0, 0.2, 0.4), 0.5 * smoothstep(1.2, 1.3, abs(n.y) + abs(n.x)));

    // Intensity modulation using low frequency
    col *= f * (2.0 + low);
    
    return half4(half3(col), 1.0);
}
