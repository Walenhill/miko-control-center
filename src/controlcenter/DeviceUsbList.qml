import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    required property var devices
    required property bool busy
    required property string errorMessage
    required property var style
    property string expandedDeviceId: ""
    signal refreshRequested()

    Layout.fillWidth: true
    spacing: 10

    RowLayout {
        Layout.fillWidth: true
        Layout.topMargin: 6
        StyledText {
            Layout.fillWidth: true
            text: "USB-оборудование"
            color: root.style.ink
            font.pixelSize: Appearance.font.pixelSize.larger
            font.weight: Font.DemiBold
        }
        StyledText {
            text: root.devices.length + " устройств"
            color: root.style.mutedInk
            font.pixelSize: Appearance.font.pixelSize.smaller
        }
        MikoButton {
            style: root.style
            icon: "refresh"
            text: ""
            implicitWidth: 42
            enabled: !root.busy
            onClicked: root.refreshRequested()
        }
    }

    GridLayout {
        visible: root.errorMessage === ""
        Layout.fillWidth: true
        columns: width > 700 ? 2 : 1
        columnSpacing: 10
        rowSpacing: 10
        Repeater {
            model: root.devices
            delegate: Rectangle {
                id: usbCard
                required property var modelData
                readonly property bool expanded: root.expandedDeviceId === modelData.id
                Layout.fillWidth: true
                implicitHeight: expanded ? 122 : 82
                radius: 21
                color: root.style.sectionSurface
                border.width: 1
                border.color: root.style.hairline
                antialiasing: true
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 13
                    spacing: 7
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 11
                        MikoIconDisc { style: root.style; icon: usbCard.modelData.icon }
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.minimumWidth: 0
                            spacing: 0
                            StyledText {
                                Layout.fillWidth: true
                                text: usbCard.modelData.name
                                color: root.style.ink
                                font.weight: Font.Medium
                                elide: Text.ElideRight
                            }
                            StyledText {
                                Layout.fillWidth: true
                                text: usbCard.modelData.description
                                color: root.style.mutedInk
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                elide: Text.ElideRight
                            }
                        }
                        MikoButton {
                            style: root.style
                            icon: usbCard.expanded ? "expand_less" : "expand_more"
                            text: ""
                            implicitWidth: 40
                            onClicked: root.expandedDeviceId = usbCard.expanded ? "" : usbCard.modelData.id
                        }
                    }
                    Rectangle {
                        visible: usbCard.expanded
                        Layout.fillWidth: true
                        implicitHeight: 1
                        color: root.style.hairline
                    }
                    StyledText {
                        visible: usbCard.expanded
                        Layout.fillWidth: true
                        text: usbCard.modelData.rawName + " · USB " + usbCard.modelData.id
                        color: root.style.mutedInk
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        elide: Text.ElideRight
                    }
                }
                Behavior on implicitHeight {
                    NumberAnimation { duration: root.style.motionFast; easing.type: Easing.OutCubic }
                }
            }
        }
    }

    StyledText {
        visible: root.errorMessage !== ""
        Layout.fillWidth: true
        text: root.errorMessage
        color: root.style.mutedInk
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: Appearance.font.pixelSize.smaller
    }
}
