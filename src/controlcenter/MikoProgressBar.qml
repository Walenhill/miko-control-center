import QtQuick
import qs.modules.common

Rectangle {
    id: root

    property var style: null
    readonly property var ui: style ? style : DefaultStyle

    property real value: 0
    property string tone: "accent" // "accent" | "warning" | "error" | "neutral"
    property color fillColor: tone === "warning"
        ? Appearance.colors.colError
        : (tone === "error" ? Appearance.colors.colError : root.ui.selectedSurface)
    property color trackColor: root.ui.controlSurface
    property int barHeight: 7
    property int barRadius: 4
    property bool animated: true

    implicitHeight: barHeight
    radius: barRadius
    color: trackColor
    antialiasing: true
    clip: true

    Rectangle {
        id: fill
        width: Math.round(parent.width * Math.max(0, Math.min(1, root.value)))
        height: parent.height
        radius: parent.radius
        color: root.fillColor
        antialiasing: true

        Behavior on width {
            enabled: root.animated
            NumberAnimation {
                duration: root.ui.motionNormal
                easing.type: Easing.OutCubic
            }
        }
        Behavior on color {
            ColorAnimation {
                duration: root.ui.motionFast
            }
        }
    }
}
