import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    required property var controller
    required property var hyprlandData
    required property var style

    Layout.fillWidth: true
    spacing: 16

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 266
        radius: root.style.radiusWindow
        color: Qt.rgba(
            Appearance.colors.colPrimary.r,
            Appearance.colors.colPrimary.g,
            Appearance.colors.colPrimary.b,
            0.13
        )
        border.width: 1
        border.color: root.style.hairline
        antialiasing: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 13

            RowLayout {
                Layout.fillWidth: true
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0
                    StyledText {
                        text: "Рабочее пространство"
                        color: root.style.ink
                        font.pixelSize: Appearance.font.pixelSize.larger
                        font.weight: Font.DemiBold
                    }
                    StyledText {
                        text: root.hyprlandData.monitors.length
                            + " подключённых экрана · перетащи для расположения"
                        color: root.style.mutedInk
                        font.pixelSize: Appearance.font.pixelSize.smaller
                    }
                }
                MikoButton {
                    style: root.style
                    icon: "refresh"
                    text: "Обновить"
                    onClicked: root.controller.refresh()
                }
            }

            Item {
                id: topologyCanvas
                Layout.fillWidth: true
                Layout.fillHeight: true

                property var monitorBounds: root.controller.bounds()
                property real fitScale: Math.min(
                    Math.max(0.04, (width - 30) / monitorBounds.width),
                    Math.max(0.04, (height - 28) / monitorBounds.height)
                )

                Repeater {
                    model: root.hyprlandData.monitors
                    delegate: Rectangle {
                        id: monitorStage
                        required property var modelData
                        required property int index

                        x: (modelData.x - topologyCanvas.monitorBounds.minX)
                            * topologyCanvas.fitScale
                            + (topologyCanvas.width
                               - topologyCanvas.monitorBounds.width
                                   * topologyCanvas.fitScale) / 2
                        y: (modelData.y - topologyCanvas.monitorBounds.minY)
                            * topologyCanvas.fitScale + 6
                        width: Math.max(
                            116,
                            modelData.width * topologyCanvas.fitScale
                        )
                        height: Math.max(
                            72,
                            modelData.height * topologyCanvas.fitScale
                        )
                        radius: 16
                        color: root.controller.selectedIndex === index
                            ? root.style.selectedSurface
                            : root.style.sectionSurface
                        border.width:
                            root.controller.selectedIndex === index ? 0 : 1
                        border.color: root.style.hairline
                        antialiasing: true

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 1
                            StyledText {
                                Layout.alignment: Qt.AlignHCenter
                                text: monitorStage.modelData.name
                                color: root.controller.selectedIndex
                                    === monitorStage.index
                                    ? root.style.selectedInk : root.style.ink
                                font.pixelSize: Appearance.font.pixelSize.larger
                                font.weight: Font.DemiBold
                            }
                            StyledText {
                                Layout.alignment: Qt.AlignHCenter
                                text: monitorStage.modelData.width + " × "
                                    + monitorStage.modelData.height + " · "
                                    + Math.round(
                                        monitorStage.modelData.refreshRate
                                    ) + " Гц"
                                color: root.controller.selectedIndex
                                    === monitorStage.index
                                    ? Qt.rgba(
                                        root.style.selectedInk.r,
                                        root.style.selectedInk.g,
                                        root.style.selectedInk.b,
                                        0.72
                                    ) : root.style.mutedInk
                                font.pixelSize: Appearance.font.pixelSize.smaller
                            }
                            StyledText {
                                visible: monitorStage.modelData.focused
                                Layout.alignment: Qt.AlignHCenter
                                text: "СЕЙЧАС ЗДЕСЬ"
                                color: root.controller.selectedIndex
                                    === monitorStage.index
                                    ? root.style.selectedInk
                                    : root.style.mutedInk
                                font.pixelSize: Appearance.font.pixelSize.smallest
                                font.weight: Font.Bold
                            }
                        }

                        MouseArea {
                            property real pressX: 0
                            property real pressY: 0
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            drag.target: monitorStage
                            drag.axis: Drag.XAndYAxis
                            onPressed: {
                                pressX = monitorStage.x;
                                pressY = monitorStage.y;
                                root.controller.selectedIndex =
                                    monitorStage.index;
                            }
                            onClicked: root.controller.selectedIndex =
                                monitorStage.index
                            onReleased: {
                                if (Math.abs(monitorStage.x - pressX) < 4
                                        && Math.abs(
                                            monitorStage.y - pressY
                                        ) < 4)
                                    return;
                                const centeredX =
                                    (topologyCanvas.width
                                     - topologyCanvas.monitorBounds.width
                                         * topologyCanvas.fitScale) / 2;
                                const nextX = Math.round(
                                    (monitorStage.x - centeredX)
                                        / topologyCanvas.fitScale
                                        + topologyCanvas.monitorBounds.minX
                                );
                                const nextY = Math.round(
                                    (monitorStage.y - 6)
                                        / topologyCanvas.fitScale
                                        + topologyCanvas.monitorBounds.minY
                                );
                                root.controller.runPreview([
                                    "apply",
                                    monitorStage.modelData.name,
                                    "--position",
                                    nextX + "x" + nextY
                                ]);
                            }
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 116
        radius: 24
        color: root.style.sectionSurface
        border.width: 1
        border.color: root.style.hairline
        antialiasing: true

        RowLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 14
            MikoIconDisc {
                style: root.style
                icon: "desktop_windows"
                accented: true
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                StyledText {
                    Layout.fillWidth: true
                    text: root.controller.selectedMonitor()
                        ? (root.controller.selectedMonitor().model
                           || root.controller.selectedMonitor().description
                           || "Монитор")
                            + " · " + root.controller.selectedMonitor().name
                        : "Выбери экран"
                    color: root.style.ink
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }
                StyledText {
                    text: root.controller.selectedMonitor()
                        ? root.controller.selectedMonitor().width + " × "
                            + root.controller.selectedMonitor().height
                            + " · " + Math.round(
                                root.controller.selectedMonitor().refreshRate
                            ) + " Гц · масштаб "
                            + root.controller.selectedMonitor().scale
                        : "Нет данных"
                    color: root.style.mutedInk
                    font.pixelSize: Appearance.font.pixelSize.smaller
                }
            }
            MikoButton {
                style: root.style
                icon: "refresh"
                text: "Перечитать"
                onClicked: root.controller.refresh()
            }
        }
    }
}
