import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    property var style: null
    readonly property var ui: style ? style : DefaultStyle

    required property var audio
    required property var bluetooth
    required property var bluetoothStatus
    required property var openSound
    required property var openBluetoothManager

    Layout.fillWidth: true
    spacing: 16

    // Bluetooth status header
    MikoSectionHeader {
        style: root.ui
        title: I18n.tr("Беспроводные подключения")
        subtitle: I18n.tr("Управление адаптером Bluetooth и сопряжёнными устройствами")
        badgeText: (root.bluetoothStatus && root.bluetoothStatus.enabled) ? I18n.tr("Включён") : I18n.tr("Выключен")
        actionText: I18n.tr("Менеджер")
        actionIcon: "tune"
        onActionClicked: root.openBluetoothManager()
    }

    // Bluetooth Quick Toggle Card
    MikoSurface {
        Layout.fillWidth: true
        style: root.ui

        RowLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 14

            MikoIconDisc {
                style: root.ui
                icon: (root.bluetoothStatus && root.bluetoothStatus.enabled) ? "bluetooth" : "bluetooth_disabled"
                accented: Boolean(root.bluetoothStatus && root.bluetoothStatus.enabled)
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                StyledText {
                    text: I18n.tr("Адаптер Bluetooth")
                    color: root.ui.ink
                    font.weight: Font.DemiBold
                    font.pixelSize: Appearance.font.pixelSize.normal
                }

                StyledText {
                    text: (root.bluetoothStatus && root.bluetoothStatus.enabled)
                        ? I18n.tr("Готов к подключению и обнаружению устройств")
                        : I18n.tr("Радиомодуль выключен для экономии энергии")
                    color: root.ui.mutedInk
                    font.pixelSize: Appearance.font.pixelSize.smaller
                }
            }

            MikoButton {
                style: root.ui
                visible: Boolean(root.bluetoothStatus && root.bluetoothStatus.available)
                icon: (root.bluetoothStatus && root.bluetoothStatus.enabled) ? "toggle_on" : "toggle_off"
                text: (root.bluetoothStatus && root.bluetoothStatus.enabled) ? I18n.tr("Включён") : I18n.tr("Выключен")
                selected: Boolean(root.bluetoothStatus && root.bluetoothStatus.enabled)
                onClicked: {
                    if (root.bluetooth && root.bluetooth.defaultAdapter)
                        root.bluetooth.defaultAdapter.enabled = !root.bluetooth.defaultAdapter.enabled;
                }
            }
        }
    }

    // Audio Output Section
    MikoSectionHeader {
        style: root.ui
        title: I18n.tr("Текущий аудиовыход")
        subtitle: I18n.tr("Основное устройство воспроизведения звука")
    }

    MikoSurface {
        Layout.fillWidth: true
        style: root.ui

        RowLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 14

            MikoIconDisc {
                style: root.ui
                icon: (root.audio && root.audio.sink && root.audio.sink.audio && root.audio.sink.audio.muted)
                    ? "volume_off" : "headphones"
                accented: Boolean(root.audio && root.audio.sink)
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                spacing: 2

                StyledText {
                    Layout.fillWidth: true
                    text: (root.audio && root.audio.sink)
                        ? root.audio.friendlyDeviceName(root.audio.sink)
                        : I18n.tr("Аудиовыход не выбран")
                    color: root.ui.ink
                    font.weight: Font.DemiBold
                    font.pixelSize: Appearance.font.pixelSize.normal
                    elide: Text.ElideRight
                }

                StyledText {
                    text: I18n.tr("Основной звук · ")
                        + Math.round((root.audio && root.audio.value !== undefined ? root.audio.value : 0) * 100) + "%"
                    color: root.ui.mutedInk
                    font.pixelSize: Appearance.font.pixelSize.smaller
                }
            }

            MikoBadge {
                style: root.ui
                text: Math.round((root.audio && root.audio.value !== undefined ? root.audio.value : 0) * 100) + "%"
                tone: "accent"
            }

            MikoButton {
                style: root.ui
                icon: "tune"
                text: I18n.tr("Звук")
                onClicked: root.openSound()
            }
        }
    }

    // Connected Bluetooth Devices Section
    MikoSectionHeader {
        style: root.ui
        title: I18n.tr("Подключённые устройства")
        badgeText: (root.bluetoothStatus && root.bluetoothStatus.connectedDevices)
            ? String(root.bluetoothStatus.connectedDevices.length) : "0"
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 8

        Repeater {
            model: (root.bluetoothStatus && root.bluetoothStatus.connectedDevices)
                ? root.bluetoothStatus.connectedDevices : []

            delegate: MikoSurface {
                id: connectedBluetooth
                required property var modelData
                Layout.fillWidth: true
                style: root.ui

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 12

                    MikoIconDisc {
                        style: root.ui
                        icon: "bluetooth_connected"
                        accented: true
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.minimumWidth: 0
                        spacing: 2

                        StyledText {
                            Layout.fillWidth: true
                            text: connectedBluetooth.modelData.name || I18n.tr("Безымянное устройство")
                            color: root.ui.ink
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                        }

                        StyledText {
                            text: I18n.tr("Bluetooth · активное сопряжение")
                            color: root.ui.mutedInk
                            font.pixelSize: Appearance.font.pixelSize.smaller
                        }
                    }

                    MikoBadge {
                        style: root.ui
                        icon: "check_circle"
                        text: I18n.tr("Подключено")
                        tone: "accent"
                    }

                    MikoButton {
                        style: root.ui
                        icon: "link_off"
                        text: I18n.tr("Отключить")
                        onClicked: connectedBluetooth.modelData.disconnect()
                    }
                }
            }
        }

        // Empty state when no Bluetooth devices are connected
        MikoSurface {
            visible: !root.bluetoothStatus || !root.bluetoothStatus.connectedDevices || root.bluetoothStatus.connectedDevices.length === 0
            Layout.fillWidth: true
            style: root.ui

            RowLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                MikoIconDisc {
                    style: root.ui
                    icon: "devices_other"
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    StyledText {
                        text: I18n.tr("Нет подключённых Bluetooth устройств")
                        color: root.ui.ink
                        font.weight: Font.Medium
                    }

                    StyledText {
                        text: I18n.tr("Включите сопряжение на наушниках или геймпаде")
                        color: root.ui.mutedInk
                        font.pixelSize: Appearance.font.pixelSize.smaller
                    }
                }
            }
        }
    }
}
