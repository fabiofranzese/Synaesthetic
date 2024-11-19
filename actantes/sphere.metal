//
//  sphere.metal
//  actantes
//
//  Created by Gabriele Fiore on 19/11/24.
//

#include <metal_stdlib>
using namespace metal;

// Random number generator
float random(float3 p) {
    return fract(sin(dot(p, float3(12.9898, 78.233, 37.719))) * 43758.5453123);
}

// Smooth noise function with interpolation
float smoothNoise(float3 p) {
    float3 i = floor(p);
    float3 f = fract(p);

    // Compute fade curve for interpolation
    float3 u = f * f * (3.0 - 2.0 * f);

    // Corner values
    float n000 = random(i);
    float n100 = random(i + float3(1.0, 0.0, 0.0));
    float n010 = random(i + float3(0.0, 1.0, 0.0));
    float n110 = random(i + float3(1.0, 1.0, 0.0));
    float n001 = random(i + float3(0.0, 0.0, 1.0));
    float n101 = random(i + float3(1.0, 0.0, 1.0));
    float n011 = random(i + float3(0.0, 1.0, 1.0));
    float n111 = random(i + float3(1.0, 1.0, 1.0));

    // Interpolate
    float n00 = mix(n000, n100, u.x);
    float n01 = mix(n001, n101, u.x);
    float n10 = mix(n010, n110, u.x);
    float n11 = mix(n011, n111, u.x);
    float n0 = mix(n00, n10, u.y);
    float n1 = mix(n01, n11, u.y);
    return mix(n0, n1, u.z);
}

// Fractal Brownian Motion (FBM) for layered noise
float fbm(float3 p) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;

    for (int i = 0; i < 5; i++) {
        value += amplitude * smoothNoise(p * frequency);
        frequency *= 2.0;
        amplitude *= 0.5;
    }
    return value;
}

// Shader for liquid sphere
[[stitchable]] half4 liquidSphere(
    float2 pos, half4 color, float2 size, float time,
    float sub, float low, float mid, float hi, float treble) {

    // Normalize UV coordinates to range (-1, 1)
    float2 uv = pos / size * 2.0 - 1.0;

    // Correct aspect ratio to ensure a circular sphere
    uv.x *= size.x / size.y;

    // Apply zoom-out scaling
    uv *= 2.8; // Scale down the sphere (adjust the factor as needed)

    // Avoid out-of-bounds values
    float r = dot(uv, uv);
    if (r > 1.0) {
        return half4(1.0); // Outside the sphere is white
    }

    // Map 2D UV to a 3D sphere
    float z = sqrt(max(0.0, 1.0 - r)); // Prevent invalid sqrt inputs
    float3 spherePos = normalize(float3(uv, z));

    // Compute liquid effect using FBM
    float liquidNoise = fbm(spherePos * (5.0 + low * 5.0) + time * 0.2);
    float displacement = liquidNoise * (0.1 + mid * 0.2);

    // Base liquid color
    float3 liquidColor = float3(0.2, 0.4, 0.8) + displacement;

    // Add shimmer effect based on `hi`
    liquidColor += fbm(spherePos * 10.0 + time * 0.5 + hi) * 0.1;

    // Inside Cube Logic
    float cubeDistance = length(spherePos - float3(0.0, 0.0, 0.0));
    float cubeVisibility = smoothstep(0.3, 0.6, 1.0 - cubeDistance); // Fades at edges
    float3 cubeColor = float3(0.0, 0.0, 1.0) * cubeVisibility; // Blue cube color

    // Combine liquid and cube colors
    float3 finalColor = mix(liquidColor, cubeColor, cubeVisibility);

    // Adjust transparency for the sphere
    float alpha = 0.5; // Semi-transparent sphere
    return half4(half3(finalColor), half(alpha));
}

