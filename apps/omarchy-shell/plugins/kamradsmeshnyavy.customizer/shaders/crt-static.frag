#version 300 es
precision highp float;

// Static CRT look for Hyprland's decoration:screen_shader: barrel curvature +
// radial chromatic aberration + scanlines + RGB phosphor mask + vignette.
// No `time` uniform: idle screen = zero extra GPU work.
//
// *** REQUIRES debug:damage_tracking = 1 ("monitor") *** - see bettercrt.frag
// for why (warp + partial damage = torn strips). crt-toggle.sh handles it.
//
// Anti-moire: scanlines and the phosphor mask are computed from
// gl_FragCoord (the physical pixel grid), NOT from the warped uv. The old
// version ran a 1-px-period sine and a 3-px mask through the warp, which puts
// them right at/over the Nyquist limit and produced wavy moire bands across
// the whole screen. Periods are now whole pixels and >= 2 px, so every pixel
// gets the same exact value on every frame - no shimmer, no bands.
//
// Cost: 3 texture fetches (1 with CA_STRENGTH_PX = 0; the compiler drops the
// branch because it's a constant).

in vec2 v_texcoord;
layout(location = 0) out vec4 fragColor;

uniform sampler2D tex;
uniform vec2 fullSize;

// ---------------------------------------------------------------------
// PARAMETERS
// ---------------------------------------------------------------------
const float CURVATURE          = 0.05;  // Barrel distortion. 0 = flat. Range: 0.0-0.15
const float EDGE_SOFTNESS_PX   = 3.0;   // Soft fade at the curved border, in pixels.
const float CA_STRENGTH_PX     = 1.2;   // Chromatic aberration at the corners, px. 0 = off (saves 2 fetches).
const float SCANLINE_STRENGTH  = 0.12;  // Scanline darkness. 0 = off. Range: 0.0-0.4
const float SCANLINE_PERIOD_PX = 4.0;   // Whole pixels, >= 2. 4 = 2 logical px at scale 2.
const float MASK_STRENGTH      = 0.12;  // RGB phosphor mask. 0 = off. Range: 0.0-0.4
const float MASK_STRIPE_PX     = 2.0;   // Width of one R/G/B stripe in whole pixels (triad = 3x this).
const float VIGNETTE_STRENGTH  = 0.30;  // Corner darkening. Range: 0.0-0.6

void main() {
    vec2 centered = v_texcoord * 2.0 - 1.0;
    float r2 = dot(centered, centered);
    vec2 uv = centered * (1.0 + CURVATURE * r2) * 0.5 + 0.5;

    vec2 edgeDistPx = min(uv, 1.0 - uv) * fullSize;
    float edge = min(edgeDistPx.x, edgeDistPx.y);
    if (edge <= 0.0) {
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }

    vec3 color;
    if (CA_STRENGTH_PX > 0.0) {
        // Offset grows with r^3 toward the corners; no normalize() needed.
        vec2 caOffset = centered * (CA_STRENGTH_PX * r2 * 0.5) / fullSize;
        color = vec3(texture(tex, uv - caOffset).r,
                     texture(tex, uv).g,
                     texture(tex, uv + caOffset).b);
    } else {
        color = texture(tex, uv).rgb;
    }

    // Scanlines on the physical pixel grid.
    float scan = 0.5 - 0.5 * cos(gl_FragCoord.y * (6.2831853 / SCANLINE_PERIOD_PX));
    color *= 1.0 - SCANLINE_STRENGTH * scan;

    // Aperture-grille mask on the physical pixel grid: branchless R|G|B stripes.
    float phase = mod(floor(gl_FragCoord.x / MASK_STRIPE_PX), 3.0);
    vec3 mask = 1.0 - MASK_STRENGTH * (1.0 - vec3(equal(vec3(phase), vec3(0.0, 1.0, 2.0))));
    color *= mask;

    color *= clamp(1.0 - VIGNETTE_STRENGTH * r2, 0.0, 1.0);
    color *= clamp(edge / EDGE_SOFTNESS_PX, 0.0, 1.0);

    fragColor = vec4(color, 1.0);
}
