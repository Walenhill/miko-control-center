import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    property var style: null
    readonly property var ui: style ? style : DefaultStyle

    required property var controller

    spacing: 14

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 120
        radius: root.ui.radiusSection
        color: root.ui.sectionSurface
        border.width: 1
        border.color: root.ui.hairline
        antialiasing: true

        RowLayout {
            anchors {
                fill: parent
                margins: 20
            }
            spacing: 16

            MikoIconDisc {
                style: root.ui
                icon: root.controller.activeServiceCount() >= 7 ? "verified_user" : "warning"
                accented: true
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                StyledText {
                    text: root.controller.activeServiceCount() >= 7
                        ? I18n.tr("Все ключевые службы активны")
                        : I18n.tr("Некоторые службы требуют внимания")
                    color: root.ui.ink
                    font.pixelSize: 20
                    font.weight: Font.DemiBold
                }

                StyledText {
                    text: root.controller.activeServiceCount() + I18n.tr(" активны · ")
                        + root.controller.installedIntegrationCount()
                        + I18n.tr(" интеграции · проверено ")
                        + root.controller.lastChecked
                    color: root.ui.mutedInk
                    font.pixelSize: Appearance.font.pixelSize.smaller
                }
            }

            MikoButton {
                style: root.ui
                icon: "refresh"
                text: I18n.tr("Проверить")
                onClicked: root.controller.refresh()
            }

            MikoButton {
                style: root.ui
                icon: root.controller.editingPins ? "done" : "tune"
                text: root.controller.editingPins ? I18n.tr("Готово") : I18n.tr("Настроить вид")
                selected: root.controller.editingPins
                onClicked: root.controller.toggleEditingPins()
            }
        }
    }

    // Optional action notification message
    MikoSurface {
        visible: Boolean(root.controller.actionMessage && root.controller.actionMessage !== "")
        Layout.fillWidth: true
        style: root.ui

        RowLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10

            MaterialSymbol {
                text: "info"
                iconSize: 18
                color: Appearance.colors.colPrimary
            }

            StyledText {
                Layout.fillWidth: true
                text: root.controller.actionMessage || ""
                color: root.ui.ink
                font.pixelSize: Appearance.font.pixelSize.smaller
            }
        }
    }
}
