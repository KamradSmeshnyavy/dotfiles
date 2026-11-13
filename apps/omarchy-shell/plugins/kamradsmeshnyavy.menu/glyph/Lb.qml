import QtQuick


// Из glyph-rice (GPL-3.0). метка: Space Mono капсом, трекинг .14em, серая. Размер — px (а не font.pixelSize: трекинг считается от него)
Text {
    textFormat: Text.PlainText // в подписях чужие строки (сети, устройства, окна, треки): AutoText грузил бы из них <img src="http://…">
    property real px: 12
    font { family: GTheme.mono; pixelSize: px; letterSpacing: px * 0.14; capitalization: Font.AllUppercase }
    color: GTheme.grey
}
