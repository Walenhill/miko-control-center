import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    property var style: null
    readonly property var ui: style ? style : DefaultStyle

    required property var applications
    required property int selectedPid
    required property string actionMessage
    required property bool actionRunning

    signal selectionRequested(int pid)
    signal stopRequested(int pid)
    signal refreshRequested()

    Layout.fillWidth: true
    spacing: 14

    MikoSectionHeader {
        style: root.ui
        title: I18n.tr("Активные процессы")
        subtitle: I18n.tr("Сортировка по нагрузке · обновление каждые 3 секунды")

        MikoButton {
            style: root.ui
            icon: "refresh"
            text: I18n.tr("Обновить")
            onClicked: root.refreshRequested()
        }
    }

    MikoSurface {
        visible: root.actionMessage !== ""
        style: root.ui
        softAccent: true
        Layout.fillWidth: true
        implicitHeight: 48

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 10

            MaterialSymbol {
                text: root.actionRunning ? "progress_activity" : "check_circle"
                iconSize: 19
                color: root.ui.selectedSurface
            }
            StyledText {
                Layout.fillWidth: true
                text: root.actionMessage
                color: root.ui.ink
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
            readonly property bool isSelected: root.selectedPid === modelData.pid

            style: root.ui
            softAccent: isSelected
            Layout.fillWidth: true
            implicitHeight: isSelected ? 124 : 68
            clip: true

            Behavior on implicitHeight {
                NumberAnimation {
                    duration: root.ui.motionNormal
                    easing.type: Easing.OutCubic
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                anchors.topMargin: 10
                anchors.bottomMargin: 10
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    MikoIconDisc {
                        style: root.ui
                        icon: "terminal"
                        accented: Number(appCard.modelData.cpu) >= 15
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.minimumWidth: 0
                        spacing: 1

                        StyledText {
                            Layout.fillWidth: true
                            text: appCard.modelData.command
                            color: root.ui.ink
                            font.pixelSize: Appearance.font.pixelSize.small
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                        }
                        StyledText {
                            text: "PID " + appCard.modelData.pid
                            color: root.ui.mutedInk
                            font.pixelSize: Appearance.font.pixelSize.smaller
                        }
                    }

                    MikoBadge {
                        style: root.ui
                        text: Number(appCard.modelData.cpu).toFixed(1) + "% CPU"
                        icon: "memory"
                        tone: Number(appCard.modelData.cpu) >= 15 ? "warning" : "neutral"
                    }

                    MikoBadge {
                        style: root.ui
                        text: Number(appCard.modelData.memory).toFixed(1) + "% RAM"
                        icon: "storage"
                        tone: "neutral"
                    }

                    MaterialSymbol {
                        text: appCard.isSelected ? "expand_less" : "expand_more"
                        iconSize: 20
                        color: root.ui.mutedInk
                    }
                }

                Rectangle {
                    visible: appCard.isSelected
                    Layout.fillWidth: true
                    height: 1
                    color: root.ui.hairline
                }

                RowLayout {
                    visible: appCard.isSelected
                    Layout.fillWidth: true
                    spacing: 10

                    MaterialSymbol {
                        text: "info"
                        iconSize: 17
                        color: root.ui.mutedInk
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: I18n.tr("Отправляет сигнал SIGTERM для штатного завершения")
                        color: root.ui.mutedInk
                        font.pixelSize: Appearance.font.pixelSize.smaller
                    }

                    MikoButton {
                        style: root.ui
                        icon: "close"
                        text: I18n.tr("Завершить")
                        onClicked: root.stopRequested(appCard.modelData.pid)
                    }
                }
            }

            MouseArea {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                height: 68
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.selectionRequested(
                    appCard.isSelected ? -1 : appCard.modelData.pid
                )
            }
        }
    }

    MikoSurface {
        visible: !root.applications || root.applications.length === 0
        style: root.ui
        Layout.fillWidth: true
        implicitHeight: 88

        RowLayout {
            anchors.centerIn: parent
            spacing: 10

            MaterialSymbol {
                text: "hourglass_empty"
                iconSize: 22
                color: root.ui.mutedInk
            }
            StyledText {
                text: I18n.tr("Список процессов загружается…")
                color: root.ui.mutedInk
                font.pixelSize: Appearance.font.pixelSize.small
            }
        }
    }
}
