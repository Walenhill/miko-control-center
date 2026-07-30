import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    required property var controller
    required property var style

    Layout.fillWidth: true
    spacing: 12

    readonly property var paletteModes: [
        { title: "Авто", value: "auto" },
        { title: "Контекст", value: "scheme-content" },
        { title: "Выразительность", value: "scheme-expressive" },
        { title: "Точность", value: "scheme-fidelity" },
        { title: "Фруктовый салат", value: "scheme-fruit-salad" },
        { title: "Монохром", value: "scheme-monochrome" },
        { title: "Нейтральность", value: "scheme-neutral" },
        { title: "Радуга", value: "scheme-rainbow" },
        { title: "Тональное пятно", value: "scheme-tonal-spot" }
    ]

    StyledText {
        text: "Характер цвета"
        color: root.style.ink
        font.pixelSize: Appearance.font.pixelSize.larger
        font.weight: Font.DemiBold
    }

    Flow {
        Layout.fillWidth: true
        spacing: 7

        Repeater {
            model: root.paletteModes

            delegate: Rectangle {
                id: paletteChoice

                required property var modelData
                readonly property bool selected:
                    Config.options.appearance.palette.type === modelData.value

                width: paletteText.implicitWidth + 28
                height: 42
                radius: root.style.radiusControl
                color: selected
                    ? root.style.selectedSurface
                    : (paletteMouse.containsMouse
                        ? root.style.hoverSurface
                        : root.style.sectionSurface)
                antialiasing: true

                Behavior on color {
                    ColorAnimation { duration: root.style.motionFast }
                }

                StyledText {
                    id: paletteText
                    anchors.centerIn: parent
                    text: paletteChoice.modelData.title
                    color: paletteChoice.selected
                        ? root.style.selectedInk
                        : root.style.ink
                    font.weight: paletteChoice.selected
                        ? Font.DemiBold
                        : Font.Normal
                }

                MouseArea {
                    id: paletteMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.controller.applyPalette(
                        paletteChoice.modelData.value
                    )
                }
            }
        }
    }
}
