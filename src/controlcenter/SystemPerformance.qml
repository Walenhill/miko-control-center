import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    property var style: null
    readonly property var ui: style ? style : DefaultStyle

    required property var controller

    spacing: 12

    MikoSectionHeader {
        style: root.ui
        title: I18n.tr("Нагрузка оборудования")
        subtitle: I18n.tr("Мониторинг вычислительных ресурсов процессора и оперативной памяти")
    }

    GridLayout {
        Layout.fillWidth: true
        columns: width > 820 ? 2 : 1
        columnSpacing: 12
        rowSpacing: 12

        // CPU Card
        MikoSurface {
            Layout.fillWidth: true
            style: root.ui

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    MikoIconDisc {
                        style: root.ui
                        icon: "memory"
                        accented: true
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        StyledText {
                            text: I18n.tr("Процессор (CPU)")
                            color: root.ui.ink
                            font.weight: Font.DemiBold
                            font.pixelSize: Appearance.font.pixelSize.normal
                        }

                        StyledText {
                            text: I18n.tr("Общая загрузка ядер")
                            color: root.ui.mutedInk
                            font.pixelSize: Appearance.font.pixelSize.smaller
                        }
                    }

                    MikoBadge {
                        style: root.ui
                        text: Math.round(root.controller.cpuUsage * 100) + "%"
                        tone: root.controller.cpuUsage > 0.85 ? "warning" : "accent"
                    }
                }

                MikoProgressBar {
                    Layout.fillWidth: true
                    style: root.ui
                    value: Math.max(0, Math.min(1, root.controller.cpuUsage))
                    tone: root.controller.cpuUsage > 0.85 ? "warning" : "accent"
                }

                StyledText {
                    text: I18n.tr("Максимальная частота: ") + root.controller.maxAvailableCpuString
                    color: root.ui.mutedInk
                    font.pixelSize: Appearance.font.pixelSize.smaller
                }
            }
        }

        // Memory Card
        MikoSurface {
            Layout.fillWidth: true
            style: root.ui

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    MikoIconDisc {
                        style: root.ui
                        icon: "memory_alt"
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        StyledText {
                            text: I18n.tr("Оперативная память (RAM)")
                            color: root.ui.ink
                            font.weight: Font.DemiBold
                            font.pixelSize: Appearance.font.pixelSize.normal
                        }

                        StyledText {
                            text: root.controller.maxAvailableMemoryString + I18n.tr(" установлено")
                            color: root.ui.mutedInk
                            font.pixelSize: Appearance.font.pixelSize.smaller
                        }
                    }

                    MikoBadge {
                        style: root.ui
                        text: Math.round(root.controller.memoryUsedPercentage * 100) + "%"
                        tone: root.controller.memoryUsedPercentage > 0.90 ? "warning" : "accent"
                    }
                }

                MikoProgressBar {
                    Layout.fillWidth: true
                    style: root.ui
                    value: Math.max(0, Math.min(1, root.controller.memoryUsedPercentage))
                    tone: root.controller.memoryUsedPercentage > 0.90 ? "warning" : "accent"
                }

                StyledText {
                    text: "Swap: " + Math.round(root.controller.swapUsedPercentage * 100) + "%"
                    color: root.ui.mutedInk
                    font.pixelSize: Appearance.font.pixelSize.smaller
                }
            }
        }
    }
}
