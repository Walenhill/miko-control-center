import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

Rectangle {
    id: root

    required property var operations
    required property var style

    visible: opacity > 0.01
    opacity: operations.snackbarVisible ? 1 : 0
    implicitWidth: Math.min(620, content.implicitWidth + 34)
    implicitHeight: Math.max(58, content.implicitHeight + 18)
    radius: style.radiusSection
    color: style.controlSurface
    border.width: 1
    border.color: style.strongHairline
    antialiasing: true
    z: 140

    Behavior on opacity {
        NumberAnimation {
            duration: root.style.motionNormal
            easing.type: Easing.OutCubic
        }
    }

    RowLayout {
        id: content
        anchors {
            fill: parent
            margins: 10
            leftMargin: 16
        }
        spacing: 10

        MaterialSymbol {
            text: root.operations.snackbarIcon
            iconSize: 21
            color: Appearance.colors.colPrimary
        }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            StyledText {
                Layout.fillWidth: true
                text: root.operations.snackbarTitle
                color: root.style.ink
                font.weight: Font.Medium
                elide: Text.ElideRight
            }
            StyledText {
                visible: text !== ""
                Layout.fillWidth: true
                text: root.operations.snackbarMessage
                color: root.style.mutedInk
                font.pixelSize: Appearance.font.pixelSize.smaller
                elide: Text.ElideRight
            }
        }
        MikoButton {
            visible: root.operations.snackbarAction !== ""
            style: root.style
            text: root.operations.snackbarAction
            onClicked: root.operations.triggerSnackbarAction()
        }
        MikoButton {
            style: root.style
            icon: "close"
            onClicked: root.operations.hideMessage()
        }
    }
}
