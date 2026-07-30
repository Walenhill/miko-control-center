import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    required property var style
    required property real cpuUsage
    required property real memoryUsage
    required property string networkValue
    required property string networkIcon
    required property string diskFree
    required property real diskUsed

    Layout.fillWidth: true
    spacing: 10

    RowLayout {
        Layout.fillWidth: true

        StyledText {
            Layout.fillWidth: true
            text: "Сейчас"
            color: root.style.ink
            font.pixelSize: Appearance.font.pixelSize.larger
            font.weight: Font.DemiBold
        }
        StyledText {
            text: "Живое состояние без лишней диагностики"
            color: root.style.mutedInk
            font.pixelSize: Appearance.font.pixelSize.smaller
        }
    }

    GridLayout {
        Layout.fillWidth: true
        columns: width >= 820 ? 4 : 2
        columnSpacing: 9
        rowSpacing: 9

        OverviewMetricCard {
            style: root.style
            title: "Процессор"
            value: Math.round(root.cpuUsage * 100) + "%"
            icon: "memory"
            progress: root.cpuUsage
        }
        OverviewMetricCard {
            style: root.style
            title: "Память"
            value: Math.round(root.memoryUsage * 100) + "%"
            icon: "memory_alt"
            progress: root.memoryUsage
        }
        OverviewMetricCard {
            style: root.style
            title: "Сеть"
            value: root.networkValue
            icon: root.networkIcon
        }
        OverviewMetricCard {
            style: root.style
            title: "Хранилище"
            value: root.diskFree
            icon: "hard_drive"
            progress: root.diskUsed
        }
    }
}
