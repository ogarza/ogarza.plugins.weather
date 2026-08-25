#version 440

// Night stars. Overlay only. Hash grid (not a per-star loop). Three slow
// parallax layers (sheen). lightning = rare fleeting shooting stars.

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

float hash11(float n) {
    return fract(sin(n * 127.1) * 43758.5453);
}

float hash12(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

vec2 hash22(vec2 p) {
    return fract(sin(vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)))) * 43758.5453);
}

void main() {
    vec2 res = max(resolution, vec2(1.0));
    vec2 uv = qt_TexCoord0;
    float aspect = res.x / res.y;
    vec2 p = vec2(uv.x * aspect, uv.y);

    float parallax = clamp(sheen, 0.0, 2.0);
    float meteorAmt = clamp(lightning, 0.0, 2.0);
    float hue = fract(clamp(azimuth, 0.0, 2.0) * 0.5);
    float sat = clamp(frequency * 0.5, 0.0, 1.0);
    vec3 tint = hsv2rgb(vec3(hue, mix(0.02, 0.55, sat), 1.0));
    vec3 hot = mix(vec3(1.0), tint, 0.35);

    float dens = clamp(density, 0.0, 2.4);
    float glowAmt = clamp(glow, 0.0, 2.0);
    float unit = 1080.0 * max(pixelRatio, 0.05);
    float sizePx = mix(0.21, 1.4, clamp(scale, 0.0, 2.0) * 0.5) / unit;
    float occupy = mix(0.035, 0.28, dens / 2.4);
    float gridBase = quality < 0.5 ? 48.0 : quality < 1.5 ? 64.0 : quality < 2.5 ? 80.0 : 96.0;

    float acc = 0.0;
    float coreAcc = 0.0;
    for (int layer = 0; layer < 3; layer++) {
        float fi = float(layer);
        float depth = fi < 0.5 ? 0.28 : (fi < 1.5 ? 0.62 : 1.0);
        float grid = gridBase * mix(1.35, 0.72, depth);
        float pan = time * mix(0.0022, 0.0095, depth) * parallax;
        float dirX = fi < 0.5 ? 1.0 : (fi < 1.5 ? -0.55 : 0.22);
        float dirY = fi < 0.5 ? 0.12 : (fi < 1.5 ? -0.08 : 0.18);
        vec2 panV = vec2(pan * dirX, pan * dirY);
        vec2 origin = vec2(fi * 17.3, fi * 9.1);
        vec2 g = p * grid + panV * grid + origin;
        vec2 cell = floor(g);
        vec2 f = fract(g);
        float r = sizePx * mix(0.38, 1.25, depth) * grid;
        float haloR = r * mix(3.6, 9.5, glowAmt * 0.5);
        for (int n = 0; n < 9; n++) {
            float ox = float(n - 3 * (n / 3)) - 1.0;
            float oy = float(n / 3) - 1.0;
            vec2 cid = cell + vec2(ox, oy);
            vec2 rnd = hash22(cid + vec2(fi * 3.7, 8.2));
            float live = step(1.0 - occupy * mix(1.15, 0.75, depth), rnd.x);
            vec2 sp = hash22(cid + vec2(4.1, fi * 5.3));
            float nCell = cid.x + cid.y * 19.1 + fi * 7.3;
            float amt = clamp(speed, 0.0, 2.0);
            float twinkleOn = step(0.004, amt);
            vec2 dlt = f - vec2(ox, oy) - sp;
            float d = length(dlt);
            if (twinkleOn < 0.5) {
                vec2 starP = (cid + sp - origin) / grid - panV;
                starP.x = (floor(starP.x / aspect * res.x) + 0.5) * aspect / res.x;
                starP.y = (floor(starP.y * res.y) + 0.5) / res.y;
                d = length(p - starP) * grid;
            }
            float phase = hash11(nCell + 21.4) * 6.2831853;
            float pFreq = 2.15 + hash11(nCell + 4.8) * 1.7;
            float raw = 0.5 + 0.5 * sin(time * pFreq + phase);
            float k = amt * 0.18;
            float lo = mix(1.0, 0.08, k);
            float hi = mix(1.0, 1.55, k);
            float twinkle = mix(lo, hi, pow(raw, mix(1.0, 2.2, k)));
            float szJ = 0.4 + hash12(cid + 2.6) * 1.05;
            float rr = r * szJ;
            float hh = haloR * szJ;
            float core = exp(-d * d / max(rr * rr * 0.18, 1.0e-8));
            float halo = exp(-d * d / max(hh * hh * 0.32, 1.0e-8));
            float spark = (core * 2.4 + halo * 0.55 * glowAmt) * twinkle * mix(0.7, 1.2, depth) * live;
            acc += spark;
            coreAcc += core * twinkle * live;
        }
    }

    if (meteorAmt > 0.004) {
        for (int m = 0; m < 8; m++) {
            float fm = float(m);
            float h0 = hash11(fm + 71.3);
            float h1 = hash11(fm + 18.6);
            float period = mix(44.0, 112.0, h0) / (0.28 + meteorAmt * 0.9);
            float phaseT = time + h1 * 47.0;
            float cycleN = floor(phaseT / period);
            float inCycle = mod(phaseT, period);
            float seed = fm * 19.0 + cycleN * 7.13;
            float hDir = hash11(seed + 1.1);
            float hClose = hash11(seed + 2.7);
            float hOrigX = hash11(seed + 3.9);
            float hOrigY = hash11(seed + 4.4);
            float hLife = hash11(seed + 5.8);
            float near = mix(0.22, 1.0, hClose * hClose);
            float life = mix(0.38, 0.16, near) * mix(0.85, 1.2, hLife);
            float u = inCycle / max(life, 0.08);
            float vis = (1.0 - step(1.0, u))
                * smoothstep(0.0, 0.12, u)
                * (1.0 - smoothstep(0.62, 1.0, u));
            float ang = hDir * 6.2831853;
            vec2 dir = vec2(cos(ang), sin(ang));
            vec2 origin = vec2(hOrigX * aspect, hOrigY);
            float travel = mix(0.22, 0.95, near);
            vec2 head = origin + dir * u * travel;
            vec2 rel = p - head;
            float along = dot(rel, dir);
            float perp = length(rel - dir * along);
            float rh = mix(0.85, 3.4, near) / unit;
            float tw = mix(0.45, 2.1, near) / unit;
            float tailLen = mix(0.018, 0.11, near);
            float headGlow = exp(-dot(rel, rel) / max(rh * rh * 0.35, 1.0e-8));
            float tail = exp(-perp * perp / max(tw * tw * 0.55, 1.0e-8))
                * smoothstep(tailLen, 0.0, -along)
                * smoothstep(0.003, -0.001, along);
            float fade = vis * vis * mix(0.4, 1.25, near);
            acc += (headGlow * 3.2 + tail * 1.15) * fade;
            coreAcc += headGlow * fade;
        }
    }

    float alpha = clamp(acc, 0.0, 1.0);
    vec3 col = mix(tint, hot, clamp(coreAcc, 0.0, 1.0));
    fragColor = vec4(col * alpha, alpha) * qt_Opacity * clamp(strength, 0.0, 1.0);
    fragColor.a += 0.0 * (sunDistance + night + nightTint + nightStrength);
}
