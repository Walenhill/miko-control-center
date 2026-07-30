import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

Rectangle {
    id: root

    required property var style
    property string icon: "warning"
    property string title: ""
    property string description: ""
    property string cancelText: "Отмена"
    property string confirmText: "Продолжить"
    property string confirmIcon: "check"

    signal cancelled()
    signal confirmed()

    color: Qt.rgba(0, 0, 0, 0.48)
    z: 200

    MouseArea {
        anchors.fill: parent
        onClicked: root.cancelled()
    }

    MikoSurface {
        anchors.centerIn: parent
        width: Math.min(520, root.width - 48)
        implicitHeight: dialogContent.implicitHeight + 42
        radius: root.style.radiusWindow
        style: root.style

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
        }

        ColumnLayout {
            id: dialogContent

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 21
            }
            spacing: 13

            MikoIconDisc {
                style: root.style
                icon: root.icon
                accented: true
            }
            StyledText {
                Layout.fillWidth: true
                text: root.title
                color: root.style.ink
                font.pixelSize: 23
                font.weight: Font.DemiBold
                wrapMode: Text.WordWrap
            }
            StyledText {
                Layout.fillWidth: true
                text: root.description
                color: root.style.mutedInk
                font.pixelSize: Appearance.font.pixelSize.smaller
                wrapMode: Text.WordWrap
            }
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 4

                Item {
                    Layout.fillWidth: true
                }
                MikoButton {
                    style: root.style
                    icon: "close"
                    text: root.cancelText
                    onClicked: root.cancelled()
                }
                MikoButton {
                    style: root.style
                    icon: root.confirmIcon
                    text: root.confirmText
                    onClicked: root.confirmed()
                }
            }
        }
    }
}
