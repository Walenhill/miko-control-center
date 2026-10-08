import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

RowLayout {
    id: root

    property var style: null
    readonly property var ui: style ? style : DefaultStyle

    required property string title
    property string subtitle: ""
    property string badgeText: ""
    property string actionText: ""
    property string actionIcon: ""
    property bool actionEnabled: true
    signal actionClicked()

    default property alias trailingData: trailingContainer.data

    Layout.fillWidth: true
    Layout.topMargin: 4
    Layout.bottomMargin: 2
    spacing: 12

    ColumnLayout {
        Layout.fillWidth: true
        Layout.minimumWidth: 0
        spacing: 1

        StyledText {
            Layout.fillWidth: true
            text: root.title
            color: root.ui.ink
            font.pixelSize: Appearance.font.pixelSize.larger
            font.weight: Font.DemiBold
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
        id: trailingContainer
        spacing: 8
        Layout.alignment: Qt.AlignVCenter

        MikoBadge {
            visible: root.badgeText !== ""
            style: root.ui
            text: root.badgeText
            tone: "accent"
        }
    }

    MikoButton {
        id: actionButton
        visible: root.actionText !== "" || root.actionIcon !== ""
        style: root.ui
        text: root.actionText
        icon: root.actionIcon
        enabled: root.actionEnabled
        Layout.alignment: Qt.AlignVCenter
        onClicked: root.actionClicked()
    }
}
