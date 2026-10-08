import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    required property var style
    required property var preferences

    Layout.fillWidth: true
    spacing: 16

    // Language Card
    MikoSurface {
        Layout.fillWidth: true
        style: root.style

        ColumnLayout {
            anchors {
                fill: parent
                margins: 16
            }
            spacing: 14

            MikoSectionHeader {
                style: root.style
                title: I18n.tr("Язык интерфейса")
                subtitle: I18n.tr("Язык центра управления")
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                MikoIconDisc {
                    style: root.style
                    icon: "language"
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    StyledText {
                        text: I18n.tr("Текущий язык")
                        color: root.style.ink
                        font.pixelSize: Appearance.font.pixelSize.normal
                        font.weight: Font.Medium
                    }
                    StyledText {
                        text: root.preferences.language === "auto"
                            ? I18n.tr("Как в системе · {language}", {
                                language: I18n.languageName(I18n.language)
                            })
                            : I18n.languageName(root.preferences.language)
                        color: root.style.mutedInk
                        font.pixelSize: Appearance.font.pixelSize.smaller
                    }
                }
                RowLayout {
                    spacing: 7
                    Repeater {
                        model: I18n.languages
                        delegate: MikoButton {
                            required property var modelData
                            style: root.style
                            text: modelData.code === "auto"
                                ? I18n.tr("Авто") : modelData.nativeName
                            selected: root.preferences.language === modelData.code
                            onClicked: root.preferences.setLanguage(modelData.code)
                        }
                    }
                }
            }
        }
    }

    // Dock Card
    MikoSurface {
        Layout.fillWidth: true
        style: root.style

        ColumnLayout {
            anchors {
                fill: parent
                margins: 16
            }
            spacing: 12

            MikoSectionHeader {
                style: root.style
                title: "Dock"
                subtitle: I18n.tr("Панель быстрого запуска избранных приложений")
                badgeText: Config.options.dock.enable ? I18n.tr("Включен") : ""
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                MikoToggleRow { style: root.style; title: I18n.tr("Включить Dock"); icon: "dock_to_bottom"; checked: Config.options.dock.enable; onToggled: checked => Config.options.dock.enable = checked }
                MikoToggleRow { style: root.style; title: I18n.tr("Показывать при наведении"); icon: "ads_click"; checked: Config.options.dock.hoverToReveal; available: Config.options.dock.enable; onToggled: checked => Config.options.dock.hoverToReveal = checked }
                MikoToggleRow { style: root.style; title: I18n.tr("Закреплять при запуске"); icon: "keep"; checked: Config.options.dock.pinnedOnStartup; available: Config.options.dock.enable; onToggled: checked => Config.options.dock.pinnedOnStartup = checked }
                MikoToggleRow { style: root.style; title: I18n.tr("Монохромные иконки"); icon: "filter_b_and_w"; checked: Config.options.dock.monochromeIcons; available: Config.options.dock.enable; onToggled: checked => Config.options.dock.monochromeIcons = checked }
                MikoStepperRow { style: root.style; title: I18n.tr("Высота Dock"); icon: "height"; value: Config.options.dock.height; minimum: 36; maximum: 100; step: 2; suffix: " px"; onChanged: value => Config.options.dock.height = value }
            }
        }
    }

    // Overview Card
    MikoSurface {
        Layout.fillWidth: true
        style: root.style

        ColumnLayout {
            anchors {
                fill: parent
                margins: 16
            }
            spacing: 12

            MikoSectionHeader {
                style: root.style
                title: I18n.tr("Обзор рабочих столов")
                subtitle: I18n.tr("Сетка рабочих столов и переключение окон")
                badgeText: Config.options.overview.enable ? I18n.tr("Включен") : ""
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                MikoToggleRow { style: root.style; title: I18n.tr("Включить обзор"); icon: "grid_view"; checked: Config.options.overview.enable; onToggled: checked => Config.options.overview.enable = checked }
                MikoToggleRow { style: root.style; title: I18n.tr("Центрировать иконки"); icon: "center_focus_strong"; checked: Config.options.overview.centerIcons; available: Config.options.overview.enable; onToggled: checked => Config.options.overview.centerIcons = checked }
                MikoStepperRow { style: root.style; title: I18n.tr("Строки"); icon: "table_rows"; value: Config.options.overview.rows; minimum: 1; maximum: 6; onChanged: value => Config.options.overview.rows = value }
                MikoStepperRow { style: root.style; title: I18n.tr("Колонки"); icon: "view_column"; value: Config.options.overview.columns; minimum: 2; maximum: 12; onChanged: value => Config.options.overview.columns = value }
                MikoStepperRow { style: root.style; title: I18n.tr("Масштаб"); icon: "zoom_out_map"; value: Math.round(Config.options.overview.scale * 100); minimum: 8; maximum: 30; suffix: "%"; onChanged: value => Config.options.overview.scale = value / 100 }
            }
        }
    }

    // Typography & OSD Card
    MikoSurface {
        Layout.fillWidth: true
        style: root.style

        ColumnLayout {
            anchors {
                fill: parent
                margins: 16
            }
            spacing: 14

            MikoSectionHeader {
                style: root.style
                title: I18n.tr("Текст и экранные элементы")
                subtitle: I18n.tr("Основной шрифт системы и длительность индикаторов OSD")
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                StyledText {
                    text: I18n.tr("Основной шрифт")
                    color: root.style.ink
                    font.pixelSize: Appearance.font.pixelSize.normal
                    font.weight: Font.Medium
                }

                TextField {
                    Layout.fillWidth: true
                    text: Config.options.appearance.fonts.main
                    color: root.style.ink
                    font.family: Appearance.font.family.main
                    font.pixelSize: Appearance.font.pixelSize.normal
                    padding: 10
                    background: Rectangle {
                        radius: root.style.radiusControl
                        color: root.style.controlSurface
                        border.width: 1
                        border.color: root.style.hairline
                    }
                    onEditingFinished:
                        Config.options.appearance.fonts.main = text.trim()
                }
            }

            MikoStepperRow {
                style: root.style
                title: I18n.tr("Время показа OSD")
                icon: "timer"
                value: Config.options.osd.timeout
                minimum: 300
                maximum: 5000
                step: 100
                suffix: I18n.tr(" мс")
                onChanged: value => Config.options.osd.timeout = value
            }
        }
    }
}
