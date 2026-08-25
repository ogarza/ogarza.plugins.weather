#version 440

// One seed per ShaderEffect sprite (not a fullscreen gather loop).

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
    vec3 tint = hsv2rgb(vec3(hue, mix(0.15, 0.85, sat), 1.0));
    vec3 fluff = mix(vec3(1.0), tint, 0.45);

    float glowAmt = clamp(glow, 0.0, 2.0);
    float tumble = clamp(lightning, 0.0, 2.0);
    float sz = clamp(density, 0.4, 1.6);
    float fi = speed;
    float ang = (time * mix(0.15, 1.35, tumble * 0.5) + fi * 0.7) * (0.4 + sz);
    float ca = cos(ang);
    float sa = sin(ang);
    vec2 q = vec2(ca * rel.x + sa * rel.y, -sa * rel.x + ca * rel.y);
    q.x *= 1.85;
    q.y *= 0.72;
    float d = length(q);
    float sizeN = mix(0.25, 1.6, clamp(scale, 0.0, 2.0) * 0.5) / 1.6;
    float r = 0.04 * (0.55 + sz * 0.9) * sizeN;
    float haloR = r * mix(2.8, 7.5, glowAmt * 0.5);
    float fit = 0.46 / max(haloR, 1.0e-5);
    float k = min(fit, 1.0);
    r *= k;
    haloR *= k;
    float seed = exp(-d * d / max(r * r * 0.28, 1.0e-8));
    float halo = exp(-d * d / max(haloR * haloR * 0.4, 1.0e-8));
    float acc = seed * 1.35 + halo * 0.32 * glowAmt;
    float alpha = clamp(acc, 0.0, 0.85);
    vec3 col = mix(tint, fluff, clamp(seed * 0.5, 0.0, 1.0));
    fragColor = vec4(col * alpha, alpha) * qt_Opacity * clamp(strength, 0.0, 1.0);
    fragColor.a += 0.0 * (sheen + scale + sunDistance + night + nightTint + nightStrength + quality + pixelRatio + resolution.x);
}
