import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

GridLayout {
    id: root

    required property var controller
    required property var style

    Layout.fillWidth: true
    columns: width >= 790 ? 2 : 1
    columnSpacing: 22
    rowSpacing: 14

    readonly property var sections: [
        { value: "form", title: "Форма", icon: "tune" },
        { value: "behavior", title: "Поведение", icon: "motion_sensor_active" },
        { value: "elements", title: "Элементы", icon: "widgets" },
        { value: "workspaces", title: "Рабочие столы", icon: "grid_view" }
    ]

    Flow {
        Layout.fillWidth: root.columns === 1
        Layout.preferredWidth: root.columns === 2 ? 190 : -1
        Layout.alignment: Qt.AlignTop
        spacing: 6

        Repeater {
            model: root.sections

            delegate: Rectangle {
                id: sectionButton

                required property var modelData
                readonly property bool selected:
                    root.controller.subsection === modelData.value

                width: root.columns === 2 ? 190 : sectionLabel.implicitWidth + 58
                height: 46
                radius: 17
                color: selected
                    ? root.style.selectedSurface
                    : (sectionMouse.containsMouse
                        ? root.style.sectionSurface : "transparent")
                antialiasing: true

                Behavior on color {
                    ColorAnimation { duration: root.style.motionFast }
                }

                RowLayout {
                    anchors {
                        fill: parent
                        leftMargin: 14
                        rightMargin: 14
                    }
                    spacing: 9
                    MaterialSymbol {
                        text: sectionButton.modelData.icon
                        iconSize: 19
                        color: sectionButton.selected
                            ? root.style.selectedInk : root.style.mutedInk
                    }
                    StyledText {
                        id: sectionLabel
                        text: sectionButton.modelData.title
                        color: sectionButton.selected
                            ? root.style.selectedInk : root.style.ink
                        font.weight: sectionButton.selected
                            ? Font.DemiBold : Font.Normal
                    }
                }
                MouseArea {
                    id: sectionMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.controller.subsection =
                        sectionButton.modelData.value
                }
            }
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignTop
        spacing: 12

        AppearanceBarForm {
            visible: root.controller.subsection === "form"
            style: root.style
        }
        AppearanceBarBehavior {
            visible: root.controller.subsection === "behavior"
            style: root.style
        }
        AppearanceBarElements {
            visible: root.controller.subsection === "elements"
            style: root.style
        }
        AppearanceBarWorkspaces {
            visible: root.controller.subsection === "workspaces"
            style: root.style
        }
    }
}
