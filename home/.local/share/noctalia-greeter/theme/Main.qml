import QtQuick 2.15

Rectangle {
    id: root
    color: config.card ? config.card : "#0b0d0e"

    // ================= Palette (theme.conf, disinkron dari wallpaper) =================
    property string accent:            config.primary          ? config.primary          : "#9ccdec"
    property string accentHover:       config.primaryHover     ? config.primaryHover     : "#30637e"
    property string accentOn:          config.onPrimary        ? config.onPrimary        : "#00344a"
    property string surfaceC:          config.surface          ? config.surface          : "#0c0e10"
    property string onSurface:         config.onSurface        ? config.onSurface        : "#e2e2e5"
    property string onSurfaceVariant:  config.onSurfaceVariant ? config.onSurfaceVariant : "#c1c7cd"
    property string outlineC:          config.outline          ? config.outline          : "#8b9297"
    property string errorC:            config.error            ? config.error            : "#ffb4ab"
    property string fontF:             config.fontFamily       ? config.fontFamily       : "Cantarell"
    property string monoF: "MesloLGS Nerd Font Mono"
    property string cjkF: "Noto Sans CJK JP"

    // font retro Jepang (bundled di folder tema)
    FontLoader { id: retroFont; source: "DotGothic16-Regular.ttf" }

    property bool   showError: false
    property string errorMsg: "Sandi salah, coba lagi"

    // ================= Latar: wallpaper blur + vignette =================
    Image {
        anchors.fill: parent
        source: config.background ? config.background : ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: false
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#40000000" }
            GradientStop { position: 0.5; color: "#70000000" }
            GradientStop { position: 1.0; color: "#c0000000" }
        }
    }

    // ================= Jam & tanggal =================
    property var now: new Date()

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.now = new Date()
    }

    function pad(n) { return n < 10 ? "0" + n : n }

    readonly property var hariID:  ["Minggu", "Senin", "Selasa", "Rabu", "Kamis", "Jumat", "Sabtu"]
    readonly property var hariJA:  ["日曜日", "月曜日", "火曜日", "水曜日", "木曜日", "金曜日", "土曜日"]
    readonly property var bulanID: ["Januari", "Februari", "Maret", "April", "Mei", "Juni",
                                    "Juli", "Agustus", "September", "Oktober", "November", "Desember"]

    property string tanggalJA:
        now.getFullYear() + "年" + pad(now.getMonth() + 1) + "月" + pad(now.getDate()) + "日  " + hariJA[now.getDay()]

    property string tanggalID:
        hariID[now.getDay()] + ", " + now.getDate() + " " + bulanID[now.getMonth()] + " " + now.getFullYear()

    Column {
        id: timeColumn
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 100
        spacing: 0

        // kanji tipis di atas jam
        Text {
            id: kanjiLabel
            anchors.horizontalCenter: parent.horizontalCenter
            text: "現在時刻"
            font.family: root.cjkF
            font.weight: Font.Light
            font.pixelSize: 11
            font.letterSpacing: 2.4
            color: Qt.rgba(1, 1, 1, 0.45)
            opacity: 0
        }

        // jam besar (retro font)
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 0

            Text {
                id: hourText
                text: pad(root.now.getHours())
                font.family: root.retroFont.name || root.monoF
                font.weight: Font.Light
                font.pixelSize: 84
                font.letterSpacing: 3
                color: root.onSurface
                opacity: 0
            }

            // titik dua digital (dua lingkaran kecil)
            Item {
                width: 12
                height: 84
                anchors.verticalCenter: hourText.verticalCenter

                Rectangle {
                    width: 6
                    height: 6
                    radius: 3
                    color: root.accent
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 24
                    opacity: 0.85

                    SequentialAnimation on opacity {
                        running: true
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.25; duration: 950; easing.type: Easing.InOutSine }
                        NumberAnimation { to: 0.85; duration: 950; easing.type: Easing.InOutSine }
                    }
                }

                Rectangle {
                    width: 6
                    height: 6
                    radius: 3
                    color: root.accent
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 24
                    opacity: 0.85

                    SequentialAnimation on opacity {
                        running: true
                        loops: Animation.Infinite
                        PauseAnimation { duration: 475 }
                        NumberAnimation { to: 0.25; duration: 950; easing.type: Easing.InOutSine }
                        NumberAnimation { to: 0.85; duration: 950; easing.type: Easing.InOutSine }
                    }
                }
            }

            Text {
                id: minuteText
                text: pad(root.now.getMinutes())
                font.family: root.retroFont.name || root.monoF
                font.weight: Font.Light
                font.pixelSize: 84
                font.letterSpacing: 3
                color: root.onSurface
                opacity: 0
            }
        }

        // garis rambut tipis di bawah jam
        Item {
            id: hairlineWrap
            width: 150
            height: 2
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 14

            Rectangle {
                anchors.fill: parent
                height: 1
                color: Qt.rgba(1, 1, 1, 0.10)
            }

            Rectangle {
                width: 4
                height: 4
                radius: 2
                color: root.accent
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                opacity: 0.7
            }
        }

        // tanggal Jepang (utama)
        Text {
            id: dateJA
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.tanggalJA
            font.family: root.cjkF
            font.weight: Font.Light
            font.pixelSize: 15
            font.letterSpacing: 1.2
            color: root.onSurfaceVariant
            opacity: 0
        }

        // tanggal Indonesia (pelengkap tipis)
        Text {
            id: dateID
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.tanggalID
            font.family: root.fontF
            font.pixelSize: 11
            font.letterSpacing: 1.0
            color: Qt.rgba(1, 1, 1, 0.5)
            opacity: 0
        }

        // animasi masuk keseluruhan blok waktu
        SequentialAnimation {
            id: timeEntry
            running: true
            PauseAnimation { duration: 60 }
            NumberAnimation { target: kanjiLabel; property: "opacity"; to: 1; duration: 700; easing.type: Easing.OutCubic }
            NumberAnimation { target: hourText; property: "opacity"; to: 1; duration: 700; easing.type: Easing.OutCubic }
            NumberAnimation { target: minuteText; property: "opacity"; to: 1; duration: 700; easing.type: Easing.OutCubic }
            NumberAnimation { target: hairlineWrap; property: "opacity"; to: 1; duration: 700; easing.type: Easing.OutCubic }
            NumberAnimation { target: dateJA; property: "opacity"; to: 1; duration: 700; easing.type: Easing.OutCubic }
            NumberAnimation { target: dateID; property: "opacity"; to: 1; duration: 700; easing.type: Easing.OutCubic }
        }
    }

    // ================= Kartu login =================
    property string currentUser: (typeof userModel !== "undefined" && userModel) ? userModel.lastUser : ""
    property int sessionIndex: (typeof session !== "undefined" && session) ? session.index : 0

    Rectangle {
        id: card
        width: 360
        color: root.surfaceC
        opacity: 0.94
        border.color: Qt.rgba(1, 1, 1, 0.06)
        border.width: 1
        radius: 22
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        // bayangan lembut
        Rectangle {
            z: -1
            anchors.fill: parent
            anchors.margins: -1
            radius: 24
            color: "#20000000"
        }

        // aksen vertikal tepi kiri (Japanese thin)
        Rectangle {
            width: 2
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            color: root.accent
            opacity: 0.35
        }

        Column {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 24
            anchors.rightMargin: 24
            spacing: 14

            // pengguna
            Row {
                spacing: 12

                Rectangle {
                    width: 40
                    height: 40
                    radius: 20
                    color: root.accent

                    Text {
                        anchors.centerIn: parent
                        text: root.currentUser.length ? root.currentUser.charAt(0).toUpperCase() : "?"
                        font.family: root.monoF
                        font.bold: true
                        font.pixelSize: 18
                        color: root.accentOn
                    }
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    Text {
                        text: root.currentUser.length ? root.currentUser : "Pengguna"
                        font.family: root.fontF
                        font.bold: true
                        font.pixelSize: 14
                        color: root.onSurface
                    }

                    Text {
                        text: "Masukkan sandi untuk masuk"
                        font.family: root.fontF
                        font.pixelSize: 11
                        font.letterSpacing: 0.6
                        color: root.onSurfaceVariant
                        opacity: root.showError ? 0 : 1
                        Behavior on opacity { NumberAnimation { duration: 200 } }
                    }
                }
            }

            // kolom sandi
            Rectangle {
                id: pwdField
                width: parent.width
                height: 46
                radius: 12
                color: Qt.rgba(1, 1, 1, 0.03)
                border.width: passwordInput.activeFocus ? 2 : 1
                border.color: passwordInput.activeFocus
                              ? root.accent
                              : (root.showError ? root.errorC : Qt.rgba(1, 1, 1, 0.14))

                Behavior on border.color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }

                TextInput {
                    id: passwordInput
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 44
                    verticalAlignment: TextInput.AlignVCenter
                    echoMode: TextInput.Password
                    passwordCharacter: "•"
                    passwordMaskDelay: 0
                    font.family: root.monoF
                    font.pixelSize: 14
                    color: root.onSurface
                    selectionColor: root.accent
                    selectedTextColor: root.accentOn
                    focus: true
                    clip: true

                    cursorDelegate: Rectangle {
                        width: 2
                        height: 16
                        radius: 1
                        color: root.accent
                        anchors.verticalCenter: parent.verticalCenter

                        SequentialAnimation on opacity {
                            running: passwordInput.activeFocus
                            loops: Animation.Infinite
                            NumberAnimation { to: 0.0; duration: 550; easing.type: Easing.InOutSine }
                            NumberAnimation { to: 1.0; duration: 550; easing.type: Easing.InOutSine }
                        }
                    }

                    onAccepted: root.doLogin()
                }

                Rectangle {
                    id: revealBtn
                    width: 30
                    height: 30
                    radius: 8
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    color: revealMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.06) : "transparent"
                    Behavior on color { ColorAnimation { duration: 140 } }

                    MouseArea {
                        id: revealMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            passwordInput.echoMode =
                                passwordInput.echoMode === TextInput.Password
                                    ? TextInput.Normal
                                    : TextInput.Password
                            passwordInput.forceActiveFocus()
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    anchors.rightMargin: 40
                    onClicked: passwordInput.forceActiveFocus()
                }
            }

            // pesan galat
            Item {
                width: parent.width
                height: root.showError ? 14 : 0
                clip: true
                Behavior on height { NumberAnimation { duration: 180; easing.type: Easing.InOutQuad } }

                Text {
                    text: root.errorMsg
                    font.family: root.fontF
                    font.pixelSize: 11
                    color: root.errorC
                }
            }

            // tombol masuk
            Rectangle {
                id: loginBtn
                width: parent.width
                height: 44
                radius: 12
                color: loginMouse.containsMouse ? root.accentHover : root.accent
                Behavior on color { ColorAnimation { duration: 150 } }

                Text {
                    anchors.centerIn: parent
                    text: "MASUK"
                    font.family: root.fontF
                    font.bold: true
                    font.pixelSize: 13
                    font.letterSpacing: 1.2
                    color: root.accentOn
                }

                MouseArea {
                    id: loginMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onPressed: loginBtn.scale = 0.98
                    onReleased: loginBtn.scale = 1
                    onClicked: root.doLogin()
                }

                Behavior on scale { NumberAnimation { duration: 110; easing.type: Easing.OutQuad } }
            }

            // sesi + layout
            Row {
                width: parent.width
                spacing: 8

                Rectangle {
                    id: sessionBtn
                    width: sessionModel && sessionModel.count > 1 ? (parent.width - 8) / 2 : parent.width
                    height: 32
                    radius: 8
                    color: sessionMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent"
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.10)
                    Behavior on color { ColorAnimation { duration: 140 } }
                    visible: sessionModel && sessionModel.count > 1

                    Text {
                        anchors.centerIn: parent
                        width: parent.width - 18
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                        text: sessionModel && sessionModel.count
                              ? sessionModel.get(session.index).name
                              : ""
                        font.family: root.fontF
                        font.pixelSize: 11
                        font.letterSpacing: 0.4
                        color: root.onSurfaceVariant
                    }

                    MouseArea {
                        id: sessionMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            var n = sessionModel.count
                            if (n > 1) session.index = (session.index + 1) % n
                        }
                    }
                }

                Rectangle {
                    id: layoutBtn
                    width: keyboard && keyboard.enabled && keyboard.layouts.length > 1
                           ? (parent.width - 8) / 2
                           : parent.width
                    height: 32
                    radius: 8
                    color: layoutMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent"
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.10)
                    Behavior on color { ColorAnimation { duration: 140 } }
                    visible: keyboard && keyboard.enabled && keyboard.layouts.length > 1

                    Text {
                        anchors.centerIn: parent
                        text: keyboard && keyboard.enabled
                              ? String(keyboard.layouts[keyboard.currentLayout]).toUpperCase()
                              : ""
                        font.family: root.monoF
                        font.bold: true
                        font.pixelSize: 10
                        color: root.onSurfaceVariant
                    }

                    MouseArea {
                        id: layoutMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: keyboard.layoutChanged()
                    }
                }
            }

            // daya
            Row {
                width: parent.width
                spacing: 8

                Repeater {
                    model: root.powerItems

                    delegate: Rectangle {
                        width: (parent.width - 8 * (root.powerItems.length - 1)) / Math.max(1, root.powerItems.length)
                        height: 32
                        radius: 8
                        color: pwrMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent"
                        border.width: 1
                        border.color: Qt.rgba(1, 1, 1, 0.10)
                        Behavior on color { ColorAnimation { duration: 140 } }

                        Text {
                            anchors.centerIn: parent
                            text: modelData.label
                            font.family: root.fontF
                            font.pixelSize: 11
                            font.letterSpacing: 0.4
                            color: root.onSurfaceVariant
                        }

                        MouseArea {
                            id: pwrMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: modelData.action()
                        }
                    }
                }
            }
        }
    }

    // animasi masuk kartu
    Component.onCompleted: {
        card.opacity = 0
        card.scale = 0.96
        cardShift.y = 20
        introAnim.start()
    }

    transform: Translate { id: cardShift; y: 20 }

    ParallelAnimation {
        id: introAnim
        NumberAnimation {
            target: card
            property: "opacity"
            to: 0.94
            duration: 800
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: card
            property: "scale"
            to: 1.0
            duration: 800
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: cardShift
            property: "y"
            to: 0
            duration: 800
            easing.type: Easing.OutCubic
        }
    }

    // aksi
    function doLogin() {
        if (!passwordInput.text.length) {
            passwordInput.forceActiveFocus()
            return
        }
        root.showError = false
        sddm.login(root.currentUser, passwordInput.text, root.sessionIndex)
    }

    Connections {
        target: sddm

        function onLoginSucceeded() { }

        function onLoginFailed() {
            passwordInput.text = ""
            passwordInput.forceActiveFocus()
            root.showError = true
        }

        function onInformationMessage(message) {
            root.errorMsg = message
            root.showError = true
        }
    }

    readonly property var powerItems: {
        var items = []
        if (typeof sddm !== "undefined" && sddm) {
            if (sddm.canSuspend)  items.push({ label: "Tidur",          action: function() { sddm.suspend()  } })
            if (sddm.canReboot)   items.push({ label: "Hidupkan ulang", action: function() { sddm.reboot()   } })
            if (sddm.canPowerOff) items.push({ label: "Matikan",        action: function() { sddm.powerOff() } })
        }
        return items
    }

    Timer {
        interval: 250
        running: true
        repeat: false
        onTriggered: passwordInput.forceActiveFocus()
    }
}
