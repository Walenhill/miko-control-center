import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    required property var style

    Layout.fillWidth: true
    spacing: 14

    StyledText {
        text: "Dock"
        color: root.style.ink
        font.pixelSize: Appearance.font.pixelSize.larger
        font.weight: Font.DemiBold
    }
    Rectangle {
        Layout.fillWidth: true
        implicitHeight: dockRows.implicitHeight + 20
        radius: 24
        color: root.style.sectionSurface
        antialiasing: true

        ColumnLayout {
            id: dockRows
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 10 }
            spacing: 0
            MikoToggleRow { style: root.style; title: "Включить Dock"; icon: "dock_to_bottom"; checked: Config.options.dock.enable; onToggled: checked => Config.options.dock.enable = checked }
            MikoToggleRow { style: root.style; title: "Показывать при наведении"; icon: "ads_click"; checked: Config.options.dock.hoverToReveal; available: Config.options.dock.enable; onToggled: checked => Config.options.dock.hoverToReveal = checked }
            MikoToggleRow { style: root.style; title: "Закреплять при запуске"; icon: "keep"; checked: Config.options.dock.pinnedOnStartup; available: Config.options.dock.enable; onToggled: checked => Config.options.dock.pinnedOnStartup = checked }
            MikoToggleRow { style: root.style; title: "Монохромные иконки"; icon: "filter_b_and_w"; checked: Config.options.dock.monochromeIcons; available: Config.options.dock.enable; onToggled: checked => Config.options.dock.monochromeIcons = checked }
            MikoStepperRow { style: root.style; title: "Высота Dock"; icon: "height"; value: Config.options.dock.height; minimum: 36; maximum: 100; step: 2; suffix: " px"; onChanged: value => Config.options.dock.height = value }
        }
    }

    StyledText {
        text: "Обзор рабочих столов"
        color: root.style.ink
        font.pixelSize: Appearance.font.pixelSize.larger
        font.weight: Font.DemiBold
    }
    Rectangle {
        Layout.fillWidth: true
        implicitHeight: overviewRows.implicitHeight + 20
        radius: 24
        color: root.style.sectionSurface
        antialiasing: true

        ColumnLayout {
            id: overviewRows
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 10 }
            spacing: 0
            MikoToggleRow { style: root.style; title: "Включить обзор"; icon: "grid_view"; checked: Config.options.overview.enable; onToggled: checked => Config.options.overview.enable = checked }
            MikoToggleRow { style: root.style; title: "Центрировать иконки"; icon: "center_focus_strong"; checked: Config.options.overview.centerIcons; available: Config.options.overview.enable; onToggled: checked => Config.options.overview.centerIcons = checked }
            MikoStepperRow { style: root.style; title: "Строки"; icon: "table_rows"; value: Config.options.overview.rows; minimum: 1; maximum: 6; onChanged: value => Config.options.overview.rows = value }
            MikoStepperRow { style: root.style; title: "Колонки"; icon: "view_column"; value: Config.options.overview.columns; minimum: 2; maximum: 12; onChanged: value => Config.options.overview.columns = value }
            MikoStepperRow { style: root.style; title: "Масштаб"; icon: "zoom_out_map"; value: Math.round(Config.options.overview.scale * 100); minimum: 8; maximum: 30; suffix: "%"; onChanged: value => Config.options.overview.scale = value / 100 }
        }
    }

    StyledText {
        text: "Текст и экранные элементы"
        color: root.style.ink
        font.pixelSize: Appearance.font.pixelSize.larger
        font.weight: Font.DemiBold
    }
    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 134
        radius: 24
        color: root.style.sectionSurface
        antialiasing: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 8
            StyledText {
                text: "Основной шрифт"
                color: root.style.ink
                font.pixelSize: Appearance.font.pixelSize.small
                font.weight: Font.Medium
            }
            TextField {
                Layout.fillWidth: true
                text: Config.options.appearance.fonts.main
                color: root.style.ink
                font.family: Appearance.font.family.main
                background: Rectangle {
                    radius: 15
                    color: root.style.controlSurface
                }
                onEditingFinished:
                    Config.options.appearance.fonts.main = text.trim()
            }
            MikoStepperRow {
                style: root.style
                title: "Время показа OSD"
                icon: "timer"
                value: Config.options.osd.timeout
                minimum: 300
                maximum: 5000
                step: 100
                suffix: " мс"
                onChanged: value => Config.options.osd.timeout = value
            }
        }
    }
}
