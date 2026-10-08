import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    property var style: null
    readonly property var ui: style ? style : DefaultStyle

    required property var controller

    spacing: 12

    MikoSectionHeader {
        style: root.ui
        title: I18n.tr("Профиль питания")
        subtitle: I18n.tr("Управление энергопотреблением процессора (AMD P-State)")
        badgeText: root.controller.powerProfile === "performance" ? I18n.tr("Производительность")
            : (root.controller.powerProfile === "power-saver" ? I18n.tr("Экономия") : I18n.tr("Баланс"))
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        Repeater {
            model: [
                {
                    id: "performance",
                    title: I18n.tr("Производительность"),
                    icon: "rocket_launch"
                },
                {
                    id: "balanced",
                    title: I18n.tr("Баланс"),
                    icon: "balance"
                },
                {
                    id: "power-saver",
                    title: I18n.tr("Экономия"),
                    icon: "eco"
                }
            ]

            delegate: Rectangle {
                id: profileButton
                required property var modelData
                readonly property bool selected: root.controller.powerProfile === modelData.id

                Layout.fillWidth: true
                implicitHeight: 60
                radius: root.ui.radiusSection
                color: selected
                    ? root.ui.selectedCardBackground
                    : (profileMouse.containsMouse ? root.ui.hoverSurface : root.ui.sectionSurface)
                border.width: selected ? 2 : 1
                border.color: selected ? root.ui.selectedCardBorder : root.ui.hairline
                antialiasing: true

                Behavior on color {
                    ColorAnimation { duration: root.ui.motionFast }
                }
                Behavior on border.color {
                    ColorAnimation { duration: root.ui.motionFast }
                }

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 8

                    MaterialSymbol {
                        text: profileButton.modelData.icon
                        iconSize: 20
                        color: profileButton.selected ? Appearance.colors.colPrimary : root.ui.ink
                    }

                    StyledText {
                        text: profileButton.modelData.title
                        color: profileButton.selected ? Appearance.colors.colPrimary : root.ui.ink
                        font.weight: profileButton.selected ? Font.DemiBold : Font.Normal
                    }
                }

                MouseArea {
                    id: profileMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.controller.setPowerProfile(profileButton.modelData.id)
                }
            }
        }
    }
}
