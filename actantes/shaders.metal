#include <metal_stdlib>
using namespace metal;

// Define the sinebow function, which will animate based on position and time
[[stitchable]] half4 sinebow(float2 pos, half4 color, float2 s, float t) {
    float2 uv = (pos / s) * 2 - 1; // Normalize position based on both width and height
    uv.y -= 0.25;                 // Offset y slightly
    float wave = sin(uv.x + t);   // Compute sine wave using x-position and time
    wave *= wave * 50;           // Amplify the wave effect
    half3 waveColor = half3(0);

    for (float i = 0; i < 10; i++) {
        float luma = abs(1 / (100 * uv.y + wave)); // Calculate luminance dynamically
        float y = sin(uv.x * sin(t) + i * 0.2 + t);
        uv.y += 0.05 * y;          // Add a dynamic wobble effect
        half3 rainbow = half3(
            sin(i * 0.3 + t) * 0.5 + 0.5,                     // Red
            sin(i * 0.3 + 2 + sin(t * 0.3) * 2) * 0.5 + 0.5, // Green
            sin(i * 0.3 + 4) * 0.5 + 0.5                      // Blue
        );
        waveColor += rainbow * luma;
    }

    // Return the accumulated waveColor outside the loop
    return half4(waveColor, 1.0);
}
