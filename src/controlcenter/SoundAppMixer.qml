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
    spacing: 12

    RowLayout {
        Layout.fillWidth: true
        Layout.topMargin: 6
        StyledText {
            Layout.fillWidth: true
            text: "Приложения"
            color: root.style.ink
            font.pixelSize: Appearance.font.pixelSize.larger
            font.weight: Font.DemiBold
        }
        StyledText {
            text: root.audio.outputAppNodes.length > 0
                ? root.audio.outputAppNodes.length + " активно" : "Нет активного звука"
            color: root.style.mutedInk
            font.pixelSize: Appearance.font.pixelSize.smaller
        }
    }

    Repeater {
        model: root.controller.groupedApps()

        delegate: Rectangle {
            id: mixerRow
            required property var modelData
            readonly property var nodes: modelData.nodes
            readonly property real groupVolume: nodes.length > 0
                ? nodes.reduce((sum, node) => sum + node.audio.volume, 0) / nodes.length
                : 0
            readonly property bool groupMuted: nodes.length > 0
                && nodes.every(node => node.audio.muted)

            Layout.fillWidth: true
            implicitHeight: 86
            radius: 20
            color: root.style.sectionSurface
            border.width: 1
            border.color: root.style.hairline
            antialiasing: true

            PwObjectTracker { objects: mixerRow.nodes }

            RowLayout {
                anchors { fill: parent; leftMargin: 14; rightMargin: 16 }
                spacing: 12
                MikoIconDisc {
                    style: root.style
                    icon: mixerRow.groupMuted ? "volume_off" : "graphic_eq"
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
                            text: mixerRow.nodes.length + " потока"
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

    Rectangle {
        visible: root.audio.outputAppNodes.length === 0
        Layout.fillWidth: true
        implicitHeight: 82
        radius: 20
        color: root.style.sectionSurface
        antialiasing: true
        RowLayout {
            anchors.centerIn: parent
            MaterialSymbol { text: "music_off"; iconSize: 21; color: root.style.mutedInk }
            StyledText { text: "Запусти музыку — приложение появится здесь"; color: root.style.mutedInk; font.pixelSize: Appearance.font.pixelSize.smaller }
        }
    }
}
