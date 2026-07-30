import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    required property var audio
    required property var bluetooth
    required property var bluetoothStatus
    required property var style
    required property var openSound
    required property var openBluetoothManager

    Layout.fillWidth: true
    spacing: 10

    RowLayout {
        Layout.fillWidth: true
        Layout.topMargin: 6
        StyledText {
            Layout.fillWidth: true
            text: "Сейчас подключено"
            color: root.style.ink
            font.pixelSize: Appearance.font.pixelSize.larger
            font.weight: Font.DemiBold
        }
        MikoButton {
            style: root.style
            visible: root.bluetoothStatus.available
            icon: root.bluetoothStatus.enabled ? "bluetooth" : "bluetooth_disabled"
            text: root.bluetoothStatus.enabled ? "Bluetooth включён" : "Bluetooth выключен"
            onClicked: if (root.bluetooth.defaultAdapter)
                root.bluetooth.defaultAdapter.enabled = !root.bluetooth.defaultAdapter.enabled
        }
        MikoButton {
            style: root.style
            icon: "tune"
            text: "Управление"
            onClicked: root.openBluetoothManager()
        }
    }

    GridLayout {
        Layout.fillWidth: true
        columns: width > 700 ? 2 : 1
        columnSpacing: 10
        rowSpacing: 10

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 92
            radius: 23
            color: root.style.sectionSurface
            border.width: 1
            border.color: root.style.hairline
            antialiasing: true
            RowLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 12
                MikoIconDisc {
                    style: root.style
                    icon: root.audio.sink?.audio.muted ? "volume_off" : "headphones"
                    accented: root.audio.sink !== null
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    spacing: 1
                    StyledText {
                        Layout.fillWidth: true
                        text: root.audio.sink ? root.audio.friendlyDeviceName(root.audio.sink) : "Аудиовыход не выбран"
                        color: root.style.ink
                        font.weight: Font.Medium
                        elide: Text.ElideRight
                    }
                    StyledText {
                        text: "Основной звук · " + Math.round(root.audio.value * 100) + "%"
                        color: root.style.mutedInk
                        font.pixelSize: Appearance.font.pixelSize.smaller
                    }
                }
                MikoButton {
                    style: root.style
                    icon: "tune"
                    text: "Звук"
                    onClicked: root.openSound()
                }
            }
        }

        Repeater {
            model: root.bluetoothStatus.connectedDevices
            delegate: Rectangle {
                id: connectedBluetooth
                required property var modelData
                Layout.fillWidth: true
                implicitHeight: 92
                radius: 23
                color: root.style.sectionSurface
                border.width: 1
                border.color: root.style.hairline
                antialiasing: true
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 12
                    MikoIconDisc { style: root.style; icon: "bluetooth_connected"; accented: true }
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.minimumWidth: 0
                        spacing: 1
                        StyledText {
                            Layout.fillWidth: true
                            text: connectedBluetooth.modelData.name
                            color: root.style.ink
                            font.weight: Font.Medium
                            elide: Text.ElideRight
                        }
                        StyledText { text: "Bluetooth · подключено"; color: root.style.mutedInk; font.pixelSize: Appearance.font.pixelSize.smaller }
                    }
                    MikoButton {
                        style: root.style
                        icon: "link_off"
                        text: "Отключить"
                        onClicked: connectedBluetooth.modelData.disconnect()
                    }
                }
            }
        }
    }
}
