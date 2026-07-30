import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    required property var style

    Layout.fillWidth: true
    spacing: 16

    StyledText {
        text: "Форма панели"
        color: root.style.ink
        font.pixelSize: Appearance.font.pixelSize.larger
        font.weight: Font.DemiBold
    }
    StyledText {
        text: "Где находится панель и как она занимает экран"
        color: root.style.mutedInk
        font.pixelSize: Appearance.font.pixelSize.small
    }

    GridLayout {
        Layout.fillWidth: true
        columns: width >= 560 ? 4 : 2
        columnSpacing: 7
        rowSpacing: 7

        Repeater {
            model: [
                { title: "Сверху", icon: "arrow_upward", bottom: false, vertical: false },
                { title: "Справа", icon: "arrow_forward", bottom: true, vertical: true },
                { title: "Слева", icon: "arrow_back", bottom: false, vertical: true },
                { title: "Снизу", icon: "arrow_downward", bottom: true, vertical: false }
            ]

            delegate: Rectangle {
                id: positionChoice
                required property var modelData
                readonly property bool selected:
                    Config.options.bar.bottom === modelData.bottom
                    && Config.options.bar.vertical === modelData.vertical

                Layout.fillWidth: true
                implicitHeight: 48
                radius: 17
                color: selected ? root.style.selectedSurface : root.style.sectionSurface
                antialiasing: true

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 6
                    MaterialSymbol {
                        text: positionChoice.modelData.icon
                        iconSize: 18
                        color: positionChoice.selected
                            ? root.style.selectedInk : root.style.ink
                    }
                    StyledText {
                        text: positionChoice.modelData.title
                        color: positionChoice.selected
                            ? root.style.selectedInk : root.style.ink
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Config.options.bar.bottom = positionChoice.modelData.bottom;
                        Config.options.bar.vertical = positionChoice.modelData.vertical;
                    }
                }
            }
        }
    }

    GridLayout {
        Layout.fillWidth: true
        columns: width >= 560 ? 3 : 1
        columnSpacing: 7
        rowSpacing: 7

        Repeater {
            model: [
                { title: "Захват", icon: "line_curve", value: 0 },
                { title: "Плавающая", icon: "page_header", value: 1 },
                { title: "Прямоугольная", icon: "toolbar", value: 2 }
            ]

            delegate: Rectangle {
                id: shapeChoice
                required property var modelData
                readonly property bool selected:
                    Config.options.bar.cornerStyle === modelData.value

                Layout.fillWidth: true
                implicitHeight: 48
                radius: 17
                color: selected ? root.style.selectedSurface : root.style.sectionSurface
                antialiasing: true

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 6
                    MaterialSymbol {
                        text: shapeChoice.modelData.icon
                        iconSize: 18
                        color: shapeChoice.selected
                            ? root.style.selectedInk : root.style.ink
                    }
                    StyledText {
                        text: shapeChoice.modelData.title
                        color: shapeChoice.selected
                            ? root.style.selectedInk : root.style.ink
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Config.options.bar.cornerStyle = shapeChoice.modelData.value
                }
            }
        }
    }

    StyledText {
        text: "Углы экрана"
        color: root.style.ink
        font.pixelSize: Appearance.font.pixelSize.small
        font.weight: Font.DemiBold
        Layout.topMargin: 5
    }

    GridLayout {
        Layout.fillWidth: true
        columns: width >= 560 ? 3 : 1
        columnSpacing: 7
        rowSpacing: 7

        Repeater {
            model: [
                { title: "Без скругления", value: 0 },
                { title: "Всегда", value: 1 },
                { title: "Не в полном экране", value: 2 }
            ]

            delegate: Rectangle {
                id: cornersChoice
                required property var modelData
                readonly property bool selected:
                    Config.options.appearance.fakeScreenRounding === modelData.value

                Layout.fillWidth: true
                implicitHeight: 48
                radius: 17
                color: selected ? root.style.selectedSurface : root.style.sectionSurface
                antialiasing: true

                StyledText {
                    anchors.centerIn: parent
                    text: cornersChoice.modelData.title
                    color: cornersChoice.selected
                        ? root.style.selectedInk : root.style.ink
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked:
                        Config.options.appearance.fakeScreenRounding =
                            cornersChoice.modelData.value
                }
            }
        }
    }
}
