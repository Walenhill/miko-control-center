import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    property var style: null
    readonly property var ui: style ? style : DefaultStyle

    required property var controller
    spacing: 12

    MikoSectionHeader {
        style: root.ui
        title: I18n.tr("Телеметрия и диагностика")
        subtitle: I18n.tr("Проверка системных служб systemd и датчиков температуры")
        badgeText: (root.controller.failedUnits && root.controller.failedUnits.length > 0)
            ? (root.controller.failedUnits.length + I18n.tr(" сбоев"))
            : I18n.tr("Норма")
        actionText: root.controller.busy ? I18n.tr("Проверяем…") : I18n.tr("Проверить")
        actionIcon: "refresh"
        actionEnabled: !root.controller.busy
        onActionClicked: root.controller.refresh()
    }

    MikoSurface {
        style: root.ui
        Layout.fillWidth: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 14

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                MikoIconDisc {
                    style: root.ui
                    icon: (root.controller.failedUnits && root.controller.failedUnits.length === 0) ? "verified" : "warning"
                    accented: Boolean(root.controller.failedUnits && root.controller.failedUnits.length === 0)
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    StyledText {
                        Layout.fillWidth: true
                        text: root.controller.message || I18n.tr("Тихая проверка запускается только по запросу")
                        color: root.ui.ink
                        font.weight: Font.DemiBold
                        font.pixelSize: Appearance.font.pixelSize.normal
                    }

                    StyledText {
                        text: I18n.tr("Последняя проверка: ") + (root.controller.lastChecked || "—")
                        color: root.ui.mutedInk
                        font.pixelSize: Appearance.font.pixelSize.smaller
                    }
                }

                MikoButton {
                    style: root.ui
                    icon: "description"
                    text: I18n.tr("Экспорт отчёта")
                    onClicked: root.controller.exportReport()
                }
            }

            // Temperature sensors and reboot suggestion
            Flow {
                Layout.fillWidth: true
                spacing: 8

                Repeater {
                    model: root.controller.temperatures || []

                    delegate: MikoBadge {
                        required property var modelData
                        style: root.ui
                        icon: "device_thermostat"
                        text: modelData.name + " " + modelData.value
                        tone: "neutral"
                    }
                }

                MikoBadge {
                    visible: Boolean(root.controller.rebootRecommended)
                    style: root.ui
                    icon: "restart_alt"
                    text: I18n.tr("Рекомендуется перезапуск")
                    tone: "warning"
                }
            }

            StyledText {
                visible: Boolean(root.controller.reportPath && root.controller.reportPath !== "")
                Layout.fillWidth: true
                text: root.controller.reportPath || ""
                color: root.ui.mutedInk
                font.family: "monospace"
                font.pixelSize: Appearance.font.pixelSize.smallest
                elide: Text.ElideMiddle
            }
        }
    }
}
