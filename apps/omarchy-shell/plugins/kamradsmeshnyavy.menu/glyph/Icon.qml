import QtQuick


// Из glyph-rice (GPL-3.0). глиф Nerd Font (Material Design). Рамка 1em, как line-height: 1 в концепте (строка NF 1.32em)
Text {
    readonly property real lead: -0.16 * font.pixelSize
    font { family: "JetBrainsMono Nerd Font"; pixelSize: 19 }
    topPadding: lead
    bottomPadding: lead
    color: GTheme.fg
}
