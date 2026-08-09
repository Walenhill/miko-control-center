import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import qs.modules.common
import qs.modules.common.widgets

Item {
    id: root

    required property var operations
    required property var style
    required property Item blurSource

    visible: operations.drawerOpen
    z: 120

    ShaderEffectSource {
        id: backgroundCapture
        anchors.fill: parent
        sourceItem: root.blurSource
        sourceRect: Qt.rect(
            0, 0, root.blurSource.width, root.blurSource.height
        )
        hideSource: false
        live: root.visible
        visible: false
    }

    FastBlur {
        anchors.fill: parent
        source: backgroundCapture
        radius: 36
        transparentBorder: false
        cached: false
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.18)
        opacity: root.visible ? 1 : 0

        MouseArea {
            anchors.fill: parent
            onClicked: root.operations.drawerOpen = false
        }
    }

    Rectangle {
        id: panel
        anchors {
            top: parent.top
            right: parent.right
            bottom: parent.bottom
            margins: 12
        }
        width: Math.min(430, parent.width - 32)
        radius: root.style.radiusWindow
        color: Qt.rgba(
            root.style.windowSurface.r,
            root.style.windowSurface.g,
            root.style.windowSurface.b,
            0.94
        )
        border.width: 1
        border.color: root.style.strongHairline
        antialiasing: true

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
        }

        ColumnLayout {
            anchors {
                fill: parent
                margins: 18
            }
            spacing: 12

            RowLayout {
                Layout.fillWidth: true
                StyledText {
                    Layout.fillWidth: true
                    text: "Операции"
                    color: root.style.ink
                    font.pixelSize: Appearance.font.pixelSize.large
                    font.weight: Font.DemiBold
                }
                StyledText {
                    visible: root.operations.activeCount > 0
                    text: root.operations.activeCount + " выполняется"
                    color: root.style.mutedInk
                    font.pixelSize: Appearance.font.pixelSize.smaller
                }
                MikoButton {
                    style: root.style
                    icon: "close"
                    onClicked: root.operations.drawerOpen = false
                }
            }

            StyledText {
                visible: root.operations.tasks.length === 0
                Layout.fillWidth: true
                Layout.fillHeight: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: "Активных и недавних операций нет"
                color: root.style.mutedInk
                font.pixelSize: Appearance.font.pixelSize.small
            }

            Flickable {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: root.operations.tasks.length > 0
                contentHeight: taskColumn.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                ColumnLayout {
                    id: taskColumn
                    width: parent.width
                    spacing: 9

                    Repeater {
                        model: root.operations.tasks

                        delegate: MikoSurface {
                            required property var modelData
                            style: root.style
                            Layout.fillWidth: true
                            implicitHeight: taskContent.implicitHeight + 28

                            ColumnLayout {
                                id: taskContent
                                anchors {
                                    fill: parent
                                    margins: 14
                                }
                                spacing: 7

                                RowLayout {
                                    Layout.fillWidth: true
                                    MaterialSymbol {
                                        text: modelData.state === "running"
                                            ? "progress_activity"
                                            : modelData.state === "success"
                                                ? "check_circle" : "error"
                                        iconSize: 20
                                        color: modelData.state === "error"
                                            ? Appearance.colors.colError
                                            : Appearance.colors.colPrimary
                                    }
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 1
                                        StyledText {
                                            Layout.fillWidth: true
                                            text: modelData.title
                                            color: root.style.ink
                                            font.weight: Font.Medium
                                            elide: Text.ElideRight
                                        }
                                        StyledText {
                                            Layout.fillWidth: true
                                            text: modelData.subtitle || "Выполняется…"
                                            color: root.style.mutedInk
                                            font.pixelSize: Appearance.font.pixelSize.smaller
                                            wrapMode: Text.WordWrap
                                        }
                                    }
                                    MikoButton {
                                        visible: modelData.state !== "running"
                                        style: root.style
                                        icon: "close"
                                        onClicked: root.operations.remove(modelData.key)
                                    }
                                }

                                Rectangle {
                                    id: progressTrack
                                    visible: modelData.state === "running"
                                    Layout.fillWidth: true
                                    implicitHeight: 4
                                    radius: 2
                                    color: root.style.controlSurface
                                    Rectangle {
                                        id: progressFill
                                        width: modelData.progress >= 0
                                            ? parent.width * modelData.progress
                                            : parent.width * 0.34
                                        height: parent.height
                                        radius: parent.radius
                                        color: Appearance.colors.colPrimary
                                        SequentialAnimation on x {
                                            running: modelData.progress < 0
                                            loops: Animation.Infinite
                                            NumberAnimation { from: 0; to: Math.max(0, progressTrack.width - progressFill.width); duration: 900 }
                                            NumberAnimation { from: Math.max(0, progressTrack.width - progressFill.width); to: 0; duration: 900 }
                                        }
                                    }
                                }

                                StyledText {
                                    visible: modelData.details !== ""
                                    Layout.fillWidth: true
                                    text: modelData.details
                                    color: root.style.mutedInk
                                    font.family: "monospace"
                                    font.pixelSize: Appearance.font.pixelSize.smallest
                                    wrapMode: Text.WrapAnywhere
                                    maximumLineCount: 5
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                visible: root.operations.tasks.some(task => task.state !== "running")
                Item { Layout.fillWidth: true }
                MikoButton {
                    style: root.style
                    icon: "delete_sweep"
                    text: "Очистить завершённые"
                    onClicked: root.operations.clearFinished()
                }
            }
        }
    }
}
