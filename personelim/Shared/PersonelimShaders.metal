#include <metal_stdlib>
using namespace metal;

float hash21(float2 p) {
    p = fract(p * float2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

float noise(float2 p) {
    float2 i = floor(p);
    float2 f = fract(p);

    float a = hash21(i);
    float b = hash21(i + float2(1.0, 0.0));
    float c = hash21(i + float2(0.0, 1.0));
    float d = hash21(i + float2(1.0, 1.0));

    float2 u = f * f * (3.0 - 2.0 * f);

    return mix(
        mix(a, b, u.x),
        mix(c, d, u.x),
        u.y
    );
}

float lineGlow(float2 uv, float offset, float time, float thickness) {
    float wave =
        sin(uv.x * 3.0 + time * 0.9 + offset) * 0.12 +
        sin(uv.x * 7.0 - time * 0.55 + offset) * 0.045 +
        sin(uv.x * 13.0 + time * 0.35 + offset) * 0.020;

    float n = noise(float2(uv.x * 3.0 + time * 0.08, offset)) * 0.08;

    float y = 0.50 + wave + n;
    float d = abs(uv.y - y);

    return smoothstep(thickness, 0.0, d);
}

[[ stitchable ]]
half4 onboardingAurora(
    float2 position,
    half4 color,
    float time,
    float2 size
) {
    float2 uv = position / size;

    uv.x *= size.x / size.y;

    float3 base = float3(0.985, 0.985, 0.970);

    float3 orange = float3(1.00, 0.42, 0.04);
    float3 red = float3(0.95, 0.06, 0.04);
    float3 green = float3(0.00, 0.52, 0.24);
    float3 gold = float3(1.00, 0.68, 0.12);

    float glow = 0.0;
    float3 waveColor = float3(0.0);

    for (int i = 0; i < 7; i++) {
        float fi = float(i);

        float g = lineGlow(
            uv,
            fi * 0.85,
            time,
            0.018 + fi * 0.002
        );

        float soft = lineGlow(
            uv,
            fi * 0.85,
            time,
            0.070 + fi * 0.008
        );

        float3 c;

        if (i % 3 == 0) {
            c = orange;
        } else if (i % 3 == 1) {
            c = red;
        } else {
            c = green;
        }

        waveColor += c * g * 0.85;
        waveColor += c * soft * 0.18;
        glow += g;
    }

    float vignette = smoothstep(1.25, 0.20, distance(position / size, float2(0.5, 0.5)));

    float3 finalColor = base;
    finalColor += waveColor;
    finalColor += gold * glow * 0.05;
    finalColor = mix(base, finalColor, vignette);

    return half4(half3(finalColor), 1.0);
}
