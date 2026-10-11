import QtQuick
import QtQuick.Controls

Switch {
    id: root
    property var style: DefaultStyle
    implicitWidth: 44
    implicitHeight: 36
    padding: 0
    activeFocusOnTab: true
    opacity: enabled ? 1 : 0.42

    contentItem: Item {}
    indicator: Rectangle {
        x: (root.width - width) / 2
        y: (root.height - height) / 2
        width: 38
        height: 24
        radius: 12
        color: root.checked ? root.style.selectedSurface : root.style.controlSurface
        border.width: root.activeFocus ? 2 : root.checked ? 0 : 1
        border.color: root.activeFocus ? root.style.focusRing : root.style.strongHairline
        antialiasing: true
        Behavior on color { ColorAnimation { duration: root.style.motionFast } }
        Rectangle {
            x: root.checked ? parent.width - width - 4 : 4
            anchors.verticalCenter: parent.verticalCenter
            width: 16
            height: 16
            radius: 8
            color: root.checked ? root.style.selectedInk : root.style.mutedInk
            antialiasing: true
            Behavior on x {
                NumberAnimation { duration: root.style.motionFast; easing.type: Easing.OutCubic }
            }
        }
    }
}
