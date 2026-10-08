import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    required property var controller
    required property var style

    Layout.fillWidth: true
    spacing: root.style.gapControl

    MikoSectionHeader {
        style: root.style
        title: I18n.tr("Звуковые сцены")
        subtitle: I18n.tr("Быстрая смена характера звука")
    }

    GridLayout {
        Layout.fillWidth: true
        columns: width > 700 ? 3 : 1
        columnSpacing: 10
        rowSpacing: 10

        Repeater {
            model: [
                { id: "night", title: I18n.tr("Ночь"), subtitle: I18n.tr("28% · лимит 60%"), icon: "bedtime" },
                { id: "focus", title: I18n.tr("Фокус"), subtitle: I18n.tr("48% · лимит 78%"), icon: "headphones" },
                { id: "open", title: I18n.tr("Свободно"), subtitle: I18n.tr("Без ограничения"), icon: "volume_up" }
            ]
            delegate: MikoSurface {
                id: scene
                required property var modelData
                readonly property bool selected: root.controller.activeScene === modelData.id

                Layout.fillWidth: true
                style: root.style
                softAccent: selected
                interactive: true
                onClicked: root.controller.applyScene(scene.modelData.id)

                RowLayout {
                    anchors { fill: parent; margins: 14 }
                    spacing: 11

                    MikoIconDisc {
                        style: root.style
                        icon: scene.modelData.icon
                        accented: scene.selected
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.minimumWidth: 0
                        spacing: 1

                        StyledText {
                            text: scene.modelData.title
                            color: root.style.ink
                            font.pixelSize: Appearance.font.pixelSize.small
                            font.weight: scene.selected ? Font.DemiBold : Font.Medium
                        }
                        StyledText {
                            text: scene.modelData.subtitle
                            color: root.style.mutedInk
                            font.pixelSize: Appearance.font.pixelSize.smaller
                        }
                    }

                    MaterialSymbol {
                        visible: scene.selected
                        text: "check_circle"
                        iconSize: 19
                        color: root.style.selectedSurface
                    }
                }
            }
        }
    }
}
