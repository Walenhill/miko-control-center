import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

GridLayout {
    id: root

    required property var style
    required property bool phoneReachable
    required property string phoneName
    required property int phoneBattery
    required property bool audioAvailable
    required property bool audioMuted
    required property string audioName
    required property real audioVolume
    required property bool attentionVisible
    required property string attentionIcon
    required property string attentionTitle
    required property string attentionSubtitle
    required property string attentionPage

    signal navigateRequested(string pageId)

    Layout.fillWidth: true
    columns: width >= 840 ? 2 : 1
    columnSpacing: 11
    rowSpacing: 11

    MikoSurface {
        style: root.style
        Layout.fillWidth: true
        Layout.columnSpan: root.columns === 2 && !root.attentionVisible ? 2 : 1
        implicitHeight: 132

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 9

            RowLayout {
                Layout.fillWidth: true

                StyledText {
                    Layout.fillWidth: true
                    text: "Устройства"
                    color: root.style.ink
                    font.pixelSize: Appearance.font.pixelSize.larger
                    font.weight: Font.DemiBold
                }
                MikoButton {
                    style: root.style
                    icon: "arrow_forward"
                    text: "Все"
                    onClicked: root.navigateRequested("devices")
                }
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                MikoIconDisc {
                    style: root.style
                    icon: "smartphone"
                    accented: root.phoneReachable
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    spacing: 0

                    StyledText {
                        Layout.fillWidth: true
                        text: root.phoneName || "Телефон"
                        color: root.style.ink
                        font.pixelSize: Appearance.font.pixelSize.small
                        font.weight: Font.Medium
                        elide: Text.ElideRight
                    }
                    StyledText {
                        Layout.fillWidth: true
                        text: root.phoneReachable
                            ? "На связи" + (root.phoneBattery >= 0
                                ? " · " + root.phoneBattery + "%" : "")
                            : "Сейчас не найден"
                        color: root.style.mutedInk
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        elide: Text.ElideRight
                    }
                }
                MikoIconDisc {
                    style: root.style
                    icon: root.audioMuted ? "volume_off" : "headphones"
                    accented: root.audioAvailable
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    spacing: 0

                    StyledText {
                        Layout.fillWidth: true
                        text: root.audioAvailable ? root.audioName : "Аудиовыход"
                        color: root.style.ink
                        font.pixelSize: Appearance.font.pixelSize.small
                        font.weight: Font.Medium
                        elide: Text.ElideRight
                    }
                    StyledText {
                        text: root.audioAvailable
                            ? Math.round(root.audioVolume * 100) + "%" : "Загружается"
                        color: root.style.mutedInk
                        font.pixelSize: Appearance.font.pixelSize.smaller
                    }
                }
            }
        }
    }

    MikoSurface {
        visible: root.attentionVisible
        style: root.style
        accented: true
        Layout.fillWidth: true
        implicitHeight: 132

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 8

            StyledText {
                text: "Требует внимания"
                color: root.style.ink
                font.pixelSize: Appearance.font.pixelSize.larger
                font.weight: Font.DemiBold
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                MaterialSymbol {
                    text: root.attentionIcon
                    iconSize: 21
                    color: root.style.selectedSurface
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    spacing: 0

                    StyledText {
                        Layout.fillWidth: true
                        text: root.attentionTitle
                        color: root.style.ink
                        font.pixelSize: Appearance.font.pixelSize.small
                        font.weight: Font.Medium
                        elide: Text.ElideRight
                    }
                    StyledText {
                        Layout.fillWidth: true
                        text: root.attentionSubtitle
                        color: root.style.mutedInk
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        elide: Text.ElideRight
                    }
                }
                MikoButton {
                    style: root.style
                    icon: "arrow_forward"
                    text: "Открыть"
                    onClicked: root.navigateRequested(root.attentionPage)
                }
            }
        }
    }
}
