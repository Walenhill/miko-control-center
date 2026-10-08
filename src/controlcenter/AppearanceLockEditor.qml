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
            spacing: 14

            MikoSectionHeader {
                style: root.style
                title: I18n.tr("Экран блокировки")
                subtitle: I18n.tr("Hyprlock, безопасность, часы и эффекты размытия")
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                MikoToggleRow { style: root.style; title: I18n.tr("Использовать Hyprlock"); subtitle: I18n.tr("Вместо экрана блокировки Quickshell"); icon: "lock"; checked: Config.options.lock.useHyprlock; onToggled: checked => AppearanceChanges.setOption("lock.useHyprlock", checked, title) }
                MikoToggleRow { style: root.style; title: I18n.tr("Запускать вместе с системой"); icon: "power_settings_new"; checked: Config.options.lock.launchOnStartup; onToggled: checked => AppearanceChanges.setOption("lock.launchOnStartup", checked, title) }
                MikoToggleRow { style: root.style; title: I18n.tr("Разблокировать связку ключей"); icon: "key"; checked: Config.options.lock.security.unlockKeyring; onToggled: checked => AppearanceChanges.setOption("lock.security.unlockKeyring", checked, title) }
                MikoToggleRow { style: root.style; title: I18n.tr("Пароль для действий питания"); icon: "shield_lock"; checked: Config.options.lock.security.requirePasswordToPower; onToggled: checked => AppearanceChanges.setOption("lock.security.requirePasswordToPower", checked, title) }
                MikoToggleRow { style: root.style; title: I18n.tr("Часы по центру"); icon: "schedule"; checked: Config.options.lock.centerClock; onToggled: checked => AppearanceChanges.setOption("lock.centerClock", checked, title) }
                MikoToggleRow { style: root.style; title: I18n.tr("Показывать текст блокировки"); icon: "text_fields"; checked: Config.options.lock.showLockedText; onToggled: checked => AppearanceChanges.setOption("lock.showLockedText", checked, title) }
                MikoToggleRow { style: root.style; title: I18n.tr("Размывать фон"); icon: "blur_on"; checked: Config.options.lock.blur.enable; onToggled: checked => AppearanceChanges.setOption("lock.blur.enable", checked, title) }
                MikoStepperRow { style: root.style; title: I18n.tr("Радиус размытия"); icon: "blur_circular"; value: Config.options.lock.blur.radius; minimum: 0; maximum: 200; step: 10; onChanged: value => AppearanceChanges.setOption("lock.blur.radius", value, title) }
                MikoStepperRow { style: root.style; title: I18n.tr("Увеличение фона"); icon: "zoom_in"; value: Math.round(Config.options.lock.blur.extraZoom * 100); minimum: 100; maximum: 140; step: 1; suffix: "%"; onChanged: value => AppearanceChanges.setOption("lock.blur.extraZoom", value / 100, title) }
            }
        }
    }
}
