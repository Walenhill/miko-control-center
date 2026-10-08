import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    required property var style

    Layout.fillWidth: true
    spacing: 16

    MikoSurface {
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
                title: I18n.tr("Положение панели")
                subtitle: I18n.tr("Где находится панель и как она занимает экран")
            }

            GridLayout {
                Layout.fillWidth: true
                columns: width >= 560 ? 4 : 2
                columnSpacing: 8
                rowSpacing: 8

                Repeater {
                    model: [
                        { title: I18n.tr("Сверху"), icon: "arrow_upward", bottom: false, vertical: false },
                        { title: I18n.tr("Справа"), icon: "arrow_forward", bottom: true, vertical: true },
                        { title: I18n.tr("Слева"), icon: "arrow_back", bottom: false, vertical: true },
                        { title: I18n.tr("Снизу"), icon: "arrow_downward", bottom: true, vertical: false }
                    ]

                    delegate: MikoSurface {
                        id: positionChoice
                        required property var modelData
                        readonly property bool selected:
                            Config.options.bar.bottom === modelData.bottom
                            && Config.options.bar.vertical === modelData.vertical

                        Layout.fillWidth: true
                        implicitHeight: 52
                        style: root.style
                        interactive: true
                        softAccent: selected

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 8
                            MaterialSymbol {
                                text: positionChoice.modelData.icon
                                iconSize: 18
                                color: positionChoice.selected ? root.style.selectedInk : root.style.ink
                            }
                            StyledText {
                                text: positionChoice.modelData.title
                                color: positionChoice.selected ? root.style.selectedInk : root.style.ink
                                font.pixelSize: Appearance.font.pixelSize.normal
                                font.weight: positionChoice.selected ? Font.DemiBold : Font.Normal
                            }
                        }
                        onClicked: {
                            Config.options.bar.bottom = positionChoice.modelData.bottom;
                            Config.options.bar.vertical = positionChoice.modelData.vertical;
                        }
                    }
                }
            }
        }
    }

    MikoSurface {
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
                title: I18n.tr("Стиль панели")
                subtitle: I18n.tr("Форма и стыковка панели с краями экрана")
            }

            GridLayout {
                Layout.fillWidth: true
                columns: width >= 560 ? 3 : 1
                columnSpacing: 8
                rowSpacing: 8

                Repeater {
                    model: [
                        { title: I18n.tr("Захват"), icon: "line_curve", value: 0 },
                        { title: I18n.tr("Плавающая"), icon: "page_header", value: 1 },
                        { title: I18n.tr("Прямоугольная"), icon: "toolbar", value: 2 }
                    ]

                    delegate: MikoSurface {
                        id: shapeChoice
                        required property var modelData
                        readonly property bool selected:
                            Config.options.bar.cornerStyle === modelData.value

                        Layout.fillWidth: true
                        implicitHeight: 52
                        style: root.style
                        interactive: true
                        softAccent: selected

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 8
                            MaterialSymbol {
                                text: shapeChoice.modelData.icon
                                iconSize: 18
                                color: shapeChoice.selected ? root.style.selectedInk : root.style.ink
                            }
                            StyledText {
                                text: shapeChoice.modelData.title
                                color: shapeChoice.selected ? root.style.selectedInk : root.style.ink
                                font.pixelSize: Appearance.font.pixelSize.normal
                                font.weight: shapeChoice.selected ? Font.DemiBold : Font.Normal
                            }
                        }
                        onClicked: Config.options.bar.cornerStyle = shapeChoice.modelData.value
                    }
                }
            }
        }
    }

    MikoSurface {
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
                title: I18n.tr("Углы экрана")
                subtitle: I18n.tr("Имитация скругления углов дисплея")
            }

            GridLayout {
                Layout.fillWidth: true
                columns: width >= 560 ? 3 : 1
                columnSpacing: 8
                rowSpacing: 8

                Repeater {
                    model: [
                        { title: I18n.tr("Без скругления"), value: 0 },
                        { title: I18n.tr("Всегда"), value: 1 },
                        { title: I18n.tr("Не в полном экране"), value: 2 }
                    ]

                    delegate: MikoSurface {
                        id: cornersChoice
                        required property var modelData
                        readonly property bool selected:
                            Config.options.appearance.fakeScreenRounding === modelData.value

                        Layout.fillWidth: true
                        implicitHeight: 52
                        style: root.style
                        interactive: true
                        softAccent: selected

                        StyledText {
                            anchors.centerIn: parent
                            text: cornersChoice.modelData.title
                            color: cornersChoice.selected ? root.style.selectedInk : root.style.ink
                            font.pixelSize: Appearance.font.pixelSize.normal
                            font.weight: cornersChoice.selected ? Font.DemiBold : Font.Normal
                        }
                        onClicked:
                            Config.options.appearance.fakeScreenRounding = cornersChoice.modelData.value
                    }
                }
            }
        }
    }
}
