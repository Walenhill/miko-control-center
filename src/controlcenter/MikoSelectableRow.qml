import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

Item {
    id: root

    property var style: null
    readonly property var ui: style ? style : DefaultStyle

    required property string title
    property string subtitle: ""
    property string icon: ""
    property bool selected: false
    property bool available: true
    property int rowHeight: subtitle === "" ? 48 : 58
    default property alias trailingData: trailing.data
    signal clicked()

    Layout.fillWidth: true
    implicitHeight: rowHeight
    opacity: available ? 1 : 0.42
    activeFocusOnTab: available

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: root.ui.radiusControl
        color: root.selected
            ? (pointer.pressed ? root.ui.selectedCardHover : (pointer.containsMouse ? root.ui.selectedCardHover : root.ui.selectedCardBackground))
            : (pointer.pressed ? root.ui.activeSurface : (pointer.containsMouse ? root.ui.hoverSurface : "transparent"))
        border.width: root.activeFocus ? 2 : (root.selected ? 1 : 0)
        border.color: root.activeFocus
            ? root.ui.focusRing
            : (root.selected ? root.ui.selectedCardBorder : "transparent")
        antialiasing: true

        Behavior on color {
            ColorAnimation {
                duration: root.ui.motionFast
                easing.type: Easing.OutCubic
            }
        }
        Behavior on border.color {
            ColorAnimation {
                duration: root.ui.motionFast
                easing.type: Easing.OutCubic
            }
        }
    }

    RowLayout {
        anchors {
            fill: parent
            leftMargin: 12
            rightMargin: 12
        }
        spacing: 11

        MaterialSymbol {
            visible: root.icon !== ""
            text: root.icon
            iconSize: 20
            color: root.selected ? root.ui.selectedSurface : root.ui.mutedInk
            Layout.alignment: Qt.AlignVCenter

            Behavior on color {
                ColorAnimation {
                    duration: root.ui.motionFast
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            spacing: 0
            Layout.alignment: Qt.AlignVCenter

            StyledText {
                Layout.fillWidth: true
                text: root.title
                color: root.ui.ink
                font.pixelSize: Appearance.font.pixelSize.small
                font.weight: root.selected ? Font.DemiBold : Font.Normal
                elide: Text.ElideRight
            }

            StyledText {
                Layout.fillWidth: true
                visible: root.subtitle !== ""
                text: root.subtitle
                color: root.ui.mutedInk
                font.pixelSize: Appearance.font.pixelSize.smaller
                elide: Text.ElideRight
            }
        }

        RowLayout {
            id: trailing
            spacing: 6
            Layout.alignment: Qt.AlignVCenter
        }

        MaterialSymbol {
            visible: root.selected
            text: "check_circle"
            iconSize: 19
            color: root.ui.selectedSurface
            Layout.alignment: Qt.AlignVCenter

            Behavior on opacity {
                NumberAnimation { duration: root.ui.motionFast }
            }
        }
    }

    MouseArea {
        id: pointer
        anchors.fill: parent
        enabled: root.available
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
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
