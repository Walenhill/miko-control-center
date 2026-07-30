import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    required property var style

    Layout.fillWidth: true
    spacing: 14

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: rows.implicitHeight + 20
        radius: 24
        color: root.style.sectionSurface
        antialiasing: true

        ColumnLayout {
            id: rows
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 10 }
            spacing: 0

            MikoToggleRow { style: root.style; title: "Использовать Hyprlock"; subtitle: "Вместо экрана блокировки Quickshell"; icon: "lock"; checked: Config.options.lock.useHyprlock; onToggled: checked => Config.options.lock.useHyprlock = checked }
            MikoToggleRow { style: root.style; title: "Запускать вместе с системой"; icon: "power_settings_new"; checked: Config.options.lock.launchOnStartup; onToggled: checked => Config.options.lock.launchOnStartup = checked }
            MikoToggleRow { style: root.style; title: "Разблокировать связку ключей"; icon: "key"; checked: Config.options.lock.security.unlockKeyring; onToggled: checked => Config.options.lock.security.unlockKeyring = checked }
            MikoToggleRow { style: root.style; title: "Пароль для действий питания"; icon: "shield_lock"; checked: Config.options.lock.security.requirePasswordToPower; onToggled: checked => Config.options.lock.security.requirePasswordToPower = checked }
            MikoToggleRow { style: root.style; title: "Часы по центру"; icon: "schedule"; checked: Config.options.lock.centerClock; onToggled: checked => Config.options.lock.centerClock = checked }
            MikoToggleRow { style: root.style; title: "Показывать текст блокировки"; icon: "text_fields"; checked: Config.options.lock.showLockedText; onToggled: checked => Config.options.lock.showLockedText = checked }
            MikoToggleRow { style: root.style; title: "Размывать фон"; icon: "blur_on"; checked: Config.options.lock.blur.enable; onToggled: checked => Config.options.lock.blur.enable = checked }
            MikoStepperRow { style: root.style; title: "Радиус размытия"; icon: "blur_circular"; value: Config.options.lock.blur.radius; minimum: 0; maximum: 200; step: 10; onChanged: value => Config.options.lock.blur.radius = value }
            MikoStepperRow { style: root.style; title: "Увеличение фона"; icon: "zoom_in"; value: Math.round(Config.options.lock.blur.extraZoom * 100); minimum: 100; maximum: 140; step: 1; suffix: "%"; onChanged: value => Config.options.lock.blur.extraZoom = value / 100 }
        }
    }
}
