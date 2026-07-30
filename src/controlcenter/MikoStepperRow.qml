import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

Item {
    id: root

    required property var style
    required property string title
    property string subtitle: ""
    property string icon: "tune"
    property real value: 0
    property real step: 1
    property real minimum: 0
    property real maximum: 100
    property string suffix: ""
    property int iconRailWidth: 32
    property int controlRailWidth: 190
    property int contentWidth: 480
    signal changed(real value)

    Layout.fillWidth: true
    implicitWidth: contentWidth
    implicitHeight: subtitle === "" ? 54 : 64

    RowLayout {
        anchors.fill: parent
        spacing: 12

        Item {
            Layout.preferredWidth: root.iconRailWidth
            Layout.fillHeight: true
            MaterialSymbol {
                anchors.centerIn: parent
                text: root.icon
                iconSize: 20
                color: root.style.mutedInk
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            spacing: 0
            StyledText {
                Layout.fillWidth: true
                text: root.title
                color: root.style.ink
                font.pixelSize: Appearance.font.pixelSize.small
                font.weight: Font.Medium
                elide: Text.ElideRight
            }
            StyledText {
                Layout.fillWidth: true
                visible: root.subtitle !== ""
                text: root.subtitle
                color: root.style.mutedInk
                font.pixelSize: Appearance.font.pixelSize.smaller
                elide: Text.ElideRight
            }
        }

        Rectangle {
            Layout.preferredWidth: root.width >= 540 ? root.controlRailWidth : 146
            implicitHeight: 42
            radius: Appearance.rounding.full
            color: root.style.controlSurface
            antialiasing: true

            RowLayout {
                anchors.fill: parent
                spacing: 0

                Rectangle {
                    Layout.preferredWidth: 44
                    Layout.fillHeight: true
                    radius: Appearance.rounding.full
                    color: minus.pressed ? root.style.activeSurface
                        : minus.containsMouse ? root.style.hoverSurface : "transparent"
                    MaterialSymbol {
                        anchors.centerIn: parent
                        text: "remove"
                        iconSize: 18
                        color: root.style.ink
                    }
                    MouseArea {
                        id: minus
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.changed(Math.max(
                            root.minimum, root.value - root.step
                        ))
                    }
                }

                StyledText {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: Math.round(root.value * 100) / 100 + root.suffix
                    color: root.style.ink
                    font.pixelSize: Appearance.font.pixelSize.small
                    font.weight: Font.DemiBold
                }

                Rectangle {
                    Layout.preferredWidth: 44
                    Layout.fillHeight: true
                    radius: Appearance.rounding.full
                    color: plus.pressed ? root.style.activeSurface
                        : plus.containsMouse ? root.style.hoverSurface : "transparent"
                    MaterialSymbol {
                        anchors.centerIn: parent
                        text: "add"
                        iconSize: 18
                        color: root.style.ink
                    }
                    MouseArea {
                        id: plus
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.changed(Math.min(
                            root.maximum, root.value + root.step
                        ))
                    }
                }
            }
        }
    }
}
