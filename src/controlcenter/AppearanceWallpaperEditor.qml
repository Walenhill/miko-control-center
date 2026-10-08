import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    required property var controller
    required property var style

    Layout.fillWidth: true
    spacing: 16

    Loader {
        Layout.fillWidth: true
        active: root.visible
        sourceComponent: AppearanceMaterialsEditor { controller: root.controller; style: root.style }
    }

    readonly property var paletteModes: [
        { title: I18n.tr("Авто"), value: "auto" },
        { title: I18n.tr("Контекст"), value: "scheme-content" },
        { title: I18n.tr("Выразительность"), value: "scheme-expressive" },
        { title: I18n.tr("Точность"), value: "scheme-fidelity" },
        { title: I18n.tr("Фруктовый салат"), value: "scheme-fruit-salad" },
        { title: I18n.tr("Монохром"), value: "scheme-monochrome" },
        { title: I18n.tr("Нейтральность"), value: "scheme-neutral" },
        { title: I18n.tr("Радуга"), value: "scheme-rainbow" },
        { title: I18n.tr("Тональное пятно"), value: "scheme-tonal-spot" }
    ]

    MikoSettingsGroup {
        Layout.fillWidth: true
        style: root.style

        ColumnLayout {
            anchors {
                fill: parent
                margins: 16
            }
            spacing: 14

            MikoSectionHeader {
                style: root.style
                title: I18n.tr("Характер палитры (Material You)")
                subtitle: I18n.tr("Алгоритм извлечения акцентных и гармонирующих цветов из текущих обоев")
            }

            Flow {
                Layout.fillWidth: true
                spacing: 8

                Repeater {
                    model: root.paletteModes

                    delegate: MikoSurface {
                        id: paletteChoice
                        required property var modelData
                        readonly property bool selected:
                            root.controller.paletteSelection === modelData.value

                        width: paletteText.implicitWidth + 28
                        height: 42
                        radius: root.style.radiusControl
                        style: root.style
                        interactive: true
                        softAccent: selected

                        StyledText {
                            id: paletteText
                            anchors.centerIn: parent
                            text: paletteChoice.modelData.title
                            color: root.style.ink
                            font.pixelSize: Appearance.font.pixelSize.normal
                            font.weight: paletteChoice.selected
                                ? Font.DemiBold
                                : Font.Normal
                        }

                        onClicked: root.controller.applyPalette(
                            paletteChoice.modelData.value
                        )
                    }
                }
            }
        }
    }
}
