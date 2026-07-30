import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

MikoSurface {
    id: root

    required property real timeoutSeconds

    signal timeoutChangeRequested(real seconds)

    Layout.fillWidth: true
    implicitHeight: 112

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 7

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            MikoIconDisc {
                style: root.style
                icon: "notifications_active"
            }
            ColumnLayout {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                spacing: 0

                StyledText {
                    text: "Поведение уведомлений"
                    color: root.style.ink
                    font.pixelSize: Appearance.font.pixelSize.small
                    font.weight: Font.Medium
                }
                StyledText {
                    text: "Время показа всплывающей карточки"
                    color: root.style.mutedInk
                    font.pixelSize: Appearance.font.pixelSize.smaller
                }
            }
            StyledText {
                text: Math.round(root.timeoutSeconds) + " сек."
                color: root.style.ink
                font.pixelSize: Appearance.font.pixelSize.small
                font.weight: Font.DemiBold
            }
        }

        StyledSlider {
            Layout.fillWidth: true
            from: 2
            to: 20
            stepSize: 1
            value: root.timeoutSeconds
            usePercentTooltip: false
            tooltipContent: Math.round(value) + " сек."
            configuration: StyledSlider.Configuration.XS
            onMoved: root.timeoutChangeRequested(Math.round(value))
        }
    }
}
