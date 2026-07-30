import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    required property var controller
    required property var style

    Layout.fillWidth: true
    spacing: 2

    StyledText {
        Layout.fillWidth: true
        text: root.controller.editorMeta().title
        color: root.style.ink
        font.pixelSize: 24
        font.weight: Font.DemiBold
        elide: Text.ElideRight
    }
    StyledText {
        Layout.fillWidth: true
        text: root.controller.editorMeta().subtitle
        color: root.style.mutedInk
        font.pixelSize: Appearance.font.pixelSize.smaller
        elide: Text.ElideRight
    }
}
