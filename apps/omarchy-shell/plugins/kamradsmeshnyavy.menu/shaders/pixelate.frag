#version 440
// Пикселизация (Retro у Vitreus на ходу): квадраты px × px, каждый — цвет своей середины. px ≤ 1 — как есть.
// Сборка: qsb --qt6 -o pixelate.frag.qsb pixelate.frag
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 size;
    float px;
};
layout(binding = 1) uniform sampler2D source;
void main() {
    vec2 p = qt_TexCoord0 * size;
    if (px > 1.0) p = (floor(p / px) + 0.5) * px;
    fragColor = texture(source, p / size) * qt_Opacity;
}
