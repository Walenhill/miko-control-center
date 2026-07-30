import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

Rectangle {
    id: root

    required property var controller
    required property var style

    Layout.fillWidth: true
    implicitHeight: 116
    radius: root.style.radiusSection
    color: root.style.sectionSurface
    border.width: 1
    border.color: Qt.rgba(
        root.style.ink.r,
        root.style.ink.g,
        root.style.ink.b,
        0.07
    )

    component LabelText: StyledText {
        color: root.style.ink
        font.pixelSize: Appearance.font.pixelSize.small
    }

    component MutedText: StyledText {
        color: root.style.mutedInk
        font.pixelSize: Appearance.font.pixelSize.smaller
    }

    component IconDisc: MikoIconDisc {
        style: root.style
    }

    component SoftButton: MikoButton {
        style: root.style
    }

    RowLayout {
        anchors {
            fill: parent
            margins: 16
        }
        spacing: 13

        IconDisc {
            icon: root.controller.diagnosticHealthy
                ? "medical_services" : "warning"
            accented: root.controller.diagnosticProcess.running
        }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2
            LabelText {
                text: "Обслуживание"
                font.weight: Font.DemiBold
            }
            MutedText {
                text: root.controller.diagnosticProcess.running
                    ? "Проверяю оболочку, службы и порталы…"
                    : root.controller.diagnosticSummary
            }
            MutedText {
                text: "Технические подробности сохраняются, но не мешают обзору"
            }
        }
        SoftButton {
            icon: "health_and_safety"
            text: root.controller.diagnosticProcess.running
                ? "Проверяем…" : "Глубокая проверка"
            onClicked: root.controller.runDiagnostics()
        }
    }
}
