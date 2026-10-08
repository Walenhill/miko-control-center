import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    property var style: null
    readonly property var ui: style ? style : DefaultStyle

    required property var controller
    required property var wakeAll

    Layout.fillWidth: true
    spacing: 12

    MikoSectionHeader {
        style: root.ui
        title: I18n.tr("Быстрые сцены")
        subtitle: I18n.tr("Временные профили отображения без изменения постоянного конфига")
    }

    GridLayout {
        Layout.fillWidth: true
        columns: width > 760 ? 3 : 1
        columnSpacing: 12
        rowSpacing: 12

        Repeater {
            model: [
                {
                    title: I18n.tr("Макс. плавность"),
                    subtitle: I18n.tr("Лучшая доступная герцовка"),
                    icon: "speed",
                    action: "performance"
                },
                {
                    title: I18n.tr("Один экран"),
                    subtitle: I18n.tr("Остальные отключатся"),
                    icon: "filter_1",
                    action: "single"
                },
                {
                    title: I18n.tr("Разбудить все"),
                    subtitle: I18n.tr("Включить питание дисплеев"),
                    icon: "wb_sunny",
                    action: "wake"
                }
            ]
            delegate: MikoSurface {
                id: sceneCard
                required property var modelData
                Layout.fillWidth: true
                implicitHeight: 84
                style: root.ui
                interactive: true

                RowLayout {
                    anchors {
                        fill: parent
                        margins: 14
                    }
                    spacing: 12

                    MikoIconDisc {
                        style: root.ui
                        icon: sceneCard.modelData.icon
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        StyledText {
                            Layout.fillWidth: true
                            text: sceneCard.modelData.title
                            color: root.ui.ink
                            font.weight: Font.DemiBold
                            font.pixelSize: Appearance.font.pixelSize.normal
                            elide: Text.ElideRight
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: sceneCard.modelData.subtitle
                            color: root.ui.mutedInk
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            elide: Text.ElideRight
                        }
                    }

                    MaterialSymbol {
                        text: "arrow_forward"
                        iconSize: 18
                        color: root.ui.mutedInk
                        Layout.alignment: Qt.AlignVCenter
                    }
                }

                onClicked: {
                    if (sceneCard.modelData.action === "wake")
                        root.wakeAll();
                    else
                        root.controller.runPreview([
                            "scene",
                            sceneCard.modelData.action
                        ]);
                }
            }
        }
    }
}
