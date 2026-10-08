import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

Rectangle {
    id: root

    required property var style
    property alias text: label.text
    property alias icon: symbol.text
    property bool selected: false
    property bool quiet: false
    readonly property bool hasIcon: symbol.text !== ""
    readonly property bool hasText: label.text !== ""
    readonly property bool iconOnly: hasIcon && !hasText
    readonly property bool pressed: pointer.pressed
    readonly property bool hovered: pointer.containsMouse
    signal clicked()

    implicitHeight: style.controlHeight
    implicitWidth: iconOnly ? implicitHeight : content.implicitWidth + 28
    radius: iconOnly ? Math.min(width, height) / 2 : style.radiusControl
    activeFocusOnTab: enabled
    Accessible.role: Accessible.Button
    Accessible.name: hasText ? label.text : symbol.text
    Accessible.onPressAction: if (enabled) root.clicked()
    opacity: enabled ? 1 : 0.42
    color: selected
        ? pressed
            ? style.selectedSurfaceActive
            : hovered
                ? style.selectedSurfaceHover
                : style.selectedSurface
        : pressed
            ? style.activeSurface
            : hovered
                ? style.hoverSurface
                : quiet ? "transparent" : style.sectionSurface
    border.width: activeFocus ? 2 : quiet || selected ? 0 : 1
    border.color: activeFocus
        ? style.focusRing
        : selected
            ? style.alpha(style.selectedSurface, 0.42)
            : hovered
                ? style.strongHairline
                : style.hairline
    antialiasing: true

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
    Behavior on opacity {
        NumberAnimation {
            duration: style.motionFast
            easing.type: Easing.BezierSpline
            easing.bezierCurve: style.motionCurve
        }
    }

    RowLayout {
        id: content
        anchors.centerIn: parent
        spacing: root.hasIcon && root.hasText ? 7 : 0
        transform: Translate {
            y: root.pressed ? 1 : 0
            Behavior on y {
                NumberAnimation {
                    duration: root.style.motionFast
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: root.style.motionCurve
                }
            }
        }

        MaterialSymbol {
            id: symbol
            visible: root.hasIcon
            iconSize: 18
            fill: root.selected ? 1 : 0
            color: root.selected ? root.style.selectedInk : root.style.ink
            Behavior on fill {
                NumberAnimation {
                    duration: root.style.motionNormal
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: root.style.motionCurve
                }
            }
        }
        StyledText {
            id: label
            visible: root.hasText
            color: root.selected ? root.style.selectedInk : root.style.ink
            font.pixelSize: Appearance.font.pixelSize.small
            font.weight: Font.Medium
        }
    }

    MouseArea {
        id: pointer
        anchors.fill: parent
        enabled: root.enabled
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    Keys.onPressed: event => {
        if (!root.enabled)
            return;
        if (event.key === Qt.Key_Return
                || event.key === Qt.Key_Enter
                || event.key === Qt.Key_Space) {
            root.clicked();
            event.accepted = true;
        }
    }
}
