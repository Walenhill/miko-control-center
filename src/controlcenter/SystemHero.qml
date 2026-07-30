import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

Rectangle {
    id: root

    required property var controller
    required property var style

    implicitHeight: 190
    radius: root.style.radiusWindow
    color: Qt.rgba(
        Appearance.colors.colPrimary.r,
        Appearance.colors.colPrimary.g,
        Appearance.colors.colPrimary.b,
        0.15
    )
    border.width: 1
    border.color: Qt.rgba(
        root.style.ink.r,
        root.style.ink.g,
        root.style.ink.b,
        0.06
    )
    antialiasing: true

    component LabelText: StyledText {
        color: root.style.ink
        font.pixelSize: Appearance.font.pixelSize.small
    }

    component MutedText: StyledText {
        color: root.style.mutedInk
        font.pixelSize: Appearance.font.pixelSize.smaller
    }

    RowLayout {
        anchors {
            fill: parent
            margins: 21
        }
        spacing: 24

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 5

            Rectangle {
                implicitWidth: machineState.implicitWidth + 20
                implicitHeight: 29
                radius: 14
                color: root.style.sectionSurface

                RowLayout {
                    id: machineState

                    anchors.centerIn: parent
                    spacing: 6

                    Rectangle {
                        width: 7
                        height: 7
                        radius: 4
                        color: root.controller.watchActiveCount > 0
                            ? Appearance.colors.colError
                            : Appearance.colors.colPrimary
                    }

                    LabelText {
                        text: root.controller.watchActiveCount > 0
                            ? "СИСТЕМЕ НУЖНО ВНИМАНИЕ"
                            : "СИСТЕМА В ПОРЯДКЕ"
                        font.pixelSize: Appearance.font.pixelSize.smallest
                        font.weight: Font.Bold
                    }
                }
            }

            LabelText {
                text: root.controller.distroName
                font.pixelSize: 28
                font.weight: Font.DemiBold
            }

            MutedText {
                text: root.controller.desktopEnvironment
                    + " · " + root.controller.windowingSystem
                font.pixelSize: Appearance.font.pixelSize.small
            }

            Item {
                Layout.fillHeight: true
            }

            MutedText {
                text: root.controller.distroName + " · "
                    + root.controller.kernelVersion
            }
        }

        GridLayout {
            columns: 2
            columnSpacing: 11
            rowSpacing: 11

            Repeater {
                model: [
                    {
                        label: "CPU",
                        value: Math.round(
                            root.controller.cpuUsage * 100
                        ) + "%",
                        icon: "memory"
                    },
                    {
                        label: "RAM",
                        value: Math.round(
                            root.controller.memoryUsedPercentage * 100
                        ) + "%",
                        icon: "memory_alt"
                    },
                    {
                        label: "Профиль",
                        value: root.controller.powerProfile === "performance"
                            ? "Макс." : root.controller.powerProfile,
                        icon: "speed"
                    },
                    {
                        label: "Обновления",
                        value: root.controller.availableUpdateCount > 0
                            ? String(root.controller.availableUpdateCount)
                            : "ОК",
                        icon: "system_update"
                    }
                ]

                delegate: Rectangle {
                    required property var modelData

                    implicitWidth: 128
                    implicitHeight: 62
                    radius: 19
                    color: root.style.sectionSurface

                    RowLayout {
                        anchors {
                            fill: parent
                            margins: 11
                        }

                        MaterialSymbol {
                            text: modelData.icon
                            iconSize: 20
                            color: root.style.mutedInk
                        }

                        ColumnLayout {
                            spacing: 0

                            LabelText {
                                text: modelData.value
                                font.weight: Font.DemiBold
                            }

                            MutedText {
                                text: modelData.label
                            }
                        }
                    }
                }
            }
        }
    }
}
