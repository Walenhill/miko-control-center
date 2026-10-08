import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    property var style: null
    readonly property var ui: style ? style : DefaultStyle

    required property var brightnessMonitor
    required property var hyprsunset
    required property var night

    Layout.fillWidth: true
    spacing: 16

    MikoSectionHeader {
        style: root.ui
        title: I18n.tr("Яркость и цветовая температура")
        subtitle: I18n.tr("Настройка комфортного уровня свечения и ночного фильтра")
    }

    GridLayout {
        Layout.fillWidth: true
        columns: width > 820 ? 2 : 1
        columnSpacing: 14
        rowSpacing: 14

        // Brightness Card
        MikoSurface {
            Layout.fillWidth: true
            style: root.ui

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 14

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    MikoIconDisc {
                        style: root.ui
                        icon: "brightness_6"
                        accented: true
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        StyledText {
                            text: I18n.tr("Яркость подсветки")
                            color: root.ui.ink
                            font.weight: Font.DemiBold
                            font.pixelSize: Appearance.font.pixelSize.normal
                        }

                        StyledText {
                            text: (root.brightnessMonitor && root.brightnessMonitor.ready)
                                ? (root.brightnessMonitor.isDdc ? I18n.tr("Управление через DDC/CI") : I18n.tr("Аппаратная подсветка"))
                                : I18n.tr("Определение монитора…")
                            color: root.ui.mutedInk
                            font.pixelSize: Appearance.font.pixelSize.smaller
                        }
                    }

                    MikoBadge {
                        style: root.ui
                        text: Math.round(((root.brightnessMonitor && root.brightnessMonitor.brightness !== undefined)
                            ? root.brightnessMonitor.brightness : 0) * 100) + "%"
                        tone: "accent"
                    }
                }

                StyledSlider {
                    Layout.fillWidth: true
                    enabled: Boolean(root.brightnessMonitor && root.brightnessMonitor.ready)
                    value: (root.brightnessMonitor && root.brightnessMonitor.brightness !== undefined)
                        ? root.brightnessMonitor.brightness : 0
                    configuration: StyledSlider.Configuration.S
                    onMoved: if (root.brightnessMonitor) root.brightnessMonitor.setBrightness(value)
                }
            }
        }

        // Night Light Card
        MikoSurface {
            Layout.fillWidth: true
            style: root.ui

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 14

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    MikoIconDisc {
                        style: root.ui
                        icon: "bedtime"
                        accented: Boolean(root.hyprsunset && root.hyprsunset.temperatureActive)
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        StyledText {
                            text: I18n.tr("Ночной свет")
                            color: root.ui.ink
                            font.weight: Font.DemiBold
                            font.pixelSize: Appearance.font.pixelSize.normal
                        }

                        StyledText {
                            text: (root.night && root.night.automatic)
                                ? (I18n.tr("По расписанию ") + root.night.from + "–" + root.night.to)
                                : I18n.tr("Ручное переключение")
                            color: root.ui.mutedInk
                            font.pixelSize: Appearance.font.pixelSize.smaller
                        }
                    }

                    MikoBadge {
                        style: root.ui
                        text: Math.round(root.night ? root.night.colorTemperature : 6500) + "K"
                        tone: (root.hyprsunset && root.hyprsunset.temperatureActive) ? "accent" : "neutral"
                    }

                    MikoButton {
                        style: root.ui
                        icon: (root.hyprsunset && root.hyprsunset.temperatureActive) ? "toggle_on" : "toggle_off"
                        text: (root.hyprsunset && root.hyprsunset.temperatureActive) ? I18n.tr("Вкл") : I18n.tr("Выкл")
                        selected: Boolean(root.hyprsunset && root.hyprsunset.temperatureActive)
                        onClicked: if (root.hyprsunset) root.hyprsunset.toggleTemperature()
                    }
                }

                StyledSlider {
                    Layout.fillWidth: true
                    from: 6500
                    to: 1200
                    value: root.night ? root.night.colorTemperature : 6500
                    tooltipContent: Math.round(value) + "K"
                    usePercentTooltip: false
                    configuration: StyledSlider.Configuration.S
                    onMoved: if (root.night) root.night.colorTemperature = value
                }
            }
        }
    }

    // Eye Comfort & Presets
    MikoSectionHeader {
        style: root.ui
        title: I18n.tr("Комфорт для зрения")
        subtitle: I18n.tr("Быстрые предустановки цветовой температуры")
    }

    MikoSurface {
        Layout.fillWidth: true
        style: root.ui

        RowLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 14

            MikoIconDisc {
                style: root.ui
                icon: "shield_with_heart"
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                StyledText {
                    text: I18n.tr("Быстрые режимы температуры")
                    color: root.ui.ink
                    font.weight: Font.DemiBold
                    font.pixelSize: Appearance.font.pixelSize.normal
                }

                StyledText {
                    text: I18n.tr("Выбери желаемый оттенок экрана в один клик")
                    color: root.ui.mutedInk
                    font.pixelSize: Appearance.font.pixelSize.smaller
                }
            }

            RowLayout {
                spacing: 8

                MikoButton {
                    style: root.ui
                    icon: "wb_sunny"
                    text: "6500K"
                    selected: root.night && Math.abs(root.night.colorTemperature - 6500) < 50
                    onClicked: {
                        if (root.night) root.night.colorTemperature = 6500;
                    }
                }

                MikoButton {
                    style: root.ui
                    icon: "filter_drama"
                    text: "4500K"
                    selected: root.night && Math.abs(root.night.colorTemperature - 4500) < 50
                    onClicked: {
                        if (root.night) root.night.colorTemperature = 4500;
                    }
                }

                MikoButton {
                    style: root.ui
                    icon: "nightlight_round"
                    text: "3200K"
                    selected: root.night && Math.abs(root.night.colorTemperature - 3200) < 50
                    onClicked: {
                        if (root.night) root.night.colorTemperature = 3200;
                    }
                }
            }
        }
    }
}
