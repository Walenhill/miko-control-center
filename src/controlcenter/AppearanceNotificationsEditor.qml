import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    required property var style

    Layout.fillWidth: true
    spacing: 16

    MikoSurface {
        Layout.fillWidth: true
        style: root.style

        ColumnLayout {
            anchors {
                fill: parent
                margins: 16
            }
            spacing: 14

            MikoSectionHeader {
                style: root.style
                title: I18n.tr("Уведомления")
                subtitle: I18n.tr("Время показа всплывающих окон и выбор экрана для вывода")
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                MikoStepperRow {
                    style: root.style
                    title: I18n.tr("Время показа уведомления")
                    subtitle: I18n.tr("После этого уведомление уходит в историю")
                    icon: "timer"
                    value: Config.options.notifications.timeout / 1000
                    minimum: 2
                    maximum: 20
                    step: 1
                    suffix: I18n.tr(" сек.")
                    onChanged: value =>
                        Config.options.notifications.timeout = value * 1000
                }
                MikoToggleRow {
                    style: root.style
                    title: I18n.tr("Отдельный монитор")
                    subtitle: I18n.tr("Всегда показывать уведомления на выбранном экране")
                    icon: "monitor"
                    checked: Config.options.notifications.monitor.enable
                    onToggled: checked =>
                        Config.options.notifications.monitor.enable = checked
                }
                Item {
                    Layout.fillWidth: true
                    implicitHeight: 64
                    opacity: Config.options.notifications.monitor.enable ? 1 : 0.42

                    Behavior on opacity {
                        NumberAnimation { duration: root.style.motionFast }
                    }

                    RowLayout {
                        anchors.fill: parent
                        spacing: 12
                        MaterialSymbol {
                            text: "desktop_windows"
                            iconSize: 20
                            color: root.style.mutedInk
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            StyledText {
                                text: I18n.tr("Имя монитора")
                                color: root.style.ink
                                font.pixelSize: Appearance.font.pixelSize.normal
                                font.weight: Font.Medium
                            }
                            TextField {
                                Layout.fillWidth: true
                                enabled: Config.options.notifications.monitor.enable
                                text: Config.options.notifications.monitor.name
                                placeholderText: I18n.tr("Например DP-1")
                                color: root.style.ink
                                placeholderTextColor: root.style.mutedInk
                                font.pixelSize: Appearance.font.pixelSize.normal
                                padding: 8
                                background: Rectangle {
                                    radius: root.style.radiusControl
                                    color: root.style.controlSurface
                                    border.width: 1
                                    border.color: root.style.hairline
                                }
                                onEditingFinished:
                                    Config.options.notifications.monitor.name = text.trim()
                            }
                        }
                    }
                }
            }
        }
    }
}
