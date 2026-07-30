import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

Rectangle {
    id: root

    required property var audio
    required property var style
    property bool input: false

    readonly property var devices: input ? audio.inputDevices : audio.outputDevices
    readonly property var activeDevice: input ? audio.source : audio.sink

    Layout.fillWidth: true
    implicitHeight: content.implicitHeight + 30
    radius: root.style.radiusSection
    color: root.style.sectionSurface
    border.width: 1
    border.color: root.style.hairline
    antialiasing: true

    ColumnLayout {
        id: content
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 15 }
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            MikoIconDisc {
                style: root.style
                icon: root.input ? "mic" : "speaker"
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0
                StyledText {
                    text: root.input ? "Откуда записывать" : "Куда воспроизводить"
                    color: root.style.ink
                    font.pixelSize: Appearance.font.pixelSize.small
                    font.weight: Font.DemiBold
                }
                StyledText {
                    text: root.devices.length + (root.input ? " входов" : " выходов")
                    color: root.style.mutedInk
                    font.pixelSize: Appearance.font.pixelSize.smaller
                }
            }
        }

        Repeater {
            model: root.devices

            delegate: Rectangle {
                id: deviceRow
                required property var modelData
                readonly property bool selected: root.activeDevice?.id === modelData.id

                Layout.fillWidth: true
                implicitHeight: 52
                radius: 17
                color: selected
                    ? root.style.selectedSurface
                    : (pointer.containsMouse ? root.style.hoverSurface : "transparent")
                antialiasing: true

                Behavior on color {
                    ColorAnimation { duration: root.style.motionFast }
                }

                RowLayout {
                    anchors {
                        fill: parent
                        leftMargin: 12
                        rightMargin: 12
                    }
                    spacing: 9
                    MaterialSymbol {
                        text: deviceRow.selected
                            ? "check_circle" : (root.input ? "mic" : "speaker")
                        iconSize: 19
                        color: deviceRow.selected
                            ? root.style.selectedInk : root.style.ink
                    }
                    StyledText {
                        Layout.fillWidth: true
                        text: root.audio.friendlyDeviceName(deviceRow.modelData)
                        color: deviceRow.selected
                            ? root.style.selectedInk : root.style.ink
                        font.pixelSize: Appearance.font.pixelSize.small
                        font.weight: deviceRow.selected ? Font.DemiBold : Font.Normal
                        elide: Text.ElideRight
                    }
                }
                MouseArea {
                    id: pointer
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.input)
                            root.audio.setDefaultSource(deviceRow.modelData);
                        else
                            root.audio.setDefaultSink(deviceRow.modelData);
                    }
                }
            }
        }
    }
}
