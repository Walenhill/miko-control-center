import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    required property var audio
    required property var style

    Layout.fillWidth: true
    spacing: 12

    RowLayout {
        Layout.fillWidth: true
        Layout.topMargin: 4
        StyledText {
            Layout.fillWidth: true
            text: "Устройства"
            color: root.style.ink
            font.pixelSize: Appearance.font.pixelSize.larger
            font.weight: Font.DemiBold
        }
        StyledText {
            text: "Системные вход и выход"
            color: root.style.mutedInk
            font.pixelSize: Appearance.font.pixelSize.smaller
        }
    }

    GridLayout {
        Layout.fillWidth: true
        columns: width > 820 ? 2 : 1
        columnSpacing: 12
        rowSpacing: 12
        SoundDeviceCard { audio: root.audio; style: root.style }
        SoundDeviceCard { audio: root.audio; style: root.style; input: true }
    }
}
