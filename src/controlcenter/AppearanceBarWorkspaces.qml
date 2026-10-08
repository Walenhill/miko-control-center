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
                title: I18n.tr("Рабочие столы")
                subtitle: I18n.tr("Отображение номеров, иконок приложений и переключение")
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                MikoToggleRow { style: root.style; title: I18n.tr("Всегда показывать номера"); icon: "tag"; checked: Config.options.bar.workspaces.alwaysShowNumbers; onToggled: checked => AppearanceChanges.setOption("bar.workspaces.alwaysShowNumbers", checked, title) }
                MikoToggleRow { style: root.style; title: I18n.tr("Иконки приложений"); icon: "apps"; checked: Config.options.bar.workspaces.showAppIcons; onToggled: checked => AppearanceChanges.setOption("bar.workspaces.showAppIcons", checked, title) }
                MikoToggleRow { style: root.style; title: I18n.tr("Монохромные иконки"); icon: "monochrome_photos"; checked: Config.options.bar.workspaces.monochromeIcons; available: Config.options.bar.workspaces.showAppIcons; onToggled: checked => AppearanceChanges.setOption("bar.workspaces.monochromeIcons", checked, title) }
                MikoStepperRow { style: root.style; title: I18n.tr("Количество рабочих столов"); icon: "grid_view"; value: Config.options.bar.workspaces.shown; minimum: 1; maximum: 20; onChanged: value => AppearanceChanges.setOption("bar.workspaces.shown", value, title) }
                MikoStepperRow { style: root.style; title: I18n.tr("Задержка номера"); subtitle: I18n.tr("Перед появлением подписи"); icon: "timer"; value: Config.options.bar.workspaces.showNumberDelay; step: 50; minimum: 0; maximum: 1000; suffix: I18n.tr(" мс"); onChanged: value => AppearanceChanges.setOption("bar.workspaces.showNumberDelay", value, title) }
                MikoToggleRow { style: root.style; title: I18n.tr("Счётчик уведомлений"); icon: "notifications"; checked: Config.options.bar.indicators.notifications.showUnreadCount; onToggled: checked => AppearanceChanges.setOption("bar.indicators.notifications.showUnreadCount", checked, title) }
            }
        }
    }
}
