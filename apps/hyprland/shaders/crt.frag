#version 300 es
precision highp float;

// Warm "old monitor" CRT: soft barrel, yellow tint, static colour grain,
// rounded dark vignette. No `time` uniform: idle screen = zero extra work.
//
// *** REQUIRES debug:damage_tracking = 1 ("monitor") *** - the barrel moves
// pixels, see bettercrt.frag. crt-toggle.sh handles it.
//
// Fixed vs the previous version:
//   - rand() was fract(sin(uv.x*uv.y) * 423870): x*y is constant along
//     hyperbolas, so the "noise" showed as curved streaks, and the huge
//     multiplier breaks down in float precision on some GPUs. Replaced with a
//     sin-free hash of the integer pixel coordinate (Dave Hoskins' hash13),
//     computed once and reused for all three channels.
//   - Noise was sampled at the warped uv, so it swam/moired with the warp;
//     it's now locked to the physical pixel grid.
//   - Output clamped and alpha forced to 1 (it could go negative/over 1).

in vec2 v_texcoord;
uniform sampler2D tex;
layout(location = 0) out vec4 fragColor;

const float BARREL        = 0.05;
const vec3  TINT          = vec3(0.95, 0.95, 0.59);
const float NOISE         = 0.75;   // grain amount (same as before)

vec3 hash32(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * vec3(0.1031, 0.1030, 0.0973));
    p3 += dot(p3, p3.yxz + 33.33);
    return fract((p3.xxy + p3.yzz) * p3.zyx);
}

void main() {
    vec2 uv = v_texcoord;
    float dist = distance(uv, vec2(0.5));

    // barrel
    uv += (0.5 - uv) * BARREL * (1.0 - smoothstep(0.28, 0.78, dist));

    // soft rounded border
    vec2 bl = smoothstep(0.0, 0.05, uv);
    vec2 tr = smoothstep(0.0, 0.05, 1.0 - uv);
    float box = 1.0 - bl.x * bl.y * tr.x * tr.y;

    vec3 color = texture(tex, uv).rgb;

    // yellow filter + radial falloff
    color *= TINT * (1.0 - dist);

    // static colour grain, brighter on brighter channels
    vec3 n = hash32(floor(gl_FragCoord.xy));
    color += mix(vec3(0.05, 0.05, 0.0), n, color) * NOISE;

    color -= box;

    fragColor = vec4(clamp(color, 0.0, 1.0), 1.0);
}
