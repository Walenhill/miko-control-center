import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    property var style: null
    readonly property var ui: style ? style : DefaultStyle

    required property var devices
    required property bool busy
    required property string errorMessage
    property string expandedDeviceId: ""
    signal refreshRequested()

    Layout.fillWidth: true
    spacing: 12

    MikoSectionHeader {
        style: root.ui
        title: I18n.tr("USB-оборудование")
        subtitle: I18n.tr("Подключённая периферия, контроллеры и внешние накопители")
        badgeText: (root.devices && root.devices.length > 0) ? String(root.devices.length) : "0"
        actionText: I18n.tr("Обновить")
        actionIcon: "refresh"
        actionEnabled: !root.busy
        onActionClicked: root.refreshRequested()
    }

    GridLayout {
        visible: root.errorMessage === ""
        Layout.fillWidth: true
        columns: width > 700 ? 2 : 1
        columnSpacing: 12
        rowSpacing: 12

        Repeater {
            model: root.devices || []

            delegate: Rectangle {
                id: usbCard
                required property var modelData
                readonly property bool expanded: root.expandedDeviceId === modelData.id

                Layout.fillWidth: true
                implicitHeight: expanded ? 126 : 84
                radius: root.ui.radiusSection
                color: root.ui.sectionSurface
                border.width: expanded ? 2 : 1
                border.color: expanded ? root.ui.selectedCardBorder : root.ui.hairline
                antialiasing: true

                Behavior on implicitHeight {
                    NumberAnimation { duration: root.ui.motionFast; easing.type: Easing.OutCubic }
                }
                Behavior on border.color {
                    ColorAnimation { duration: root.ui.motionFast }
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        MikoIconDisc {
                            style: root.ui
                            icon: usbCard.modelData.icon || "usb"
                            accented: usbCard.expanded
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.minimumWidth: 0
                            spacing: 2

                            StyledText {
                                Layout.fillWidth: true
                                text: usbCard.modelData.name || I18n.tr("Неизвестное USB-устройство")
                                color: root.ui.ink
                                font.weight: Font.DemiBold
                                elide: Text.ElideRight
                            }

                            StyledText {
                                Layout.fillWidth: true
                                text: usbCard.modelData.description || I18n.tr("Шина USB")
                                color: root.ui.mutedInk
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                elide: Text.ElideRight
                            }
                        }

                        MikoButton {
                            style: root.ui
                            icon: usbCard.expanded ? "expand_less" : "expand_more"
                            text: ""
                            implicitWidth: 38
                            onClicked: root.expandedDeviceId = usbCard.expanded ? "" : usbCard.modelData.id
                        }
                    }

                    Rectangle {
                        visible: usbCard.expanded
                        Layout.fillWidth: true
                        implicitHeight: 1
                        color: root.ui.hairline
                    }

                    RowLayout {
                        visible: usbCard.expanded
                        Layout.fillWidth: true
                        spacing: 8

                        MikoBadge {
                            style: root.ui
                            text: "ID " + (usbCard.modelData.id || "0")
                            tone: "accent"
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: usbCard.modelData.rawName || ""
                            color: root.ui.mutedInk
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            elide: Text.ElideRight
                        }
                    }
                }
            }
        }
    }

    // Error or empty state
    MikoSurface {
        visible: root.errorMessage !== "" || (!root.devices || root.devices.length === 0)
        Layout.fillWidth: true
        style: root.ui

        RowLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            MikoIconDisc {
                style: root.ui
                icon: root.errorMessage !== "" ? "error" : "usb"
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                StyledText {
                    text: root.errorMessage !== "" ? I18n.tr("Ошибка опроса USB") : I18n.tr("Устройства не найдены")
                    color: root.ui.ink
                    font.weight: Font.Medium
                }

                StyledText {
                    text: root.errorMessage !== "" ? root.errorMessage : I18n.tr("Подключите клавиатуру, мышь или накопитель")
                    color: root.ui.mutedInk
                    font.pixelSize: Appearance.font.pixelSize.smaller
                }
            }
        }
    }
}
