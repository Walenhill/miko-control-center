import QtQuick
import qs.modules.common

Rectangle {
    id: root

    required property var style
    property bool interactive: false
    property bool accented: false
    property bool outlined: true
    readonly property bool hovered:
        interactive && pointer.containsMouse
    readonly property bool pressed:
        interactive && pointer.pressed
    signal clicked()

    radius: style.radiusSection
    color: accented
        ? style.accentContainer
        : pressed
            ? style.activeSurface
            : hovered
                ? style.hoverSurface
                : style.sectionSurface
    border.width: activeFocus ? 2 : outlined ? 1 : 0
    border.color: accented
        ? style.alpha(style.selectedSurface, 0.38)
        : activeFocus
            ? style.focusRing
            : hovered
                ? style.strongHairline
                : style.hairline
    antialiasing: true
    activeFocusOnTab: interactive

    Behavior on color {
        ColorAnimation {
            duration: style.motionFast
            easing.type: Easing.BezierSpline
            easing.bezierCurve: style.motionCurve
        }
    }
    Behavior on border.color {
        ColorAnimation {
            duration: style.motionFast
            easing.type: Easing.BezierSpline
            easing.bezierCurve: style.motionCurve
        }
    }

    MouseArea {
        id: pointer
        anchors.fill: parent
        enabled: root.interactive
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onPressed: root.forceActiveFocus()
        onClicked: root.clicked()
    }

    Keys.onPressed: event => {
        if (!root.interactive)
            return;
        if (event.key === Qt.Key_Return
                || event.key === Qt.Key_Enter
                || event.key === Qt.Key_Space) {
            root.clicked();
            event.accepted = true;
        }
    }
}
