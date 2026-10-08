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
    spacing: 12

    MikoSectionHeader {
        style: root.style
        title: I18n.tr("Живые показатели")
        subtitle: I18n.tr("Текущая нагрузка процессора, памяти, сети и накопителя")
    }

    GridLayout {
        Layout.fillWidth: true
        columns: width >= 820 ? 4 : 2
        columnSpacing: 10
        rowSpacing: 10

        OverviewMetricCard {
            style: root.style
            title: I18n.tr("Процессор")
            value: Math.round(root.cpuUsage * 100) + "%"
            icon: "memory"
            progress: root.cpuUsage
        }
        OverviewMetricCard {
            style: root.style
            title: I18n.tr("Память")
            value: Math.round(root.memoryUsage * 100) + "%"
            icon: "memory_alt"
            progress: root.memoryUsage
        }
        OverviewMetricCard {
            style: root.style
            title: I18n.tr("Сеть")
            value: root.networkValue
            icon: root.networkIcon
        }
        OverviewMetricCard {
            style: root.style
            title: I18n.tr("Хранилище")
            value: root.diskFree
            icon: "hard_drive"
            progress: root.diskUsed
        }
    }
}
