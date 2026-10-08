import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

Rectangle {
    id: root

    property var style: null
    readonly property var ui: style ? style : DefaultStyle

    required property var controller

    implicitHeight: 184
    radius: root.ui.radiusSection
    color: root.ui.sectionSurface
    border.width: 1
    border.color: root.ui.hairline
    antialiasing: true

    RowLayout {
        anchors {
            fill: parent
            margins: 20
        }
        spacing: 24

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8

            MikoBadge {
                style: root.ui
                icon: root.controller.watchActiveCount > 0 ? "warning" : "verified"
                text: root.controller.watchActiveCount > 0
                    ? I18n.tr("СИСТЕМЕ НУЖНО ВНИМАНИЕ")
                    : I18n.tr("СИСТЕМА В ПОРЯДКЕ")
                tone: root.controller.watchActiveCount > 0 ? "warning" : "accent"
            }

            StyledText {
                text: root.controller.distroName || "Arch Linux"
                color: root.ui.ink
                font.pixelSize: 26
                font.weight: Font.DemiBold
            }

            StyledText {
                text: (root.controller.desktopEnvironment || "Hyprland")
                    + " · " + (root.controller.windowingSystem || "Wayland")
                color: root.ui.mutedInk
                font.pixelSize: Appearance.font.pixelSize.smaller
            }

            Item { Layout.fillHeight: true }

            StyledText {
                text: root.controller.distroName + " · " + (root.controller.kernelVersion || "")
                color: root.ui.mutedInk
                font.pixelSize: Appearance.font.pixelSize.smaller
            }
        }

        GridLayout {
            columns: 2
            columnSpacing: 10
            rowSpacing: 10

            Repeater {
                model: [
                    {
                        label: "CPU",
                        value: Math.round(root.controller.cpuUsage * 100) + "%",
                        icon: "memory"
                    },
                    {
                        label: "RAM",
                        value: Math.round(root.controller.memoryUsedPercentage * 100) + "%",
                        icon: "memory_alt"
                    },
                    {
                        label: I18n.tr("Профиль"),
                        value: root.controller.powerProfile === "performance"
                            ? I18n.tr("Макс.") : root.controller.powerProfile,
                        icon: "speed"
                    },
                    {
                        label: I18n.tr("Обновления"),
                        value: root.controller.availableUpdateCount > 0
                            ? String(root.controller.availableUpdateCount)
                            : I18n.tr("ОК"),
                        icon: "system_update"
                    }
                ]

                delegate: Rectangle {
                    required property var modelData

                    implicitWidth: 124
                    implicitHeight: 60
                    radius: root.ui.radiusControl
                    color: root.ui.controlSurface
                    border.width: 1
                    border.color: root.ui.hairline
                    antialiasing: true

                    RowLayout {
                        anchors {
                            fill: parent
                            margins: 10
                        }
                        spacing: 10

                        MaterialSymbol {
                            text: modelData.icon
                            iconSize: 20
                            color: Appearance.colors.colPrimary
                        }

                        ColumnLayout {
                            spacing: 1

                            StyledText {
                                text: modelData.value
                                color: root.ui.ink
                                font.weight: Font.DemiBold
                                font.pixelSize: Appearance.font.pixelSize.normal
                            }

                            StyledText {
                                text: modelData.label
                                color: root.ui.mutedInk
                                font.pixelSize: Appearance.font.pixelSize.smaller
                            }
                        }
                    }
                }
            }
        }
    }
}
