import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

MikoSurface {
    id: root

    required property var style
    required property string title
    property string subtitle: ""
    property string icon: "tune"
    property bool active: false
    property bool available: true

    Layout.fillWidth: true
    implicitHeight: 72
    interactive: root.available
    softAccent: root.active
    opacity: available ? 1 : 0.44

    RowLayout {
        anchors {
            fill: parent
            leftMargin: 14
            rightMargin: 14
        }
        spacing: 12

        MikoIconDisc {
            style: root.style
            icon: root.icon
            accented: root.active
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            spacing: 2

            StyledText {
                Layout.fillWidth: true
                text: root.title
                color: root.style.ink
                font.pixelSize: Appearance.font.pixelSize.normal
                font.weight: root.active ? Font.DemiBold : Font.Medium
                elide: Text.ElideRight
            }

            StyledText {
                visible: root.subtitle !== ""
                Layout.fillWidth: true
                text: root.subtitle
                color: root.style.mutedInk
                font.pixelSize: Appearance.font.pixelSize.smaller
                elide: Text.ElideRight
            }
        }
    }

    Keys.onPressed: event => {
        if (!root.available)
            return;
        if (event.key === Qt.Key_Return
                || event.key === Qt.Key_Enter
                || event.key === Qt.Key_Space) {
            root.clicked();
            event.accepted = true;
        }
    }
}
