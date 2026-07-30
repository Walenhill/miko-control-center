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
    property bool checked: false
    property bool available: true
    property int iconRailWidth: 32
    property int controlRailWidth: 190
    property int contentWidth: 480
    signal toggled(bool checked)

    Layout.fillWidth: true
    implicitWidth: contentWidth
    implicitHeight: subtitle === "" ? 54 : 64
    opacity: available ? 1 : 0.42

    Behavior on opacity {
        NumberAnimation {
            duration: root.style.motionFast
            easing.type: Easing.OutCubic
        }
    }

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

        Item {
            Layout.preferredWidth: root.width >= 540 ? root.controlRailWidth : 112
            implicitHeight: 42

            StyledSwitch {
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
                enabled: root.available
                checked: root.checked
                onClicked: root.toggled(checked)
            }
        }
    }
}
