import QtQuick
import QtQuick.Controls
import qs.modules.common

TextField {
    required property var style

    color: style.ink
    placeholderTextColor: style.mutedInk
    selectByMouse: true
    padding: 12
    font.family: Appearance.font.family.main
    font.pixelSize: Appearance.font.pixelSize.normal

    background: Rectangle {
        radius: parent.style.radiusControl
        color: parent.style.controlSurface
        border.width: parent.activeFocus ? 2 : 1
        border.color: parent.activeFocus ? parent.style.focusRing : parent.style.hairline
    }

}
