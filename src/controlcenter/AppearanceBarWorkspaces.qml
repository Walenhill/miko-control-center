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
        text: "Рабочие столы"
        color: root.style.ink
        font.pixelSize: Appearance.font.pixelSize.larger
        font.weight: Font.DemiBold
        Layout.bottomMargin: 8
    }

    MikoToggleRow { style: root.style; title: "Всегда показывать номера"; icon: "tag"; checked: Config.options.bar.workspaces.alwaysShowNumbers; onToggled: checked => Config.options.bar.workspaces.alwaysShowNumbers = checked }
    MikoToggleRow { style: root.style; title: "Иконки приложений"; icon: "apps"; checked: Config.options.bar.workspaces.showAppIcons; onToggled: checked => Config.options.bar.workspaces.showAppIcons = checked }
    MikoToggleRow { style: root.style; title: "Монохромные иконки"; icon: "monochrome_photos"; checked: Config.options.bar.workspaces.monochromeIcons; available: Config.options.bar.workspaces.showAppIcons; onToggled: checked => Config.options.bar.workspaces.monochromeIcons = checked }
    MikoStepperRow { style: root.style; title: "Количество рабочих столов"; icon: "grid_view"; value: Config.options.bar.workspaces.shown; minimum: 1; maximum: 20; onChanged: value => Config.options.bar.workspaces.shown = value }
    MikoStepperRow { style: root.style; title: "Задержка номера"; subtitle: "Перед появлением подписи"; icon: "timer"; value: Config.options.bar.workspaces.showNumberDelay; step: 50; minimum: 0; maximum: 1000; suffix: " мс"; onChanged: value => Config.options.bar.workspaces.showNumberDelay = value }
    MikoToggleRow { style: root.style; title: "Счётчик уведомлений"; icon: "notifications"; checked: Config.options.bar.indicators.notifications.showUnreadCount; onToggled: checked => Config.options.bar.indicators.notifications.showUnreadCount = checked }
}
