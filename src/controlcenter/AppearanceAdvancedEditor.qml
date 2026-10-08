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
            spacing: 12

            MikoSectionHeader {
                style: root.style
                title: I18n.tr("Темизация приложений")
                subtitle: I18n.tr("Генерация тем из обоев для Qt, GTK, терминала и интерфейса")
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                MikoToggleRow { style: root.style; title: I18n.tr("Оболочка и приложения"); icon: "palette"; checked: Config.options.appearance.wallpaperTheming.enableAppsAndShell; onToggled: checked => Config.options.appearance.wallpaperTheming.enableAppsAndShell = checked }
                MikoToggleRow { style: root.style; title: I18n.tr("Qt-приложения"); icon: "deployed_code"; checked: Config.options.appearance.wallpaperTheming.enableQtApps; onToggled: checked => Config.options.appearance.wallpaperTheming.enableQtApps = checked }
                MikoToggleRow { style: root.style; title: I18n.tr("Терминал"); icon: "terminal"; checked: Config.options.appearance.wallpaperTheming.enableTerminal; onToggled: checked => Config.options.appearance.wallpaperTheming.enableTerminal = checked }
                MikoToggleRow { style: root.style; title: I18n.tr("Всегда тёмная тема терминала"); icon: "dark_mode"; checked: Config.options.appearance.wallpaperTheming.terminalGenerationProps.forceDarkMode; available: Config.options.appearance.wallpaperTheming.enableTerminal; onToggled: checked => Config.options.appearance.wallpaperTheming.terminalGenerationProps.forceDarkMode = checked }
                MikoToggleRow { style: root.style; title: I18n.tr("Дополнительный оттенок фона"); icon: "format_color_fill"; checked: Config.options.appearance.extraBackgroundTint; onToggled: checked => Config.options.appearance.extraBackgroundTint = checked }
            }
        }
    }

    MikoSurface {
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
                title: I18n.tr("Движение обоев (Parallax)")
                subtitle: I18n.tr("Смещение обоев при переключении рабочих столов или открытии боковой панели")
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                MikoToggleRow { style: root.style; title: I18n.tr("Parallax рабочих столов"); icon: "view_carousel"; checked: Config.options.background.parallax.enableWorkspace; onToggled: checked => Config.options.background.parallax.enableWorkspace = checked }
                MikoToggleRow { style: root.style; title: I18n.tr("Parallax боковой панели"); icon: "view_sidebar"; checked: Config.options.background.parallax.enableSidebar; onToggled: checked => Config.options.background.parallax.enableSidebar = checked }
                MikoToggleRow { style: root.style; title: I18n.tr("Вертикальное движение"); icon: "swap_vert"; checked: Config.options.background.parallax.vertical; onToggled: checked => Config.options.background.parallax.vertical = checked }
                MikoStepperRow { style: root.style; title: I18n.tr("Масштаб движения"); icon: "zoom_out_map"; value: Math.round(Config.options.background.parallax.workspaceZoom * 100); minimum: 100; maximum: 130; step: 1; suffix: "%"; onChanged: value => Config.options.background.parallax.workspaceZoom = value / 100 }
            }
        }
    }
}
