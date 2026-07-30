import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    required property var controller
    required property var style

    Layout.fillWidth: true
    spacing: 10

    RowLayout {
        Layout.fillWidth: true
        Layout.topMargin: 6
        StyledText {
            Layout.fillWidth: true
            text: "Звуковые сцены"
            color: root.style.ink
            font.pixelSize: Appearance.font.pixelSize.larger
            font.weight: Font.DemiBold
        }
        StyledText {
            text: "Быстрая смена характера звука"
            color: root.style.mutedInk
            font.pixelSize: Appearance.font.pixelSize.smaller
        }
    }

    GridLayout {
        Layout.fillWidth: true
        columns: width > 700 ? 3 : 1
        columnSpacing: 10
        rowSpacing: 10

        Repeater {
            model: [
                { id: "night", title: "Ночь", subtitle: "28% · лимит 60%", icon: "bedtime" },
                { id: "focus", title: "Фокус", subtitle: "48% · лимит 78%", icon: "headphones" },
                { id: "open", title: "Свободно", subtitle: "Без ограничения", icon: "volume_up" }
            ]
            delegate: Rectangle {
                id: scene
                required property var modelData
                readonly property bool selected: root.controller.activeScene === modelData.id

                Layout.fillWidth: true
                implicitHeight: 76
                radius: 21
                color: selected
                    ? root.style.selectedSurface
                    : (pointer.containsMouse ? root.style.hoverSurface : root.style.sectionSurface)
                antialiasing: true

                Behavior on color { ColorAnimation { duration: root.style.motionFast } }

                RowLayout {
                    anchors { fill: parent; margins: 13 }
                    MaterialSymbol {
                        text: scene.modelData.icon
                        iconSize: 21
                        color: scene.selected ? root.style.selectedInk : root.style.ink
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        StyledText {
                            text: scene.modelData.title
                            color: scene.selected ? root.style.selectedInk : root.style.ink
                            font.pixelSize: Appearance.font.pixelSize.small
                            font.weight: Font.Medium
                        }
                        StyledText {
                            text: scene.modelData.subtitle
                            color: scene.selected
                                ? Qt.rgba(root.style.selectedInk.r, root.style.selectedInk.g, root.style.selectedInk.b, 0.72)
                                : root.style.mutedInk
                            font.pixelSize: Appearance.font.pixelSize.smaller
                        }
                    }
                }
                MouseArea {
                    id: pointer
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.controller.applyScene(scene.modelData.id)
                }
            }
        }
    }
}
