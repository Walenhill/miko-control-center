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

    readonly property string greeting: {
        const hour = new Date().getHours();
        if (hour >= 5 && hour < 12) return I18n.tr("Доброе утро");
        if (hour >= 12 && hour < 18) return I18n.tr("Добрый день");
        if (hour >= 18 && hour < 23) return I18n.tr("Добрый вечер");
        return I18n.tr("Доброй ночи");
    }

    GridLayout {
        anchors {
            fill: parent
            margins: 20
        }
        columns: width >= 720 ? 2 : 1
        columnSpacing: 20
        rowSpacing: 16

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: 0
            spacing: 8

            MikoBadge {
                style: root.style
                icon: root.activeIssueCount > 0
                    ? "warning"
                    : root.updateCount > 0
                        ? "system_update" : "verified"
                text: root.activeIssueCount > 0
                    ? I18n.tr("СИСТЕМЕ НУЖНО ВНИМАНИЕ")
                    : root.updateCount > 0
                        ? I18n.tr("ДОСТУПНЫ ОБНОВЛЕНИЯ") : I18n.tr("СИСТЕМА В ПОРЯДКЕ")
                tone: root.activeIssueCount > 0
                    ? "warning"
                    : root.updateCount > 0
                        ? "accent" : "success"
            }

            StyledText {
                Layout.fillWidth: true
                text: root.greeting + (root.userName ? (", " + root.userName) : "")
                color: root.style.ink
                font.pixelSize: Appearance.font.pixelSize.huge
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }

            StyledText {
                Layout.fillWidth: true
                text: root.connectionSummary
                color: root.style.mutedInk
                font.pixelSize: Appearance.font.pixelSize.normal
                elide: Text.ElideRight
            }
        }

        MikoSurface {
            Layout.preferredWidth: width >= 720 ? 260 : -1
            Layout.fillWidth: width < 720
            Layout.fillHeight: true
            style: root.style
            interactive: false

            ColumnLayout {
                anchors {
                    fill: parent
                    margins: 14
                }
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    MaterialSymbol {
                        text: root.powerProfile === "performance" ? "rocket_launch"
                            : root.powerProfile === "power-saver" ? "eco" : "speed"
                        iconSize: 18
                        color: root.style.selectedInk
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        StyledText {
                            text: I18n.tr("Профиль питания")
                            color: root.style.mutedInk
                            font.pixelSize: Appearance.font.pixelSize.smaller
                        }

                        StyledText {
                            text: root.powerProfile === "performance"
                                ? I18n.tr("Производительность")
                                : root.powerProfile === "power-saver"
                                    ? I18n.tr("Экономия") : I18n.tr("Баланс")
                            color: root.style.ink
                            font.pixelSize: Appearance.font.pixelSize.small
                            font.weight: Font.DemiBold
                        }
                    }
                }

                Item { Layout.fillHeight: true }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true
                        StyledText {
                            text: "CPU"
                            color: root.style.mutedInk
                            font.pixelSize: Appearance.font.pixelSize.smaller
                        }
                        Item { Layout.fillWidth: true }
                        StyledText {
                            text: Math.round(root.cpuUsage * 100) + "%"
                            color: root.style.ink
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            font.weight: Font.Medium
                        }
                    }

                    MikoProgressBar {
                        Layout.fillWidth: true
                        style: root.style
                        value: root.cpuUsage
                        tone: root.cpuUsage > 0.88 ? "error" : (root.cpuUsage > 0.72 ? "warning" : "accent")
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true
                        StyledText {
                            text: "RAM"
                            color: root.style.mutedInk
                            font.pixelSize: Appearance.font.pixelSize.smaller
                        }
                        Item { Layout.fillWidth: true }
                        StyledText {
                            text: Math.round(root.memoryUsage * 100) + "%"
                            color: root.style.ink
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            font.weight: Font.Medium
                        }
                    }

                    MikoProgressBar {
                        Layout.fillWidth: true
                        style: root.style
                        value: root.memoryUsage
                        tone: root.memoryUsage > 0.88 ? "error" : (root.memoryUsage > 0.72 ? "warning" : "accent")
                    }
                }
            }
        }
    }
}
