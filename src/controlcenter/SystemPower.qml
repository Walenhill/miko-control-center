import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    required property var controller
    required property var style

    spacing: 9

    component LabelText: StyledText {
        color: root.style.ink
        font.pixelSize: Appearance.font.pixelSize.small
    }

    component MutedText: StyledText {
        color: root.style.mutedInk
        font.pixelSize: Appearance.font.pixelSize.smaller
    }

    RowLayout {
        Layout.fillWidth: true

        LabelText {
            Layout.fillWidth: true
            text: "Профиль питания"
            font.pixelSize: Appearance.font.pixelSize.larger
            font.weight: Font.DemiBold
        }

        MutedText {
            text: "AMD P-State"
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 9

        Repeater {
            model: [
                {
                    id: "performance",
                    title: "Производительность",
                    icon: "rocket_launch"
                },
                {
                    id: "balanced",
                    title: "Баланс",
                    icon: "balance"
                },
                {
                    id: "power-saver",
                    title: "Экономия",
                    icon: "eco"
                }
            ]

            delegate: Rectangle {
                id: profileButton

                required property var modelData

                property bool selected:
                    root.controller.powerProfile === modelData.id

                Layout.fillWidth: true
                implicitHeight: 58
                radius: 20
                color: selected
                    ? Appearance.colors.colPrimary
                    : (profileMouse.containsMouse
                        ? root.style.hoverSurface
                        : root.style.sectionSurface)
                antialiasing: true

                RowLayout {
                    anchors.centerIn: parent

                    MaterialSymbol {
                        text: profileButton.modelData.icon
                        iconSize: 19
                        color: profileButton.selected
                            ? Appearance.colors.colOnPrimary
                            : root.style.ink
                    }

                    LabelText {
                        text: profileButton.modelData.title
                        color: profileButton.selected
                            ? Appearance.colors.colOnPrimary
                            : root.style.ink
                        font.weight: profileButton.selected
                            ? Font.DemiBold : Font.Normal
                    }
                }

                MouseArea {
                    id: profileMouse

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.controller.setPowerProfile(
                        profileButton.modelData.id
                    )
                }
            }
        }
    }
}
