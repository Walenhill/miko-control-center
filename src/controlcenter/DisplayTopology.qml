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

    MikoSectionHeader {
        style: root.style
        title: I18n.tr("Топология мониторов")
        subtitle: I18n.tr("Перетащите экраны мышью для настройки взаимного расположения")
        badgeText: (root.hyprlandData.monitors && root.hyprlandData.monitors.length > 0)
            ? String(root.hyprlandData.monitors.length) + I18n.tr(" экрана") : ""
        actionText: I18n.tr("Обновить")
        actionIcon: "refresh"
        onActionClicked: root.controller.refresh()
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 260
        radius: root.style.radiusSection
        color: root.style.sectionSurface
        border.width: 1
        border.color: root.style.hairline
        antialiasing: true

        Item {
            id: topologyCanvas
            anchors.fill: parent
            anchors.margins: 16

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

                    readonly property bool isSelected: root.controller.selectedIndex === index

                    x: (modelData.x - topologyCanvas.monitorBounds.minX)
                        * topologyCanvas.fitScale
                        + (topologyCanvas.width
                           - topologyCanvas.monitorBounds.width
                               * topologyCanvas.fitScale) / 2
                    y: (modelData.y - topologyCanvas.monitorBounds.minY)
                        * topologyCanvas.fitScale + 6
                    width: Math.max(
                        124,
                        modelData.width * topologyCanvas.fitScale
                    )
                    height: Math.max(
                        78,
                        modelData.height * topologyCanvas.fitScale
                    )
                    radius: root.style.radiusControl
                    color: isSelected
                        ? (root.style.selectedCardBackground ? root.style.selectedCardBackground : Qt.rgba(Appearance.colors.colPrimary.r, Appearance.colors.colPrimary.g, Appearance.colors.colPrimary.b, 0.15))
                        : root.style.cardSurface
                    border.width: isSelected ? 2 : 1
                    border.color: isSelected
                        ? (root.style.selectedCardBorder ? root.style.selectedCardBorder : Appearance.colors.colPrimary)
                        : root.style.hairline
                    antialiasing: true

                    Behavior on color {
                        ColorAnimation { duration: root.style.motionFast }
                    }
                    Behavior on border.color {
                        ColorAnimation { duration: root.style.motionFast }
                    }

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 3

                        StyledText {
                            Layout.alignment: Qt.AlignHCenter
                            text: monitorStage.modelData.name
                            color: monitorStage.isSelected ? root.style.ink : root.style.mutedInk
                            font.pixelSize: Appearance.font.pixelSize.normal
                            font.weight: Font.DemiBold
                        }
                        StyledText {
                            Layout.alignment: Qt.AlignHCenter
                            text: monitorStage.modelData.width + "×"
                                + monitorStage.modelData.height + " · "
                                + Math.round(
                                    monitorStage.modelData.refreshRate
                                ) + I18n.tr(" Гц")
                            color: root.style.mutedInk
                            font.pixelSize: Appearance.font.pixelSize.smaller
                        }
                        MikoBadge {
                            visible: Boolean(monitorStage.modelData.focused)
                            Layout.alignment: Qt.AlignHCenter
                            style: root.style
                            text: I18n.tr("В фокусе")
                            tone: "accent"
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
                            root.controller.selectedIndex = monitorStage.index;
                        }
                        onClicked: root.controller.selectedIndex = monitorStage.index
                        onReleased: {
                            if (Math.abs(monitorStage.x - pressX) < 4
                                    && Math.abs(monitorStage.y - pressY) < 4)
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

    // Selected Monitor Card
    MikoSectionHeader {
        style: root.style
        title: I18n.tr("Выбранный экран")
        badgeText: (root.controller.selectedMonitor() && root.controller.selectedMonitor().name)
            ? root.controller.selectedMonitor().name : ""
    }

    MikoSurface {
        Layout.fillWidth: true
        style: root.style

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 14

            RowLayout {
                Layout.fillWidth: true
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
                        text: (root.controller.selectedMonitor() && (root.controller.selectedMonitor().model || root.controller.selectedMonitor().description))
                            ? (root.controller.selectedMonitor().model || root.controller.selectedMonitor().description)
                            : I18n.tr("Выбери экран")
                        color: root.style.ink
                        font.pixelSize: Appearance.font.pixelSize.larger
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                    }

                    StyledText {
                        text: (root.controller.selectedMonitor() && root.controller.selectedMonitor().make)
                            ? root.controller.selectedMonitor().make
                            : I18n.tr("Монитор дисплея")
                        color: root.style.mutedInk
                        font.pixelSize: Appearance.font.pixelSize.smaller
                    }
                }
            }

            // Chips / Badges row for selected monitor properties
            Flow {
                Layout.fillWidth: true
                spacing: 8

                MikoBadge {
                    style: root.style
                    icon: "aspect_ratio"
                    text: (root.controller.selectedMonitor() && root.controller.selectedMonitor().width)
                        ? (root.controller.selectedMonitor().width + " × " + root.controller.selectedMonitor().height)
                        : ""
                    tone: "neutral"
                }

                MikoBadge {
                    style: root.style
                    icon: "speed"
                    text: (root.controller.selectedMonitor() && root.controller.selectedMonitor().refreshRate)
                        ? (Math.round(root.controller.selectedMonitor().refreshRate) + I18n.tr(" Гц"))
                        : ""
                    tone: "accent"
                }

                MikoBadge {
                    style: root.style
                    icon: "zoom_in"
                    text: (root.controller.selectedMonitor() && root.controller.selectedMonitor().scale !== undefined)
                        ? (I18n.tr("Масштаб ") + root.controller.selectedMonitor().scale + "×")
                        : ""
                    tone: "neutral"
                }

                MikoBadge {
                    style: root.style
                    icon: "place"
                    text: (root.controller.selectedMonitor() && root.controller.selectedMonitor().x !== undefined)
                        ? ("X: " + root.controller.selectedMonitor().x + " · Y: " + root.controller.selectedMonitor().y)
                        : ""
                    tone: "neutral"
                }

                MikoBadge {
                    visible: Boolean(root.controller.selectedMonitor() && root.controller.selectedMonitor().focused)
                    style: root.style
                    icon: "check_circle"
                    text: I18n.tr("В фокусе")
                    tone: "success"
                }
            }
        }
    }
}
