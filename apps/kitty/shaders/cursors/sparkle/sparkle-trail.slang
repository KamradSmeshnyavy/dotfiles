#language slang 2026
// Sparkle cursor trail: a glowing comet that follows kitty's own trail quad,
// plus sparks thrown off the path while the cursor travels and a small burst
// where it lands. Sparks cool from white-hot to the trail colour, twinkle and
// flash four-point star flares.
//
// Pair with sparkle-trail.pipeline and `cursor_trail 1` in kitty.conf.
//
// PARAMETERS. Every `static const` below can be overridden from the pipeline file with
//   var float SPARK_SPEED = 14
// without editing this file.
//
// USE_CURSOR_COLOR  true = take the colour from the theme's cursor, false = SPARK_COLOR.
// SPARK_COLOR       Trail/spark colour (linear RGB) when USE_CURSOR_COLOR is false.
// HOT_COLOR         Colour of freshly emitted sparks before they cool down.
// SPARK_COUNT       Sparks thrown along the path (long jumps use all of them,
//                   single-cell moves about a quarter). Range: 8-64
// BURST_COUNT       Sparks in the landing burst at the new cursor position. Range: 0-24
// SPARK_SPEED       Initial spark speed, in cell heights per second. Range: 4-30
// SPARK_DRAG        Air drag; higher = sparks stop sooner. Range: 2-12
// SPARK_GRAVITY     Downward pull, in cell heights per second^2. Negative floats up. Range: -10-30
// SPARK_LIFE        Max spark lifetime in seconds (each spark lives 40-100% of it). Range: 0.2-1.0
//                   Keep animation_stop in the pipeline above SPARK_LIFE + 0.1 s.
// SPARK_SIZE        Spark core radius in pixels. Range: 0.6-3.0
// FLARE_CHANCE      Fraction of sparks that flash a four-point star. Range: 0.0-1.0
// FLARE_LENGTH      Star flare arm length relative to SPARK_SIZE. Range: 2-12
// TWINKLE_SPEED     Twinkle frequency in Hz. Range: 5-40
// SPARK_INTENSITY   Overall brightness of the sparks. Range: 0.3-3.0
// COMET_GLOW        Glow radius around the comet trail in pixels. 0 disables the comet. Range: 0-20
// COMET_INTENSITY   Brightness of the comet glow. Range: 0.0-1.5

import kitty_custom_shader_types;

static const bool USE_CURSOR_COLOR = true;
static const float3 SPARK_COLOR = float3(1.0, 0.55, 0.15);
static const float3 HOT_COLOR = float3(1.0, 0.95, 0.85);
static const int SPARK_COUNT = 40;
static const int BURST_COUNT = 12;
static const float SPARK_SPEED = 12.0;
static const float SPARK_DRAG = 5.0;
static const float SPARK_GRAVITY = 10.0;
static const float SPARK_LIFE = 0.55;
static const float SPARK_SIZE = 1.3;
static const float FLARE_CHANCE = 0.35;
static const float FLARE_LENGTH = 6.0;
static const float TWINKLE_SPEED = 18.0;
static const float SPARK_INTENSITY = 1.2;
static const float COMET_GLOW = 7.0;
static const float COMET_INTENSITY = 0.7;

// Time the cursor head takes to sweep the path; sparks are emitted as it passes.
static const float SWEEP_TIME = 0.07;
static const float TAU = 6.28318530718;

static float
hash11(float p) {
    p = frac(p * 0.1031);
    p *= p + 33.33;
    p *= p + p;
    return frac(p);
}

static float
segDist(float2 p, float2 a, float2 b) {
    float2 ab = b - a;
    float h = clamp(dot(p - a, ab) / max(dot(ab, ab), 1e-7), 0.0, 1.0);
    return length(p - (a + ab * h));
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

// Light contributed at offset `delta` by one spark of radius `size`.
// `flare` scales the four-point star arms (0 = round spark only).
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

public float4
fragment_main(float4 color, KittyTextures t, KittyCustomShaderData d) {
    float2 pixelDims = float2(d.viewport_size_pixels) * t.viewport.zw;
    float2 px = t.pos * pixelDims;

    float4 cur = d.cursor_trail_edge; // .x=left .y=right .z=top .w=bottom (UV, y-up)
    float4 prev = d.cursor_trail_prev_edge;
    float2 cellSize = float2(cur.y - cur.x, cur.z - cur.w) * pixelDims;
    // The cursor rectangle is thin for beam/underline shapes; size sparks from its larger side.
    float cellH = max(max(cellSize.x, cellSize.y), 1.0);

    float3 baseColor = USE_CURSOR_COLOR ? d.cursor_color.rgb : SPARK_COLOR;
    if (USE_CURSOR_COLOR && dot(baseColor, baseColor) < 1e-4) baseColor = d.foreground.rgb;

    float3 light = float3(0.0);

    // Comet: soft glow around kitty's animated trail quad.
    float trailAlpha = d.cursor_trail_color.a;
    if (COMET_GLOW > 0.0 && trailAlpha > 0.0) {
        float2 c0 = float2(d.cursor_trail_corners_x.x, d.cursor_trail_corners_y.x) * pixelDims;
        float2 c1 = float2(d.cursor_trail_corners_x.y, d.cursor_trail_corners_y.y) * pixelDims;
        float2 c2 = float2(d.cursor_trail_corners_x.z, d.cursor_trail_corners_y.z) * pixelDims;
        float2 c3 = float2(d.cursor_trail_corners_x.w, d.cursor_trail_corners_y.w) * pixelDims;
        float sd = sdQuad(px, c0, c1, c2, c3);
        float body = 1.0 - smoothstep(-1.0, 1.0, sd);
        float glow = exp(-max(sd, 0.0) / COMET_GLOW);
        float3 cometColor = lerp(baseColor, HOT_COLOR, 0.35 * body);
        light += cometColor * (body * 0.6 + glow * 0.5) * trailAlpha * COMET_INTENSITY;
    }

    // Sparks: need a real move (both edges known) that happened recently.
    float age = d.timestamp - d.cursor_trail_change_time;
    if (prev.z > 0.0 && age >= 0.0 && age < SPARK_LIFE + SWEEP_TIME + 0.06) {
        float2 curCenter = float2(cur.x + cur.y, cur.z + cur.w) * 0.5 * pixelDims;
        float2 prevCenter = float2(prev.x + prev.y, prev.z + prev.w) * 0.5 * pixelDims;
        float2 move = curCenter - prevCenter;
        float moveLen = length(move);

        if (moveLen > 0.5) {
            float2 dir = move / moveLen;
            float2 perp = float2(-dir.y, dir.x);
            float speed = SPARK_SPEED * cellH;
            float gravity = SPARK_GRAVITY * cellH;

            // Bounding box of everything a spark can reach; skip pixels outside it.
            float reach = speed / SPARK_DRAG + 0.5 * gravity * SPARK_LIFE * SPARK_LIFE + cellH;
            float2 lo = min(prevCenter, curCenter) - reach;
            float2 hi = max(prevCenter, curCenter) + reach;
            if (all(px > lo) && all(px < hi)) {
                float seed = floor(d.cursor_trail_change_time * 1000.0) * 0.0137;
                // Short moves (typing) get a light sprinkle, long jumps the full shower.
                float active = float(SPARK_COUNT) * clamp(moveLen / (cellH * 6.0), 0.25, 1.0);
                int total = SPARK_COUNT + BURST_COUNT;

                for (int i = 0; i < total; i++) {
                    bool burst = i >= SPARK_COUNT;
                    if (!burst && float(i) >= active) continue;

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
                        // Radial burst where the cursor lands, biased forward.
                        float ang = h1 * TAU;
                        float2 rdir = float2(cos(ang), sin(ang));
                        origin = curCenter + rdir * cellH * 0.3;
                        vel = normalize(rdir + dir * 0.6) * speed * (0.35 + 0.65 * h2);
                        born = SWEEP_TIME + h3 * 0.04;
                    } else {
                        // Thrown backwards and sideways from where the head passed.
                        float s = h1;
                        origin = lerp(prevCenter, curCenter, s) + perp * (h2 - 0.5) * cellH * 0.8;
                        float side = h3 * 2.0 - 1.0;
                        vel = (-dir * (0.2 + 0.6 * h4) + perp * side * 1.1) * speed * (0.3 + 0.7 * h5);
                        born = s * SWEEP_TIME;
                    }

                    float life = SPARK_LIFE * (0.4 + 0.6 * h6);
                    float tau = age - born;
                    if (tau < 0.0 || tau > life) continue;

                    // Drag-damped flight plus gravity (y is up, so gravity is negative y).
                    float2 pos = origin + vel * (1.0 - exp(-SPARK_DRAG * tau)) / SPARK_DRAG;
                    pos.y -= 0.5 * gravity * tau * tau;

                    float2 delta = px - pos;
                    float size = SPARK_SIZE * (0.6 + 0.8 * h2);
                    float maxR = size * FLARE_LENGTH * 4.0;
                    if (dot(delta, delta) > maxR * maxR) continue;

                    float lifeFrac = tau / life;
                    float fade = (1.0 - lifeFrac) * (1.0 - lifeFrac);
                    // Sharp twinkle: mostly on, with quick dips and bright peaks.
                    float tw = sin(tau * TWINKLE_SPEED * TAU * (0.6 + 0.8 * h4) + h3 * TAU);
                    float twinkle = 0.45 + 0.55 * tw * tw;
                    float flare = step(1.0 - FLARE_CHANCE, h5) * pow(max(tw, 0.0), 4.0) * 0.9;

                    float3 sparkColor = lerp(HOT_COLOR, baseColor, smoothstep(0.0, 0.6, lifeFrac));
                    light += sparkColor * sparkLight(delta, size, flare) * fade * twinkle * SPARK_INTENSITY;
                }
            }
        }
    }

    if (all(light <= float3(0.0))) return color;

    // Keep the real cursor crisp above the effect.
    float insideCursor = step(cur.x, t.pos.x) * step(t.pos.x, cur.y) * step(cur.w, t.pos.y) * step(t.pos.y, cur.z);
    light *= 1.0 - insideCursor;

    // Additive light with a soft shoulder so overlapping sparks do not clip harshly.
    float3 rgb = color.rgb + light / (1.0 + max(max(light.r, light.g), light.b) * 0.35);
    return float4(saturate(rgb), color.a);
}
