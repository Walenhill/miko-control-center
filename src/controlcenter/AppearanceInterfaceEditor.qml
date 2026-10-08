import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    required property var style
    required property var preferences
    required property var controller

    Layout.fillWidth: true
    spacing: 16

    // Language Card
    MikoSettingsGroup {
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
    MikoSettingsGroup {
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

                MikoToggleRow { style: root.style; title: I18n.tr("Включить Dock"); icon: "dock_to_bottom"; checked: Config.options.dock.enable; onToggled: checked => AppearanceChanges.setOption("dock.enable", checked, title) }
                MikoToggleRow { style: root.style; title: I18n.tr("Показывать при наведении"); icon: "ads_click"; checked: Config.options.dock.hoverToReveal; available: Config.options.dock.enable; onToggled: checked => AppearanceChanges.setOption("dock.hoverToReveal", checked, title) }
                MikoToggleRow { style: root.style; title: I18n.tr("Закреплять при запуске"); icon: "keep"; checked: Config.options.dock.pinnedOnStartup; available: Config.options.dock.enable; onToggled: checked => AppearanceChanges.setOption("dock.pinnedOnStartup", checked, title) }
                MikoToggleRow { style: root.style; title: I18n.tr("Монохромные иконки"); icon: "filter_b_and_w"; checked: Config.options.dock.monochromeIcons; available: Config.options.dock.enable; onToggled: checked => AppearanceChanges.setOption("dock.monochromeIcons", checked, title) }
                MikoStepperRow { style: root.style; title: I18n.tr("Высота Dock"); icon: "height"; value: Config.options.dock.height; minimum: 36; maximum: 100; step: 2; suffix: " px"; onChanged: value => AppearanceChanges.setOption("dock.height", value, title) }
            }
        }
    }

    // Overview Card
    MikoSettingsGroup {
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

                MikoToggleRow { style: root.style; title: I18n.tr("Включить обзор"); icon: "grid_view"; checked: Config.options.overview.enable; onToggled: checked => AppearanceChanges.setOption("overview.enable", checked, title) }
                MikoToggleRow { style: root.style; title: I18n.tr("Центрировать иконки"); icon: "center_focus_strong"; checked: Config.options.overview.centerIcons; available: Config.options.overview.enable; onToggled: checked => AppearanceChanges.setOption("overview.centerIcons", checked, title) }
                MikoStepperRow { style: root.style; title: I18n.tr("Строки"); icon: "table_rows"; value: Config.options.overview.rows; minimum: 1; maximum: 6; onChanged: value => AppearanceChanges.setOption("overview.rows", value, title) }
                MikoStepperRow { style: root.style; title: I18n.tr("Колонки"); icon: "view_column"; value: Config.options.overview.columns; minimum: 2; maximum: 12; onChanged: value => AppearanceChanges.setOption("overview.columns", value, title) }
                MikoStepperRow { style: root.style; title: I18n.tr("Масштаб"); icon: "zoom_out_map"; value: Math.round(Config.options.overview.scale * 100); minimum: 8; maximum: 30; suffix: "%"; onChanged: value => AppearanceChanges.setOption("overview.scale", value / 100, title) }
            }
        }
    }

    // Typography & OSD Card
    MikoSettingsGroup {
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

                MikoButton {
                    style: root.style; text: Config.options.appearance.fonts.main; icon: "text_fields"
                    onClicked: root.controller.openEditor("fonts")
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
                onChanged: value => AppearanceChanges.setOption("osd.timeout", value, title)
            }
        }
    }
}
