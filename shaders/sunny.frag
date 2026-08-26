#version 440

// Warm sunlight overlay: a high-corner glow, faint shafts, and dust motes.
// After sunset, `night` blends the same glow to cool moonlight.
// Premultiplied transparent overlay: no scene texture. Kept low-alpha.

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

float hash11(float n) {
    return fract(sin(n * 127.1) * 43758.5453);
}

void main() {
    vec2 res = max(resolution, vec2(1.0));
    float unit = 1080.0 * max(pixelRatio, 0.05);
    vec2 uv = qt_TexCoord0;
    float aspect = res.x / res.y;
    vec2 p = vec2(uv.x * aspect, uv.y);

    float az = clamp(azimuth, 0.0, 2.0);
    float dAmt = clamp(sunDistance, 0.0, 2.0);
    float sunX = aspect * mix(-0.35, 2.01, az * 0.5);
    float sunY = -0.12 + clamp(lightning, -2.0, 2.0) * 0.58;
    vec2 sun = vec2(sunX, sunY);
    vec2 delta = p - sun;
    float angle = atan(delta.y, delta.x);
    float radial = length(delta);

    float srcR = mix(0.0, 0.30, clamp(scale, 0.0, 2.0) * 0.5);
    float distSurf = max(radial - srcR, 0.0);
    float radialSafe = max(radial, 1e-5);

    // Wide depth range so the slider is obvious. 1.0 is the original cone.
    float z = mix(0.06, 7.5, pow(dAmt * 0.5, 0.85));
    float zRef = mix(0.06, 7.5, pow(0.5, 0.85));
    float fall = z / zRef;
    float dist = length(vec3(delta * (distSurf / radialSafe), z));
    float distScreen = distSurf * fall;

    float glowAmt = clamp(glow, 0.0, 2.0);
    float n = clamp(night, 0.0, 1.0);
    float t = time * 3.5 * max(speed, 0.0);

    float dayWash = exp(-distScreen * 1.1) * 0.28;
    float nightWash = exp(-distScreen * 0.85) * 0.22;
    if (quality > 0.5) {
        dayWash += exp(-distScreen * 2.6) * 0.12;
        nightWash += exp(-distScreen * 1.8) * 0.10;
    }
    if (quality > 2.5) {
        dayWash += exp(-distScreen * 5.2) * 0.07;
        nightWash += exp(-distScreen * 3.6) * 0.06;
    }
    float sunGlow = mix(dayWash, nightWash, n) * glowAmt;
    if (srcR > 0.001)
        sunGlow += (1.0 - smoothstep(srcR * 0.52, srcR, radial)) * mix(0.34, 0.26, n) * glowAmt;

    // Integer lobe counts so sin(n * atan2) is 2π-periodic (no left-side seam).
    float nRays = max(2.0, floor(mix(3.0, 12.0, dAmt * 0.5) + 0.5));
    float nRays2 = max(2.0, nRays - 2.0);
    float nRays3 = nRays + 2.0;
    float sharp = mix(2.2, 26.0, dAmt * 0.5);
    float shafts = pow(max(sin(angle * nRays + t * 0.05) * 0.5 + 0.5, 0.0), sharp);
    float shafts2 = 0.0;
    float shafts3 = 0.0;
    if (quality > 0.5)
        shafts2 = pow(max(sin(angle * nRays2 + 0.7 - t * 0.03) * 0.5 + 0.5, 0.0), sharp + 4.0);
    if (quality > 2.5)
        shafts3 = pow(max(sin(angle * nRays3 + 1.4 + t * 0.04) * 0.5 + 0.5, 0.0), sharp + 8.0);
    float rayFade = mix(0.35, 1.0, exp(-distScreen * mix(0.08, 0.55, dAmt * 0.5)));
    float rayAmt = mix(1.0, 0.40, n);
    float cone = pow(zRef / max(dist, 0.001), mix(0.15, 1.8, dAmt * 0.5));
    float shaftMask = srcR < 0.001 ? 1.0 : smoothstep(srcR * 0.86, srcR * 1.14, radial);
    shafts = shafts * mix(0.34, 0.10, dAmt * 0.5) * glowAmt * rayFade * rayAmt * cone * shaftMask;
    shafts2 = shafts2 * mix(0.18, 0.05, dAmt * 0.5) * glowAmt * rayFade * rayAmt * cone * shaftMask;
    shafts3 = shafts3 * mix(0.10, 0.03, dAmt * 0.5) * glowAmt * rayFade * rayAmt * cone * shaftMask;

    float motes = 0.0;
    int moteCount = quality < 0.5 ? 4 : quality < 1.5 ? 8 : quality < 2.5 ? 18 : 24;
    for (int i = 0; i < 24; i++) {
        if (i >= moteCount)
            break;
        float fi = float(i);
        float sx = hash11(fi + 1.7);
        float sy = hash11(fi + 8.3);
        float moteSpeed = 0.006 + sx * 0.012;
        vec2 pos = vec2(
            fract(sx + t * moteSpeed * 0.35) * aspect,
            fract(sy + t * moteSpeed * 0.22 + sx * 0.1)
        );
        float r = (2.4 + hash11(fi + 3.1) * 4.0) / unit;
        float d = length(p - pos);
        float spark = smoothstep(r * 2.4, 0.0, d);
        spark *= 0.35 + 0.65 * (0.5 + 0.5 * sin(t * (1.3 + sx * 2.0) + fi));
        motes += spark;
    }
    motes *= glowAmt * mix(1.0, 0.55, n) * clamp(density, 0.0, 2.0);

    vec3 gold = vec3(1.0, 0.86, 0.55);
    vec3 warm = vec3(1.0, 0.93, 0.78);
    vec3 steel = vec3(0.55, 0.66, 0.92);
    vec3 silver = vec3(0.82, 0.88, 1.0);
    float heat = clamp(sunGlow * 1.4, 0.0, 1.0);
    vec3 col = mix(mix(gold, warm, heat), mix(steel, silver, heat), n);
    float alpha = sunGlow * mix(0.22, 0.18, n) + shafts + shafts2 + shafts3 + motes * mix(0.16, 0.10, n);
    alpha = clamp(alpha, 0.0, mix(0.72, 0.22, dAmt * 0.5) * mix(1.0, 0.72, n));

    fragColor = vec4(col * alpha, alpha) * qt_Opacity * clamp(strength, 0.0, 1.0);
    fragColor.a += 0.0 * (sheen + azimuth + sunDistance + nightTint + nightStrength);
}
