import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

Rectangle {
    id: root

    required property var style
    required property string title
    property string subtitle: ""
    property string icon: "tune"
    property bool active: false
    property bool available: true
    signal clicked()

    Layout.fillWidth: true
    implicitHeight: 68
    radius: style.radiusControl
    opacity: available ? 1 : 0.42
    activeFocusOnTab: available
    color: active
        ? style.accentContainer
        : pointer.pressed
            ? style.activeSurface
            : pointer.containsMouse ? style.hoverSurface : style.sectionSurface
    border.width: activeFocus ? 2 : 1
    border.color: activeFocus
        ? style.focusRing
        : active
        ? Qt.rgba(style.selectedSurface.r, style.selectedSurface.g,
            style.selectedSurface.b, 0.32)
        : style.hairline
    antialiasing: true

    Behavior on color {
        ColorAnimation {
            duration: root.style.motionFast
            easing.type: Easing.BezierSpline
            easing.bezierCurve: root.style.motionCurve
        }
    }
    Behavior on border.color {
        ColorAnimation {
            duration: root.style.motionFast
            easing.type: Easing.BezierSpline
            easing.bezierCurve: root.style.motionCurve
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 13
        anchors.rightMargin: 13
        spacing: 10

        MikoIconDisc {
            style: root.style
            icon: root.icon
            accented: root.active
        }
        ColumnLayout {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            spacing: 0

            StyledText {
                Layout.fillWidth: true
                text: root.title
                color: root.style.ink
                font.pixelSize: Appearance.font.pixelSize.small
                font.weight: Font.Medium
                elide: Text.ElideRight
            }
            StyledText {
                visible: root.subtitle !== ""
                Layout.fillWidth: true
                text: root.subtitle
                color: root.style.mutedInk
                font.pixelSize: Appearance.font.pixelSize.smaller
                elide: Text.ElideRight
            }
        }
    }

    MouseArea {
        id: pointer
        anchors.fill: parent
        enabled: root.available
        hoverEnabled: true
        cursorShape: root.available ? Qt.PointingHandCursor : Qt.ArrowCursor
        onPressed: root.forceActiveFocus()
        onClicked: root.clicked()
    }

    Keys.onPressed: event => {
        if (!root.available)
            return;
        if (event.key === Qt.Key_Return
                || event.key === Qt.Key_Enter
                || event.key === Qt.Key_Space) {
            root.clicked();
            event.accepted = true;
        }
    }
}
