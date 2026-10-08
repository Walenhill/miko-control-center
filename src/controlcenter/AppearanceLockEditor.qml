import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    required property var style

    Layout.fillWidth: true
    spacing: 16

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
                title: I18n.tr("Экран блокировки")
                subtitle: I18n.tr("Hyprlock, безопасность, часы и эффекты размытия")
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                MikoToggleRow { style: root.style; title: I18n.tr("Использовать Hyprlock"); subtitle: I18n.tr("Вместо экрана блокировки Quickshell"); icon: "lock"; checked: Config.options.lock.useHyprlock; onToggled: checked => Config.options.lock.useHyprlock = checked }
                MikoToggleRow { style: root.style; title: I18n.tr("Запускать вместе с системой"); icon: "power_settings_new"; checked: Config.options.lock.launchOnStartup; onToggled: checked => Config.options.lock.launchOnStartup = checked }
                MikoToggleRow { style: root.style; title: I18n.tr("Разблокировать связку ключей"); icon: "key"; checked: Config.options.lock.security.unlockKeyring; onToggled: checked => Config.options.lock.security.unlockKeyring = checked }
                MikoToggleRow { style: root.style; title: I18n.tr("Пароль для действий питания"); icon: "shield_lock"; checked: Config.options.lock.security.requirePasswordToPower; onToggled: checked => Config.options.lock.security.requirePasswordToPower = checked }
                MikoToggleRow { style: root.style; title: I18n.tr("Часы по центру"); icon: "schedule"; checked: Config.options.lock.centerClock; onToggled: checked => Config.options.lock.centerClock = checked }
                MikoToggleRow { style: root.style; title: I18n.tr("Показывать текст блокировки"); icon: "text_fields"; checked: Config.options.lock.showLockedText; onToggled: checked => Config.options.lock.showLockedText = checked }
                MikoToggleRow { style: root.style; title: I18n.tr("Размывать фон"); icon: "blur_on"; checked: Config.options.lock.blur.enable; onToggled: checked => Config.options.lock.blur.enable = checked }
                MikoStepperRow { style: root.style; title: I18n.tr("Радиус размытия"); icon: "blur_circular"; value: Config.options.lock.blur.radius; minimum: 0; maximum: 200; step: 10; onChanged: value => Config.options.lock.blur.radius = value }
                MikoStepperRow { style: root.style; title: I18n.tr("Увеличение фона"); icon: "zoom_in"; value: Math.round(Config.options.lock.blur.extraZoom * 100); minimum: 100; maximum: 140; step: 1; suffix: "%"; onChanged: value => Config.options.lock.blur.extraZoom = value / 100 }
            }
        }
    }
}
