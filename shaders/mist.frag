#version 440

// Ground mist / rolling fog. FBM haze denser toward the bottom, faded at the
// very top so the desktop stays readable. Overlay only.

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

float hash(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p, int octaves) {
    float v = 0.0;
    float a = 0.5;
    v += a * noise(p);
    if (octaves < 2) return v;
    p = p * 2.03 + vec2(17.1, 9.2); a *= 0.5;
    v += a * noise(p);
    if (octaves < 3) return v;
    p = p * 2.03 + vec2(3.7, 13.8); a *= 0.5;
    v += a * noise(p);
    if (octaves < 4) return v;
    p = p * 2.03 + vec2(11.3, 5.4); a *= 0.5;
    v += a * noise(p);
    if (octaves < 5) return v;
    p = p * 2.03 + vec2(7.9, 21.6); a *= 0.5;
    v += a * noise(p);
    if (octaves < 6) return v;
    p = p * 2.03 + vec2(19.4, 2.6); a *= 0.5;
    v += a * noise(p);
    return v;
}

void main() {
    vec2 res = max(resolution, vec2(1.0));
    vec2 uv = qt_TexCoord0;
    float aspect = res.x / res.y;

    float yb = 1.0 - uv.y;
    float base = clamp(sheen, -2.0, 2.0) * 0.40;
    float span = mix(0.22, 1.05, clamp(lightning, 0.0, 2.0) * 0.5);
    float yPacked = (yb - base) / max(span, 0.08);
    vec2 p = vec2(uv.x * aspect, 1.0 - yPacked);

    float t = time * 0.12 * max(speed, 0.0);
    vec2 drift = vec2(t * 0.62, t * 0.07);
    int octaves = quality < 0.5 ? 2 : quality < 1.5 ? 3 : quality < 2.5 ? 5 : 6;
    float feat = mix(2.4, 0.5, clamp(scale, 0.0, 2.0) * 0.5);
    float n = fbm(p * 1.55 * feat + drift, octaves);
    if (quality > 0.5)
        n = fbm(p * 1.05 * feat + vec2(n * 0.9, t * 0.14) + drift * 0.4, octaves);

    float band = smoothstep(-0.05, 0.02, yPacked) * (1.0 - smoothstep(0.58, 1.06, yPacked));
    float cover = smoothstep(0.26, 0.78, n) * band;
    cover = mix(cover * 0.5, cover, smoothstep(0.4, 0.82, n));
    cover *= clamp(density, 0.0, 2.0);

    float hue = fract(clamp(azimuth, 0.0, 2.0) * 0.5);
    float sat = 0.16;
    vec3 tint = hsv2rgb(vec3(hue, sat, 0.92));
    vec3 cool = mix(vec3(0.55, 0.62, 0.70), tint, 0.55);
    vec3 bright = mix(vec3(0.88, 0.90, 0.93), tint, 0.25);
    vec3 col = mix(cool, bright, clamp(n * 1.1, 0.0, 1.0));
    col *= mix(0.75, 1.15, clamp(glow, 0.0, 2.0) * 0.5);

    float alpha = clamp(cover * 0.52, 0.0, 0.78);
    fragColor = vec4(col * alpha, alpha) * qt_Opacity * clamp(strength, 0.0, 1.0);
    fragColor.a += 0.0 * (frequency + sunDistance + night + nightTint + nightStrength + pixelRatio);
}
