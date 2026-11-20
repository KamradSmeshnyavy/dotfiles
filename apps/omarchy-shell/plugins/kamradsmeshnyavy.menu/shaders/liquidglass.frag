#version 440
// Жидкое стекло (идея — стекло Vitreus, github.com/natepayn3/Vitreus, MIT; код свой). Панель — скруглённый прямоугольник
// толстого стекла поверх обоев: у края линза отклоняет то, что за ним (край увеличивает и подтягивает внутрь), цветные
// каналы отклоняются по-разному (радужная кайма), середина — чистая или матовая (frost — смесь резких и размытых обоев).
// Сверху — ободок светлее сверху-слева, мягкий купол света и блик под курсором. Обои — те же, что на рабочем столе:
// sharpTex / softTex, обрезанные под экран, как PreserveAspectCrop (crop). over 1 — за панелью окно или живые обои:
// преломлять нечего, панель — тонированная плёнка, а размывает Hyprland (layer_rule blur).
// Сборка: qsb --qt6 -o liquidglass.frag.qsb liquidglass.frag

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 size;      // панель, px
    vec2 screen;    // экран, px
    vec2 origin;    // левый верхний угол панели на экране, px
    vec2 crop;      // видимая доля обоев по x / y
    vec4 tint;      // rgb — цвет стекла, a — сколько его
    vec4 shine;     // xy — блик (px панели), z — сила, w — 1 если курсор над панелью
    float radius;
    float lens;     // ширина линзы у края, px
    float refr;     // сила преломления 0…1
    float disp;     // радуга 0…1
    float frost;    // матовость 0…1
    float rim;      // ободок 0…1
    float dome;     // купол света сверху 0…1
    float over;     // 0 — преломлять обои, 1 — плёнка над окнами
    float alphaOver;// непрозрачность плёнки над окнами
    vec4 panel;     // сама панель внутри эффекта (эффект шире на bleed — там рисуется перешеек), px
    vec4 join;      // вторая фигура — пилюля бара (или край, к которому тянется), px; w 0 — нет
    float joinR;    // её скругление
    float joinK;    // ширина «перешейка»: насколько мягко две фигуры сливаются (0 — не сливаются)
    vec4 join2;     // ещё две фигуры (крылья у рамки, куски вырезов бара), px; w 0 — нет
    vec4 join3;
    vec4 joinRK;    // x, y — скругление join2 / join3; z, w — их слияние
    vec4 hole;      // рамка вокруг экрана: всё поле эффекта минус скруглённая «дырка» hole (px)
    vec4 frame;     // x — 1 рамка есть, y — скругление дырки, z — слияние рамки с фигурами
    vec4 cut;       // здесь стекло не рисуется (внутри бара или рамки: там своё стекло, фигура только тянется к нему)
    vec4 cut2;
    vec4 ripple;    // рябь по краю (панель втянулась в бар, как у Vitreus): xy — откуда (px эффекта), z — 0…1 время, w — сила px
};
layout(binding = 1) uniform sampler2D sharpTex;
layout(binding = 2) uniform sampler2D softTex;

float sdBox(vec2 p, vec2 b, float r) {
    vec2 q = abs(p) - b + r;
    return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

vec3 wall(vec2 sp) {
    vec2 uv = (sp / screen - 0.5) * crop + 0.5;
    uv = clamp(uv, vec2(0.001), vec2(0.999));
    return mix(texture(sharpTex, uv).rgb, texture(softTex, uv).rgb, frost);
}

// плавное объединение (жидкий перешеек между панелью и баром)
float smin(float a, float b, float k) {
    if (k <= 0.0) return min(a, b);
    float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
    return mix(b, a, h) - k * h * (1.0 - h);
}

float shape(vec2 p) {
    vec2 c = panel.xy + panel.zw * 0.5;
    float r = min(radius, min(panel.z, panel.w) * 0.5);
    float d = sdBox(p - c, panel.zw * 0.5, r);
    if (join.z > 0.5 && join.w > 0.5) {
        vec2 jc = join.xy + join.zw * 0.5;
        float jd = sdBox(p - jc, join.zw * 0.5, min(joinR, min(join.z, join.w) * 0.5));
        d = smin(d, jd, joinK);
    }
    if (join2.z > 0.5 && join2.w > 0.5)
        d = smin(d, sdBox(p - join2.xy - join2.zw * 0.5, join2.zw * 0.5, min(joinRK.x, min(join2.z, join2.w) * 0.5)), joinRK.z);
    if (join3.z > 0.5 && join3.w > 0.5)
        d = smin(d, sdBox(p - join3.xy - join3.zw * 0.5, join3.zw * 0.5, min(joinRK.y, min(join3.z, join3.w) * 0.5)), joinRK.w);
    if (frame.x > 0.5) {
        // рамка: прямоугольник поля минус дырка с внутренними скруглениями (как у Vitreus и caelestia)
        float outer = sdBox(p - size * 0.5, size * 0.5, 0.0);
        float dh = sdBox(p - hole.xy - hole.zw * 0.5, hole.zw * 0.5, min(frame.y, min(hole.z, hole.w) * 0.5));
        d = smin(d, max(outer, -dh), frame.z);
    }
    return d;
}

// рябь: кольцо расходится от точки и гаснет, край фигуры колышется (3 гребня, затухает к концу и вдаль)
float rippleAt(vec2 p) {
    if (ripple.w <= 0.0 || ripple.z <= 0.0 || ripple.z >= 1.0) return 0.0;
    float t = ripple.z;
    float r = length(p - ripple.xy);
    float front = 40.0 + 520.0 * t;
    float env = smoothstep(front, front - 60.0, r) * (1.0 - t) * (1.0 - t) * exp(-r / 260.0);
    return ripple.w * env * sin(r / 13.0 - t * 22.0);
}

void main() {
    vec2 p = qt_TexCoord0 * size;
    if ((cut.z > 0.5 && p.x > cut.x && p.y > cut.y && p.x < cut.x + cut.z && p.y < cut.y + cut.w) ||
        (cut2.z > 0.5 && p.x > cut2.x && p.y > cut2.y && p.x < cut2.x + cut2.z && p.y < cut2.y + cut2.w)) { fragColor = vec4(0.0); return; }
    float d = shape(p) + rippleAt(p);
    float mask = clamp(0.5 - d, 0.0, 1.0);
    if (mask <= 0.0) { fragColor = vec4(0.0); return; }

    // нормаль края — градиент расстояния
    float e = 1.0;
    vec2 n = normalize(vec2(shape(p + vec2(e, 0.0)) + rippleAt(p + vec2(e, 0.0)) - shape(p - vec2(e, 0.0)) - rippleAt(p - vec2(e, 0.0)),
                            shape(p + vec2(0.0, e)) + rippleAt(p + vec2(0.0, e)) - shape(p - vec2(0.0, e)) - rippleAt(p - vec2(0.0, e))) + 1e-5);
    float inside = -d;                                   // 0 на краю, растёт внутрь
    float t = clamp(1.0 - inside / max(lens, 1.0), 0.0, 1.0);
    float bend = t * t * refr * lens * 1.6;              // у самого края сильнее, к середине — ноль

    vec2 sp = origin + p;
    vec3 col;
    if (over < 0.999) {
        vec2 o = -n * bend;
        vec3 rgb = vec3(wall(sp + o * (1.0 + disp * 0.35)).r,
                        wall(sp + o).g,
                        wall(sp + o * (1.0 - disp * 0.35)).b);
        col = mix(rgb, tint.rgb, tint.a);
    } else {
        col = tint.rgb;
    }

    // свет: купол сверху, ободок (ярче сверху-слева), блик под курсором
    float domeL = dome * 0.10 * (1.0 - smoothstep(panel.y, panel.y + panel.w * 0.55, p.y));
    float lit = 0.55 + 0.45 * dot(-n, normalize(vec2(-0.55, -0.85)));
    float rimL = rim * (smoothstep(2.2, 0.0, inside) * 0.55 * lit + t * t * 0.10);
    float sh = shine.z * shine.w * exp(-pow(length(p - shine.xy) / (min(panel.z, panel.w) * 0.45), 2.0)) * 0.16;
    col += vec3(domeL + rimL + sh);

    float a = mix(1.0, alphaOver, over);
    fragColor = vec4(col * a, a) * mask * qt_Opacity;
}
