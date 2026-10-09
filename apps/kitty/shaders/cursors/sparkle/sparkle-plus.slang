#language slang 2026
// Sparkle cursor trail, extended edition. Builds on sparkle-trail.slang with:
//   comet     glowing trail body following kitty's trail quad, head→tail gradient + glitter
//   sparks    thrown off the path, drawn as motion-blurred streaks with star flares
//   embers    slow glowing motes that float up and sway, outliving the sparks
//   burst     radial spark burst where the cursor lands
//   ring      sparkling shockwave ring expanding from the landing point
//   pulse     quick glow flash around the cursor on every move (typing feedback)
//   aura      after the cursor settles: breathing halo and motes orbiting it, fading out
//
// Pair with sparkle-plus.pipeline and `cursor_trail 1` in kitty.conf. Works with
// block, beam and underline cursors.
//
// PARAMETERS. Every `static const` below can be overridden from the pipeline file with
//   var float RING_INTENSITY = 0
// without editing this file. Setting an *_INTENSITY to 0 disables that effect.
//
// COLORS (sRGB 0..1, i.e. hex / 255: #ebbcba -> float3(0.92, 0.74, 0.73))
// COLOR_MODE        0 = theme cursor colour, 1 = PRIMARY_COLOR/SECONDARY_COLOR, 2 = rainbow
// PRIMARY_COLOR     Head of the trail and half of the sparks (COLOR_MODE 1).
// SECONDARY_COLOR   Tail of the trail and the other sparks (COLOR_MODE 1).
// HOT_COLOR         Colour of freshly emitted sparks before they cool down (all modes).
// RAINBOW_SPEED     Hue cycles per second in COLOR_MODE 2. Range: 0.0-1.0
// RAINBOW_SATURATION  0 = white, 1 = fully saturated rainbow. Range: 0.3-1.0
//
// TIMING. AURA_DURATION is the longest effect; keep animation_stop in the
// pipeline at least 300 ms above it so the last frame is clean.

import kitty_custom_shader_types;

// --- colour ---
static const int COLOR_MODE = 0;
static const float3 PRIMARY_COLOR = float3(0.92, 0.74, 0.73);
static const float3 SECONDARY_COLOR = float3(0.77, 0.65, 0.91);
static const float3 HOT_COLOR = float3(1.0, 0.97, 0.9);
static const float RAINBOW_SPEED = 0.25;
static const float RAINBOW_SATURATION = 0.75;
static const float INTENSITY = 1.0; // master brightness for everything

// --- comet ---
static const float COMET_INTENSITY = 0.8;
static const float COMET_GLOW = 8.0;        // glow radius in pixels
static const float GLITTER_INTENSITY = 0.9; // twinkling points inside the trail body
static const float GLITTER_DENSITY = 0.12;  // fraction of glitter cells lit. Range: 0.02-0.4
static const float GLITTER_SCALE = 4.0;     // glitter cell size in pixels

// --- sparks ---
static const float SPARK_INTENSITY = 1.2;
static const int SPARK_COUNT = 48;
static const float SPARK_SPEED = 13.0;   // cell heights per second
static const float SPARK_DRAG = 5.0;     // higher = stop sooner
static const float SPARK_GRAVITY = 10.0; // cell heights / s^2, negative floats up
static const float SPARK_LIFE = 0.6;     // seconds
static const float SPARK_SIZE = 1.2;     // core radius in pixels
static const float STREAK_LENGTH = 0.03; // motion blur in seconds of travel, 0 = round dots
static const float FLARE_CHANCE = 0.35;  // fraction of sparks that flash a star
static const float FLARE_LENGTH = 6.0;   // star arm length relative to spark size
static const float TWINKLE_SPEED = 18.0; // Hz

// --- embers ---
static const float EMBER_INTENSITY = 0.9;
static const int EMBER_COUNT = 14;
static const float EMBER_LIFE = 1.4;  // seconds
static const float EMBER_RISE = 1.6;  // cell heights per second upwards
static const float EMBER_SWAY = 0.35; // sideways sway amplitude in cell heights

// --- landing ---
static const float BURST_INTENSITY = 1.0;
static const int BURST_COUNT = 16;
static const float RING_INTENSITY = 0.8;
static const float RING_SIZE = 2.2;     // final radius in cell heights
static const float RING_DURATION = 0.45;
static const float PULSE_INTENSITY = 0.45;

// --- aura (after the cursor stops) ---
static const float AURA_INTENSITY = 0.7;
static const int AURA_MOTES = 3;
static const float AURA_SPEED = 0.45;   // orbits per second
static const float AURA_DURATION = 3.0; // seconds until the aura has faded out

static const float SWEEP_TIME = 0.07; // time the head takes to sweep the path
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
    return pow(saturate(c), float3(2.2));
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

// Signed distance to the convex trail quad (negative inside). Corners come
// clockwise in y-up space, so the interior is to the right of every edge.
static float
sdQuad(float2 p, float2 c0, float2 c1, float2 c2, float2 c3) {
    float d = min(min(segDist(p, c0, c1), segDist(p, c1, c2)), min(segDist(p, c2, c3), segDist(p, c3, c0)));
    float2 e0 = c1 - c0, e1 = c2 - c1, e2 = c3 - c2, e3 = c0 - c3;
    bool inside = e0.x * (p.y - c0.y) - e0.y * (p.x - c0.x) <= 0.0 && e1.x * (p.y - c1.y) - e1.y * (p.x - c1.x) <= 0.0 &&
                  e2.x * (p.y - c2.y) - e2.y * (p.x - c2.x) <= 0.0 && e3.x * (p.y - c3.y) - e3.y * (p.x - c3.x) <= 0.0;
    return inside ? -d : d;
}

// Light of a round spark plus optional four-point star (flare 0 = none).
static float
sparkLight(float2 delta, float size, float flare) {
    float r2 = dot(delta, delta);
    float core = exp(-r2 / (size * size));
    float halo = exp(-sqrt(r2) / (size * 3.0)) * 0.25;
    float2 a = abs(delta);
    float arm = size * FLARE_LENGTH;
    float star = exp(-a.x / (size * 0.35) - a.y / arm) + exp(-a.y / (size * 0.35) - a.x / arm);
    return core + halo + star * flare;
}

// Light of a streak from `head` back to `tail` (bright head, fading tail).
static float
streakLight(float2 p, float2 head, float2 tail, float size) {
    float2 ab = tail - head;
    float h = clamp(dot(p - head, ab) / max(dot(ab, ab), 1e-7), 0.0, 1.0);
    float dist = length(p - (head + ab * h));
    float taper = 1.0 - h * 0.85;
    return exp(-dist * dist / (size * size * taper * taper)) * taper + exp(-dist / (size * 3.0)) * 0.2 * taper;
}

struct Palette {
    float3 head;
    float3 tail;
};

static Palette
makePalette(KittyCustomShaderData d) {
    Palette p;
    if (COLOR_MODE == 1) {
        p.head = srgbToLinear(PRIMARY_COLOR);
        p.tail = srgbToLinear(SECONDARY_COLOR);
    } else if (COLOR_MODE == 2) {
        float h = frac(d.timestamp * RAINBOW_SPEED);
        p.head = hueColor(h);
        p.tail = hueColor(h + 0.35);
    } else {
        float3 c = d.cursor_color.rgb;
        if (dot(c, c) < 1e-4) c = d.foreground.rgb;
        p.head = c;
        p.tail = lerp(c, d.foreground.rgb, 0.3);
    }
    return p;
}

// Colour of one particle: per-particle pick between head/tail (or its own hue
// in rainbow mode), cooling from HOT_COLOR as it ages.
static float3
particleColor(Palette pal, float h, float lifeFrac, float time) {
    float3 base = COLOR_MODE == 2 ? hueColor(h + time * RAINBOW_SPEED) : lerp(pal.head, pal.tail, h);
    return lerp(srgbToLinear(HOT_COLOR), base, smoothstep(0.0, 0.6, lifeFrac));
}

public float4
fragment_main(float4 color, KittyTextures t, KittyCustomShaderData d) {
    float2 pixelDims = float2(d.viewport_size_pixels) * t.viewport.zw;
    float2 px = t.pos * pixelDims;

    float4 cur = d.cursor_trail_edge; // .x=left .y=right .z=top .w=bottom (UV, y-up)
    float4 prev = d.cursor_trail_prev_edge;
    float2 rect = float2(cur.y - cur.x, cur.z - cur.w) * pixelDims;
    if (rect.x <= 0.0 && rect.y <= 0.0) return color;

    // Recover the character cell from the cursor rectangle: block = whole cell,
    // beam = thin left strip, underline = thin bottom strip. Cells are ~1:2.
    float cellH = max(max(rect.y, rect.x * 2.0), 1.0);
    float2 cellSize = float2(max(rect.x, cellH * 0.5), cellH);
    float2 cellMin = float2(cur.x, cur.w) * pixelDims;
    float2 cellCenter = cellMin + cellSize * 0.5;

    Palette pal = makePalette(d);
    float3 hot = srgbToLinear(HOT_COLOR);
    float age = d.timestamp - d.cursor_trail_change_time;
    float3 light = float3(0.0);

    bool hasMove = prev.z > 0.0 && age >= 0.0;
    float2 prevCenter = float2(prev.x, prev.w) * pixelDims + cellSize * 0.5;
    float2 move = cellCenter - prevCenter;
    float moveLen = length(move);
    float2 dir = moveLen > 0.5 ? move / moveLen : float2(1.0, 0.0);
    float2 perp = float2(-dir.y, dir.x);
    // 0.25 for a one-cell typing step, 1 for long jumps.
    float moveScale = clamp(moveLen / (cellH * 4.0), 0.25, 1.0);
    float seed = floor(d.cursor_trail_change_time * 1000.0) * 0.0137;

    // ---- comet: trail body, glow and glitter ----
    float trailAlpha = d.cursor_trail_color.a;
    if (COMET_INTENSITY > 0.0 && trailAlpha > 0.0) {
        float2 c0 = float2(d.cursor_trail_corners_x.x, d.cursor_trail_corners_y.x) * pixelDims;
        float2 c1 = float2(d.cursor_trail_corners_x.y, d.cursor_trail_corners_y.y) * pixelDims;
        float2 c2 = float2(d.cursor_trail_corners_x.z, d.cursor_trail_corners_y.z) * pixelDims;
        float2 c3 = float2(d.cursor_trail_corners_x.w, d.cursor_trail_corners_y.w) * pixelDims;
        float sd = sdQuad(px, c0, c1, c2, c3);
        if (sd < COMET_GLOW * 6.0) {
            float body = 1.0 - smoothstep(-1.0, 1.0, sd);
            float glow = exp(-max(sd, 0.0) / COMET_GLOW);
            // 0 at the previous position, 1 at the cursor.
            float along = hasMove && moveLen > 0.5 ? saturate(dot(px - prevCenter, move) / (moveLen * moveLen)) : 1.0;
            float3 cometColor = lerp(pal.tail, pal.head, along);
            cometColor = lerp(cometColor, hot, 0.3 * body * along);
            light += cometColor * (body * 0.6 + glow * 0.5) * trailAlpha * COMET_INTENSITY;

            if (GLITTER_INTENSITY > 0.0 && body > 0.0) {
                float2 g = floor(px / GLITTER_SCALE);
                float lit = step(1.0 - GLITTER_DENSITY, hash12(g + seed));
                float2 gp = (frac(px / GLITTER_SCALE) - 0.5) * GLITTER_SCALE;
                float tw = sin(d.timestamp * 25.0 + hash12(g + 7.7) * TAU);
                light += hot * lit * exp(-dot(gp, gp) * 0.6) * tw * tw * body * trailAlpha * GLITTER_INTENSITY;
            }
        }
    }

    // ---- pulse: flash around the cursor cell on every move ----
    if (PULSE_INTENSITY > 0.0 && age >= 0.0 && age < 0.4) {
        float sd = sdBox(px, cellCenter, cellSize * 0.5);
        float glow = exp(-max(sd, 0.0) / (cellH * 0.25));
        light += pal.head * glow * exp(-age * 12.0) * PULSE_INTENSITY;
    }

    if (hasMove && moveLen > 0.5) {
        float speed = SPARK_SPEED * cellH;
        float gravity = SPARK_GRAVITY * cellH;

        // ---- sparks along the path + landing burst ----
        if (age < SPARK_LIFE + SWEEP_TIME + 0.1 && (SPARK_INTENSITY > 0.0 || BURST_INTENSITY > 0.0)) {
            float reach = speed / SPARK_DRAG + 0.5 * abs(gravity) * SPARK_LIFE * SPARK_LIFE + cellH * 2.0;
            float2 lo = min(prevCenter, cellCenter) - reach;
            float2 hi = max(prevCenter, cellCenter) + reach;
            if (all(px > lo) && all(px < hi)) {
                float active = float(SPARK_COUNT) * moveScale;
                int total = SPARK_COUNT + BURST_COUNT;
                for (int i = 0; i < total; i++) {
                    bool burst = i >= SPARK_COUNT;
                    if (!burst && float(i) >= active) continue;
                    float strength = burst ? BURST_INTENSITY * moveScale : SPARK_INTENSITY;
                    if (strength <= 0.0) continue;

                    float fi = float(i) * 7.31 + seed;
                    float h1 = hash11(fi + 0.13);
                    float h2 = hash11(fi + 1.71);
                    float h3 = hash11(fi + 2.39);
                    float h4 = hash11(fi + 3.97);
                    float h5 = hash11(fi + 5.53);
                    float h6 = hash11(fi + 6.11);

                    float2 origin;
                    float2 vel;
                    float born;
                    if (burst) {
                        float ang = h1 * TAU;
                        float2 rdir = float2(cos(ang), sin(ang));
                        origin = cellCenter + rdir * cellH * 0.3;
                        vel = normalize(rdir + dir * 0.6) * speed * (0.35 + 0.65 * h2);
                        born = SWEEP_TIME + h3 * 0.04;
                    } else {
                        origin = lerp(prevCenter, cellCenter, h1) + perp * (h2 - 0.5) * cellH * 0.8;
                        vel = (-dir * (0.2 + 0.6 * h4) + perp * (h3 * 2.0 - 1.0) * 1.1) * speed * (0.3 + 0.7 * h5);
                        born = h1 * SWEEP_TIME;
                    }

                    float life = SPARK_LIFE * (0.4 + 0.6 * h6);
                    float tau = age - born;
                    if (tau < 0.0 || tau > life) continue;

                    float damp = exp(-SPARK_DRAG * tau);
                    float2 pos = origin + vel * (1.0 - damp) / SPARK_DRAG;
                    pos.y -= 0.5 * gravity * tau * tau;
                    float2 delta = px - pos;
                    float size = SPARK_SIZE * (0.6 + 0.8 * h2);
                    float maxR = size * FLARE_LENGTH * 4.0 + speed * STREAK_LENGTH;
                    if (dot(delta, delta) > maxR * maxR) continue;

                    float lifeFrac = tau / life;
                    float fade = (1.0 - lifeFrac) * (1.0 - lifeFrac);
                    float tw = sin(tau * TWINKLE_SPEED * TAU * (0.6 + 0.8 * h4) + h3 * TAU);
                    float twinkle = 0.45 + 0.55 * tw * tw;
                    float flare = step(1.0 - FLARE_CHANCE, h5) * pow(max(tw, 0.0), 4.0) * 0.9;

                    float2 velNow = vel * damp - float2(0.0, gravity * tau);
                    float2 tail = pos - velNow * STREAK_LENGTH;
                    float l = max(streakLight(px, pos, tail, size), sparkLight(delta, size, flare));
                    light += particleColor(pal, h3, lifeFrac, d.timestamp) * l * fade * twinkle * strength;
                }
            }
        }

        // ---- embers: slow rising, swaying motes ----
        if (EMBER_INTENSITY > 0.0 && age < EMBER_LIFE + 0.3) {
            float rise = EMBER_RISE * cellH;
            float2 lo = min(prevCenter, cellCenter) - float2(cellH * (EMBER_SWAY + 1.5), cellH * 1.5);
            float2 hi = max(prevCenter, cellCenter) + float2(cellH * (EMBER_SWAY + 1.5), rise * EMBER_LIFE + cellH * 1.5);
            if (all(px > lo) && all(px < hi)) {
                float active = max(float(EMBER_COUNT) * moveScale, 1.0);
                for (int i = 0; i < EMBER_COUNT; i++) {
                    if (float(i) >= active) break;
                    float fi = float(i) * 13.17 + seed + 101.0;
                    float h1 = hash11(fi + 0.37);
                    float h2 = hash11(fi + 1.19);
                    float h3 = hash11(fi + 2.83);
                    float h4 = hash11(fi + 4.41);

                    float born = h1 * SWEEP_TIME + h2 * 0.2;
                    float life = EMBER_LIFE * (0.5 + 0.5 * h3);
                    float tau = age - born;
                    if (tau < 0.0 || tau > life) continue;

                    float2 origin = lerp(prevCenter, cellCenter, h1) + perp * (h4 - 0.5) * cellH;
                    float2 pos = origin - dir * cellH * 0.6 * (1.0 - exp(-3.0 * tau));
                    pos.x += sin(tau * (2.0 + 2.0 * h2) + h4 * TAU) * EMBER_SWAY * cellH * smoothstep(0.0, 0.4, tau);
                    pos.y += rise * (0.5 + 0.5 * h4) * tau;

                    float lifeFrac = tau / life;
                    float fade = smoothstep(0.0, 0.1, lifeFrac) * (1.0 - lifeFrac);
                    float flicker = 0.6 + 0.4 * sin(tau * 9.0 + h2 * TAU);
                    float2 delta = px - pos;
                    float size = SPARK_SIZE * (0.8 + 0.8 * h3);
                    float l = exp(-dot(delta, delta) / (size * size)) + exp(-length(delta) / (size * 4.0)) * 0.35;
                    light += particleColor(pal, h2, 0.4 + 0.6 * lifeFrac, d.timestamp) * l * fade * flicker * EMBER_INTENSITY;
                }
            }
        }

        // ---- ring: sparkling shockwave from the landing point ----
        float ringT = age - SWEEP_TIME;
        if (RING_INTENSITY > 0.0 && ringT > 0.0 && ringT < RING_DURATION) {
            float p = ringT / RING_DURATION;
            float inv = 1.0 - p;
            float radius = cellH * RING_SIZE * (1.0 - inv * inv * inv) * lerp(0.5, 1.0, moveScale);
            float2 rel = px - cellCenter;
            float r = length(rel);
            float width = cellH * 0.07 * inv + 0.8;
            float band = exp(-(r - radius) * (r - radius) / (width * width));
            if (band > 1e-3) {
                float ang = atan2(rel.y, rel.x);
                float sparkle = 0.55 + 0.45 * sin(ang * 14.0 + seed * 40.0 + ringT * 30.0);
                float3 ringColor = lerp(hot, COLOR_MODE == 2 ? hueColor(ang / TAU + d.timestamp * RAINBOW_SPEED) : pal.head, p);
                light += ringColor * band * sparkle * inv * inv * RING_INTENSITY * moveScale;
            }
        }
    }

    // ---- aura: breathing halo + orbiting motes once the cursor settles ----
    if (AURA_INTENSITY > 0.0 && age > 0.1 && age < AURA_DURATION) {
        float a = smoothstep(0.15, 0.6, age) * (1.0 - smoothstep(AURA_DURATION * 0.55, AURA_DURATION, age)) * AURA_INTENSITY;
        float sd = sdBox(px, cellCenter, cellSize * 0.5);
        if (sd < cellH * 2.0) {
            float breathe = 0.5 + 0.5 * sin(age * TAU * 0.9);
            light += pal.head * exp(-max(sd, 0.0) / (cellH * 0.3)) * breathe * 0.22 * a;

            float2 orbit = float2(cellSize.x * 0.5 + cellH * 0.45, cellH * 0.8);
            for (int k = 0; k < AURA_MOTES; k++) {
                float fk = float(k);
                float spin = (k % 2 == 0) ? 1.0 : -0.8;
                float ang = age * AURA_SPEED * TAU * spin + fk * TAU / float(AURA_MOTES) + seed;
                float2 pos = cellCenter + float2(cos(ang), sin(ang)) * orbit * (0.9 + 0.1 * sin(age * 3.0 + fk));
                float tw = sin(age * 7.0 + fk * 2.1);
                float flare = pow(max(tw, 0.0), 6.0) * 0.8;
                float3 moteColor = COLOR_MODE == 2 ? hueColor(fk / float(AURA_MOTES) + d.timestamp * RAINBOW_SPEED)
                                                   : lerp(pal.head, pal.tail, fk / max(float(AURA_MOTES - 1), 1.0));
                light += lerp(moteColor, hot, 0.3) * sparkLight(px - pos, SPARK_SIZE * 0.9, flare) * (0.6 + 0.4 * tw) * a;
            }
        }
    }

    light *= INTENSITY;
    if (all(light <= float3(0.0))) return color;

    // Keep the real cursor crisp above the effect.
    float insideCursor = step(cur.x, t.pos.x) * step(t.pos.x, cur.y) * step(cur.w, t.pos.y) * step(t.pos.y, cur.z);
    light *= 1.0 - insideCursor;

    // Additive light with a soft shoulder so overlapping sparks do not clip harshly.
    float3 rgb = color.rgb + light / (1.0 + max(max(light.r, light.g), light.b) * 0.35);
    return float4(saturate(rgb), color.a);
}
