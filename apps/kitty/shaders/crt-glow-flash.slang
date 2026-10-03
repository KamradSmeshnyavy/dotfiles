#language slang 2026
// In-game CRT cursor flash - port of "In-game CRT shader" (author: sarphiv, CC BY-NC-SA 4.0)
// from Ghostty/Shadertoy GLSL to kitty's custom shader format.
//
// Highlights the cursor on every change/move with a brief glow, plus a triangular
// "beam" toward the previous position for large jumps. This is a fast FLASH
// (roughly 100-200 ms with default settings), not a lingering trail.
//
// Pair with crt-glow-flash.pipeline (animation_start cursor-trail-move) and
// `cursor_trail 1` in kitty.conf. Works with any cursor shape (block/beam/underline).
//
// Every `static const` below can be overridden from the pipeline file without editing
// this file, e.g.   var float3 GLOW_COLOR_CURRENT = float3(0.2, 0.4, 1.0)
//
// ======================================================================
// COLORS. All color params are plain sRGB, i.e. hex / 255 (#ebbcba = 235/255, 188/255, 186/255).
// The shader converts to linear RGB internally.
// ======================================================================
// FORCE_OVERRIDE_COLORS   true (default) = always use GLOW_COLOR_CURRENT/PREVIOUS below,
//                         ignoring kitty's actual cursor color, so you get full manual
//                         control over the glow color. false = use kitty's real cursor
//                         trail color (the `cursor_trail_color`/`cursor` option) and only
//                         fall back to the override colors when that color is close to
//                         grey (this matches the original shader's behavior, designed for
//                         a white/grey terminal cursor).
//                         Note: kitty has no separate "previous cursor color", so with
//                         FORCE_OVERRIDE_COLORS false, both ends of the beam use the same
//                         real cursor color and only the override colors differ (current
//                         vs previous) when a fallback triggers.
// GLOW_COLOR_CURRENT      Glow color used for the current (new) cursor position.
// GLOW_COLOR_PREVIOUS     Glow color used near the previous cursor position / beam base.
// GLOW_COLOR_OVERRIDE_THRESHOLD
//                         (Only used when FORCE_OVERRIDE_COLORS is false.) Use the override
//                         colors when the real cursor color's channel spread is below this
//                         threshold (i.e. it looks white/grey/black). Range: 0.0 - 0.577
// GLOW_COLOR_OFFSET_BRIGHTNESS
//                         Extra brightness added to the glow so it "pops" above the plain
//                         cursor color. Range: 0.0-1.0
//
// ======================================================================
// SHAPE AND TIMING
// ======================================================================
// TRAIL_MIN_DISTANCE   Minimum cursor movement (in UV units, screen diagonal = sqrt(2))
//                      before a beam/trail is drawn instead of just a highlighted cursor.
//                      Range: 0.0-1.41
// TIME_DURATION_FACTOR Slows down the flash. 1.0 = fades out in ~100-150 ms. 2.0 = twice
//                      as slow (~250-300 ms). Scale animation_stop in the pipeline file
//                      together with this (roughly 200 * TIME_DURATION_FACTOR ms).
//                      Range: x > 0

import kitty_custom_shader_types;

static const bool FORCE_OVERRIDE_COLORS = true;
static const float3 GLOW_COLOR_CURRENT = float3(0.2, 0.4, 1.0);
static const float3 GLOW_COLOR_PREVIOUS = float3(0.4, 0.1, 1.0);
static const float GLOW_COLOR_OVERRIDE_THRESHOLD = 0.1;
static const float GLOW_COLOR_OFFSET_BRIGHTNESS = 0.5;
static const float TRAIL_MIN_DISTANCE = 0.1;
static const float TIME_DURATION_FACTOR = 1.0;

static const float EPS = 1e-9;

static float
min3(float a, float b, float c) { return min(a, min(b, c)); }
static float
max3(float a, float b, float c) { return max(a, max(b, c)); }

// Signed distance from p to an axis-aligned rectangle. topLeft/size are in the same
// UV space as everything else here: Y increases upward, so "top" has the larger Y
// and the rectangle extends from topLeft toward (topLeft.x + size.x, topLeft.y - size.y).
static float
sdRectangle(float2 p, float2 topLeft, float2 size) {
    float2 center = topLeft + float2(size.x, -size.y) * 0.5;
    float2 d = abs(p - center) - size * 0.5;
    return length(max(d, float2(0.0))) + min(max(d.x, d.y), 0.0);
}

static float
sdSeg(float2 p, float2 a) {
    float2 c = a * clamp(dot(p, a) / (dot(a, a) + EPS), 0.0, 1.0) - p;
    return sqrt(dot(c, c));
}

static float
sdTriangle(float2 p, float2 a, float2 b, float2 c) {
    a -= p; b -= p; c -= p;

    float3 t = cross(float3(a.x, b.x, c.x), float3(a.y, b.y, c.y));
    float m0 = min3(t.x, t.y, t.z);
    float m1 = max3(t.x, t.y, t.z);
    float s = -1.0 + 2.0 * step(m0, 0.0) * step(0.0, m1);

    return s * min3(
        sdSeg(a, a - b),
        sdSeg(b, b - c),
        sdSeg(c, c - a)
    );
}

// Distance field for cursor-plus-beam shape: a rectangle at the current cursor,
// widening into a triangular beam toward the previous cursor for large jumps.
static float
sdTrail(float2 p, float2 currPos, float2 currSize, float2 prevPos, float2 prevSize, float t) {
    float2 currWidth = float2(currSize.x, 0.0);
    float2 currHeight = float2(0.0, -currSize.y);
    float2 currTopLeft = currPos;
    float2 currTopRight = currTopLeft + currWidth;
    float2 currBottomLeft = currTopLeft + currHeight;
    float2 currBottomRight = currBottomLeft + currWidth;
    float2 currCenter = (currTopLeft + currBottomRight) * 0.5;

    float2 prevWidth = float2(prevSize.x, 0.0);
    float2 prevHeight = float2(0.0, -prevSize.y);
    float2 prevTopLeft = prevPos;
    float2 prevTopRight = prevTopLeft + prevWidth;
    float2 prevBottomLeft = prevTopLeft + prevHeight;
    float2 prevBottomRight = prevBottomLeft + prevWidth;
    float2 prevCenter = (prevTopLeft + prevBottomRight) * 0.5;

    bool nearbyPrev = distance(currCenter, prevCenter) < TRAIL_MIN_DISTANCE;
    bool insidePrev = (
        currCenter.x >= prevTopLeft.x && currCenter.x <= prevTopRight.x &&
        currCenter.y <= prevTopLeft.y && currCenter.y >= prevBottomLeft.y
    );

    float rectDist = max(sdRectangle(p, currTopLeft, currSize), 0.0);

    if (nearbyPrev || insidePrev)
        return rectDist;

    float2 corners[4];
    corners[0] = currTopLeft;
    corners[1] = currTopRight;
    corners[2] = currBottomRight;
    corners[3] = currBottomLeft;

    float2 dir = normalize(currCenter - prevCenter);
    float2 triB = corners[0];
    float2 triC = corners[0];
    float minRel = 1.0 / EPS;
    float maxRel = -minRel;

    for (int i = 0; i < 4; ++i) {
        float2 delta = corners[i] - prevCenter;
        float rel = atan2(dir.x * delta.y - dir.y * delta.x, dot(dir, delta));

        if (rel < minRel) { minRel = rel; triB = corners[i]; }
        if (rel > maxRel) { maxRel = rel; triC = corners[i]; }
    }

    float triDist = max(sdTriangle(p, prevCenter, triB, triC), 0.0);

    return min(rectDist, lerp(triDist, rectDist, t));
}

// kitty shaders work in linear RGB; the override colors you configure are sRGB.
static float3
srgbToLinear(float3 c) {
    return lerp(pow((c + 0.055) / 1.055, float3(2.4)), c / 12.92, step(c, float3(0.04045)));
}

// Falls back to an override color when baseColor's channels are close to grey
// (low standard deviation), matching the original shader's "cursor is white/grey"
// detection so a colorful glow still shows up on a plain white cursor.
static float3
colorOverride(float3 baseColor, float3 overrideColor) {
    float3 diff = baseColor - float3(dot(baseColor, float3(1.0)) / 3.0);
    float spread = length(diff) / sqrt(3.0);
    if (spread < GLOW_COLOR_OVERRIDE_THRESHOLD)
        return overrideColor;
    return baseColor;
}

public float4
fragment_main(float4 color, KittyTextures t, KittyCustomShaderData d) {
    // No previous cursor position yet (kitty just started): nothing to flash toward.
    if (d.cursor_trail_prev_edge.y <= 0.0) return color;

    // Cursor rectangles as (topLeft, size) in the same UV space as t.pos:
    // Y increases upward, origin at the bottom-left, values in [0, 1].
    // .x=left .y=right .z=top .w=bottom
    float4 cur = d.cursor_trail_edge;
    float4 prev = d.cursor_trail_prev_edge;

    float2 currPos = float2(cur.x, cur.z);
    float2 currSize = float2(cur.y - cur.x, cur.z - cur.w);
    float2 prevPos = float2(prev.x, prev.z);
    float2 prevSize = float2(prev.y - prev.x, prev.z - prev.w);

    if (currSize.x <= 0.0 || currSize.y <= 0.0) return color;

    float2 currCenter = currPos + currSize * float2(0.5, -0.5);
    float2 prevCenter = prevPos + prevSize * float2(0.5, -0.5);

    float2 uv = t.pos;

    float dCenter = distance(currCenter, prevCenter);
    float dSeg = dot(uv - prevCenter, currCenter - prevCenter) * pow(dCenter + EPS, -2.0);
    bool nearbyPrev = dCenter < TRAIL_MIN_DISTANCE;

    float age = d.timestamp - d.cursor_trail_change_time;
    if (age < 0.0) return color;

    float tShape = 1.0 - pow(1.0 - clamp(age / TIME_DURATION_FACTOR, 0.0, 1.0), 3.0);
    float tVisible = exp(-(age / TIME_DURATION_FACTOR) * 50.0);
    if (tVisible < 0.002) return color; // effectively invisible, skip the rest

    float dTrail = sdTrail(uv, currPos, currSize, prevPos, prevSize, tShape);
    float dTip = nearbyPrev ? 0.0 : clamp(1.0 - abs(dSeg - 1.0), 0.0, 1.0);

    // Real cursor color from kitty (falls back to the plain cursor color when
    // cursor_trail_color is "none"). kitty has no history of a *previous* cursor
    // color, so the same value is reused for both ends unless colors are forced.
    float3 realColor = d.cursor_trail_color.rgb;

    float3 currColor, prevColor;
    if (FORCE_OVERRIDE_COLORS) {
        currColor = srgbToLinear(GLOW_COLOR_CURRENT);
        prevColor = srgbToLinear(GLOW_COLOR_PREVIOUS);
    } else {
        currColor = colorOverride(realColor, srgbToLinear(GLOW_COLOR_CURRENT));
        prevColor = colorOverride(realColor, srgbToLinear(GLOW_COLOR_PREVIOUS));
    }

    float4 glowBase = float4(lerp(prevColor, currColor, dTip), 1.0) + GLOW_COLOR_OFFSET_BRIGHTNESS;
    float4 glowColor = lerp(color, glowBase, pow(dTip, 3.0));
    glowColor = lerp(glowColor, color, pow(smoothstep(0.0, 0.3, dTrail), 0.1));

    float4 trailColor = lerp(float4(1.0), glowColor, pow(smoothstep(0.0, 0.01, dTrail), 0.2));
    float4 trail = lerp(trailColor, color, pow(smoothstep(0.0, nearbyPrev ? 0.01 : 0.1, dTrail), 0.2));
    if (!nearbyPrev) {
        trail = lerp(trailColor, trail, pow(smoothstep(0.0, 6.0, dTip), 0.05));
        trail = lerp(trailColor, trail, pow(smoothstep(0.0, 8.0, dTip), 0.005));
    }

    return lerp(color, trail, tVisible);
}
