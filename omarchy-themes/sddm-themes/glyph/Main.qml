import QtQuick

// glyph для SDDM: диск, как колесо режимов на камере, а внутри тахометр из глифов. Центр — на нижнем краю экрана:
// видна верхняя половина, шкала — полукруг спидометра.
// Старт — поэтапное включение, как приборка машины: красная точка, насечка обходит круг, глифы до упора и стрелка
// туда-обратно (самотест), потом часы и сессии. Слева за насечкой — лог шагов.
// Буквы пароля разгоняют стрелку, Enter — до отсечки, пока pam думает; не тот — красная вспышка и стрелка падает.
// ←→ или колесо мыши — крутить диск (сессия), Tab — следующий пользователь, Shift+Tab или клик по имени — вписать своё,
// Esc — стереть.
// ↑ — второе кольцо, питание справа: там ←→ выбрать, Enter — выполнить, ↓ или Esc — назад, буква — назад к паролю
Rectangle {
    id: root

    width: 1920
    height: 1080
    color: bg

    readonly property color bg: "#000000"
    readonly property color s2: "#1A1A1A"
    readonly property color s3: "#2A2A2A"
    readonly property color mute: "#4A4A4A"
    readonly property color grey: "#8C8C8C"
    readonly property color fg: "#F2F2F2"
    readonly property color red: "#D71921"

    FontLoader { id: doto; source: "fonts/Doto[ROND,wght].ttf" }
    FontLoader { id: grotesk; source: "fonts/SpaceGrotesk-Regular.otf" }
    FontLoader { id: mono; source: "fonts/SpaceMono-Regular.ttf" }

    property date now: new Date()
    property bool blink: true
    Timer { running: true; repeat: true; interval: 500; onTriggered: { root.blink = !root.blink; root.now = new Date(); } }

    // ---- включение: шаги по очереди ----
    property real knurl: 0 // насечка: доля обойдённого круга
    property real test: 0  // самотест: глифы и стрелка до упора и назад
    property real face: 0  // часы, сессии, имя
    property int step: 0   // сколько шагов лога закончено
    SequentialAnimation {
        running: true
        PauseAnimation { duration: 350 }
        NumberAnimation { target: root; property: "knurl"; to: 1; duration: 700; easing.type: Easing.InOutSine }
        PropertyAction { target: root; property: "step"; value: 1 }
        NumberAnimation { target: root; property: "test"; to: 1; duration: 650; easing.type: Easing.OutCubic }
        PropertyAction { target: root; property: "step"; value: 2 }
        PauseAnimation { duration: 150 }
        NumberAnimation { target: root; property: "test"; to: 0; duration: 600; easing.type: Easing.InOutCubic }
        PropertyAction { target: root; property: "step"; value: 3 }
        NumberAnimation { target: root; property: "face"; to: 1; duration: 500; easing.type: Easing.OutQuart }
        PropertyAction { target: root; property: "step"; value: 4 }
    }

    // ---- тахометр ----
    readonly property int n: 32 // глифов на шкале, по одному на букву
    property bool busy: false
    property bool ok: false
    property bool flash: false
    property bool fail: false
    property real wave: 0
    NumberAnimation on wave { running: root.busy; from: 0; to: 1; duration: 600; loops: Animation.Infinite }
    // куда тянет стрелку; стрелка догоняет пружиной — с перелётом, как настоящая. Цель не должна меняться каждый кадр:
    // Behavior перезапустит пружину раньше её шага и стрелка встанет. Поэтому самотест (step < 3) идёт без пружины,
    // а дрожь на отсечке прибавляется к углу, а не к цели
    readonly property real level: ok ? 1 : busy ? 0.94 : Math.max(test, Math.min(pwd.text.length / n, 1))
    property real needle: level
    Behavior on needle { enabled: root.step >= 3; SpringAnimation { spring: 4; damping: 0.26; epsilon: 0.002 } }
    function deg(v) { return -84 + 168 * v; } // 0…1 → угол от 12 часов по часовой, полукруг над краем экрана

    SequentialAnimation {
        id: denied
        loops: 3
        PropertyAction { target: root; property: "flash"; value: true }
        PauseAnimation { duration: 110 }
        PropertyAction { target: root; property: "flash"; value: false }
        PauseAnimation { duration: 90 }
    }

    // ---- сессия: позиция диска ----
    property int si: sessionModel.lastIndex
    readonly property real gap: 22 // градусов между сессиями на диске
    property real rot: -si * gap
    Behavior on rot { SpringAnimation { spring: 5; damping: 0.35 } }
    function turn(d) { if (labels.count) si = (si + d + labels.count) % labels.count; }

    // ---- второе кольцо: питание. pm — выбранное с клавиатуры, -1 — кольцо не выбрано ----
    readonly property var power: [
        { t: "sleep", a: 37, can: sddm.canSuspend, go: () => sddm.suspend() },
        { t: "reboot", a: 52, can: sddm.canReboot, go: () => sddm.reboot() },
        { t: "power off", a: 68, can: sddm.canPowerOff, go: () => sddm.powerOff() }
    ]
    property int pm: -1
    // следующее доступное от i в сторону d; нет такого — остаётся i
    function next(i, d) {
        for (let j = i + d; j >= 0 && j < power.length; j += d) if (power[j].can) return j;
        return i;
    }
    // стрелки и Enter на кольце — общие для обоих полей. true — клавиша съедена, поле её не увидит
    function key(e) {
        if (pm >= 0) {
            if (e.key === Qt.Key_Left || e.key === Qt.Key_Right) pm = next(pm, e.key === Qt.Key_Right ? 1 : -1);
            else if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) { const p = power[pm]; pm = -1; p.go(); } // проснулись — кольцо отпущено, Enter будит, а не усыпляет снова
            else if (e.key === Qt.Key_Down || e.key === Qt.Key_Escape) pm = -1;
            else if (e.key !== Qt.Key_Up) { pm = -1; return false; } // печатают — назад, буква уходит в поле
            return true;
        }
        if (e.key === Qt.Key_Up) { pm = next(-1, 1); return pm >= 0; }
        if (e.key === Qt.Key_Left || e.key === Qt.Key_Right) { turn(e.key === Qt.Key_Right ? 1 : -1); return true; }
        return false;
    }

    // ---- кто входит: имя — поле, список sddm его только заполняет (Tab). Вписать можно любого, в том числе скрытого ----
    property int ui: Math.max(0, userModel.lastIndex)
    function pick(d) {
        if (!names.count) return;
        ui = (ui + d + names.count) % names.count;
        user.text = names.itemAt(ui).name;
    }
    Component.onCompleted: {
        if (!user.text && names.count) user.text = names.itemAt(ui).name; // sddm не запомнил последнего — первый из списка
        (user.text ? pwd : user).forceActiveFocus();
    }

    property bool queued: false
    property string msg // что сказал pam: «заблокирован после 3 попыток» у faillock
    function login() {
        if (busy || ok) return;
        const who = user.text.trim();
        if (!who) { user.forceActiveFocus(); return; }
        if (step < 4) { queued = true; return; } // Enter во время самотеста — войдём, как только он кончится
        queued = false;
        busy = true;
        fail = false;
        msg = "";
        sddm.login(who, pwd.text, si);
    }
    onStepChanged: if (step === 4 && queued) login()
    Connections {
        target: sddm
        function onLoginFailed() { root.busy = false; root.fail = true; pwd.text = ""; denied.restart(); }
        function onLoginSucceeded() { root.busy = false; root.ok = true; }
        function onInformationMessage(m) { root.msg = m; }
    }

    // метка: Space Mono капсом, трекинг .14em, серая
    component Lb: Text {
        property real px: 12
        font { family: mono.name; pixelSize: px; letterSpacing: px * 0.14; capitalization: Font.AllUppercase }
        color: root.grey
    }
    // надпись по дуге: буквы по окружности радиуса r, середина — под углом a (градусы от 12 часов). Space Mono
    // моноширинный — шаг у всех букв один. button — кликается (hit) и белеет под мышью
    component Arc: Item {
        id: arc
        property string text
        property real r
        property real a
        property real px: 12
        property color color: root.grey
        property bool button: false
        property int hov: 0 // сколько букв под мышью: уход с одной и приход на соседнюю приходят в любом порядке
        signal hit
        readonly property string up: text.toUpperCase()
        FontMetrics { id: fm; font { family: mono.name; pixelSize: arc.px } }
        readonly property real adv: fm.advanceWidth("M") + px * 0.14
        Repeater {
            model: arc.up.split("")
            Text {
                required property string modelData
                required property int index
                readonly property real b: arc.a + (index + 0.5 - arc.up.length / 2) * arc.adv / arc.r * 180 / Math.PI
                x: arc.r * Math.sin(b * Math.PI / 180) - width / 2
                y: -arc.r * Math.cos(b * Math.PI / 180) - height / 2
                rotation: b
                text: modelData
                font { family: mono.name; pixelSize: arc.px }
                color: arc.button && arc.hov > 0 ? root.fg : arc.color
                MouseArea {
                    x: (parent.width - arc.adv) / 2
                    y: -8
                    width: arc.adv
                    height: parent.height + 16
                    enabled: arc.button
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onContainsMouseChanged: arc.hov += containsMouse ? 1 : -1
                    onClicked: arc.hit()
                }
            }
        }
    }
    // точка на окружности радиуса r под углом a (градусы от 12 часов), центр детали — в этой точке, повёрнута по радиусу
    component Polar: Rectangle {
        property real a
        property real r
        x: r * Math.sin(a * Math.PI / 180) - width / 2
        y: -r * Math.cos(a * Math.PI / 180) - height / 2
        rotation: a
    }

    // холст 1920×1080, растянут на экран
    Item {
        id: stage
        readonly property real s: Math.min(root.width / 1920, root.height / 1080)
        width: root.width / s
        height: root.height / s
        scale: s
        transformOrigin: Item.TopLeft
        opacity: root.ok ? 0 : 1
        Behavior on opacity { SequentialAnimation { PauseAnimation { duration: 300 } NumberAnimation { duration: 500 } } }

        MouseArea {
            anchors.fill: parent
            property real acc: 0 // тачпад шлёт мелкие шаги — копим до щелчка
            onClicked: pwd.forceActiveFocus()
            onWheel: w => {
                acc += w.angleDelta.y;
                if (Math.abs(acc) < 120) return;
                root.turn(acc < 0 ? 1 : -1);
                acc = 0;
            }
        }

        Image {
            visible: config.boolValue("grid")
            anchors.fill: parent
            opacity: root.face
            fillMode: Image.Tile
            source: "data:image/svg+xml," + encodeURIComponent(`<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32"><circle cx="16" cy="16" r="1.5" fill="${root.s2}"/></svg>`)
        }

        // ---- диск: всё меряется от центра ----
        Item {
            id: dial
            x: stage.width / 2
            y: stage.height

            // вращается: насечка по краю и сессии
            Item {
                rotation: root.rot

                Repeater {
                    model: 240
                    Polar {
                        required property int index
                        // насколько фронт ушёл дальше этой риски: фронт обходит видимую половину от левого края до правого
                        readonly property real d: root.knurl - ((index * 1.5 + root.rot) % 360 + 450) % 360 / 180
                        a: index * 1.5
                        r: 760
                        width: 2.5
                        height: 22
                        visible: d >= 0 || root.knurl >= 1
                        color: d < 0.06 && root.knurl < 1 ? root.fg : root.mute
                    }
                }
                Repeater {
                    id: labels
                    model: sessionModel
                    Arc {
                        required property int index
                        required property string name
                        readonly property real off: Math.abs(((a + root.rot) % 360 + 540) % 360 - 180) // от метки, 0…180
                        a: index * root.gap
                        r: 712
                        px: 14
                        text: name
                        color: index === root.si ? root.fg : root.grey
                        opacity: root.face * Math.max(0, 1 - off / 80) * (root.pm < 0 ? 1 : 0.35)
                        button: opacity > 0.2
                        onHit: root.si = index
                    }
                }
            }

            // метка диска сверху, над ней — подсказка
            Rectangle { x: -2.5; y: -808; width: 5; height: 24; radius: 2.5; color: root.fg; opacity: root.knurl }
            Arc {
                r: 860
                px: 11
                color: root.mute
                opacity: root.face
                text: `←→ · session      ${root.next(-1, 1) >= 0 ? "↑ · power      " : ""}tab · user      enter · start`
            }

            // за насечкой по дуге: слева лог включения снизу вверх (шаг идёт — мигает, кончился — ok) и имя машины,
            // справа раскладка и питание. Питание видно всегда: нельзя (или --test-mode, там демона нет и все can* — false) —
            // тёмное и не кликается
            Repeater {
                model: ["dial", "glyph", "needle", "auth"]
                Arc {
                    required property string modelData
                    required property int index
                    readonly property bool done: root.step > index
                    r: 845
                    a: -76 + index * 13
                    visible: root.step >= index
                    opacity: done || root.blink ? 1 : 0.4
                    text: `0${index + 1} ${modelData} · ${done ? (index === 3 ? "ready" : "ok") : "··"}`
                }
            }
            Arc { r: 845; a: -22; color: root.mute; opacity: root.face; text: sddm.hostName }
            Arc { r: 845; a: 22; color: root.mute; opacity: root.face; text: keyboard.layouts[keyboard.currentLayout]?.shortName ?? "" }
            Repeater {
                model: root.power
                Arc {
                    required property var modelData
                    required property int index
                    r: 845
                    a: modelData.a
                    button: modelData.can
                    color: !button ? root.mute : root.pm === index ? root.fg : root.grey
                    opacity: root.face
                    text: modelData.t
                    onHit: modelData.go()
                }
            }
            // метка второго кольца: снаружи у выбранного, ездит, как метка диска
            Polar {
                a: root.power[Math.max(0, root.pm)].a
                r: 885
                width: 4
                height: 16
                radius: 2
                color: root.fg
                opacity: root.pm >= 0 ? 1 : 0
                Behavior on a { SpringAnimation { spring: 5; damping: 0.35 } }
                Behavior on opacity { NumberAnimation { duration: 150 } }
            }

            // шкала: глифы-капсулы, горят до стрелки. Отсечка — пока pam думает, по ним бежит провал
            Repeater {
                model: root.n
                Polar {
                    required property int index
                    readonly property bool lit: index < Math.round(root.needle * root.n)
                    readonly property bool dip: root.busy && Math.abs(index - root.wave * root.n) < 2
                    a: root.deg((index + 0.5) / root.n)
                    r: 610
                    width: 10
                    height: 36
                    radius: 5
                    visible: root.step >= 1 || root.test > 0
                    color: root.flash ? root.red : lit && !dip ? root.fg : root.s3
                    Behavior on color { ColorAnimation { duration: 90 } }
                }
            }
            Repeater {
                model: 5
                Lb {
                    required property int index
                    readonly property real a: root.deg(index / 4) * Math.PI / 180
                    x: 658 * Math.sin(a) - width / 2
                    y: -658 * Math.cos(a) - height / 2
                    px: 13
                    text: index * root.n / 4
                    opacity: root.face
                }
            }

            // секунды: внутренняя дуга точек, той же ширины, что шкала
            Repeater {
                model: 60
                Polar {
                    required property int index
                    a: root.deg(index / 59)
                    r: 320
                    width: 5
                    height: 5
                    radius: 2.5
                    opacity: root.knurl
                    color: index === root.now.getSeconds() ? root.fg : index < root.now.getSeconds() ? root.mute : root.s2
                }
            }

            // стрелка: от кольца секунд до шкалы, кончик красный
            Item {
                rotation: root.deg(root.needle + (root.busy ? 0.015 * Math.sin(root.wave * 4 * Math.PI) : 0))
                opacity: root.step >= 1 ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 200 } }
                Rectangle {
                    x: -2
                    y: -578
                    width: 4
                    height: 230
                    radius: 2
                    color: root.fg
                    Rectangle { width: 4; height: 44; radius: 2; color: root.red }
                }
            }

            // первое, что загорается
            Rectangle {
                x: -8; y: -200; width: 16; height: 16; radius: 8
                color: root.red
                opacity: 1 - root.face
                NumberAnimation on scale { from: 0; to: 1; duration: 300; easing.type: Easing.OutBack }
            }

            Row {
                x: -width / 2
                y: -262
                opacity: root.face
                Repeater {
                    // "h" без AP в формате у Qt всё равно 0…23 — 12-часовое считаем сами
                    model: [config.boolValue("clock24") ? Qt.formatTime(root.now, "hh") : String(root.now.getHours() % 12 || 12), ":", Qt.formatTime(root.now, "mm")]
                    Text {
                        required property string modelData
                        required property int index
                        text: modelData
                        font { family: doto.name; pixelSize: 130; weight: Font.Black; variableAxes: ({ "ROND": 100, "wght": 900 }) }
                        topPadding: -0.175 * font.pixelSize
                        bottomPadding: topPadding
                        color: root.fg
                        opacity: index === 1 && !root.blink ? 0.2 : 1
                    }
                }
            }
            Lb {
                x: -width / 2
                y: -128
                px: 12
                text: Qt.locale("en_US").toString(root.now, "ddd · d MMM")
                opacity: root.face
            }

            // под часами — кто входит и что происходит
            Repeater { id: names; model: userModel; Item { required property string name } } // логины для Tab
            TextInput {
                id: user
                x: -width / 2
                y: -98
                width: 360
                height: 30
                opacity: root.face
                text: userModel.lastUser
                horizontalAlignment: TextInput.AlignHCenter
                font { family: grotesk.name; pixelSize: 24 }
                color: root.fg
                selectionColor: root.s3
                selectedTextColor: root.fg
                Lb { anchors.centerIn: parent; visible: !parent.text; text: "user" }
                onActiveFocusChanged: if (activeFocus) selectAll() // начали печатать — имя заменяется целиком
                onAccepted: pwd.forceActiveFocus()
                Keys.onPressed: e => {
                    if (root.pm < 0 && (e.key === Qt.Key_Left || e.key === Qt.Key_Right)) return; // поле видно — стрелки двигают курсор, не диск
                    if (root.key(e)) e.accepted = true;
                    else if (e.key === Qt.Key_Tab || e.key === Qt.Key_Backtab) { pwd.forceActiveFocus(); e.accepted = true; }
                }
            }
            Lb {
                x: -width / 2
                y: -52
                px: 12
                opacity: root.face
                color: root.flash || root.fail ? root.red : root.grey
                text: root.ok ? "welcome" : root.busy ? "ignition…" : root.fail ? root.msg || "denied · try again"
                    : root.pm >= 0 ? `enter · ${root.power[root.pm].t}      ↓ · back`
                    : user.activeFocus ? "type user · tab"
                    : pwd.text ? `${pwd.text.length} · enter to start` : "type password"
            }
        }

        // ввод — настоящий TextInput (раскладки, IME), только невидимый
        TextInput {
            id: pwd
            width: 1
            height: 1
            opacity: 0
            focus: true
            echoMode: TextInput.Password
            onTextEdited: root.fail = false
            onAccepted: root.login()
            // курсор в невидимом поле не нужен — стрелки отданы диску и кольцу
            Keys.onPressed: e => {
                if (root.key(e)) e.accepted = true;
                else if (e.key === Qt.Key_Escape) { text = ""; e.accepted = true; }
                else if (e.key === Qt.Key_Tab || e.key === Qt.Key_Backtab) {
                    if (e.key === Qt.Key_Tab && names.count > 1) root.pick(1);
                    else user.forceActiveFocus(); // один в списке или Shift+Tab — вписать имя
                    e.accepted = true;
                }
            }
        }

        // углы сверху: слева марка, справа индикаторы — точка горит, пока клавиша включена
        Column {
            x: 44
            y: 36
            spacing: 6
            opacity: root.face
            Text {
                text: "GLYPH"
                font { family: doto.name; pixelSize: 34; weight: Font.Black; variableAxes: ({ "ROND": 100, "wght": 900 }) }
                topPadding: -0.175 * font.pixelSize
                bottomPadding: topPadding
                color: root.fg
            }
            Lb { px: 11; text: "login" }
        }
        Row {
            anchors { right: parent.right; rightMargin: 44 }
            y: 40
            spacing: 28
            opacity: root.face
            Repeater {
                model: [["caps", keyboard.capsLock], ["num", keyboard.numLock]]
                Row {
                    required property var modelData
                    spacing: 10
                    Rectangle { anchors.verticalCenter: parent.verticalCenter; width: 8; height: 8; radius: 4; color: parent.modelData[1] ? root.fg : root.s3 }
                    Lb { px: 11; text: parent.modelData[0]; color: parent.modelData[1] ? root.fg : root.grey }
                }
            }
        }

    }
}
