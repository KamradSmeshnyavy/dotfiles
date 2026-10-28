#version 300 es
precision highp float;

// Animated CRT for Hyprland's decoration:screen_shader: crt-static.frag plus
// brightness flicker, a rolling scan band and periodic horizontal glitches.
//
// *** POWER WARNING ***
// Any shader using the `time` uniform needs debug:damage_tracking = 0, i.e.
// the whole 2880x1800 screen is recomposited at 120 Hz forever, even when
// nothing moves (Hyprland freezes `time` at 0 otherwise). That is the single
// biggest power cost you can add to the compositor - prefer bettercrt.frag
// or crt-static.frag for daily use. crt-toggle.sh sets the right mode.

in vec2 v_texcoord;
layout(location = 0) out vec4 fragColor;

uniform sampler2D tex;
uniform vec2 fullSize;
uniform float time;

// ---------------------------------------------------------------------
// PARAMETERS
// ---------------------------------------------------------------------
const float CURVATURE          = 0.05;
const float EDGE_SOFTNESS_PX   = 3.0;
const float CA_STRENGTH_PX     = 1.2;
const float SCANLINE_STRENGTH  = 0.12;
const float SCANLINE_PERIOD_PX = 4.0;
const float MASK_STRENGTH      = 0.12;
const float MASK_STRIPE_PX     = 2.0;
const float VIGNETTE_STRENGTH  = 0.30;

const float FLICKER_STRENGTH   = 0.03;  // 0 = off. Range: 0.0-0.15
const float FLICKER_SPEED      = 6.0;

const float ROLL_STRENGTH      = 0.05;  // 0 = off.
const float ROLL_WIDTH         = 0.08;  // Fraction of screen height.
const float ROLL_SPEED         = 0.12;  // Screen heights per second.

const float GLITCH_INTERVAL    = 6.0;   // Seconds between bursts.
const float GLITCH_DURATION    = 0.15;  // Burst length, seconds.
const float GLITCH_STRENGTH_PX = 6.0;   // Max row jitter, px.

float hash11(float p) {
    p = fract(p * 0.1031);
    p *= p + 33.33;
    p *= p + p;
    return fract(p);
}

void main() {
    float t = time;

    vec2 centered = v_texcoord * 2.0 - 1.0;
    float r2 = dot(centered, centered);
    vec2 uv = centered * (1.0 + CURVATURE * r2) * 0.5 + 0.5;

    vec2 edgeDistPx = min(uv, 1.0 - uv) * fullSize;
    float edge = min(edgeDistPx.x, edgeDistPx.y);
    if (edge <= 0.0) {
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }

    // Glitch: the hash is only evaluated during a burst.
    if (mod(t, GLITCH_INTERVAL) > GLITCH_INTERVAL - GLITCH_DURATION) {
        float row = floor(uv.y * fullSize.y);
        uv.x += (hash11(row + floor(t * 30.0)) * 2.0 - 1.0) * GLITCH_STRENGTH_PX / fullSize.x;
    }

    vec2 caOffset = centered * (CA_STRENGTH_PX * r2 * 0.5) / fullSize;
    vec3 color = vec3(texture(tex, uv - caOffset).r,
                      texture(tex, uv).g,
                      texture(tex, uv + caOffset).b);

    float scan = 0.5 - 0.5 * cos(gl_FragCoord.y * (6.2831853 / SCANLINE_PERIOD_PX));
    color *= 1.0 - SCANLINE_STRENGTH * scan;

    float phase = mod(floor(gl_FragCoord.x / MASK_STRIPE_PX), 3.0);
    color *= 1.0 - MASK_STRENGTH * (1.0 - vec3(equal(vec3(phase), vec3(0.0, 1.0, 2.0))));

    color *= clamp(1.0 - VIGNETTE_STRENGTH * r2, 0.0, 1.0);
    color *= clamp(edge / EDGE_SOFTNESS_PX, 0.0, 1.0);

    color *= 1.0 - FLICKER_STRENGTH * (0.5 + 0.5 * sin(t * FLICKER_SPEED));

    float bandDist = abs(fract(uv.y - fract(t * ROLL_SPEED) + 0.5) - 0.5);
    color += smoothstep(ROLL_WIDTH, 0.0, bandDist) * ROLL_STRENGTH;

    fragColor = vec4(color, 1.0);
}
