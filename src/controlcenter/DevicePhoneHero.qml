import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

Rectangle {
    id: root

    required property var kde
    required property var style

    Layout.fillWidth: true
    implicitHeight: 252
    radius: root.style.radiusWindow
    color: Qt.rgba(
        Appearance.colors.colPrimary.r,
        Appearance.colors.colPrimary.g,
        Appearance.colors.colPrimary.b,
        0.16
    )
    border.width: phoneDrop.containsDrag ? 2 : 1
    border.color: phoneDrop.containsDrag ? Appearance.colors.colPrimary : root.style.hairline
    antialiasing: true
    clip: true

    Rectangle {
        anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: 35 }
        width: 240
        height: 240
        radius: width / 2
        color: Qt.rgba(
            Appearance.colors.colPrimary.r,
            Appearance.colors.colPrimary.g,
            Appearance.colors.colPrimary.b,
            0.13
        )
    }

    StyledImage {
        id: phoneImage

        anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
            rightMargin: 48
            topMargin: 4
            bottomMargin: -10
        }
        width: 176
        source: `${Directories.assetsPath}/images/nothing-phone-3a-black.png`
        fillMode: Image.PreserveAspectFit
        smooth: true
        mipmap: true
        rotation: 4
        opacity: phoneDrop.containsDrag ? 0.30 : (root.kde.reachable ? 1 : 0.40)
        scale: phoneDrop.containsDrag ? 0.94 : 1
        Behavior on opacity {
            NumberAnimation {
                duration: root.style.motionNormal
                easing.type: Easing.BezierSpline
                easing.bezierCurve: root.style.motionCurve
            }
        }
        Behavior on scale {
            NumberAnimation {
                duration: root.style.motionNormal
                easing.type: Easing.BezierSpline
                easing.bezierCurve: root.style.motionCurve
            }
        }
    }

    MaterialSymbol {
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
            rightMargin: 92
        }
        visible: phoneImage.status !== Image.Ready
        text: "smartphone"
        iconSize: 104
        color: root.style.mutedInk
        opacity: root.kde.reachable ? 0.75 : 0.35
    }

    ColumnLayout {
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
            right: parent.horizontalCenter
            margins: 22
            rightMargin: -30
        }
        spacing: 9

        Rectangle {
            implicitWidth: phoneStatus.implicitWidth + 20
            implicitHeight: 29
            radius: 14
            color: root.kde.reachable
                ? Qt.rgba(Appearance.colors.colPrimary.r, Appearance.colors.colPrimary.g,
                          Appearance.colors.colPrimary.b, 0.18)
                : root.style.controlSurface
            RowLayout {
                id: phoneStatus
                anchors.centerIn: parent
                spacing: 6
                Rectangle {
                    width: 7; height: 7; radius: 4
                    color: root.kde.reachable ? Appearance.colors.colPrimary : root.style.mutedInk
                }
                StyledText {
                    text: root.kde.reachable ? "НА СВЯЗИ" : "НЕ В СЕТИ"
                    color: root.style.ink
                    font.pixelSize: Appearance.font.pixelSize.smallest
                    font.weight: Font.Bold
                }
            }
        }

        StyledText {
            Layout.fillWidth: true
            text: root.kde.deviceName || "Телефон"
            color: root.style.ink
            font.pixelSize: 29
            font.weight: Font.DemiBold
            wrapMode: Text.WordWrap
        }
        StyledText {
            text: root.kde.reachable ? "Подключён через локальную сеть" : "Открой KDE Connect на телефоне"
            color: root.style.mutedInk
            font.pixelSize: Appearance.font.pixelSize.small
        }
        Item { Layout.fillHeight: true }
        RowLayout {
            spacing: 7
            MaterialSymbol {
                text: root.kde.isCharging ? "battery_charging_full" : "battery_android_frame_4"
                iconSize: 20
                color: Appearance.colors.colPrimary
            }
            StyledText {
                text: root.kde.batteryCharge >= 0 ? root.kde.batteryCharge + "%" : "—"
                color: root.style.ink
                font.pixelSize: Appearance.font.pixelSize.larger
                font.weight: Font.DemiBold
            }
            StyledText { text: "· LAN"; color: root.style.mutedInk }
        }
        Rectangle {
            Layout.fillWidth: true
            Layout.maximumWidth: 280
            implicitHeight: 6
            radius: 3
            color: root.style.controlSurface
            Rectangle {
                width: parent.width * Math.max(0, Math.min(1, root.kde.batteryCharge / 100))
                height: parent.height
                radius: parent.radius
                color: Appearance.colors.colPrimary
            }
        }
    }

    DropArea {
        id: phoneDrop
        anchors.fill: parent
        enabled: root.kde.reachable
        onDropped: drop => {
            if (drop.hasUrls) {
                root.kde.sendFiles(drop.urls)
                drop.acceptProposedAction()
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 8
        radius: 24
        visible: phoneDrop.containsDrag
        color: Qt.rgba(Appearance.colors.colLayer0.r, Appearance.colors.colLayer0.g,
                       Appearance.colors.colLayer0.b, 0.91)
        ColumnLayout {
            anchors.centerIn: parent
            MaterialSymbol {
                Layout.alignment: Qt.AlignHCenter
                text: "send_to_mobile"
                iconSize: 38
                color: Appearance.colors.colPrimary
            }
            StyledText {
                text: "Отпускай — отправлю по LAN"
                color: root.style.ink
                font.pixelSize: Appearance.font.pixelSize.larger
                font.weight: Font.DemiBold
            }
        }
    }

    Rectangle {
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom; margins: 10 }
        implicitHeight: 48
        radius: 18
        visible: root.kde.transferState !== "idle" && !phoneDrop.containsDrag
        color: root.style.controlSurface
        RowLayout {
            anchors { fill: parent; leftMargin: 13; rightMargin: 13 }
            MaterialSymbol {
                text: root.kde.transferState === "sending" ? "sync"
                    : (root.kde.transferState === "success" ? "check_circle" : "error")
                iconSize: 21
                color: root.kde.transferState === "error" ? Appearance.colors.colError : Appearance.colors.colPrimary
                RotationAnimation on rotation {
                    running: root.kde.transferState === "sending"
                    from: 0; to: 360; duration: 900; loops: Animation.Infinite
                }
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0
                StyledText {
                    text: root.kde.transferState === "sending" ? "Отправляю по LAN"
                        : (root.kde.transferState === "success" ? "Отправлено" : "Ошибка передачи")
                    color: root.style.ink
                    font.weight: Font.Medium
                }
                StyledText {
                    visible: root.kde.transferState === "sending"
                    text: root.kde.transferFileName
                    color: root.style.mutedInk
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    elide: Text.ElideMiddle
                }
            }
        }
    }
}
