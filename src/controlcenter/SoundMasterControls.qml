import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

GridLayout {
    id: root

    required property var audio
    required property var style
    property real microphonePeak: 0

    readonly property bool sinkMuted: root.audio.sink && root.audio.sink.audio
        ? root.audio.sink.audio.muted : false
    readonly property bool sourceMuted: root.audio.source && root.audio.source.audio
        ? root.audio.source.audio.muted : false
    readonly property real sourceVolume: root.audio.source && root.audio.source.audio
        ? root.audio.source.audio.volume : 0

    Layout.fillWidth: true
    columns: width > 820 ? 2 : 1
    columnSpacing: 12
    rowSpacing: 12

    MikoSurface {
        Layout.fillWidth: true
        Layout.fillHeight: true
        implicitHeight: 168
        style: root.style
        softAccent: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: root.style.cardPadding
            spacing: 9

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                MikoIconDisc {
                    style: root.style
                    icon: root.sinkMuted ? "volume_off" : "headphones"
                    accented: true
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    spacing: 0

                    StyledText {
                        text: I18n.tr("Выход")
                        color: root.style.ink
                        font.pixelSize: Appearance.font.pixelSize.small
                        font.weight: Font.DemiBold
                    }
                    StyledText {
                        Layout.fillWidth: true
                        text: root.audio.sink
                            ? root.audio.friendlyDeviceName(root.audio.sink)
                            : I18n.tr("Загрузка устройства…")
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

            Item { Layout.fillHeight: true }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                MikoButton {
                    style: root.style
                    icon: root.sinkMuted ? "volume_up" : "volume_off"
                    text: root.sinkMuted ? I18n.tr("Включить") : I18n.tr("Без звука")
                    onClicked: {
                        if (root.audio.sink)
                            root.audio.toggleMute();
                    }
                }
                StyledSlider {
                    Layout.fillWidth: true
                    enabled: root.audio.sink !== null
                    value: root.audio.value
                    configuration: StyledSlider.Configuration.S
                    onMoved: {
                        if (root.audio.sink)
                            root.audio.sink.audio.volume = value;
                    }
                }
            }
        }
    }

    MikoSurface {
        Layout.fillWidth: true
        Layout.fillHeight: true
        implicitHeight: 168
        style: root.style

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: root.style.cardPadding
            spacing: 9

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                MikoIconDisc {
                    style: root.style
                    icon: root.sourceMuted ? "mic_off" : "mic"
                    accented: false
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    spacing: 0

                    StyledText {
                        text: I18n.tr("Микрофон")
                        color: root.style.ink
                        font.pixelSize: Appearance.font.pixelSize.small
                        font.weight: Font.DemiBold
                    }
                    StyledText {
                        Layout.fillWidth: true
                        text: root.audio.source
                            ? root.audio.friendlyDeviceName(root.audio.source)
                            : I18n.tr("Загрузка устройства…")
                        color: root.style.mutedInk
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        elide: Text.ElideRight
                    }
                }
                StyledText {
                    text: Math.round(root.sourceVolume * 100) + "%"
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
                    icon: root.sourceMuted ? "mic" : "mic_off"
                    text: root.sourceMuted ? I18n.tr("Включить") : I18n.tr("Отключить")
                    onClicked: {
                        if (root.audio.source)
                            root.audio.toggleMicMute();
                    }
                }
                StyledSlider {
                    Layout.fillWidth: true
                    enabled: root.audio.source !== null
                    value: root.sourceVolume
                    configuration: StyledSlider.Configuration.S
                    onMoved: {
                        if (root.audio.source)
                            root.audio.source.audio.volume = value;
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 9

                StyledText {
                    text: I18n.tr("Голос")
                    color: root.style.mutedInk
                    font.pixelSize: Appearance.font.pixelSize.smaller
                }

                MikoProgressBar {
                    Layout.fillWidth: true
                    style: root.style
                    value: Math.min(1, root.microphonePeak * 2.4)
                }

                StyledText {
                    text: root.microphonePeak > 0.72
                        ? I18n.tr("громко") : root.microphonePeak > 0.08 ? I18n.tr("сигнал") : I18n.tr("тишина")
                    color: root.style.mutedInk
                    font.pixelSize: Appearance.font.pixelSize.smaller
                }
            }
        }
    }
}
