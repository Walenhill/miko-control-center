import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    required property var style

    Layout.fillWidth: true
    spacing: 14

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: rows.implicitHeight + 20
        radius: 24
        color: root.style.sectionSurface
        antialiasing: true

        ColumnLayout {
            id: rows
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 10 }
            spacing: 0

            MikoStepperRow {
                style: root.style
                title: "Время показа уведомления"
                subtitle: "После этого уведомление уходит в историю"
                icon: "timer"
                value: Config.options.notifications.timeout / 1000
                minimum: 2
                maximum: 20
                step: 1
                suffix: " сек."
                onChanged: value =>
                    Config.options.notifications.timeout = value * 1000
            }
            MikoToggleRow {
                style: root.style
                title: "Отдельный монитор"
                subtitle: "Всегда показывать уведомления на выбранном экране"
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
                            text: "Имя монитора"
                            color: root.style.ink
                            font.pixelSize: Appearance.font.pixelSize.small
                            font.weight: Font.Medium
                        }
                        TextField {
                            Layout.fillWidth: true
                            enabled: Config.options.notifications.monitor.enable
                            text: Config.options.notifications.monitor.name
                            placeholderText: "Например DP-1"
                            color: root.style.ink
                            placeholderTextColor: root.style.mutedInk
                            background: Rectangle {
                                radius: 13
                                color: root.style.controlSurface
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
