#version 440
// Переходы обоев kamradsmeshnyavy.background: один шейдер, эффект выбирает `mode`.
// fromTex — старые обои, toTex — новые, оба уже обрезаны под экран (ShaderEffectSource).
// Сборка: just shaders-wallpaper (qsb → transition.frag.qsb).

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float progress;  // 0 → 1
    float mode;      // номер эффекта, см. TransitionEffect.qml
    float angle;     // направление wipe / wave / slide, радианы
    float softness;  // ширина мягкого края, доля экрана
    float aspect;    // ширина / высота
    float seed;      // случайность на каждый переход
    vec2 origin;     // центр круга и волн, 0..1
};

layout(binding = 1) uniform sampler2D fromTex;
layout(binding = 2) uniform sampler2D toTex;

const float PI = 3.14159265;

float rand(vec2 co) { return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453); }

// Плавный шум для «прогорания»: билинейная интерполяция случайных узлов.
float noise(vec2 p) {
    vec2 i = floor(p), f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(rand(i), rand(i + vec2(1, 0)), u.x), mix(rand(i + vec2(0, 1)), rand(i + vec2(1, 1)), u.x), u.y);
}

vec4 A(vec2 uv) { return texture(fromTex, clamp(uv, 0.0, 1.0)); }
vec4 B(vec2 uv) { return texture(toTex, clamp(uv, 0.0, 1.0)); }

// d > 0 — уже открыто. Мягкий край шириной softness.
float reveal(float d) {
    float s = max(softness, 0.0008);
    return smoothstep(-s, s, d);
}

// Порог, который за progress проходит отрезок [lo, hi] с запасом под мягкий край.
float sweep(float lo, float hi) {
    float s = max(softness, 0.0008);
    return mix(lo - s, hi + s, progress);
}

// Самое дальнее расстояние от origin до угла экрана (в координатах с учётом aspect).
float farthest(vec2 o) {
    vec2 a = vec2(aspect, 1.0);
    return max(max(length(o * a), length((o - vec2(1, 0)) * a)),
               max(length((o - vec2(0, 1)) * a), length((o - vec2(1, 1)) * a)));
}

void main() {
    vec2 uv = qt_TexCoord0;
    float p = progress;
    int m = int(mode + 0.5);
    vec2 asp = vec2(aspect, 1.0);
    vec2 dir = vec2(cos(angle), sin(angle));
    vec4 c;

    if (m == 1) {            // fade
        c = mix(A(uv), B(uv), smoothstep(0.0, 1.0, p));
    } else if (m == 2) {     // slant — как стоковая шторка: полоса от центра со скосом
        float line = 0.5 + 0.18 * (uv.y - 0.5) / aspect;
        float reach = 0.5 + 0.09 / aspect + 0.01;
        c = mix(A(uv), B(uv), reveal(sweep(0.0, reach) - abs(uv.x - line)));
    } else if (m == 3 || m == 4) {  // wipe, wave
        float r = 0.5 * (abs(dir.x) + abs(dir.y));
        float proj = dot(uv - 0.5, dir);
        if (m == 4) {
            float perp = dot((uv - 0.5) * asp, vec2(-dir.y, dir.x));
            proj += sin(perp * 28.0 + seed * 6.0) * 0.025;
            r += 0.03;
        }
        c = mix(A(uv), B(uv), reveal(sweep(-r, r) - proj));
    } else if (m == 5 || m == 6) {  // grow, outer
        float dist = length((uv - origin) * asp);
        float far = farthest(origin);
        float t = (m == 5) ? reveal(sweep(0.0, far) - dist) : reveal(dist - (far - sweep(0.0, far)));
        c = mix(A(uv), B(uv), t);
    } else if (m == 7) {     // diamond
        vec2 d = abs((uv - origin) * asp);
        float dist = d.x + d.y;
        c = mix(A(uv), B(uv), reveal(sweep(0.0, aspect + 1.0) - dist));
    } else if (m == 8) {     // clock — радиальная развёртка от 12 часов
        vec2 d = (uv - origin) * asp;
        float a = fract(atan(d.x, -d.y) / (2.0 * PI) + 1.0);
        c = mix(A(uv), B(uv), reveal(sweep(0.0, 1.0) - a));
    } else if (m == 9) {     // blinds — 14 горизонтальных жалюзи
        float f = fract(uv.y * 14.0);
        c = mix(A(uv), B(uv), reveal(sweep(0.0, 1.0) - f));
    } else if (m == 10) {    // doors — раскрытие от вертикальной середины
        c = mix(A(uv), B(uv), reveal(sweep(0.0, 1.0) - abs(uv.x - 0.5) * 2.0));
    } else if (m == 11) {    // mosaic — квадраты в случайном порядке
        vec2 cell = floor(uv * vec2(18.0 * aspect / 1.6, 18.0 / 1.6) * 1.6);
        float order = rand(cell + seed);
        c = mix(A(uv), B(uv), step(order, p * 1.02));
    } else if (m == 12) {    // dissolve — пиксельный шум
        float order = rand(floor(uv * vec2(aspect, 1.0) * 540.0) + seed);
        c = mix(A(uv), B(uv), step(order, p));
    } else if (m == 13) {    // pixelize — блоки растут к середине и снова мельчают
        float k = 1.0 - abs(2.0 * p - 1.0);
        vec2 size = vec2(1.0 / aspect, 1.0) * (0.0015 + 0.05 * k * k);
        vec2 q = (floor(uv / size) + 0.5) * size;
        c = mix(A(q), B(q), smoothstep(0.4, 0.6, p));
    } else if (m == 14 || m == 21) {  // ripple (от центра), water-drop (от origin, затухает)
        vec2 o = (m == 14) ? vec2(0.5) : origin;
        vec2 d = (uv - o) * asp;
        float dist = length(d);
        float amp = (m == 14) ? 0.03 * sin(p * PI) : 0.04 * (1.0 - p);
        vec2 off = (dist > 0.0001 ? d / dist : vec2(0.0)) * sin(dist * 45.0 - p * 30.0) * amp / asp;
        float t = (m == 14) ? smoothstep(0.2, 0.8, p) : reveal(sweep(0.0, farthest(o)) - dist);
        c = mix(A(uv + off), B(uv + off), t);
    } else if (m == 15) {    // swirl — закрутка к середине и обратно
        vec2 d = (uv - 0.5) * asp;
        float dist = length(d);
        float k = sin(p * PI) * 6.0 * max(0.0, 1.0 - dist / 0.9);
        float s = sin(k), co = cos(k);
        vec2 r = vec2(d.x * co - d.y * s, d.x * s + d.y * co) / asp + 0.5;
        c = mix(A(r), B(r), smoothstep(0.35, 0.65, p));
    } else if (m == 16) {    // cross-zoom — радиальное размытие к центру
        float k = sin(p * PI) * 0.25;
        vec4 acc = vec4(0.0);
        for (int i = 0; i < 12; i++) {
            float f = float(i) / 11.0;
            vec2 q = 0.5 + (uv - 0.5) * (1.0 - k * f);
            acc += mix(A(q), B(q), smoothstep(0.3, 0.7, p));
        }
        c = acc / 12.0;
    } else if (m == 17) {    // slide — новые выталкивают старые по направлению angle
        vec2 shift = dir * p;
        vec2 qa = uv + shift;
        vec2 qb = uv + shift - dir;
        bool inA = qa.x >= 0.0 && qa.x <= 1.0 && qa.y >= 0.0 && qa.y <= 1.0;
        c = inA ? A(qa) : B(qb);
    } else if (m == 18) {    // zoom — старые улетают вперёд, новые проявляются из глубины
        vec2 qa = 0.5 + (uv - 0.5) / (1.0 + p * 0.6);
        vec2 qb = 0.5 + (uv - 0.5) * (1.25 - 0.25 * p);
        c = mix(A(qa), B(qb), smoothstep(0.0, 1.0, p));
    } else if (m == 19) {    // glitch — рваные полосы, разъезд каналов
        float k = sin(p * PI);
        float band = floor(uv.y * 34.0);
        float step_ = floor(p * 18.0);
        float off = (rand(vec2(band, step_ + seed)) - 0.5) * 0.25 * k * step(0.55, rand(vec2(band * 1.7, step_)));
        vec2 q = vec2(uv.x + off, uv.y);
        float t = step(rand(vec2(band, step_ * 3.1)), p);
        vec2 ch = vec2(0.012 * k, 0.0);
        vec4 a = vec4(A(q + ch).r, A(q).g, A(q - ch).b, 1.0);
        vec4 b = vec4(B(q + ch).r, B(q).g, B(q - ch).b, 1.0);
        c = mix(a, b, t);
    } else if (m == 20) {    // burn — прогорание пятнами с раскалённым краем
        float n = noise(uv * asp * 6.0 + seed * 10.0) * 0.7 + noise(uv * asp * 18.0) * 0.3;
        float edge = sweep(0.0, 1.0) - n;
        float t = reveal(edge);
        float glow = smoothstep(0.08, 0.0, abs(edge)) * (1.0 - t * 0.6);
        c = mix(A(uv), B(uv), t) + vec4(1.0, 0.45, 0.1, 0.0) * glow * 1.2;
    } else if (m == 22) {    // hexagon — соты открываются от центра с разбросом
        vec2 g = uv * asp * 14.0;
        float row = floor(g.y);
        float col = floor(g.x + mod(row, 2.0) * 0.5);
        vec2 cell = vec2(col, row);
        vec2 center = (vec2(col + 0.5 - mod(row, 2.0) * 0.5, row + 0.5) / 14.0) / asp;
        float order = length((center - 0.5) * asp) / farthest(vec2(0.5)) * 0.7 + rand(cell + seed) * 0.3;
        c = mix(A(uv), B(uv), step(order, p * 1.02));
    } else {                 // запасной — простое смешивание
        c = mix(A(uv), B(uv), p);
    }

    fragColor = vec4(c.rgb, 1.0) * qt_Opacity;
}
