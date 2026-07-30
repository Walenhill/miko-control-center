import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    required property var style
    required property var applications
    required property int selectedPid
    required property string actionMessage
    required property bool actionRunning

    signal selectionRequested(int pid)
    signal stopRequested(int pid)

    Layout.fillWidth: true
    spacing: 10

    RowLayout {
        Layout.fillWidth: true

        StyledText {
            Layout.fillWidth: true
            text: "Сейчас запущено"
            color: root.style.ink
            font.pixelSize: Appearance.font.pixelSize.larger
            font.weight: Font.DemiBold
        }
        StyledText {
            text: "Обновляется каждые 3 секунды"
            color: root.style.mutedInk
            font.pixelSize: Appearance.font.pixelSize.smaller
        }
    }

    MikoSurface {
        visible: root.actionMessage !== ""
        style: root.style
        Layout.fillWidth: true
        implicitHeight: 48

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 13
            anchors.rightMargin: 13
            spacing: 9

            MaterialSymbol {
                text: root.actionRunning ? "progress_activity" : "check_circle"
                iconSize: 19
                color: root.style.selectedSurface
            }
            StyledText {
                Layout.fillWidth: true
                text: root.actionMessage
                color: root.style.ink
                font.pixelSize: Appearance.font.pixelSize.small
                font.weight: Font.Medium
                elide: Text.ElideRight
            }
        }
    }

    Repeater {
        model: root.applications

        delegate: MikoSurface {
            id: appCard

            required property var modelData
            readonly property bool selected: root.selectedPid === modelData.pid

            style: root.style
            accented: selected
            Layout.fillWidth: true
            implicitHeight: selected ? 112 : 72
            clip: true

            Behavior on implicitHeight {
                NumberAnimation {
                    duration: root.style.motionNormal
                    easing.type: Easing.OutCubic
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                anchors.topMargin: 10
                anchors.bottomMargin: 10
                spacing: 7

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    MikoIconDisc {
                        style: root.style
                        icon: "apps"
                        accented: Number(appCard.modelData.cpu) >= 20
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.minimumWidth: 0
                        spacing: 0

                        StyledText {
                            Layout.fillWidth: true
                            text: appCard.modelData.command
                            color: root.style.ink
                            font.pixelSize: Appearance.font.pixelSize.small
                            font.weight: Font.Medium
                            elide: Text.ElideRight
                        }
                        StyledText {
                            text: "PID " + appCard.modelData.pid
                            color: root.style.mutedInk
                            font.pixelSize: Appearance.font.pixelSize.smaller
                        }
                    }
                    ColumnLayout {
                        spacing: 0

                        StyledText {
                            text: Number(appCard.modelData.cpu).toFixed(1) + "%"
                            color: root.style.ink
                            font.pixelSize: Appearance.font.pixelSize.small
                            font.weight: Font.DemiBold
                        }
                        StyledText {
                            text: "CPU"
                            color: root.style.mutedInk
                            font.pixelSize: Appearance.font.pixelSize.smaller
                        }
                    }
                    ColumnLayout {
                        spacing: 0

                        StyledText {
                            text: Number(appCard.modelData.memory).toFixed(1) + "%"
                            color: root.style.ink
                            font.pixelSize: Appearance.font.pixelSize.small
                            font.weight: Font.DemiBold
                        }
                        StyledText {
                            text: "RAM"
                            color: root.style.mutedInk
                            font.pixelSize: Appearance.font.pixelSize.smaller
                        }
                    }
                    MaterialSymbol {
                        text: appCard.selected ? "expand_less" : "expand_more"
                        iconSize: 20
                        color: root.style.mutedInk
                    }
                }

                RowLayout {
                    visible: appCard.selected
                    Layout.fillWidth: true
                    Layout.leftMargin: 56
                    spacing: 8

                    StyledText {
                        Layout.fillWidth: true
                        text: "Сначала отправится обычный SIGTERM"
                        color: root.style.mutedInk
                        font.pixelSize: Appearance.font.pixelSize.smaller
                    }
                    MikoButton {
                        style: root.style
                        icon: "close"
                        text: "Завершить"
                        onClicked: root.stopRequested(appCard.modelData.pid)
                    }
                }
            }

            MouseArea {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                height: 72
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.selectionRequested(
                    appCard.selected ? -1 : appCard.modelData.pid
                )
            }
        }
    }

    MikoSurface {
        visible: root.applications.length === 0
        style: root.style
        Layout.fillWidth: true
        implicitHeight: 76

        RowLayout {
            anchors.centerIn: parent
            spacing: 9

            MaterialSymbol {
                text: "hourglass_empty"
                iconSize: 20
                color: root.style.mutedInk
            }
            StyledText {
                text: "Список процессов загружается…"
                color: root.style.mutedInk
                font.pixelSize: Appearance.font.pixelSize.small
            }
        }
    }
}
