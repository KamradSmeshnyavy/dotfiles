#version 300 es
precision highp float;

// "Better CRT" (shadertoy.com/view/WsVSzV, CC BY-NC-SA 3.0) for Hyprland's
// decoration:screen_shader. Same math as kitty's built-in `crt` shader
// (/usr/lib/kitty/kitty/shaders/custom/crt.slang) and Ghostty's bettercrt.glsl:
// independent-axis barrel warp + sin(pixel row) scanlines.
//
// *** REQUIRES debug:damage_tracking = 1 ("monitor") ***
// Hyprland runs the screen shader only over the damaged region of the frame
// (OpenGL.cpp: `damage = finalDamage` before the final blit). The warp moves
// pixels by up to ~27 px at the corners (2880x1800), so with the default
// damage_tracking = 2 the pixels just outside a damaged box never get
// re-warped -> torn strips / stale ghosts next to anything that changes
// (typing, cursor blink, scrolling). Mode 1 repaints the whole monitor, but
// ONLY on frames where something changed; an idle screen still costs nothing.
// Mode 0 is never needed here (no `time` uniform).
// crt-toggle.sh sets this automatically.
//
// Cost: 1 texture fetch + a handful of ALU ops per pixel.

in vec2 v_texcoord;
layout(location = 0) out vec4 fragColor;

uniform sampler2D tex;
uniform vec2 fullSize; // monitor size in physical pixels

// ---------------------------------------------------------------------
// PARAMETERS
// ---------------------------------------------------------------------
const float WARP  = 0.25;  // curvature, same as kitty/ghostty. 0 = flat (then mode 2 is fine too)
const float SCAN  = 0.50;  // scanline darkness, same as kitty/ghostty

// false = exact kitty/ghostty look: sin() of the raw pixel row. Its period
//         is 2*pi px, which never lines up with the pixel grid, so it shows
//         faint wide horizontal bands (~66 px) - that's in kitty too.
// true  = clean, band-free scanlines with a whole-pixel period.
const bool  CLEAN_SCANLINES = false;
const float SCAN_PERIOD_PX  = 4.0;   // CLEAN_SCANLINES only: 4 px = 2 logical px at scale 2

const vec3  BORDER_COLOR = vec3(0.0);

void main() {
    vec2 uv = v_texcoord;

    // Squared distance from center, per axis.
    vec2 dc = abs(0.5 - uv);
    dc *= dc;

    // Each axis is stretched by the other axis's distance (kitty/ghostty warp).
    uv = (uv - 0.5) * (1.0 + dc.yx * (vec2(0.3, 0.4) * WARP)) + 0.5;

    // Antialiased tube edge: distance to the warped border in pixels, clamped
    // to 0..1. Kills the stair-stepped curved edge a hard in/out test gives.
    vec2 edgePx = min(uv, 1.0 - uv) * fullSize;
    float edge  = clamp(min(edgePx.x, edgePx.y) + 0.5, 0.0, 1.0);
    if (edge <= 0.0) {
        fragColor = vec4(BORDER_COLOR, 1.0);
        return;
    }

    float apply;
    if (CLEAN_SCANLINES)
        apply = (0.5 - 0.5 * cos(gl_FragCoord.y * (6.2831853 / SCAN_PERIOD_PX))) * 0.25 * SCAN;
    else
        apply = abs(sin(gl_FragCoord.y)) * 0.25 * SCAN;

    vec3 color = texture(tex, uv).rgb * (1.0 - apply);
    fragColor  = vec4(mix(BORDER_COLOR, color, edge), 1.0);
}
