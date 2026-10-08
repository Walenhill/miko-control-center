import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

MikoSurface {
    id: root

    required property var style
    required property string title
    required property string value
    property string icon: "monitoring"
    property real progress: -1

    Layout.fillWidth: true
    implicitHeight: 88
    interactive: false

    ColumnLayout {
        anchors {
            fill: parent
            margins: 14
        }
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            MikoIconDisc {
                style: root.style
                icon: root.icon
                accented: root.progress >= 0.75
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                StyledText {
                    Layout.fillWidth: true
                    text: root.title
                    color: root.style.mutedInk
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.fillWidth: true
                    text: root.value
                    color: root.style.ink
                    font.pixelSize: Appearance.font.pixelSize.large
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }
            }
        }

        MikoProgressBar {
            visible: root.progress >= 0
            Layout.fillWidth: true
            style: root.style
            value: root.progress
            tone: root.progress > 0.88 ? "error" : (root.progress > 0.72 ? "warning" : "accent")
        }
    }
}
