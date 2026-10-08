import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    required property var style
    required property string title
    required property var choices
    required property string value

    signal selected(string value)

    Layout.fillWidth: true
    spacing: 8

    StyledText {
        text: root.title
        color: root.style.ink
        font.pixelSize: Appearance.font.pixelSize.normal
    }

    Flow {
        Layout.fillWidth: true
        spacing: 6

        Repeater {
            model: root.choices

            delegate: MikoButton {
                required property var modelData

                style: root.style
                text: modelData.title
                selected: root.value === modelData.value
                onClicked: root.selected(modelData.value)
            }

        }

    }

}
