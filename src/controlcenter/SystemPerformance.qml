import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    required property var controller
    required property var style

    spacing: 12

    component LabelText: StyledText {
        color: root.style.ink
        font.pixelSize: Appearance.font.pixelSize.small
    }

    component MutedText: StyledText {
        color: root.style.mutedInk
        font.pixelSize: Appearance.font.pixelSize.smaller
    }

    component IconDisc: MikoIconDisc {
        style: root.style
    }

    component ProgressStrip: Rectangle {
        id: progressStrip

        property real value: 0
        property color fillColor: Appearance.colors.colPrimary

        implicitHeight: 7
        radius: 4
        color: root.style.controlSurface
        antialiasing: true

        Rectangle {
            width: parent.width * Math.max(
                0, Math.min(1, progressStrip.value)
            )
            height: parent.height
            radius: parent.radius
            color: progressStrip.fillColor
            antialiasing: true

            Behavior on width {
                NumberAnimation {
                    duration: root.style.motionNormal
                    easing.type: Easing.OutCubic
                }
            }
        }
    }

    LabelText {
        text: "Производительность"
        font.pixelSize: Appearance.font.pixelSize.larger
        font.weight: Font.DemiBold
        Layout.topMargin: 4
    }

    GridLayout {
        Layout.fillWidth: true
        columns: width > 820 ? 2 : 1
        columnSpacing: 12
        rowSpacing: 12

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 164
            radius: root.style.radiusSection
            color: root.style.hoverSurface
            border.width: 1
            border.color: Qt.rgba(
                root.style.ink.r,
                root.style.ink.g,
                root.style.ink.b,
                0.055
            )
            antialiasing: true

            ColumnLayout {
                anchors {
                    fill: parent
                    margins: 17
                }
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true

                    IconDisc {
                        icon: "memory"
                        accented: true
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        LabelText {
                            text: "Процессор"
                            font.weight: Font.DemiBold
                        }

                        MutedText {
                            text: "Текущая общая загрузка"
                        }
                    }

                    LabelText {
                        text: Math.round(
                            root.controller.cpuUsage * 100
                        ) + "%"
                        font.pixelSize: Appearance.font.pixelSize.larger
                        font.weight: Font.DemiBold
                    }
                }

                ProgressStrip {
                    Layout.fillWidth: true
                    value: root.controller.cpuUsage
                }

                MutedText {
                    text: "Доступная частота до "
                        + root.controller.maxAvailableCpuString
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 164
            radius: root.style.radiusSection
            color: root.style.hoverSurface
            border.width: 1
            border.color: Qt.rgba(
                root.style.ink.r,
                root.style.ink.g,
                root.style.ink.b,
                0.055
            )
            antialiasing: true

            ColumnLayout {
                anchors {
                    fill: parent
                    margins: 17
                }
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true

                    IconDisc {
                        icon: "memory_alt"
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        LabelText {
                            text: "Память"
                            font.weight: Font.DemiBold
                        }

                        MutedText {
                            text: root.controller.maxAvailableMemoryString
                                + " установлено"
                        }
                    }

                    LabelText {
                        text: Math.round(
                            root.controller.memoryUsedPercentage * 100
                        ) + "%"
                        font.pixelSize: Appearance.font.pixelSize.larger
                        font.weight: Font.DemiBold
                    }
                }

                ProgressStrip {
                    Layout.fillWidth: true
                    value: root.controller.memoryUsedPercentage
                }

                MutedText {
                    text: "Swap: " + Math.round(
                        root.controller.swapUsedPercentage * 100
                    ) + "%"
                }
            }
        }
    }
}
