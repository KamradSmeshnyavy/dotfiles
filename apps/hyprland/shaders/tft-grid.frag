#version 300 es
precision mediump float;

// TFT pixel-grid shader for Hyprland's decoration:screen_shader.
// Port of a minimal Ghostty/Shadertoy shader: darkens the boundary between
// simulated TFT "pixels" (a screen-door grid), nothing else. Kept as
// simple as the original on purpose.
//
// Purely a function of on-screen pixel position - no `time` uniform, so
// Hyprland's damage tracking keeps working normally: this costs nothing
// while the screen isn't changing, same as without a shader.
//
// Optimizations versus a direct line-for-line port:
//   - Uses gl_FragCoord.xy directly (already in physical screen pixels)
//     instead of v_texcoord * fullSize. This drops the fullSize uniform
//     entirely and removes a multiply per pixel.
//   - Replaces the original's step()/step()/max() chain with two compares
//     and a bool. Whether this is actually faster depends on the driver's
//     shader compiler - many will fold both forms to the same code - but it
//     is never more expensive, and it's one fewer uniform to look up.
//   - `mediump` instead of `highp`: there's no large-magnitude math here
//     (no `time`, no trig), so full precision buys nothing. On most desktop
//     Intel iGPUs mediump and highp run identically anyway, so treat this
//     as "correct, costs nothing to try" rather than a guaranteed win.
//
// Usage: ~/.config/hypr/shaders/tft-grid.frag, then in hyprland.conf:
//   decoration:screen_shader = ~/.config/hypr/shaders/tft-grid.frag
// After editing, `hyprctl reload` to force a recompile.
// Only one decoration:screen_shader can be active at a time.

in vec2 v_texcoord;
layout(location = 0) out vec4 fragColor;

uniform sampler2D tex;

// ---------------------------------------------------------------------
// PARAMETERS - edit these constants directly.
// ---------------------------------------------------------------------
const float CELL_SIZE  = 4.0;  // Size of one simulated TFT "pixel", in real screen pixels.
const float STRENGTH   = 0.5;  // How dark the grid lines are. 0 = invisible, 1 = fully black.
const float LINE_WIDTH = 1.2;  // Grid line thickness, in real pixels (matches the original).

void main() {
    vec3 color = texture(tex, v_texcoord).rgb;

    vec2 cell = mod(gl_FragCoord.xy, CELL_SIZE);
    bool onLine = cell.x < LINE_WIDTH || cell.y < LINE_WIDTH;
    color *= onLine ? (1.0 - STRENGTH) : 1.0;

    fragColor = vec4(color, 1.0);
}
