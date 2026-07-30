import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

GridLayout {
    id: root

    required property var audio
    required property var style
    property real microphonePeak: 0

    Layout.fillWidth: true
    columns: width > 820 ? 2 : 1
    columnSpacing: 12
    rowSpacing: 12

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 164
        radius: root.style.radiusSection
        color: Qt.rgba(
            Appearance.colors.colPrimary.r,
            Appearance.colors.colPrimary.g,
            Appearance.colors.colPrimary.b,
            0.16
        )
        border.width: 1
        border.color: root.style.hairline
        antialiasing: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 9
            RowLayout {
                Layout.fillWidth: true
                MikoIconDisc {
                    style: root.style
                    icon: root.audio.sink?.audio.muted ? "volume_off" : "headphones"
                    accented: true
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0
                    StyledText {
                        text: "Выход"
                        color: root.style.ink
                        font.pixelSize: Appearance.font.pixelSize.small
                        font.weight: Font.DemiBold
                    }
                    StyledText {
                        Layout.fillWidth: true
                        text: root.audio.sink
                            ? root.audio.friendlyDeviceName(root.audio.sink)
                            : "Загрузка устройства…"
                        color: root.style.mutedInk
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        elide: Text.ElideRight
                    }
                }
                StyledText {
                    text: Math.round(root.audio.value * 100) + "%"
                    color: root.style.ink
                    font.pixelSize: Appearance.font.pixelSize.larger
                    font.weight: Font.DemiBold
                }
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                MikoButton {
                    style: root.style
                    icon: root.audio.sink?.audio.muted ? "volume_up" : "volume_off"
                    text: root.audio.sink?.audio.muted ? "Включить" : "Без звука"
                    onClicked: if (root.audio.sink) root.audio.toggleMute()
                }
                StyledSlider {
                    Layout.fillWidth: true
                    enabled: root.audio.sink !== null
                    value: root.audio.value
                    configuration: StyledSlider.Configuration.S
                    onMoved: if (root.audio.sink) root.audio.sink.audio.volume = value
                }
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 184
        radius: root.style.radiusSection
        color: root.style.sectionSurface
        border.width: 1
        border.color: root.style.hairline
        antialiasing: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 9
            RowLayout {
                Layout.fillWidth: true
                MikoIconDisc {
                    style: root.style
                    icon: root.audio.source?.audio.muted ? "mic_off" : "mic"
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0
                    StyledText { text: "Микрофон"; color: root.style.ink; font.pixelSize: Appearance.font.pixelSize.small; font.weight: Font.DemiBold }
                    StyledText {
                        Layout.fillWidth: true
                        text: root.audio.source
                            ? root.audio.friendlyDeviceName(root.audio.source)
                            : "Загрузка устройства…"
                        color: root.style.mutedInk
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        elide: Text.ElideRight
                    }
                }
                StyledText {
                    text: Math.round((root.audio.source?.audio.volume ?? 0) * 100) + "%"
                    color: root.style.ink
                    font.pixelSize: Appearance.font.pixelSize.larger
                    font.weight: Font.DemiBold
                }
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                MikoButton {
                    style: root.style
                    icon: root.audio.source?.audio.muted ? "mic" : "mic_off"
                    text: root.audio.source?.audio.muted ? "Включить" : "Отключить"
                    onClicked: if (root.audio.source) root.audio.toggleMicMute()
                }
                StyledSlider {
                    Layout.fillWidth: true
                    enabled: root.audio.source !== null
                    value: root.audio.source?.audio.volume ?? 0
                    configuration: StyledSlider.Configuration.S
                    onMoved: if (root.audio.source) root.audio.source.audio.volume = value
                }
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: 9
                StyledText { text: "Голос"; color: root.style.mutedInk; font.pixelSize: Appearance.font.pixelSize.smaller }
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 7
                    radius: 4
                    color: root.style.controlSurface
                    antialiasing: true
                    Rectangle {
                        width: parent.width * Math.max(0, Math.min(
                            1, root.microphonePeak * 2.4
                        ))
                        height: parent.height
                        radius: parent.radius
                        color: root.style.selectedSurface
                        antialiasing: true
                        Behavior on width {
                            NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
                        }
                    }
                }
                StyledText {
                    text: root.microphonePeak > 0.72
                        ? "громко" : root.microphonePeak > 0.08 ? "сигнал" : "тишина"
                    color: root.style.mutedInk
                    font.pixelSize: Appearance.font.pixelSize.smaller
                }
            }
        }
    }
}
