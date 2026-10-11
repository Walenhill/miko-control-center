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
                title: I18n.tr("Поведение панели")
                subtitle: I18n.tr("Автоматическое скрытие, показ по нажатию Super и границы")
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                MikoToggleRow {
                    style: root.style
                    title: I18n.tr("Автоматически скрывать")
                    subtitle: I18n.tr("Освобождать место для окон")
                    icon: "visibility_off"
                    checked: Config.options.bar.autoHide.enable
                    onToggled: checked => AppearanceChanges.setOption("bar.autoHide.enable", checked, title)
                }
                MikoToggleRow {
                    style: root.style
                    title: I18n.tr("Толкать окна при появлении")
                    subtitle: I18n.tr("Не перекрывать содержимое")
                    icon: "vertical_align_center"
                    checked: Config.options.bar.autoHide.pushWindows
                    available: Config.options.bar.autoHide.enable
                    onToggled: checked => AppearanceChanges.setOption("bar.autoHide.pushWindows", checked, title)
                }
                MikoToggleRow {
                    style: root.style
                    title: I18n.tr("Показывать по клавише Super")
                    icon: "keyboard_command_key"
                    checked: Config.options.bar.autoHide.showWhenPressingSuper.enable
                    available: Config.options.bar.autoHide.enable
                    onToggled: checked =>
                        AppearanceChanges.setOption("bar.autoHide.showWhenPressingSuper.enable", checked, title)
                }
                MikoToggleRow {
                    style: root.style
                    title: I18n.tr("Фон панели")
                    icon: "background_replace"
                    checked: Config.options.bar.showBackground
                    onToggled: checked => AppearanceChanges.setOption("bar.showBackground", checked, title)
                }
                MikoToggleRow {
                    style: root.style
                    title: I18n.tr("Без границ")
                    icon: "border_clear"
                    checked: Config.options.bar.borderless
                    onToggled: checked => AppearanceChanges.setOption("bar.borderless", checked, title)
                }
            }
        }
    }
}
