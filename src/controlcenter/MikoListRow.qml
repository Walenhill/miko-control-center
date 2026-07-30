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
    property string value: ""
    property bool showChevron: false
    property bool dividerVisible: true
    property bool interactive: false
    property bool available: true
    property int rowHeight: subtitle === "" ? 58 : 68
    default property alias trailingData: trailing.data
    signal clicked()

    Layout.fillWidth: true
    implicitHeight: rowHeight
    opacity: available ? 1 : 0.42
    activeFocusOnTab: interactive && available

    Rectangle {
        anchors.fill: parent
        radius: root.style.radiusControl
        color: pointer.pressed
            ? root.style.activeSurface
            : pointer.containsMouse && root.interactive
                ? root.style.hoverSurface : "transparent"
        border.width: root.activeFocus ? 2 : 0
        border.color: root.style.focusRing

        Behavior on color {
            ColorAnimation {
                duration: root.style.motionFast
                easing.type: Easing.OutCubic
            }
        }
    }

    RowLayout {
        anchors {
            fill: parent
            leftMargin: 10
            rightMargin: 10
        }
        spacing: 13

        Item {
            Layout.preferredWidth: 32
            Layout.fillHeight: true
            MaterialSymbol {
                anchors.centerIn: parent
                text: root.icon
                iconSize: 21
                color: root.style.mutedInk
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            spacing: 1
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

        StyledText {
            visible: root.value !== ""
            text: root.value
            color: root.style.ink
            font.pixelSize: Appearance.font.pixelSize.small
            font.weight: Font.DemiBold
        }

        RowLayout {
            id: trailing
            spacing: 6
        }

        MaterialSymbol {
            visible: root.showChevron
            text: "arrow_forward"
            iconSize: 19
            color: root.style.mutedInk
        }
    }

    Rectangle {
        visible: root.dividerVisible
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: 52
            rightMargin: 4
        }
        height: 1
        color: root.style.hairline
    }

    MouseArea {
        id: pointer
        anchors.fill: parent
        enabled: root.interactive && root.available
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onPressed: root.forceActiveFocus()
        onClicked: root.clicked()
    }

    Keys.onPressed: event => {
        if (!root.interactive || !root.available)
            return;
        if (event.key === Qt.Key_Return
                || event.key === Qt.Key_Enter
                || event.key === Qt.Key_Space) {
            root.clicked();
            event.accepted = true;
        }
    }
}
