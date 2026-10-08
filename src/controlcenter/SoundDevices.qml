import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    required property var audio
    required property var style

    Layout.fillWidth: true
    spacing: root.style.gapControl

    MikoSectionHeader {
        style: root.style
        title: I18n.tr("Устройства")
        subtitle: I18n.tr("Системные вход и выход")
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
