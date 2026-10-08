import QtQuick
import qs.modules.common

Rectangle {
    id: root

    property var style: null
    readonly property var ui: style ? style : DefaultStyle

    property bool interactive: false
    property bool accented: false
    property bool softAccent: false
    property bool outlined: true
    readonly property bool hovered:
        interactive && pointer.containsMouse
    readonly property bool pressed:
        interactive && pointer.pressed
    signal clicked()

    radius: ui.radiusSection
    color: accented
        ? ui.accentContainer
        : softAccent
            ? ui.accentSubtle
            : pressed
                ? ui.activeSurface
                : hovered
                    ? ui.hoverSurface
                    : ui.sectionSurface
    border.width: activeFocus ? 2 : outlined ? 1 : 0
    border.color: accented
        ? ui.alpha(ui.selectedSurface, 0.38)
        : softAccent
            ? ui.accentSubtleBorder
            : activeFocus
                ? ui.focusRing
                : hovered
                    ? ui.strongHairline
                    : ui.hairline
    antialiasing: true
    activeFocusOnTab: interactive

    readonly property Item primaryChild: {
        for (let i = 0; i < children.length; ++i) {
            let ch = children[i];
            if (ch && ch !== pointer && ch.visible !== false) return ch;
        }
        return null;
    }

    implicitHeight: {
        if (!primaryChild) return 0;
        let tm = primaryChild.anchors ? (primaryChild.anchors.topMargin || 0) : 0;
        let bm = primaryChild.anchors ? (primaryChild.anchors.bottomMargin || 0) : 0;
        return (primaryChild.implicitHeight || 0) + tm + bm;
    }

    implicitWidth: {
        if (!primaryChild) return 0;
        let lm = primaryChild.anchors ? (primaryChild.anchors.leftMargin || 0) : 0;
        let rm = primaryChild.anchors ? (primaryChild.anchors.rightMargin || 0) : 0;
        return (primaryChild.implicitWidth || 0) + lm + rm;
    }

    Behavior on color {
        ColorAnimation {
            duration: root.ui.motionFast
            easing.type: Easing.BezierSpline
            easing.bezierCurve: root.ui.motionCurve
        }
    }
    Behavior on border.color {
        ColorAnimation {
            duration: root.ui.motionFast
            easing.type: Easing.BezierSpline
            easing.bezierCurve: root.ui.motionCurve
        }
    }

    MouseArea {
        id: pointer
        anchors.fill: parent
        enabled: root.interactive
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
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
