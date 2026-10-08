import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    required property var audio
    required property var controller
    required property var style

    Layout.fillWidth: true
    spacing: root.style.gapControl

    MikoSectionHeader {
        style: root.style
        title: I18n.tr("Приложения")
        subtitle: root.audio.outputAppNodes.length > 0
            ? root.audio.outputAppNodes.length + I18n.tr(" активно")
            : I18n.tr("Нет активного звука")
    }

    Repeater {
        model: root.controller.groupedApps()

        delegate: MikoSurface {
            id: mixerRow
            required property var modelData
            readonly property var nodes: modelData.nodes
            readonly property real groupVolume: nodes.length > 0
                ? nodes.reduce((sum, node) => sum + node.audio.volume, 0) / nodes.length
                : 0
            readonly property bool groupMuted: nodes.length > 0
                && nodes.every(node => node.audio.muted)

            style: root.style
            Layout.fillWidth: true
            implicitHeight: 86

            PwObjectTracker { objects: mixerRow.nodes }

            RowLayout {
                anchors { fill: parent; leftMargin: 14; rightMargin: 16 }
                spacing: 12

                MikoIconDisc {
                    style: root.style
                    icon: mixerRow.groupMuted ? "volume_off" : "graphic_eq"
                    accented: !mixerRow.groupMuted && mixerRow.groupVolume > 0
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    RowLayout {
                        Layout.fillWidth: true

                        StyledText {
                            Layout.fillWidth: true
                            text: mixerRow.modelData.name
                            color: root.style.ink
                            font.pixelSize: Appearance.font.pixelSize.small
                            font.weight: Font.Medium
                            elide: Text.ElideRight
                        }

                        StyledText {
                            visible: mixerRow.nodes.length > 1
                            text: mixerRow.nodes.length + I18n.tr(" потока")
                            color: root.style.mutedInk
                            font.pixelSize: Appearance.font.pixelSize.smaller
                        }
                    }

                    StyledSlider {
                        Layout.fillWidth: true
                        value: mixerRow.groupVolume
                        configuration: StyledSlider.Configuration.XS
                        onMoved: mixerRow.nodes.forEach(node => node.audio.volume = value)
                    }
                }

                StyledText {
                    text: Math.round(mixerRow.groupVolume * 100) + "%"
                    color: root.style.ink
                    font.pixelSize: Appearance.font.pixelSize.small
                    font.weight: Font.DemiBold
                }

                MikoButton {
                    style: root.style
                    icon: mixerRow.groupMuted ? "volume_up" : "volume_off"
                    text: ""
                    implicitWidth: 42
                    onClicked: {
                        const muted = !mixerRow.groupMuted;
                        mixerRow.nodes.forEach(node => node.audio.muted = muted);
                    }
                }
            }
        }
    }

    MikoSurface {
        visible: root.audio.outputAppNodes.length === 0
        style: root.style
        Layout.fillWidth: true
        implicitHeight: 82

        RowLayout {
            anchors.centerIn: parent
            spacing: 8
            MaterialSymbol { text: "music_off"; iconSize: 21; color: root.style.mutedInk }
            StyledText { text: I18n.tr("Запусти музыку — приложение появится здесь"); color: root.style.mutedInk; font.pixelSize: Appearance.font.pixelSize.smaller }
        }
    }
}
