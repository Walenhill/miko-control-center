import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root
    required property var controller
    required property var style
    spacing: 10

    RowLayout {
        Layout.fillWidth: true
        StyledText {
            Layout.fillWidth: true
            text: "Телеметрия и диагностика"
            color: root.style.ink
            font.pixelSize: Appearance.font.pixelSize.larger
            font.weight: Font.DemiBold
        }
        StyledText {
            text: "Проверено " + root.controller.lastChecked
            color: root.style.mutedInk
            font.pixelSize: Appearance.font.pixelSize.smaller
        }
        MikoButton {
            style: root.style
            icon: "refresh"
            text: root.controller.busy ? "Проверяем…" : "Проверить"
            enabled: !root.controller.busy
            onClicked: root.controller.refresh()
        }
    }

    MikoSurface {
        style: root.style
        Layout.fillWidth: true
        implicitHeight: content.implicitHeight + 28
        ColumnLayout {
            id: content
            anchors { fill: parent; margins: 14 }
            spacing: 10
            RowLayout {
                Layout.fillWidth: true
                MaterialSymbol {
                    text: root.controller.failedUnits.length === 0 ? "verified" : "warning"
                    color: root.controller.failedUnits.length === 0
                        ? Appearance.colors.colPrimary : Appearance.colors.colError
                }
                StyledText {
                    Layout.fillWidth: true
                    text: root.controller.message || "Тихая проверка запускается только по запросу"
                    color: root.style.ink
                }
                MikoButton {
                    style: root.style
                    icon: "description"
                    text: "Экспорт отчёта"
                    onClicked: root.controller.exportReport()
                }
            }
            Flow {
                Layout.fillWidth: true
                spacing: 8
                Repeater {
                    model: root.controller.temperatures
                    delegate: MikoButton {
                        required property var modelData
                        style: root.style
                        icon: "device_thermostat"
                        text: modelData.name + "  " + modelData.value
                    }
                }
                MikoButton {
                    visible: root.controller.rebootRecommended
                    style: root.style
                    icon: "restart_alt"
                    text: "Рекомендуется перезапуск"
                }
            }
            StyledText {
                visible: root.controller.reportPath !== ""
                Layout.fillWidth: true
                text: root.controller.reportPath
                color: root.style.mutedInk
                font.family: "monospace"
                font.pixelSize: Appearance.font.pixelSize.smallest
                elide: Text.ElideMiddle
            }
        }
    }
}
