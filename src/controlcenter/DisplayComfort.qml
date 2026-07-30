import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    required property var brightnessMonitor
    required property var hyprsunset
    required property var night
    required property var style

    Layout.fillWidth: true
    spacing: 12

    GridLayout {
        Layout.fillWidth: true
        columns: width > 820 ? 2 : 1
        columnSpacing: 12
        rowSpacing: 12

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 154
            radius: root.style.radiusSection
            color: root.style.sectionSurface
            border.width: 1
            border.color: root.style.hairline
            antialiasing: true
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 17
                spacing: 9
                RowLayout {
                    Layout.fillWidth: true
                    MikoIconDisc { style: root.style; icon: "brightness_6" }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        StyledText { text: "Яркость"; color: root.style.ink; font.weight: Font.DemiBold }
                        StyledText {
                            text: root.brightnessMonitor?.ready
                                ? (root.brightnessMonitor.isDdc ? "Управление через DDC" : "Системная подсветка")
                                : "Определение возможностей…"
                            color: root.style.mutedInk
                            font.pixelSize: Appearance.font.pixelSize.smaller
                        }
                    }
                    StyledText {
                        text: Math.round((root.brightnessMonitor?.brightness ?? 0) * 100) + "%"
                        color: root.style.ink
                        font.pixelSize: Appearance.font.pixelSize.larger
                        font.weight: Font.DemiBold
                    }
                }
                StyledSlider {
                    Layout.fillWidth: true
                    enabled: root.brightnessMonitor?.ready ?? false
                    value: root.brightnessMonitor?.brightness ?? 0
                    configuration: StyledSlider.Configuration.S
                    onMoved: if (root.brightnessMonitor) root.brightnessMonitor.setBrightness(value)
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 154
            radius: root.style.radiusSection
            color: Qt.rgba(Appearance.colors.colPrimary.r, Appearance.colors.colPrimary.g,
                           Appearance.colors.colPrimary.b,
                           root.hyprsunset.temperatureActive ? 0.16 : 0.07)
            border.width: 1
            border.color: root.style.hairline
            antialiasing: true
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 17
                spacing: 9
                RowLayout {
                    Layout.fillWidth: true
                    MikoIconDisc { style: root.style; icon: "bedtime"; accented: root.hyprsunset.temperatureActive }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        StyledText { text: "Ночной свет"; color: root.style.ink; font.weight: Font.DemiBold }
                        StyledText {
                            text: root.night.automatic
                                ? "Автоматически " + root.night.from + "–" + root.night.to
                                : "Ручное управление"
                            color: root.style.mutedInk
                            font.pixelSize: Appearance.font.pixelSize.smaller
                        }
                    }
                    MikoButton {
                        style: root.style
                        icon: root.hyprsunset.temperatureActive ? "toggle_on" : "toggle_off"
                        text: root.hyprsunset.temperatureActive ? "Включён" : "Выключен"
                        onClicked: root.hyprsunset.toggleTemperature()
                    }
                }
                StyledSlider {
                    Layout.fillWidth: true
                    from: 6500
                    to: 1200
                    value: root.night.colorTemperature
                    tooltipContent: Math.round(value) + "K"
                    usePercentTooltip: false
                    configuration: StyledSlider.Configuration.S
                    onMoved: root.night.colorTemperature = value
                }
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 74
        radius: 21
        color: "transparent"
        border.width: 1
        border.color: root.style.hairline
        antialiasing: true
        RowLayout {
            anchors { fill: parent; leftMargin: 16; rightMargin: 16 }
            MikoIconDisc { style: root.style; icon: "shield_with_heart" }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0
                StyledText { text: "Комфорт для глаз"; color: root.style.ink; font.weight: Font.Medium }
                StyledText {
                    text: "Гамма, анти-вспышка и автоматическая яркость"
                    color: root.style.mutedInk
                    font.pixelSize: Appearance.font.pixelSize.smaller
                }
            }
            MikoButton { style: root.style; icon: "tune"; text: "Дополнительно" }
        }
    }
}
