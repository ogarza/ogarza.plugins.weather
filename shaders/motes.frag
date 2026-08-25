#version 440

// One mote per ShaderEffect sprite. Glow pulse matches the old fullscreen shader.

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float time;
    vec2 resolution;
    float pixelRatio;
    float strength;
    float density;
    float speed;
    float scale;
    float glow;
    float sheen;
    float lightning;
    float frequency;
    float azimuth;
    float sunDistance;
    float night;
    float nightTint;
    float nightStrength;
    float quality;
};

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
    vec2 rel = qt_TexCoord0 - vec2(0.5);

    float hue = fract(clamp(azimuth, 0.0, 2.0) * 0.5);
    float sat = clamp(frequency * 0.5, 0.0, 1.0);
    vec3 tint = hsv2rgb(vec3(hue, mix(0.12, 0.95, sat), 1.0));
    vec3 hot = mix(vec3(1.0), tint, 0.62);

    float glowAmt = clamp(glow, 0.0, 2.0);
    float pulseAmt = clamp(lightning, 0.0, 2.0) * 0.5;
    float sz = clamp(density, 0.4, 1.7);
    float fi = speed;
    float phase = fract(sin(fi * 127.1) * 43758.5453) * 6.2831853;
    float pFreq = 0.7 + fract(sin(fi * 127.1 + 4.2 * 311.7) * 43758.5453) * 1.9;
    float raw = 0.5 + 0.5 * sin(time * 2.15 * pFreq + phase);
    float wave = pow(raw, mix(1.0, 2.4, pulseAmt * 0.5));
    float pulse = mix(1.0, mix(0.08, 1.2, wave), clamp(pulseAmt, 0.0, 1.0));
    float haloPulse = mix(1.0, mix(0.02, 2.6, wave), pulseAmt * 0.5);

    float d = length(rel);
    float sizeN = mix(0.192, 2.5, clamp(scale, 0.0, 2.0) * 0.5) / 2.5;
    float r = 0.033 * sz * sizeN;
    float haloR = r * mix(5.5, 16.0, glowAmt * 0.5) * mix(1.0, mix(0.4, 1.7, wave), pulseAmt * 0.5);
    float fit = 0.46 / max(haloR, 1.0e-5);
    float k = min(fit, 1.0);
    r *= k;
    haloR *= k;
    float core = exp(-d * d / max(r * r * 0.22, 1.0e-8));
    float halo = exp(-d * d / max(haloR * haloR * 0.28, 1.0e-8));
    float acc = core * 1.55 * pulse + halo * 0.42 * glowAmt * haloPulse;
    float alpha = clamp(acc, 0.0, 0.92);
    vec3 col = mix(tint, hot, clamp(core * pulse * 0.45, 0.0, 1.0));
    fragColor = vec4(col * alpha, alpha) * qt_Opacity * clamp(strength, 0.0, 1.0);
    fragColor.a += 0.0 * (sheen + sunDistance + night + nightTint + nightStrength + quality + pixelRatio + resolution.x);
}
