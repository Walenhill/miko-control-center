import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

MikoSurface {
    id: root

    required property var controller
    required property var style

    Layout.fillWidth: true

    ColumnLayout {
        anchors {
            fill: parent
            margins: 16
        }
        spacing: 14

        MikoSectionHeader {
            style: root.style
            title: I18n.tr("Диагностика системы")
            subtitle: I18n.tr("Проверка целостности демонов, порталов и системного журнала")
            badgeText: root.controller.diagnosticHealthy ? I18n.tr("В норме") : I18n.tr("Внимание")
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 14

            MikoIconDisc {
                style: root.style
                icon: root.controller.diagnosticHealthy
                    ? "medical_services" : "warning"
                accented: root.controller.diagnosticProcess.running
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 3

                StyledText {
                    text: root.controller.diagnosticProcess.running
                        ? I18n.tr("Проверяю оболочку, службы и порталы…")
                        : root.controller.diagnosticSummary
                    color: root.style.ink
                    font.pixelSize: Appearance.font.pixelSize.normal
                    font.weight: Font.Medium
                }
                StyledText {
                    text: I18n.tr("Технические подробности сохраняются, но не мешают обзору")
                    color: root.style.mutedInk
                    font.pixelSize: Appearance.font.pixelSize.smaller
                }
            }

            MikoButton {
                style: root.style
                icon: "health_and_safety"
                text: root.controller.diagnosticProcess.running
                    ? I18n.tr("Проверяем…") : I18n.tr("Глубокая проверка")
                selected: !root.controller.diagnosticHealthy
                onClicked: root.controller.runDiagnostics()
            }
        }
    }
}
