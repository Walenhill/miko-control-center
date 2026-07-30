import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

GridLayout {
    id: root

    required property var controller
    required property var style

    Layout.fillWidth: true
    columns: width > 820 ? 2 : 1
    columnSpacing: 12
    rowSpacing: 12

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: modeContent.implicitHeight + 32
        radius: root.style.radiusSection
        color: root.style.sectionSurface
        border.width: 1
        border.color: root.style.hairline

        ColumnLayout {
            id: modeContent
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 16
            }
            spacing: 10
            RowLayout {
                Layout.fillWidth: true
                MikoIconDisc {
                    style: root.style
                    icon: "display_settings"
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0
                    StyledText {
                        text: "Режим и герцовка"
                        color: root.style.ink
                        font.weight: Font.DemiBold
                    }
                    StyledText {
                        text: "Временно, с автоматическим откатом"
                        color: root.style.mutedInk
                        font.pixelSize: Appearance.font.pixelSize.smaller
                    }
                }
            }
            Flow {
                Layout.fillWidth: true
                spacing: 7
                Repeater {
                    model: root.controller.selectedMonitor()
                        ? root.controller.selectedMonitor().availableModes
                            .filter((item, index, values) =>
                                values.indexOf(item) === index
                            ).slice(0, 8)
                        : []
                    MikoButton {
                        required property string modelData
                        style: root.style
                        icon: ""
                        text: modelData.replace("Hz", "")
                        onClicked: root.controller.runPreview([
                            "apply",
                            root.controller.selectedMonitor().name,
                            "--mode",
                            modelData.replace("Hz", "")
                        ])
                    }
                }
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: scaleContent.implicitHeight + 32
        radius: root.style.radiusSection
        color: root.style.sectionSurface
        border.width: 1
        border.color: root.style.hairline

        ColumnLayout {
            id: scaleContent
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 16
            }
            spacing: 10
            RowLayout {
                Layout.fillWidth: true
                MikoIconDisc {
                    style: root.style
                    icon: "zoom_out_map"
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0
                    StyledText {
                        text: "Масштаб и ориентация"
                        color: root.style.ink
                        font.weight: Font.DemiBold
                    }
                    StyledText {
                        text: "Сейчас "
                            + (root.controller.selectedMonitor()?.scale ?? 1)
                            + "×"
                        color: root.style.mutedInk
                        font.pixelSize: Appearance.font.pixelSize.smaller
                    }
                }
            }
            Flow {
                Layout.fillWidth: true
                spacing: 7
                Repeater {
                    model: [0.75, 1, 1.25, 1.5, 2]
                    MikoButton {
                        required property real modelData
                        style: root.style
                        icon: ""
                        text: modelData + "×"
                        enabled: root.controller.selectedMonitor() !== null
                        onClicked: root.controller.runPreview([
                            "apply",
                            root.controller.selectedMonitor().name,
                            "--scale",
                            String(modelData)
                        ])
                    }
                }
            }
            RowLayout {
                Layout.fillWidth: true
                MikoButton {
                    Layout.fillWidth: true
                    style: root.style
                    icon: "screen_rotation"
                    text: "Альбомная"
                    enabled: root.controller.selectedMonitor() !== null
                    onClicked: root.controller.runPreview([
                        "apply",
                        root.controller.selectedMonitor().name,
                        "--transform",
                        "0"
                    ])
                }
                MikoButton {
                    Layout.fillWidth: true
                    style: root.style
                    icon: "screen_rotation"
                    text: "Портретная"
                    enabled: root.controller.selectedMonitor() !== null
                    onClicked: root.controller.runPreview([
                        "apply",
                        root.controller.selectedMonitor().name,
                        "--transform",
                        "1"
                    ])
                }
            }
        }
    }
}
