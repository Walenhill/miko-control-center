import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

Rectangle {
    id: root

    property var style: null
    readonly property var ui: style ? style : DefaultStyle

    required property var kde

    Layout.fillWidth: true
    implicitHeight: 240
    radius: root.ui.radiusSection
    color: root.ui.sectionSurface
    border.width: phoneDrop.containsDrag ? 2 : 1
    border.color: phoneDrop.containsDrag
        ? Appearance.colors.colPrimary
        : (root.kde.reachable ? root.ui.selectedCardBorder : root.ui.hairline)
    antialiasing: true
    clip: true

    Behavior on border.color {
        ColorAnimation { duration: root.ui.motionFast }
    }

    Item {
        id: phoneArtwork

        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
            rightMargin: 28
        }
        width: 220
        height: 200

        Rectangle {
            anchors.centerIn: parent
            width: 190
            height: 190
            radius: width / 2
            color: root.kde.reachable
                ? root.ui.selectedCardBackground
                : root.ui.controlSurface
        }

        StyledImage {
            id: phoneImage

            anchors.centerIn: parent
            width: 180
            height: 180
            source: `${Directories.assetsPath}/images/nothing-phone-3a-black.png`
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true
            rotation: 0
            opacity: phoneDrop.containsDrag
                ? 0.25 : (root.kde.reachable ? 1 : 0.40)
            scale: phoneDrop.containsDrag ? 0.94 : 1

            Behavior on opacity {
                NumberAnimation {
                    duration: root.ui.motionNormal
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: root.ui.motionCurve
                }
            }
            Behavior on scale {
                NumberAnimation {
                    duration: root.ui.motionNormal
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: root.ui.motionCurve
                }
            }
        }

        MaterialSymbol {
            anchors.centerIn: parent
            visible: phoneImage.status !== Image.Ready
            text: "smartphone"
            iconSize: 96
            color: root.ui.mutedInk
            opacity: root.kde.reachable ? 0.75 : 0.35
        }
    }

    ColumnLayout {
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
            right: phoneArtwork.left
            margins: 22
            rightMargin: 12
        }
        spacing: 10

        MikoBadge {
            style: root.ui
            icon: root.kde.reachable ? "wifi" : "wifi_off"
            text: root.kde.reachable ? I18n.tr("НА СВЯЗИ (LAN)") : I18n.tr("НЕ В СЕТИ")
            tone: root.kde.reachable ? "accent" : "neutral"
        }

        StyledText {
            Layout.fillWidth: true
            text: root.kde.deviceName || I18n.tr("Телефон")
            color: root.ui.ink
            font.pixelSize: 26
            font.weight: Font.DemiBold
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
        }

        StyledText {
            Layout.fillWidth: true
            text: root.kde.reachable
                ? I18n.tr("Синхронизация через KDE Connect · перетащите файлы для отправки")
                : I18n.tr("Откройте KDE Connect на смартфоне в одной сети Wi-Fi")
            color: root.ui.mutedInk
            font.pixelSize: Appearance.font.pixelSize.smaller
            wrapMode: Text.WordWrap
        }

        Item { Layout.fillHeight: true }

        // Battery indicator
        RowLayout {
            spacing: 8

            MaterialSymbol {
                text: root.kde.isCharging ? "battery_charging_full" : "battery_android_frame_4"
                iconSize: 20
                color: Appearance.colors.colPrimary
            }

            StyledText {
                text: root.kde.batteryCharge >= 0 ? root.kde.batteryCharge + "%" : "—"
                color: root.ui.ink
                font.pixelSize: Appearance.font.pixelSize.normal
                font.weight: Font.DemiBold
            }

            StyledText {
                text: root.kde.isCharging ? I18n.tr("· Зарядка") : I18n.tr("· Аккумулятор")
                color: root.ui.mutedInk
                font.pixelSize: Appearance.font.pixelSize.smaller
            }
        }

        MikoProgressBar {
            Layout.fillWidth: true
            Layout.maximumWidth: 260
            style: root.ui
            value: Math.max(0, Math.min(1, (root.kde.batteryCharge >= 0 ? root.kde.batteryCharge : 0) / 100))
        }
    }

    // Drag-and-drop drop area
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

    // Drag over overlay
    Rectangle {
        anchors.fill: parent
        anchors.margins: 6
        radius: root.ui.radiusSection
        visible: phoneDrop.containsDrag
        color: Qt.rgba(Appearance.colors.colLayer0.r, Appearance.colors.colLayer0.g,
                       Appearance.colors.colLayer0.b, 0.92)

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 8

            MaterialSymbol {
                Layout.alignment: Qt.AlignHCenter
                text: "send_to_mobile"
                iconSize: 42
                color: Appearance.colors.colPrimary
            }

            StyledText {
                text: I18n.tr("Отпустите файлы для отправки на телефон")
                color: root.ui.ink
                font.pixelSize: Appearance.font.pixelSize.larger
                font.weight: Font.DemiBold
            }
        }
    }

    // Transfer status bar
    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: 10
        }
        implicitHeight: 46
        radius: root.ui.radiusControl
        visible: root.kde.transferState !== "idle" && !phoneDrop.containsDrag
        color: root.ui.controlSurface
        border.width: 1
        border.color: root.ui.hairline

        RowLayout {
            anchors { fill: parent; leftMargin: 14; rightMargin: 14 }
            spacing: 10

            MaterialSymbol {
                text: root.kde.transferState === "sending" ? "sync"
                    : (root.kde.transferState === "success" ? "check_circle" : "error")
                iconSize: 20
                color: root.kde.transferState === "error" ? Appearance.colors.colError : Appearance.colors.colPrimary
                RotationAnimation on rotation {
                    running: root.visible && !root.style.reducedMotion && root.kde.transferState === "sending"
                    from: 0; to: 360; duration: 900; loops: Animation.Infinite
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                StyledText {
                    text: root.kde.transferState === "sending" ? I18n.tr("Отправка по локальной сети…")
                        : (root.kde.transferState === "success" ? I18n.tr("Файл успешно передан") : I18n.tr("Ошибка передачи файла"))
                    color: root.ui.ink
                    font.weight: Font.Medium
                    font.pixelSize: Appearance.font.pixelSize.smaller
                }

                StyledText {
                    visible: root.kde.transferState === "sending"
                    text: root.kde.transferFileName || ""
                    color: root.ui.mutedInk
                    font.pixelSize: Appearance.font.pixelSize.smallest
                    elide: Text.ElideMiddle
                }
            }
        }
    }
}
