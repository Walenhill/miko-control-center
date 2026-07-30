import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

Rectangle {
    id: root

    required property var style
    required property string title
    required property string value
    property string icon: "monitoring"
    property real progress: -1

    Layout.fillWidth: true
    implicitHeight: 84
    radius: style.radiusControl
    color: style.sectionSurface
    border.width: 1
    border.color: style.hairline
    antialiasing: true

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 13
        spacing: 7

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            MaterialSymbol {
                text: root.icon
                iconSize: 18
                color: root.style.mutedInk
            }
            StyledText {
                Layout.fillWidth: true
                text: root.title
                color: root.style.ink
                font.pixelSize: Appearance.font.pixelSize.small
                font.weight: Font.Medium
                elide: Text.ElideRight
            }
            StyledText {
                text: root.value
                color: root.style.ink
                font.pixelSize: Appearance.font.pixelSize.small
                font.weight: Font.DemiBold
            }
        }

        Rectangle {
            visible: root.progress >= 0
            Layout.fillWidth: true
            implicitHeight: 7
            radius: 4
            color: root.style.controlSurface
            antialiasing: true

            Rectangle {
                width: parent.width * Math.max(0, Math.min(1, root.progress))
                height: parent.height
                radius: parent.radius
                color: root.style.selectedSurface
                antialiasing: true

                Behavior on width {
                    NumberAnimation {
                        duration: root.style.motionNormal
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: root.style.motionCurve
                    }
                }
            }
        }
    }
}
