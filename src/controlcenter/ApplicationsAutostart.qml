import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    required property var style
    required property var entries

    Layout.fillWidth: true
    spacing: 10

    RowLayout {
        Layout.fillWidth: true

        StyledText {
            Layout.fillWidth: true
            text: "Автозапуск"
            color: root.style.ink
            font.pixelSize: Appearance.font.pixelSize.larger
            font.weight: Font.DemiBold
        }
        StyledText {
            text: root.entries.length + " записей"
            color: root.style.mutedInk
            font.pixelSize: Appearance.font.pixelSize.smaller
        }
    }

    GridLayout {
        Layout.fillWidth: true
        columns: width > 760 ? 2 : 1
        columnSpacing: 10
        rowSpacing: 10

        Repeater {
            model: root.entries.slice(0, 8)

            delegate: MikoSurface {
                id: autostartCard

                required property var modelData

                style: root.style
                Layout.fillWidth: true
                implicitHeight: 72

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    spacing: 12

                    MaterialSymbol {
                        text: "start"
                        iconSize: 20
                        color: root.style.mutedInk
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.minimumWidth: 0
                        spacing: 0

                        StyledText {
                            Layout.fillWidth: true
                            text: autostartCard.modelData.name
                            color: root.style.ink
                            font.pixelSize: Appearance.font.pixelSize.small
                            font.weight: Font.Medium
                            elide: Text.ElideRight
                        }
                        StyledText {
                            Layout.fillWidth: true
                            text: autostartCard.modelData.execLine
                            color: root.style.mutedInk
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            elide: Text.ElideRight
                        }
                    }
                    Rectangle {
                        implicitWidth: 8
                        implicitHeight: 8
                        radius: 4
                        color: root.style.selectedSurface
                    }
                }
            }
        }
    }

    MikoSurface {
        visible: root.entries.length === 0
        style: root.style
        Layout.fillWidth: true
        implicitHeight: 72

        RowLayout {
            anchors.centerIn: parent
            spacing: 9

            MaterialSymbol {
                text: "start"
                iconSize: 20
                color: root.style.mutedInk
            }
            StyledText {
                text: "Активных записей автозапуска не найдено"
                color: root.style.mutedInk
                font.pixelSize: Appearance.font.pixelSize.small
            }
        }
    }
}
