import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    required property var controller
    required property var style
    required property var wakeAll

    Layout.fillWidth: true
    spacing: 10

    RowLayout {
        Layout.fillWidth: true
        StyledText {
            Layout.fillWidth: true
            text: "Сцены экранов"
            color: root.style.ink
            font.pixelSize: Appearance.font.pixelSize.larger
            font.weight: Font.DemiBold
        }
        StyledText {
            text: "Не записывают глобальный конфиг"
            color: root.style.mutedInk
            font.pixelSize: Appearance.font.pixelSize.smaller
        }
    }

    GridLayout {
        Layout.fillWidth: true
        columns: width > 760 ? 3 : 1
        columnSpacing: 10
        rowSpacing: 10

        Repeater {
            model: [
                {
                    title: "Максимальная плавность",
                    subtitle: "Лучшая доступная герцовка",
                    icon: "speed",
                    action: "performance"
                },
                {
                    title: "Только текущий экран",
                    subtitle: "Остальные временно отключатся",
                    icon: "filter_1",
                    action: "single"
                },
                {
                    title: "Разбудить все",
                    subtitle: "Включить питание экранов",
                    icon: "wb_sunny",
                    action: "wake"
                }
            ]
            delegate: Rectangle {
                id: sceneCard
                required property var modelData
                Layout.fillWidth: true
                implicitHeight: 82
                radius: 22
                color: pointer.containsMouse
                    ? root.style.hoverSurface
                    : root.style.sectionSurface
                border.width: 1
                border.color: root.style.hairline
                antialiasing: true
                Behavior on color {
                    ColorAnimation { duration: root.style.motionFast }
                }
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 13
                    spacing: 11
                    MikoIconDisc {
                        style: root.style
                        icon: sceneCard.modelData.icon
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        StyledText {
                            Layout.fillWidth: true
                            text: sceneCard.modelData.title
                            color: root.style.ink
                            font.weight: Font.Medium
                            elide: Text.ElideRight
                        }
                        StyledText {
                            Layout.fillWidth: true
                            text: sceneCard.modelData.subtitle
                            color: root.style.mutedInk
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            elide: Text.ElideRight
                        }
                    }
                }
                MouseArea {
                    id: pointer
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
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
}
