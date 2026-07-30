import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    required property var controller
    required property var style

    spacing: 18

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

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 122
        radius: root.style.radiusWindow
        color: Qt.rgba(
            Appearance.colors.colPrimary.r,
            Appearance.colors.colPrimary.g,
            Appearance.colors.colPrimary.b,
            0.14
        )
        border.width: 1
        border.color: Qt.rgba(
            root.style.ink.r,
            root.style.ink.g,
            root.style.ink.b,
            0.07
        )
        antialiasing: true

        RowLayout {
            anchors {
                fill: parent
                margins: 18
            }
            spacing: 15

            IconDisc {
                icon: root.controller.activeServiceCount() >= 7
                    ? "verified_user" : "heart_broken"
                accented: true
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                LabelText {
                    text: root.controller.activeServiceCount() >= 7
                        ? "Система в порядке"
                        : "Есть компоненты, которым нужно внимание"
                    font.pixelSize: 23
                    font.weight: Font.DemiBold
                }
                MutedText {
                    text: root.controller.activeServiceCount() + " активны · "
                        + root.controller.installedIntegrationCount()
                        + " интеграции · проверено "
                        + root.controller.lastChecked
                }
            }
            SoftButton {
                icon: "refresh"
                text: "Проверить"
                onClicked: root.controller.refresh()
            }
            SoftButton {
                icon: root.controller.editingPins ? "done" : "tune"
                text: root.controller.editingPins
                    ? "Готово" : "Настроить вид"
                onClicked: root.controller.toggleEditingPins()
            }
        }
    }

    Rectangle {
        visible: root.controller.actionMessage !== ""
        Layout.fillWidth: true
        implicitHeight: 48
        radius: 17
        color: root.style.hoverSurface

        RowLayout {
            anchors {
                fill: parent
                leftMargin: 14
                rightMargin: 14
            }
            MaterialSymbol {
                text: root.controller.actionProcess.running
                    ? "sync" : "check_circle"
                iconSize: 19
                color: Appearance.colors.colPrimary
            }
            LabelText {
                Layout.fillWidth: true
                text: root.controller.actionMessage
                font.weight: Font.Medium
            }
        }
    }
}
