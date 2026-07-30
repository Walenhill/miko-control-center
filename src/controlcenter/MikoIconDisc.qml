import QtQuick
import qs.modules.common
import qs.modules.common.widgets

Rectangle {
    id: root

    required property var style
    required property string icon
    property bool accented: false

    implicitWidth: 44
    implicitHeight: 44
    radius: Appearance.rounding.full
    color: accented ? style.selectedSurface : style.controlSurface
    border.width: 1
    border.color: accented
        ? style.alpha(style.selectedSurface, 0.42)
        : style.hairline
    antialiasing: true

    Behavior on color {
        ColorAnimation {
            duration: style.motionFast
            easing.type: Easing.OutCubic
        }
    }
    Behavior on border.color {
        ColorAnimation {
            duration: style.motionFast
            easing.type: Easing.BezierSpline
            easing.bezierCurve: style.motionCurve
        }
    }

    MaterialSymbol {
        anchors.centerIn: parent
        text: root.icon
        iconSize: 22
        fill: root.accented ? 1 : 0
        color: root.accented ? root.style.selectedInk : root.style.ink
    }
}
