#version 300 es
precision highp float;

// "Thin Film LCD" look for Hyprland's decoration:screen_shader.
// Same API contract as crt-static.frag (confirmed against Hyprland's own
// source: tex/v_texcoord/fragColor from the official example, fullSize set
// unconditionally every frame). No `time` uniform, so damage tracking keeps
// working normally and this costs nothing while the screen isn't changing -
// same energy story as the static CRT version.
//
// Swaps the CRT-specific effects (tube curvature, scanlines, dot-mask glow)
// for panel-specific ones: a flat RGB sub-pixel stripe (how a real TFT panel
// is physically wired, not a CRT phosphor triad), a faint screen-door pixel
// grid, raised/blue-tinted "IPS blacks" from backlight leakage, soft
// corner backlight bleed/glow, and a fixed matte-coating grain. No
// curvature or vignette-as-darkening in the CRT sense - LCDs are flat and
// their brightness problems are backlight-driven (bleed/glow), not
// tube-geometry darkening.
//
// Usage: ~/.config/hypr/shaders/tft.frag, then in hyprland.conf:
//   decoration:screen_shader = ~/.config/hypr/shaders/tft.frag
// After editing, `hyprctl reload` to force a recompile.
// Only one decoration:screen_shader can be active at a time - this replaces
// crt-static.frag rather than stacking with it.

in vec2 v_texcoord;
layout(location = 0) out vec4 fragColor;

uniform sampler2D tex;
uniform vec2 fullSize;

// ---------------------------------------------------------------------
// PARAMETERS - edit these constants directly.
// ---------------------------------------------------------------------
// PIXEL_SCALE groups this many real screen pixels into one simulated "LCD
// pixel". On a high-DPI panel the real sub-pixel pitch is too fine to see,
// so this fakes a coarser, more visible panel. Raise it for a more visible
// (lower "resolution") grid/stripe effect, lower it for subtlety.
const float PIXEL_SCALE        = 3.0;   // Range: 1.0-6.0

const float SUBPIXEL_STRENGTH  = 0.12;  // RGB vertical stripe mask. 0 = off. Range: 0.0-0.35
const float GRID_STRENGTH      = 0.10;  // Screen-door pixel-grid darkness. 0 = off. Range: 0.0-0.3
const float GRID_LINE_WIDTH_PX = 1.0;   // Grid line thickness, in real pixels.

const float BLACK_LEVEL        = 0.025; // How much backlight leaks through "black". Range: 0.0-0.08
const vec3  BLACK_TINT         = vec3(0.10, 0.16, 0.28); // Cool/blue "IPS black" tint (sRGB-ish, 0-1).

const float VIGNETTE_STRENGTH  = 0.06;  // Gentle overall edge darkening. Range: 0.0-0.2
const float BLEED_RADIUS       = 0.35;  // Reach of corner backlight bleed, in UV units. Range: 0.1-0.6
const float BLEED_STRENGTH     = 0.05;  // Brightness added by corner bleed. 0 = off. Range: 0.0-0.15
const vec3  BLEED_TINT         = vec3(1.0, 0.97, 0.90); // Warm-white "IPS glow" tint.

const float GRAIN_STRENGTH     = 0.012; // Fixed matte anti-glare grain. 0 = off. Range: 0.0-0.03

float hash21(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

void main() {
    vec2 uv = v_texcoord;
    vec3 color = texture(tex, uv).rgb;

    // Position in simulated-LCD-pixel units.
    vec2 gridPos = uv * fullSize / PIXEL_SCALE;

    // RGB vertical sub-pixel stripe (real TFT panels are wired R|G|B columns,
    // not a CRT dot triad).
    float subBand = floor(fract(gridPos.x) * 3.0);
    vec3 stripe;
    if (subBand < 1.0)      stripe = vec3(1.0, 1.0 - SUBPIXEL_STRENGTH, 1.0 - SUBPIXEL_STRENGTH);
    else if (subBand < 2.0) stripe = vec3(1.0 - SUBPIXEL_STRENGTH, 1.0, 1.0 - SUBPIXEL_STRENGTH);
    else                     stripe = vec3(1.0 - SUBPIXEL_STRENGTH, 1.0 - SUBPIXEL_STRENGTH, 1.0);
    color *= stripe;

    // Screen-door effect: faint dark lines at the boundary of each simulated pixel.
    vec2 cellFrac = fract(gridPos);
    vec2 edgeDistPx = min(cellFrac, 1.0 - cellFrac) * PIXEL_SCALE;
    float gridLine = 1.0 - smoothstep(0.0, GRID_LINE_WIDTH_PX, min(edgeDistPx.x, edgeDistPx.y));
    color *= 1.0 - GRID_STRENGTH * gridLine;

    // Raised, blue-tinted blacks from backlight leakage through the panel.
    color = color * (1.0 - BLACK_LEVEL) + BLACK_LEVEL * BLACK_TINT;

    // Gentle overall vignette (much subtler than a CRT tube's).
    float distCenter = clamp(length(uv - 0.5) * 2.0, 0.0, 1.0);
    color *= 1.0 - VIGNETTE_STRENGTH * distCenter;

    // Corner backlight bleed / "IPS glow" - brightening, not darkening.
    float bleed = 0.0;
    bleed += smoothstep(BLEED_RADIUS, 0.0, distance(uv, vec2(0.0, 0.0)));
    bleed += smoothstep(BLEED_RADIUS, 0.0, distance(uv, vec2(1.0, 0.0)));
    bleed += smoothstep(BLEED_RADIUS, 0.0, distance(uv, vec2(0.0, 1.0)));
    bleed += smoothstep(BLEED_RADIUS, 0.0, distance(uv, vec2(1.0, 1.0)));
    color += bleed * BLEED_STRENGTH * BLEED_TINT;

    // Fixed matte anti-glare coating grain (static - it's a coating texture,
    // not sensor noise, so it shouldn't sparkle frame to frame).
    float grain = hash21(floor(uv * fullSize)) - 0.5;
    color += grain * GRAIN_STRENGTH;

    fragColor = vec4(clamp(color, 0.0, 1.0), 1.0);
}
