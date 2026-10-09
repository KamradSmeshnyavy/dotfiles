#language slang 2026
// Sparkle cursor trail, power-saving edition. Most of the sparkle-plus look at a
// fraction of the GPU work:
//   comet     trail body with head→tail gradient, glow and glitter
//   sparks    thrown off the path, with star flares on some of them
//   embers    a few slow motes that float up
//   burst     small spark burst where the cursor lands
//   ring      quick shockwave ring on long jumps
//   star      a four-point star that pops on the cursor when it lands
//   pulse     glow flash around the cursor on every move
//
// Where the savings come from:
//   * everything is over in ~0.65 s, so the pipeline stops redrawing quickly
//     (sparkle-plus keeps animating for 3.3 s after every move because of the aura);
//   * one bounding-box test rejects every pixel far from the cursor path before
//     any other math, so almost the whole window costs a few instructions;
//   * fewer particles, one hash per particle, cheap distance rejection before
//     any exp/sin, no motion-blur streaks, no atan2;
//   * typing steps (one-cell moves) spawn only a handful of sparks and no ring.
//
// Pair with sparkle-lite.pipeline and `cursor_trail 1` in kitty.conf.
// Works with block, beam and underline cursors.
//
// PARAMETERS. Every `static const` below can be overridden from the pipeline file with
//   var float RING_INTENSITY = 0
// Setting an *_INTENSITY to 0 disables that effect.
//
// COLORS (sRGB 0..1, i.e. hex / 255: #ebbcba -> float3(0.92, 0.74, 0.73))
// COLOR_MODE        0 = theme cursor colour, 1 = PRIMARY_COLOR/SECONDARY_COLOR, 2 = rainbow
//
// TIMING. The longest effect lasts EMBER_LIFE + 0.15 s; keep animation_stop in
// the pipeline at or above that.

import kitty_custom_shader_types;

// --- colour ---
static const int COLOR_MODE = 0;
static const float3 PRIMARY_COLOR = float3(0.92, 0.74, 0.73);
static const float3 SECONDARY_COLOR = float3(0.77, 0.65, 0.91);
static const float3 HOT_COLOR = float3(1.0, 0.97, 0.9);
static const float RAINBOW_SPEED = 0.25;
static const float RAINBOW_SATURATION = 0.75;
static const float INTENSITY = 1.0;

// --- comet ---
static const float COMET_INTENSITY = 0.8;
static const float COMET_GLOW = 6.0; // glow radius in pixels
static const float GLITTER_INTENSITY = 0.8;
static const float GLITTER_DENSITY = 0.1;
static const float GLITTER_SCALE = 4.0;

// --- sparks ---
static const float SPARK_INTENSITY = 1.2;
static const int SPARK_COUNT = 18;
static const float SPARK_SPEED = 11.0;  // cell heights per second
static const float SPARK_DRAG = 6.0;
static const float SPARK_GRAVITY = 9.0; // cell heights / s^2, negative floats up
static const float SPARK_LIFE = 0.45;   // seconds
static const float SPARK_SIZE = 1.3;    // core radius in pixels
static const float FLARE_CHANCE = 0.3;
static const float FLARE_LENGTH = 5.0;
static const float TWINKLE_SPEED = 16.0; // Hz

// --- embers ---
static const float EMBER_INTENSITY = 0.8;
static const int EMBER_COUNT = 5;
static const float EMBER_LIFE = 0.5;
static const float EMBER_RISE = 1.8; // cell heights per second

// --- landing ---
static const float BURST_INTENSITY = 1.0;
static const int BURST_COUNT = 8;
static const float RING_INTENSITY = 0.7;
static const float RING_SIZE = 1.8; // final radius in cell heights
static const float RING_DURATION = 0.35;
static const float STAR_INTENSITY = 0.8;
static const float PULSE_INTENSITY = 0.4;

static const float SWEEP_TIME = 0.06;
static const float TAU = 6.28318530718;

static float
hash11(float p) {
    p = frac(p * 0.1031);
    p *= p + 33.33;
    p *= p + p;
    return frac(p);
}

static float
hash12(float2 p) {
    float3 p3 = frac(float3(p.x, p.y, p.x) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return frac((p3.x + p3.y) * p3.z);
}

static float3
srgbToLinear(float3 c) {
    c = saturate(c);
    return c * c * (c * 0.2 + 0.8); // cheap ~gamma 2.2 curve, exact at 0 and 1
}

static float3
hueColor(float h) {
    float3 rgb = saturate(abs(frac(h + float3(0.0, 2.0 / 3.0, 1.0 / 3.0)) * 6.0 - 3.0) - 1.0);
    return srgbToLinear(lerp(float3(1.0), rgb, RAINBOW_SATURATION));
}

static float
segDist(float2 p, float2 a, float2 b) {
    float2 ab = b - a;
    float h = clamp(dot(p - a, ab) / max(dot(ab, ab), 1e-7), 0.0, 1.0);
    return length(p - (a + ab * h));
}

static float
sdBox(float2 p, float2 center, float2 hext) {
    float2 q = abs(p - center) - hext;
    return length(max(q, float2(0.0))) + min(max(q.x, q.y), 0.0);
}

// Signed distance to the convex trail quad (negative inside), corners clockwise in y-up space.
static float
sdQuad(float2 p, float2 c0, float2 c1, float2 c2, float2 c3) {
    float d = min(min(segDist(p, c0, c1), segDist(p, c1, c2)), min(segDist(p, c2, c3), segDist(p, c3, c0)));
    float2 e0 = c1 - c0, e1 = c2 - c1, e2 = c3 - c2, e3 = c0 - c3;
    bool inside = e0.x * (p.y - c0.y) - e0.y * (p.x - c0.x) <= 0.0 && e1.x * (p.y - c1.y) - e1.y * (p.x - c1.x) <= 0.0 &&
                  e2.x * (p.y - c2.y) - e2.y * (p.x - c2.x) <= 0.0 && e3.x * (p.y - c3.y) - e3.y * (p.x - c3.x) <= 0.0;
    return inside ? -d : d;
}

// Round spark with an optional four-point star (flare 0 = none).
static float
sparkLight(float2 delta, float size, float flare) {
    float r2 = dot(delta, delta);
    float l = exp(-r2 / (size * size)) + 0.2 / (1.0 + r2 / (size * size * 4.0));
    if (flare > 0.0) {
        float2 a = abs(delta);
        float arm = size * FLARE_LENGTH;
        l += (exp(-a.x / (size * 0.35) - a.y / arm) + exp(-a.y / (size * 0.35) - a.x / arm)) * flare;
    }
    return l;
}

public float4
fragment_main(float4 color, KittyTextures t, KittyCustomShaderData d) {
    float age = d.timestamp - d.cursor_trail_change_time;
    float trailAlpha = d.cursor_trail_color.a;
    // Nothing left to draw: bail out before touching anything else.
    if (trailAlpha <= 0.0 && (age < 0.0 || age > EMBER_LIFE + 0.15)) return color;

    float4 cur = d.cursor_trail_edge; // .x=left .y=right .z=top .w=bottom (UV, y-up)
    float4 prev = d.cursor_trail_prev_edge;
    float2 pixelDims = float2(d.viewport_size_pixels) * t.viewport.zw;
    float2 rect = float2(cur.y - cur.x, cur.z - cur.w) * pixelDims;
    if (rect.x <= 0.0 && rect.y <= 0.0) return color;

    // Character cell from the cursor rectangle (block / beam / underline); cells are ~1:2.
    float cellH = max(max(rect.y, rect.x * 2.0), 1.0);
    float2 cellSize = float2(max(rect.x, cellH * 0.5), cellH);
    float2 cellCenter = float2(cur.x, cur.w) * pixelDims + cellSize * 0.5;
    bool hasMove = prev.z > 0.0;
    float2 prevCenter = hasMove ? float2(prev.x, prev.w) * pixelDims + cellSize * 0.5 : cellCenter;

    // One box around everything any effect can reach. Pixels outside it are
    // untouched, which is nearly the whole window.
    float speed = SPARK_SPEED * cellH;
    float reach = max(speed / SPARK_DRAG + 0.5 * abs(SPARK_GRAVITY) * cellH * SPARK_LIFE * SPARK_LIFE,
                      max(RING_SIZE, EMBER_RISE * EMBER_LIFE)) + cellH * 1.5 + COMET_GLOW * 4.0;
    float2 px = t.pos * pixelDims;
    float2 lo = min(prevCenter, cellCenter) - reach;
    float2 hi = max(prevCenter, cellCenter) + reach;
    if (trailAlpha > 0.0) {
        // kitty's trail tail can lag several moves behind during fast typing.
        float2 glow = float2(COMET_GLOW * 4.0);
        float4 cx = d.cursor_trail_corners_x * pixelDims.x;
        float4 cy = d.cursor_trail_corners_y * pixelDims.y;
        lo = min(lo, float2(min(min(cx.x, cx.y), min(cx.z, cx.w)), min(min(cy.x, cy.y), min(cy.z, cy.w))) - glow);
        hi = max(hi, float2(max(max(cx.x, cx.y), max(cx.z, cx.w)), max(max(cy.x, cy.y), max(cy.z, cy.w))) + glow);
    }
    if (any(px < lo) || any(px > hi)) return color;

    // Palette.
    float3 headCol, tailCol;
    if (COLOR_MODE == 1) {
        headCol = srgbToLinear(PRIMARY_COLOR);
        tailCol = srgbToLinear(SECONDARY_COLOR);
    } else if (COLOR_MODE == 2) {
        float h = frac(d.timestamp * RAINBOW_SPEED);
        headCol = hueColor(h);
        tailCol = hueColor(h + 0.35);
    } else {
        headCol = d.cursor_color.rgb;
        if (dot(headCol, headCol) < 1e-4) headCol = d.foreground.rgb;
        tailCol = lerp(headCol, d.foreground.rgb, 0.3);
    }
    float3 hot = srgbToLinear(HOT_COLOR);

    float2 move = cellCenter - prevCenter;
    float moveLen = length(move);
    float2 dir = moveLen > 0.5 ? move / moveLen : float2(1.0, 0.0);
    float2 perp = float2(-dir.y, dir.x);
    float moveScale = clamp(moveLen / (cellH * 4.0), 0.0, 1.0); // 0 typing step .. 1 long jump
    float seed = floor(d.cursor_trail_change_time * 1000.0) * 0.0137;
    float3 light = float3(0.0);

    // ---- comet ----
    if (COMET_INTENSITY > 0.0 && trailAlpha > 0.0) {
        float2 c0 = float2(d.cursor_trail_corners_x.x, d.cursor_trail_corners_y.x) * pixelDims;
        float2 c1 = float2(d.cursor_trail_corners_x.y, d.cursor_trail_corners_y.y) * pixelDims;
        float2 c2 = float2(d.cursor_trail_corners_x.z, d.cursor_trail_corners_y.z) * pixelDims;
        float2 c3 = float2(d.cursor_trail_corners_x.w, d.cursor_trail_corners_y.w) * pixelDims;
        float sd = sdQuad(px, c0, c1, c2, c3);
        if (sd < COMET_GLOW * 4.0) {
            float body = saturate(0.5 - sd);
            float glow = exp(-max(sd, 0.0) / COMET_GLOW);
            float along = moveLen > 0.5 ? saturate(dot(px - prevCenter, move) / (moveLen * moveLen)) : 1.0;
            float3 c = lerp(tailCol, headCol, along);
            light += lerp(c, hot, 0.3 * body * along) * (body * 0.6 + glow * 0.5) * trailAlpha * COMET_INTENSITY;

            if (GLITTER_INTENSITY > 0.0 && body > 0.0) {
                float2 g = floor(px / GLITTER_SCALE);
                if (hash12(g + seed) > 1.0 - GLITTER_DENSITY) {
                    float2 gp = (frac(px / GLITTER_SCALE) - 0.5) * GLITTER_SCALE;
                    float tw = sin(d.timestamp * 25.0 + hash12(g + 7.7) * TAU);
                    light += hot * exp(-dot(gp, gp) * 0.6) * tw * tw * body * trailAlpha * GLITTER_INTENSITY;
                }
            }
        }
    }

    if (age >= 0.0) {
        // ---- pulse + landing star around the cursor ----
        if (age < 0.35) {
            float2 rel = px - cellCenter;
            if (PULSE_INTENSITY > 0.0) {
                float sd = sdBox(px, cellCenter, cellSize * 0.5);
                light += headCol * exp(-max(sd, 0.0) / (cellH * 0.25) - age * 12.0) * PULSE_INTENSITY;
            }
            float starT = age - SWEEP_TIME;
            if (STAR_INTENSITY > 0.0 && starT > 0.0) {
                float k = 1.0 - starT / (0.35 - SWEEP_TIME);
                float2 a = abs(rel);
                float arm = cellH * (0.6 + 0.8 * moveScale) * k;
                float star = exp(-a.x / 1.2 - a.y / arm) + exp(-a.y / 1.2 - a.x / arm);
                light += lerp(headCol, hot, k) * star * k * k * STAR_INTENSITY;
            }
        }

        if (hasMove && moveLen > 0.5) {
            // ---- sparks + burst ----
            if (age < SPARK_LIFE + SWEEP_TIME + 0.05) {
                float gravity = SPARK_GRAVITY * cellH;
                // Typing steps get 3 sparks, long jumps the full count.
                float active = lerp(3.0, float(SPARK_COUNT), moveScale);
                float burstActive = float(BURST_COUNT) * moveScale;
                float cullR = SPARK_SIZE * FLARE_LENGTH * 4.0;

                for (int i = 0; i < SPARK_COUNT + BURST_COUNT; i++) {
                    bool burst = i >= SPARK_COUNT;
                    if (burst ? float(i - SPARK_COUNT) >= burstActive : float(i) >= active) continue;

                    // One hash, the rest derived from it.
                    float h1 = hash11(float(i) * 7.31 + seed);
                    float h2 = frac(h1 * 13.73);
                    float h3 = frac(h1 * 57.31);
                    float h4 = frac(h1 * 91.17);

                    float born = burst ? SWEEP_TIME + h3 * 0.03 : h1 * SWEEP_TIME;
                    float life = SPARK_LIFE * (0.45 + 0.55 * h4);
                    float tau = age - born;
                    if (tau < 0.0 || tau > life) continue;

                    float2 origin, vel;
                    if (burst) {
                        float2 rdir = float2(cos(h1 * TAU), sin(h1 * TAU));
                        origin = cellCenter + rdir * cellH * 0.3;
                        vel = normalize(rdir + dir * 0.6) * speed * (0.35 + 0.65 * h2);
                    } else {
                        origin = lerp(prevCenter, cellCenter, h1) + perp * (h2 - 0.5) * cellH * 0.8;
                        vel = (-dir * (0.2 + 0.6 * h4) + perp * (h3 * 2.0 - 1.0) * 1.1) * speed * (0.3 + 0.7 * h2);
                    }

                    float2 pos = origin + vel * ((1.0 - exp(-SPARK_DRAG * tau)) / SPARK_DRAG);
                    pos.y -= 0.5 * gravity * tau * tau;
                    float2 delta = px - pos;
                    if (dot(delta, delta) > cullR * cullR) continue;

                    float lifeFrac = tau / life;
                    float fade = (1.0 - lifeFrac) * (1.0 - lifeFrac);
                    float tw = sin(tau * TWINKLE_SPEED * TAU * (0.6 + 0.8 * h4) + h3 * TAU);
                    float tw2 = tw * tw;
                    float flare = h2 > 1.0 - FLARE_CHANCE ? tw2 * tw2 * 0.9 : 0.0;
                    float3 base = COLOR_MODE == 2 ? hueColor(h3 + d.timestamp * RAINBOW_SPEED) : lerp(headCol, tailCol, h3);
                    float3 c = lerp(hot, base, saturate(lifeFrac * 1.7));
                    float strength = burst ? BURST_INTENSITY : SPARK_INTENSITY;
                    light += c * sparkLight(delta, SPARK_SIZE * (0.6 + 0.8 * h2), flare) * fade * (0.45 + 0.55 * tw2) * strength;
                }
            }

            // ---- embers (long jumps only) ----
            if (EMBER_INTENSITY > 0.0 && moveScale > 0.3 && age < EMBER_LIFE + 0.15) {
                float rise = EMBER_RISE * cellH;
                for (int i = 0; i < EMBER_COUNT; i++) {
                    float h1 = hash11(float(i) * 13.17 + seed + 101.0);
                    float h2 = frac(h1 * 23.71);
                    float h3 = frac(h1 * 71.13);
                    float tau = age - h1 * SWEEP_TIME - h2 * 0.1;
                    float life = EMBER_LIFE * (0.6 + 0.4 * h3);
                    if (tau < 0.0 || tau > life) continue;

                    float2 pos = lerp(prevCenter, cellCenter, h1) + perp * (h3 - 0.5) * cellH;
                    pos.x += sin(tau * 5.0 + h2 * TAU) * cellH * 0.25;
                    pos.y += rise * (0.5 + 0.5 * h2) * tau;
                    float2 delta = px - pos;
                    float size = SPARK_SIZE * (1.0 + 0.6 * h3);
                    float r2 = dot(delta, delta) / (size * size);
                    if (r2 > 64.0) continue;

                    float lifeFrac = tau / life;
                    float fade = saturate(lifeFrac * 10.0) * (1.0 - lifeFrac);
                    float3 base = COLOR_MODE == 2 ? hueColor(h2 + d.timestamp * RAINBOW_SPEED) : lerp(headCol, tailCol, h2);
                    light += base * (exp(-r2) + 0.3 / (1.0 + r2 * 0.25)) * fade * EMBER_INTENSITY;
                }
            }

            // ---- ring (long jumps only) ----
            float ringT = age - SWEEP_TIME;
            if (RING_INTENSITY > 0.0 && moveScale > 0.3 && ringT > 0.0 && ringT < RING_DURATION) {
                float inv = 1.0 - ringT / RING_DURATION;
                float radius = cellH * RING_SIZE * (1.0 - inv * inv * inv);
                float2 rel = px - cellCenter;
                float dr = length(rel) - radius;
                float width = cellH * 0.07 * inv + 0.8;
                if (abs(dr) < width * 3.0) {
                    // Sparkle along the ring without atan2: a 2D stripe pattern on the direction.
                    float2 n = rel / max(length(rel), 1e-3);
                    float sparkle = 0.55 + 0.45 * sin(dot(n, float2(9.0, 11.0)) + n.x * n.y * 30.0 + seed * 40.0 + ringT * 30.0);
                    light += lerp(hot, headCol, 1.0 - inv) * exp(-dr * dr / (width * width)) * sparkle * inv * inv * RING_INTENSITY * moveScale;
                }
            }
        }
    }

    light *= INTENSITY;
    if (all(light <= float3(0.0))) return color;

    // Keep the real cursor crisp above the effect.
    float2 uv = t.pos;
    light *= 1.0 - step(cur.x, uv.x) * step(uv.x, cur.y) * step(cur.w, uv.y) * step(uv.y, cur.z);

    float3 rgb = color.rgb + light / (1.0 + max(max(light.r, light.g), light.b) * 0.35);
    return float4(saturate(rgb), color.a);
}
