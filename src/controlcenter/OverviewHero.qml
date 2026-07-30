import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

MikoSurface {
    id: root

    required property string userName
    required property string connectionSummary
    required property string powerProfile
    required property real cpuUsage
    required property real memoryUsage
    required property int activeIssueCount
    required property int updateCount

    Layout.fillWidth: true
    implicitHeight: 162
    accented: true

    RowLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 18

        ColumnLayout {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            spacing: 5

            Rectangle {
                implicitWidth: healthText.implicitWidth + 24
                implicitHeight: 30
                radius: 15
                color: root.style.controlSurface

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 6

                    Rectangle {
                        width: 7
                        height: 7
                        radius: 4
                        color: root.activeIssueCount > 0
                            ? Appearance.colors.colError
                            : root.updateCount > 0
                                ? root.style.selectedSurface : root.style.ink
                    }
                    StyledText {
                        id: healthText
                        text: root.activeIssueCount > 0
                            ? "СИСТЕМЕ НУЖНО ВНИМАНИЕ"
                            : root.updateCount > 0
                                ? "ЕСТЬ ЧТО ПОСМОТРЕТЬ" : "СИСТЕМА В ПОРЯДКЕ"
                        color: root.style.mutedInk
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        font.weight: Font.DemiBold
                    }
                }
            }
            StyledText {
                Layout.fillWidth: true
                text: "Доброй ночи, " + root.userName
                color: root.style.ink
                font.pixelSize: 27
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }
            StyledText {
                Layout.fillWidth: true
                text: root.connectionSummary
                color: root.style.mutedInk
                font.pixelSize: Appearance.font.pixelSize.small
                elide: Text.ElideRight
            }
        }

        Rectangle {
            Layout.preferredWidth: 230
            Layout.fillHeight: true
            radius: root.style.radiusSection
            color: root.style.controlSurface
            antialiasing: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 4

                StyledText {
                    text: "СЕЙЧАС"
                    color: root.style.mutedInk
                    font.pixelSize: Appearance.font.pixelSize.smaller
                }
                StyledText {
                    text: root.powerProfile === "performance"
                        ? "Максимальная мощность"
                        : root.powerProfile === "power-saver"
                            ? "Экономия энергии" : "Сбалансированный режим"
                    color: root.style.ink
                    font.pixelSize: Appearance.font.pixelSize.small
                    font.weight: Font.DemiBold
                }
                Item { Layout.fillHeight: true }
                RowLayout {
                    Layout.fillWidth: true

                    MaterialSymbol {
                        text: "memory"
                        iconSize: 18
                        color: root.style.mutedInk
                    }
                    StyledText {
                        text: "CPU " + Math.round(root.cpuUsage * 100) + "%"
                        color: root.style.mutedInk
                        font.pixelSize: Appearance.font.pixelSize.smaller
                    }
                    Item { Layout.fillWidth: true }
                    StyledText {
                        text: "RAM " + Math.round(root.memoryUsage * 100) + "%"
                        color: root.style.mutedInk
                        font.pixelSize: Appearance.font.pixelSize.smaller
                    }
                }
            }
        }
    }
}
