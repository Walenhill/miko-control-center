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
        text: "Поведение"
        color: root.style.ink
        font.pixelSize: Appearance.font.pixelSize.larger
        font.weight: Font.DemiBold
        Layout.bottomMargin: 8
    }

    MikoToggleRow {
        style: root.style
        title: "Автоматически скрывать"
        subtitle: "Освобождать место для окон"
        icon: "visibility_off"
        checked: Config.options.bar.autoHide.enable
        onToggled: checked => Config.options.bar.autoHide.enable = checked
    }
    MikoToggleRow {
        style: root.style
        title: "Толкать окна при появлении"
        subtitle: "Не перекрывать содержимое"
        icon: "vertical_align_center"
        checked: Config.options.bar.autoHide.pushWindows
        available: Config.options.bar.autoHide.enable
        onToggled: checked => Config.options.bar.autoHide.pushWindows = checked
    }
    MikoToggleRow {
        style: root.style
        title: "Показывать по клавише Super"
        icon: "keyboard_command_key"
        checked: Config.options.bar.autoHide.showWhenPressingSuper.enable
        available: Config.options.bar.autoHide.enable
        onToggled: checked =>
            Config.options.bar.autoHide.showWhenPressingSuper.enable = checked
    }
    MikoToggleRow {
        style: root.style
        title: "Фон панели"
        icon: "background_replace"
        checked: Config.options.bar.showBackground
        onToggled: checked => Config.options.bar.showBackground = checked
    }
    MikoToggleRow {
        style: root.style
        title: "Без границ"
        icon: "border_clear"
        checked: Config.options.bar.borderless
        onToggled: checked => Config.options.bar.borderless = checked
    }
    MikoToggleRow {
        style: root.style
        title: "Тень плавающей панели"
        icon: "shadow"
        checked: Config.options.bar.floatStyleShadow
        available: Config.options.bar.cornerStyle === 1
        onToggled: checked => Config.options.bar.floatStyleShadow = checked
    }
}
