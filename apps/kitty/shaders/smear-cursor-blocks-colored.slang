#language slang 2026
// Block-style cursor smear with fully configurable colors.
// Cell-snapped trail, port of a Ghostty (Shadertoy-style GLSL) shader to kitty.
// Physics derived from smear-cursor.nvim (overdamped spring): https://github.com/sphamba/smear-cursor.nvim
//
// Pair with smear-blocks.pipeline (animation_start cursor-trail-move) and
// `cursor_trail 1` in kitty.conf. Use a block cursor shape.
//
// Every `static const` below can be overridden from the pipeline file without editing
// this file, e.g.   var float3 TRAIL_COLOR_HEAD = float3(0.769, 0.655, 0.906)
//
// ======================================================================
// COLORS. All colors are plain sRGB, i.e. hex / 255 (#ebbcba = 235/255, 188/255, 186/255).
// Unlike kitty's built-in shaders you do NOT need to convert to linear RGB;
// the shader does that itself.
// ======================================================================
// TRAIL_COLOR_HEAD   Color of the trail next to the cursor (the leading end).
// TRAIL_COLOR_TAIL   Color of the trail at its trailing end. The trail fades from
//                    head color to tail color along its length. Set both to the same
//                    value for a flat color.
// HEAD_FROM_CURSOR   true = use kitty's actual cursor color as the head color instead
//                    of TRAIL_COLOR_HEAD (follows your `cursor` setting / theme).
// EDGE_COLOR         Color that partially filled edge cells (the ragged block borders)
//                    are tinted toward.
// EDGE_COLOR_MIX     How much of EDGE_COLOR to mix into edge cells. 0 = no tint. Range: 0.0-1.0
// INVERT_BACKGROUND  true = ignore all colors above and use reverse video, like the
//                    original: the trail inverts whatever background is under it.
//
// ======================================================================
// SHAPE AND TIMING
// ======================================================================
// HEAD_RATE       How fast the leading edge reaches the target cursor position.
//                 Higher = head arrives faster, trail stretches more. Range: 30-200.
// TAIL_RATE       How fast the trailing edge catches up to the head.
//                 Higher = shorter trail duration, lower = tail lingers. Range: 3-30.
//                 The trail is nearly invisible after ~6 / TAIL_RATE seconds, so keep
//                 animation_stop in the pipeline about that long.
// TRAIL_OPACITY   Overall opacity of the trail. Range: 0.0-1.0
// TRAIL_RADIUS    Thickness of the trail perpendicular to movement, as a multiplier
//                 of the cursor cell size. Range: 0.3-1.0
// TRAIL_TIMEOUT   Hard cap on the effect duration in seconds. Range: 0.3-2.0
// TAIL_FADE_MIN   Minimum opacity at the tail end (head is always 1.0). Range: 0.0-1.0
// FILL_STEPS      Quantization steps for partial block fills at edges.
//                 8 = fine, 2 = half-blocks only. Range: 2-16
// CHAOS_DECAY     How fast early-frame randomization fades. Higher = more subtle. Range: 10-100
// CHAOS_DROPOUT   Probability of skipping cells in early frames. Range: 0.0-0.8
// CHAOS_SCATTER   Perpendicular scatter of cells in early frames, in cell heights. Range: 0.0-5.0
// CHAOS_RADIUS    Per-cell trail radius jitter in early frames, in cell heights. Range: 0.0-3.0
// FILL_JITTER     Random variation of partial fills at edge cells. Range: 0.0-0.5

import kitty_custom_shader_types;

// Colors (sRGB). Defaults: Rose Pine, rose -> iris.
static const float3 TRAIL_COLOR_HEAD = float3(0.922, 0.737, 0.729); // rose #ebbcba
static const float3 TRAIL_COLOR_TAIL = float3(0.769, 0.655, 0.906); // iris #c4a7e7
static const bool HEAD_FROM_CURSOR = false;
static const float3 EDGE_COLOR = float3(0.612, 0.812, 0.847); // foam #9ccfd8
static const float EDGE_COLOR_MIX = 0.0;
static const bool INVERT_BACKGROUND = false;

// Shape and timing.
static const float HEAD_RATE = 200.0;
static const float TAIL_RATE = 8.0;
static const float TRAIL_OPACITY = 1.0;
static const float TRAIL_RADIUS = 0.3;
static const float TRAIL_TIMEOUT = 2.0;
static const float TAIL_FADE_MIN = 0.3;
static const float FILL_STEPS = 4.0;
static const float CHAOS_DECAY = 40.0;
static const float CHAOS_DROPOUT = 0.8;
static const float CHAOS_SCATTER = 3.5;
static const float CHAOS_RADIUS = 1.5;
static const float FILL_JITTER = 0.5;

// Distance from point p to line segment a-b.
static float
sdSegment(float2 p, float2 a, float2 b) {
    float2 pa = p - a;
    float2 ba = b - a;
    float h = clamp(dot(pa, ba) / max(dot(ba, ba), 1e-7), 0.0, 1.0);
    return length(pa - ba * h);
}

// Per-cell hash, seeded by the cursor change time.
static float
cellHash(float2 cellIdx, float seed) {
    return frac(sin(dot(cellIdx + seed, float2(127.1, 311.7))) * 43758.5453);
}

// kitty shaders work in linear RGB; colors you configure are sRGB.
static float3
linearToSrgb(float3 c) {
    c = saturate(c);
    return lerp(1.055 * pow(c, float3(1.0 / 2.4)) - 0.055, c * 12.92, step(c, float3(0.0031308)));
}

static float3
srgbToLinear(float3 c) {
    return lerp(pow((c + 0.055) / 1.055, float3(2.4)), c / 12.92, step(c, float3(0.04045)));
}

public float4
fragment_main(float4 color, KittyTextures t, KittyCustomShaderData d) {
    // No previous cursor position yet (kitty just started): nothing to smear.
    if (d.cursor_trail_prev_edge.y <= 0.0) return color;

    float age = d.timestamp - d.cursor_trail_change_time;
    if (age < 0.0 || age > TRAIL_TIMEOUT) return color;

    float2 pixelDims = float2(d.viewport_size_pixels) * t.viewport.zw;
    float2 px = t.pos * pixelDims;

    // Cursor rectangle edges: .x=left .y=right .z=top .w=bottom (UV, y-up).
    float4 cur = d.cursor_trail_edge;
    float4 prev = d.cursor_trail_prev_edge;

    // Cell size in pixels, taken from the cursor rectangle (use a block cursor shape).
    float2 cellSize = round(float2(cur.y - cur.x, cur.z - cur.w) * pixelDims);
    if (cellSize.x < 1.0 || cellSize.y < 1.0) return color;

    float2 curCenter = float2((cur.x + cur.y) * 0.5, (cur.z + cur.w) * 0.5) * pixelDims;
    float2 prevCenter = float2((prev.x + prev.y) * 0.5, (prev.z + prev.w) * 0.5) * pixelDims;

    float totalDist = distance(curCenter, prevCenter);
    if (totalDist < 1.0) return color;

    // Overdamped spring: head arrives fast, tail follows slowly.
    float headAlpha = 1.0 - exp(-HEAD_RATE * age);
    float tailAlpha = 1.0 - exp(-TAIL_RATE * age);
    float2 head = lerp(prevCenter, curCenter, headAlpha);
    float2 tail = lerp(prevCenter, curCenter, tailAlpha);

    float2 trailVec = head - tail;
    float trailLen = length(trailVec);
    if (trailLen < 0.5) return color;

    // Cell grid anchored to the cursor's own cell, so it lines up with the real
    // terminal grid even with window padding.
    float2 gridOrigin = float2(cur.x, cur.w) * pixelDims;
    float2 cellIdx = floor((px - gridOrigin) / cellSize);
    float2 cellOrigin = gridOrigin + cellIdx * cellSize;
    float2 cellCenterPx = cellOrigin + cellSize * 0.5;
    float2 subCell = (px - cellOrigin) / cellSize; // 0..1 within the cell

    // Per-cell random values (each cursor movement gets its own pattern).
    float rng = cellHash(cellIdx, d.cursor_trail_change_time);
    float rng2 = cellHash(cellIdx, d.cursor_trail_change_time + 73.0);
    float rng3 = cellHash(cellIdx, d.cursor_trail_change_time + 197.0);

    // Strong randomization in early frames, fading as the trail develops.
    float chaos = exp(-age * CHAOS_DECAY);

    // Randomly skip cells in early frames.
    if (rng2 < chaos * CHAOS_DROPOUT) return color;

    // Direction-aware radius: horizontal movement has a vertical cross-section
    // (cell height), vertical movement a horizontal one (cell width).
    float2 moveDir = (curCenter - prevCenter) / totalDist;
    float perpExtent = abs(moveDir.y) * cellSize.x + abs(moveDir.x) * cellSize.y;
    float radius = perpExtent * TRAIL_RADIUS + chaos * (rng - 0.5) * cellSize.y * CHAOS_RADIUS;

    // Scatter cells perpendicular to the trail axis in early frames.
    float2 perpDir = normalize(float2(-trailVec.y, trailVec.x));
    float2 scatteredCenter = cellCenterPx + perpDir * chaos * (rng3 - 0.5) * cellSize.y * CHAOS_SCATTER;

    float dist = sdSegment(scatteredCenter, tail, head);
    if (dist > radius + cellSize.y * 0.5) return color; // outside the trail

    // Don't draw over the current cursor cell.
    float2 toCur = abs(cellCenterPx - curCenter);
    if (toCur.x < cellSize.x * 0.6 && toCur.y < cellSize.y * 0.6) return color;

    // Fill fraction for this cell.
    float fillAmount;
    if (dist <= radius - cellSize.y * 0.25) {
        fillAmount = 1.0; // fully inside the trail
    } else {
        // Edge cell: partial fill with jitter, quantized to FILL_STEPS.
        fillAmount = 1.0 - (dist - (radius - cellSize.y * 0.25)) / (cellSize.y * 0.75);
        fillAmount = clamp(fillAmount + (rng - 0.5) * FILL_JITTER, 0.0, 1.0);
        fillAmount = floor(fillAmount * FILL_STEPS + 0.5) / FILL_STEPS;
    }
    if (fillAmount <= 0.0) return color;

    // Position of this cell along the trail axis (0 at tail, 1 at head).
    float longitudinal = clamp(dot(cellCenterPx - tail, trailVec) / (trailLen * trailLen), 0.0, 1.0);

    // Partial fills: cut the cell like a block character (left/right/top/bottom part).
    if (fillAmount < 1.0) {
        float2 closest = tail + trailVec * longitudinal;
        float2 edgeDir = cellCenterPx - closest;

        if (abs(edgeDir.y) > abs(edgeDir.x)) {
            // Vertical edge: top/bottom partial block. Y is up here.
            if (edgeDir.y > 0.0) {
                if (subCell.y > fillAmount) return color;       // above the axis: fill from bottom
            } else {
                if (subCell.y < 1.0 - fillAmount) return color; // below the axis: fill from top
            }
        } else {
            // Horizontal edge: left/right partial block.
            if (edgeDir.x > 0.0) {
                if (subCell.x > fillAmount) return color;       // right of the axis: fill from left
            } else {
                if (subCell.x < 1.0 - fillAmount) return color; // left of the axis: fill from right
            }
        }
    }

    // Cells closer to the tail fade out.
    float fade = (1.0 - tailAlpha) * lerp(TAIL_FADE_MIN, 1.0, longitudinal);

    // Trail color (linear RGB).
    float3 trailColor;
    if (INVERT_BACKGROUND) {
        // Reverse video: invert the background under the cell center (in sRGB).
        float3 bgSrgb = linearToSrgb(t.backbuffer.Sample(cellCenterPx / pixelDims).rgb);
        trailColor = srgbToLinear(1.0 - bgSrgb);
    } else {
        float3 headColor = srgbToLinear(TRAIL_COLOR_HEAD);
        if (HEAD_FROM_CURSOR && d.cursor_color.a > 0.0) {
            headColor = d.cursor_color.rgb; // already linear
        }
        float3 tailColor = srgbToLinear(TRAIL_COLOR_TAIL);
        trailColor = lerp(tailColor, headColor, longitudinal);
        if (fillAmount < 1.0) {
            trailColor = lerp(trailColor, srgbToLinear(EDGE_COLOR), EDGE_COLOR_MIX);
        }
    }

    float amount = clamp(fade * TRAIL_OPACITY, 0.0, 1.0);
    return float4(lerp(color.rgb, trailColor, amount), color.a);
}
