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
    required property bool showDevices
    required property bool showAttention

    signal navigateRequested(string pageId)

    Layout.fillWidth: true
    columns: width >= 840 ? 2 : 1
    columnSpacing: 12
    rowSpacing: 12

    MikoSurface {
        visible: root.showDevices
        style: root.style
        Layout.fillWidth: true
        Layout.columnSpan: root.columns === 2
            && (!root.attentionVisible || !root.showAttention) ? 2 : 1

        ColumnLayout {
            anchors {
                fill: parent
                margins: 16
            }
            spacing: 12

            RowLayout {
                Layout.fillWidth: true

                MikoSectionHeader {
                    Layout.fillWidth: true
                    style: root.style
                    title: I18n.tr("Устройства")
                    subtitle: I18n.tr("Подключённые телефон и аудиовыход")
                }

                MikoButton {
                    style: root.style
                    icon: "arrow_forward"
                    text: I18n.tr("Все устройства")
                    onClicked: root.navigateRequested("devices")
                }
            }

            GridLayout {
                Layout.fillWidth: true
                columns: width >= 500 ? 2 : 1
                columnSpacing: 10
                rowSpacing: 10

                // Phone quick info
                MikoSurface {
                    Layout.fillWidth: true
                    style: root.style
                    interactive: true
                    softAccent: root.phoneReachable
                    onClicked: root.navigateRequested("devices")

                    RowLayout {
                        anchors {
                            fill: parent
                            margins: 12
                        }
                        spacing: 10

                        MikoIconDisc {
                            style: root.style
                            icon: "smartphone"
                            accented: root.phoneReachable
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.minimumWidth: 0
                            spacing: 1

                            StyledText {
                                Layout.fillWidth: true
                                text: root.phoneName || I18n.tr("Телефон")
                                color: root.style.ink
                                font.pixelSize: Appearance.font.pixelSize.normal
                                font.weight: Font.Medium
                                elide: Text.ElideRight
                            }

                            StyledText {
                                Layout.fillWidth: true
                                text: root.phoneReachable
                                    ? I18n.tr("На связи") + (root.phoneBattery >= 0 ? " · " + root.phoneBattery + "%" : "")
                                    : I18n.tr("Не подключён")
                                color: root.style.mutedInk
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                elide: Text.ElideRight
                            }
                        }
                    }
                }

                // Audio output quick info
                MikoSurface {
                    Layout.fillWidth: true
                    style: root.style
                    interactive: true
                    softAccent: root.audioAvailable && !root.audioMuted
                    onClicked: root.navigateRequested("sound")

                    RowLayout {
                        anchors {
                            fill: parent
                            margins: 12
                        }
                        spacing: 10

                        MikoIconDisc {
                            style: root.style
                            icon: root.audioMuted ? "volume_off" : "headphones"
                            accented: root.audioAvailable && !root.audioMuted
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.minimumWidth: 0
                            spacing: 1

                            StyledText {
                                Layout.fillWidth: true
                                text: root.audioAvailable ? root.audioName : I18n.tr("Аудиовыход")
                                color: root.style.ink
                                font.pixelSize: Appearance.font.pixelSize.normal
                                font.weight: Font.Medium
                                elide: Text.ElideRight
                            }

                            StyledText {
                                Layout.fillWidth: true
                                text: root.audioAvailable
                                    ? (root.audioMuted ? I18n.tr("Звук выключен") : Math.round(root.audioVolume * 100) + "%")
                                    : I18n.tr("Не найдено")
                                color: root.style.mutedInk
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
            }
        }
    }

    MikoSurface {
        visible: root.attentionVisible && root.showAttention
        style: root.style
        softAccent: true
        Layout.fillWidth: true

        ColumnLayout {
            anchors {
                fill: parent
                margins: 16
            }
            spacing: 12

            MikoSectionHeader {
                style: root.style
                title: I18n.tr("Требует внимания")
                subtitle: I18n.tr("Системные предупреждения и события")
                badgeText: I18n.tr("Внимание")
            }

            MikoSurface {
                Layout.fillWidth: true
                style: root.style
                interactive: true
                onClicked: root.navigateRequested(root.attentionPage)

                RowLayout {
                    anchors {
                        fill: parent
                        margins: 12
                    }
                    spacing: 12

                    MikoIconDisc {
                        style: root.style
                        icon: root.attentionIcon
                        accented: true
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.minimumWidth: 0
                        spacing: 1

                        StyledText {
                            Layout.fillWidth: true
                            text: root.attentionTitle
                            color: root.style.ink
                            font.pixelSize: Appearance.font.pixelSize.normal
                            font.weight: Font.DemiBold
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
                        text: I18n.tr("Подробнее")
                        onClicked: root.navigateRequested(root.attentionPage)
                    }
                }
            }
        }
    }
}
