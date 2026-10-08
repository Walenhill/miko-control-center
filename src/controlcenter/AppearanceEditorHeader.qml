import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

RowLayout {
    id: root

    required property var controller
    required property var style

    Layout.fillWidth: true
    spacing: 12

    MikoButton {
        style: root.style
        icon: "arrow_back"
        text: I18n.tr("Назад")
        onClicked: root.controller.closeEditor()
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 2

        StyledText {
            Layout.fillWidth: true
            text: root.controller.editorMeta().title
            color: root.style.ink
            font.pixelSize: Appearance.font.pixelSize.larger
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
}
