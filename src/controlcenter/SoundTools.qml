import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    required property var controller
    required property var effects
    required property var style

    Layout.fillWidth: true
    spacing: 12

    GridLayout {
        Layout.fillWidth: true
        columns: width > 820 ? 2 : 1
        columnSpacing: 12
        rowSpacing: 12

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: effectsContent.implicitHeight + 30
            radius: root.style.radiusSection
            color: root.style.sectionSurface
            border.width: 1
            border.color: root.style.hairline
            antialiasing: true
            ColumnLayout {
                id: effectsContent
                anchors { left: parent.left; right: parent.right; top: parent.top; margins: 15 }
                spacing: 8
                RowLayout {
                    Layout.fillWidth: true
                    MikoIconDisc { style: root.style; icon: "equalizer"; accented: root.effects.active }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        StyledText { text: "Обработка звука"; color: root.style.ink; font.pixelSize: Appearance.font.pixelSize.small; font.weight: Font.DemiBold }
                        StyledText {
                            text: root.effects.available
                                ? (root.effects.active ? "EasyEffects работает" : "EasyEffects выключен")
                                : "EasyEffects не установлен"
                            color: root.style.mutedInk
                            font.pixelSize: Appearance.font.pixelSize.smaller
                        }
                    }
                    MikoButton {
                        style: root.style
                        visible: !root.effects.available
                        icon: "download"
                        text: root.controller.effectsInstallBusy
                            ? "Установка…" : "Установить"
                        enabled: root.controller.effectsInstallAvailable
                            && !root.controller.effectsInstallBusy
                        onClicked: root.controller.installEffects()
                    }
                    StyledSwitch {
                        visible: root.effects.available
                        checked: root.effects.active
                        onClicked: root.effects.toggle()
                    }
                }
                StyledText {
                    visible: root.controller.actionMessage !== ""
                    text: root.controller.actionMessage
                    color: root.style.mutedInk
                    font.pixelSize: Appearance.font.pixelSize.smaller
                }
                MikoButton {
                    style: root.style
                    visible: root.effects.available
                    Layout.alignment: Qt.AlignRight
                    icon: "open_in_new"
                    text: "Эквалайзер и эффекты"
                    onClicked: root.effects.openApp()
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: protectionContent.implicitHeight + 30
            radius: root.style.radiusSection
            color: root.style.sectionSurface
            border.width: 1
            border.color: root.style.hairline
            antialiasing: true
            ColumnLayout {
                id: protectionContent
                anchors { left: parent.left; right: parent.right; top: parent.top; margins: 15 }
                spacing: 2
                MikoToggleRow { style: root.style; title: "Защита слуха"; subtitle: "Останавливает резкий скачок громкости"; icon: "hearing"; checked: Config.options.audio.protection.enable; onToggled: checked => Config.options.audio.protection.enable = checked }
                MikoStepperRow { style: root.style; title: "Максимальная громкость"; icon: "vertical_align_top"; value: Config.options.audio.protection.maxAllowed; minimum: 20; maximum: 120; step: 5; suffix: "%"; onChanged: value => Config.options.audio.protection.maxAllowed = value }
                MikoStepperRow { style: root.style; title: "Допустимый скачок"; icon: "arrow_warm_up"; value: Config.options.audio.protection.maxAllowedIncrease; minimum: 2; maximum: 50; step: 2; suffix: "%"; onChanged: value => Config.options.audio.protection.maxAllowedIncrease = value }
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 92
        radius: root.style.radiusSection
        color: root.style.sectionSurface
        border.width: 1
        border.color: root.style.hairline
        antialiasing: true
        RowLayout {
            anchors { fill: parent; margins: 15 }
            spacing: 12
            MikoIconDisc { style: root.style; icon: "spatial_audio" }
            ColumnLayout {
                Layout.preferredWidth: 180
                spacing: 0
                StyledText { text: "Стереобаланс"; color: root.style.ink; font.pixelSize: Appearance.font.pixelSize.small; font.weight: Font.DemiBold }
                StyledText {
                    text: Math.abs(root.controller.balance) < 0.02 ? "По центру"
                        : root.controller.balance < 0
                            ? "Левее на " + Math.round(Math.abs(root.controller.balance) * 100) + "%"
                            : "Правее на " + Math.round(root.controller.balance * 100) + "%"
                    color: root.style.mutedInk
                    font.pixelSize: Appearance.font.pixelSize.smaller
                }
            }
            StyledText { text: "Л"; color: root.style.mutedInk; font.pixelSize: Appearance.font.pixelSize.smaller }
            StyledSlider {
                Layout.fillWidth: true
                from: -1
                to: 1
                value: root.controller.balance
                configuration: StyledSlider.Configuration.S
                onMoved: root.controller.applyBalance(value)
            }
            StyledText { text: "П"; color: root.style.mutedInk; font.pixelSize: Appearance.font.pixelSize.smaller }
            MikoButton {
                style: root.style
                icon: "center_focus_strong"
                text: "Центр"
                enabled: Math.abs(root.controller.balance) >= 0.02
                onClicked: root.controller.applyBalance(0)
            }
        }
    }
}
