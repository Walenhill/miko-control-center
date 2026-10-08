import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    property var style: null
    readonly property var ui: style ? style : DefaultStyle

    required property real timeoutSeconds
    property bool notificationsSilent: false

    signal timeoutChangeRequested(real seconds)
    signal toggleSilentRequested()

    Layout.fillWidth: true
    spacing: 14

    MikoSectionHeader {
        style: root.ui
        title: I18n.tr("Уведомления")
        subtitle: I18n.tr("Режим фокусировки и параметры экранных баннеров")
    }

    MikoListGroup {
        style: root.ui

        MikoToggleRow {
            style: root.ui
            title: I18n.tr("Режим «Не беспокоить»")
            subtitle: root.notificationsSilent
                ? I18n.tr("Всплывающие окна заглушены")
                : I18n.tr("Показывать всплывающие баннеры в обычном режиме")
            icon: root.notificationsSilent ? "notifications_off" : "notifications_active"
            checked: root.notificationsSilent
            onToggled: () => root.toggleSilentRequested()
        }
    }

    MikoSurface {
        style: root.ui
        Layout.fillWidth: true
        implicitHeight: durationColumn.implicitHeight + 32

        ColumnLayout {
            id: durationColumn
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 16
            }
            spacing: 14

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                MikoIconDisc {
                    style: root.ui
                    icon: "timer"
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    spacing: 1

                    StyledText {
                        text: I18n.tr("Длительность показа")
                        color: root.ui.ink
                        font.pixelSize: Appearance.font.pixelSize.small
                        font.weight: Font.Medium
                    }
                    StyledText {
                        text: I18n.tr("Время отображения уведомления на экране до исчезновения")
                        color: root.ui.mutedInk
                        font.pixelSize: Appearance.font.pixelSize.smaller
                    }
                }

                MikoBadge {
                    style: root.ui
                    text: Math.round(root.timeoutSeconds) + I18n.tr(" сек.")
                    icon: "schedule"
                    tone: "accent"
                }
            }

            StyledSlider {
                Layout.fillWidth: true
                from: 2
                to: 20
                stepSize: 1
                value: root.timeoutSeconds
                usePercentTooltip: false
                tooltipContent: Math.round(value) + I18n.tr(" сек.")
                configuration: StyledSlider.Configuration.XS
                onMoved: root.timeoutChangeRequested(Math.round(value))
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                StyledText {
                    text: I18n.tr("Быстрый выбор:")
                    color: root.ui.mutedInk
                    font.pixelSize: Appearance.font.pixelSize.smaller
                }

                Repeater {
                    model: [3, 5, 8, 12, 15]

                    delegate: MikoButton {
                        required property int modelData
                        style: root.ui
                        text: modelData + I18n.tr(" сек.")
                        selected: Math.round(root.timeoutSeconds) === modelData
                        onClicked: root.timeoutChangeRequested(modelData)
                    }
                }

                Item { Layout.fillWidth: true }
            }
        }
    }
}
