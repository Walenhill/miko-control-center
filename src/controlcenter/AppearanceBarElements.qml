import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    required property var style

    Layout.fillWidth: true
    spacing: 0

    StyledText {
        text: "Элементы панели"
        color: root.style.ink
        font.pixelSize: Appearance.font.pixelSize.larger
        font.weight: Font.DemiBold
        Layout.bottomMargin: 8
    }

    MikoToggleRow { style: root.style; title: "Расширенный вид"; subtitle: "Показывать больше подписей и данных"; icon: "view_agenda"; checked: Config.options.bar.verbose; onToggled: checked => Config.options.bar.verbose = checked }
    MikoToggleRow { style: root.style; title: "Подсказки по нажатию"; icon: "tooltip"; checked: Config.options.bar.tooltips.clickToShow; onToggled: checked => Config.options.bar.tooltips.clickToShow = checked }
    MikoToggleRow { style: root.style; title: "Пипетка"; icon: "colorize"; checked: Config.options.bar.utilButtons.showColorPicker; onToggled: checked => Config.options.bar.utilButtons.showColorPicker = checked }
    MikoToggleRow { style: root.style; title: "Переключатель темы"; icon: "dark_mode"; checked: Config.options.bar.utilButtons.showDarkModeToggle; onToggled: checked => Config.options.bar.utilButtons.showDarkModeToggle = checked }
    MikoToggleRow { style: root.style; title: "Запись экрана"; icon: "screen_record"; checked: Config.options.bar.utilButtons.showScreenRecord; onToggled: checked => Config.options.bar.utilButtons.showScreenRecord = checked }
    MikoToggleRow { style: root.style; title: "Снимок области"; icon: "screenshot_region"; checked: Config.options.bar.utilButtons.showScreenSnip; onToggled: checked => Config.options.bar.utilButtons.showScreenSnip = checked }
    MikoToggleRow { style: root.style; title: "Погода"; icon: "partly_cloudy_day"; checked: Config.options.bar.weather.enable; onToggled: checked => Config.options.bar.weather.enable = checked }
}
