import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    required property var style

    Layout.fillWidth: true
    spacing: 16

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
                title: I18n.tr("Элементы панели")
                subtitle: I18n.tr("Кнопки быстрых действий, утилиты и виджеты")
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                MikoToggleRow { style: root.style; title: I18n.tr("Расширенный вид"); subtitle: I18n.tr("Показывать больше подписей и данных"); icon: "view_agenda"; checked: Config.options.bar.verbose; onToggled: checked => AppearanceChanges.setOption("bar.verbose", checked, title) }
                MikoToggleRow { style: root.style; title: I18n.tr("Подсказки по нажатию"); icon: "tooltip"; checked: Config.options.bar.tooltips.clickToShow; onToggled: checked => AppearanceChanges.setOption("bar.tooltips.clickToShow", checked, title) }
                MikoToggleRow { style: root.style; title: I18n.tr("Пипетка"); icon: "colorize"; checked: Config.options.bar.utilButtons.showColorPicker; onToggled: checked => AppearanceChanges.setOption("bar.utilButtons.showColorPicker", checked, title) }
                MikoToggleRow { style: root.style; title: I18n.tr("Переключатель темы"); icon: "dark_mode"; checked: Config.options.bar.utilButtons.showDarkModeToggle; onToggled: checked => AppearanceChanges.setOption("bar.utilButtons.showDarkModeToggle", checked, title) }
                MikoToggleRow { style: root.style; title: I18n.tr("Запись экрана"); icon: "screen_record"; checked: Config.options.bar.utilButtons.showScreenRecord; onToggled: checked => AppearanceChanges.setOption("bar.utilButtons.showScreenRecord", checked, title) }
                MikoToggleRow { style: root.style; title: I18n.tr("Снимок области"); icon: "screenshot_region"; checked: Config.options.bar.utilButtons.showScreenSnip; onToggled: checked => AppearanceChanges.setOption("bar.utilButtons.showScreenSnip", checked, title) }
                MikoToggleRow { style: root.style; title: I18n.tr("Погода"); icon: "partly_cloudy_day"; checked: Config.options.bar.weather.enable; onToggled: checked => AppearanceChanges.setOption("bar.weather.enable", checked, title) }
            }
        }
    }
}
