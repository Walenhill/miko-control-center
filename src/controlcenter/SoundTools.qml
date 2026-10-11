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
    spacing: root.style.gapSection

    MikoSectionHeader {
        style: root.style
        title: I18n.tr("Тонкая настройка")
        subtitle: I18n.tr("Эффекты, баланс и защита")
    }

    GridLayout {
        Layout.fillWidth: true
        columns: width > 820 ? 2 : 1
        columnSpacing: 12
        rowSpacing: 12

        MikoSurface {
            Layout.fillWidth: true
            implicitHeight: effectsContent.implicitHeight + 30
            style: root.style

            ColumnLayout {
                id: effectsContent
                anchors { left: parent.left; right: parent.right; top: parent.top; margins: root.style.cardPadding }
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    MikoIconDisc { style: root.style; icon: "equalizer"; accented: root.effects.active }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        StyledText { text: I18n.tr("Обработка звука"); color: root.style.ink; font.pixelSize: Appearance.font.pixelSize.small; font.weight: Font.DemiBold }
                        StyledText {
                            text: root.effects.available
                                ? (root.effects.active ? I18n.tr("EasyEffects работает") : I18n.tr("EasyEffects выключен"))
                                : I18n.tr("EasyEffects не установлен")
                            color: root.style.mutedInk
                            font.pixelSize: Appearance.font.pixelSize.smaller
                        }
                    }
                    MikoButton {
                        style: root.style
                        visible: !root.effects.available
                        icon: "download"
                        text: root.controller.effectsInstallBusy
                            ? I18n.tr("Установка…") : I18n.tr("Установить")
                        enabled: root.controller.effectsInstallAvailable
                            && !root.controller.effectsInstallBusy
                        onClicked: root.controller.installEffects()
                    }
                    MikoSwitch {
                        style: root.style
                        Accessible.name: "EasyEffects"
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
                    text: I18n.tr("Эквалайзер и эффекты")
                    onClicked: root.effects.openApp()
                }
            }
        }

        MikoSurface {
            Layout.fillWidth: true
            implicitHeight: protectionContent.implicitHeight + 30
            style: root.style

            ColumnLayout {
                id: protectionContent
                anchors { left: parent.left; right: parent.right; top: parent.top; margins: root.style.cardPadding }
                spacing: 2
                MikoToggleRow { style: root.style; title: I18n.tr("Защита слуха"); subtitle: I18n.tr("Останавливает резкий скачок громкости"); icon: "hearing"; checked: Config.options.audio.protection.enable; onToggled: checked => Config.options.audio.protection.enable = checked }
                MikoStepperRow { style: root.style; title: I18n.tr("Максимальная громкость"); icon: "vertical_align_top"; value: Config.options.audio.protection.maxAllowed; minimum: 20; maximum: 120; step: 5; suffix: "%"; onChanged: value => Config.options.audio.protection.maxAllowed = value }
                MikoStepperRow { style: root.style; title: I18n.tr("Допустимый скачок"); icon: "arrow_warm_up"; value: Config.options.audio.protection.maxAllowedIncrease; minimum: 2; maximum: 50; step: 2; suffix: "%"; onChanged: value => Config.options.audio.protection.maxAllowedIncrease = value }
            }
        }
    }

    MikoSurface {
        Layout.fillWidth: true
        implicitHeight: 92
        style: root.style

        RowLayout {
            anchors { fill: parent; margins: root.style.cardPadding }
            spacing: 12
            MikoIconDisc { style: root.style; icon: "spatial_audio" }
            ColumnLayout {
                Layout.preferredWidth: 180
                spacing: 0
                StyledText { text: I18n.tr("Стереобаланс"); color: root.style.ink; font.pixelSize: Appearance.font.pixelSize.small; font.weight: Font.DemiBold }
                StyledText {
                    text: Math.abs(root.controller.balance) < 0.02 ? I18n.tr("По центру")
                        : root.controller.balance < 0
                            ? I18n.tr("Левее на ") + Math.round(Math.abs(root.controller.balance) * 100) + "%"
                            : I18n.tr("Правее на ") + Math.round(root.controller.balance * 100) + "%"
                    color: root.style.mutedInk
                    font.pixelSize: Appearance.font.pixelSize.smaller
                }
            }
            StyledText { text: I18n.tr("Л"); color: root.style.mutedInk; font.pixelSize: Appearance.font.pixelSize.smaller }
            StyledSlider {
                Layout.fillWidth: true
                from: -1
                to: 1
                value: root.controller.balance
                configuration: StyledSlider.Configuration.S
                onMoved: root.controller.applyBalance(value)
            }
            StyledText { text: I18n.tr("П"); color: root.style.mutedInk; font.pixelSize: Appearance.font.pixelSize.smaller }
            MikoButton {
                style: root.style
                icon: "center_focus_strong"
                text: I18n.tr("Центр")
                enabled: Math.abs(root.controller.balance) >= 0.02
                onClicked: root.controller.applyBalance(0)
            }
        }
    }
}
