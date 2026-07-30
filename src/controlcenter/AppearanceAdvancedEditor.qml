import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    required property var style

    Layout.fillWidth: true
    spacing: 14

    StyledText {
        text: "Темизация приложений"
        color: root.style.ink
        font.pixelSize: Appearance.font.pixelSize.larger
        font.weight: Font.DemiBold
    }
    Rectangle {
        Layout.fillWidth: true
        implicitHeight: themeRows.implicitHeight + 20
        radius: 24
        color: root.style.sectionSurface
        antialiasing: true
        ColumnLayout {
            id: themeRows
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 10 }
            spacing: 0
            MikoToggleRow { style: root.style; title: "Оболочка и приложения"; icon: "palette"; checked: Config.options.appearance.wallpaperTheming.enableAppsAndShell; onToggled: checked => Config.options.appearance.wallpaperTheming.enableAppsAndShell = checked }
            MikoToggleRow { style: root.style; title: "Qt-приложения"; icon: "deployed_code"; checked: Config.options.appearance.wallpaperTheming.enableQtApps; onToggled: checked => Config.options.appearance.wallpaperTheming.enableQtApps = checked }
            MikoToggleRow { style: root.style; title: "Терминал"; icon: "terminal"; checked: Config.options.appearance.wallpaperTheming.enableTerminal; onToggled: checked => Config.options.appearance.wallpaperTheming.enableTerminal = checked }
            MikoToggleRow { style: root.style; title: "Всегда тёмная тема терминала"; icon: "dark_mode"; checked: Config.options.appearance.wallpaperTheming.terminalGenerationProps.forceDarkMode; available: Config.options.appearance.wallpaperTheming.enableTerminal; onToggled: checked => Config.options.appearance.wallpaperTheming.terminalGenerationProps.forceDarkMode = checked }
            MikoToggleRow { style: root.style; title: "Дополнительный оттенок фона"; icon: "format_color_fill"; checked: Config.options.appearance.extraBackgroundTint; onToggled: checked => Config.options.appearance.extraBackgroundTint = checked }
        }
    }

    StyledText {
        text: "Движение обоев"
        color: root.style.ink
        font.pixelSize: Appearance.font.pixelSize.larger
        font.weight: Font.DemiBold
    }
    Rectangle {
        Layout.fillWidth: true
        implicitHeight: parallaxRows.implicitHeight + 20
        radius: 24
        color: root.style.sectionSurface
        antialiasing: true
        ColumnLayout {
            id: parallaxRows
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 10 }
            spacing: 0
            MikoToggleRow { style: root.style; title: "Parallax рабочих столов"; icon: "view_carousel"; checked: Config.options.background.parallax.enableWorkspace; onToggled: checked => Config.options.background.parallax.enableWorkspace = checked }
            MikoToggleRow { style: root.style; title: "Parallax боковой панели"; icon: "view_sidebar"; checked: Config.options.background.parallax.enableSidebar; onToggled: checked => Config.options.background.parallax.enableSidebar = checked }
            MikoToggleRow { style: root.style; title: "Вертикальное движение"; icon: "swap_vert"; checked: Config.options.background.parallax.vertical; onToggled: checked => Config.options.background.parallax.vertical = checked }
            MikoStepperRow { style: root.style; title: "Масштаб движения"; icon: "zoom_out_map"; value: Math.round(Config.options.background.parallax.workspaceZoom * 100); minimum: 100; maximum: 130; step: 1; suffix: "%"; onChanged: value => Config.options.background.parallax.workspaceZoom = value / 100 }
        }
    }
}
