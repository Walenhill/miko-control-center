import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

Rectangle {
    id: root

    // Expandable inventory kept separate from the pinned overview.
    required property var controller
    required property var style
    signal componentRequested(string componentId)

    property real expansion: root.controller.showAllComponents ? 1 : 0

    Layout.fillWidth: true
    implicitHeight: Math.round(
        78 + (componentsGrid.implicitHeight + 12) * expansion
    )
    radius: root.style.radiusSection
    color: root.style.sectionSurface
    border.width: 1
    border.color: Qt.rgba(
        root.style.ink.r,
        root.style.ink.g,
        root.style.ink.b,
        0.055
    )
    clip: true

    component LabelText: StyledText {
        color: root.style.ink
        font.pixelSize: Appearance.font.pixelSize.small
    }

    component MutedText: StyledText {
        color: root.style.mutedInk
        font.pixelSize: Appearance.font.pixelSize.smaller
    }

    component IconDisc: MikoIconDisc {
        style: root.style
    }

    component SoftButton: MikoButton {
        style: root.style
    }

    Behavior on expansion {
        NumberAnimation {
            duration: root.style.motionSlow
            easing.type: Easing.BezierSpline
            easing.bezierCurve: root.style.motionCurve
        }
    }

    ColumnLayout {
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 15
        }
        spacing: 12

        RowLayout {
            Layout.fillWidth: true

            IconDisc {
                icon: "widgets"
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0
                LabelText {
                    text: "Все компоненты"
                    font.weight: Font.DemiBold
                }
                MutedText {
                    text: root.controller.allServiceComponents().length
                        + " системных возможностей обнаружено"
                }
            }
            SoftButton {
                icon: root.controller.showAllComponents
                    ? "expand_less" : "expand_more"
                text: root.controller.showAllComponents
                    ? "Свернуть" : "Показать"
                onClicked: root.controller.toggleAllComponents()
            }
        }

        GridLayout {
            id: componentsGrid

            visible: root.expansion > 0.001
            opacity: Math.min(1, root.expansion * 1.5)
            Layout.fillWidth: true
            columns: width > 760 ? 2 : 1
            columnSpacing: 9
            rowSpacing: 9

            Repeater {
                model: root.controller.allServiceComponents()

                delegate: Rectangle {
                    id: componentRow

                    required property var modelData
                    Layout.fillWidth: true
                    implicitHeight: 66
                    radius: 19
                    color: componentMouse.containsMouse
                        ? root.style.hoverSurface : "transparent"

                    Behavior on color {
                        ColorAnimation {
                            duration: root.style.motionFast
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: root.style.motionCurve
                        }
                    }

                    RowLayout {
                        anchors {
                            fill: parent
                            leftMargin: 11
                            rightMargin: 11
                        }
                        spacing: 10

                        MaterialSymbol {
                            text: componentRow.modelData.icon
                            iconSize: 20
                            color: root.style.ink
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            LabelText {
                                text: componentRow.modelData.title
                                font.weight: Font.Medium
                            }
                            MutedText {
                                text: root.controller.componentStateText(
                                    componentRow.modelData
                                )
                            }
                        }
                        MaterialSymbol {
                            text: root.controller.pinnedComponentIds.includes(
                                componentRow.modelData.id
                            ) ? "keep" : "keep_off"
                            iconSize: 18
                            color: root.style.mutedInk
                        }
                    }

                    MouseArea {
                        id: componentMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.componentRequested(componentRow.modelData.id);
                            if (!root.controller.pinnedComponentIds.includes(
                                componentRow.modelData.id
                            )) {
                                root.controller.togglePin(
                                    componentRow.modelData.id
                                );
                            }
                        }
                    }
                }
            }
        }
    }
}
