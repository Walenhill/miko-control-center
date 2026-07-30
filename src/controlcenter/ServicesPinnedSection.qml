import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    required property var controller
    required property var style
    required property string selectedComponentId
    signal componentRequested(string componentId)

    spacing: 18

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

    RowLayout {
        Layout.fillWidth: true
        Layout.topMargin: 2
        spacing: 10

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            LabelText {
                text: "Твоя система"
                font.pixelSize: Appearance.font.pixelSize.larger
                font.weight: Font.DemiBold
            }
            MutedText {
                text: root.controller.editingPins
                    ? "Нажми на карточку, чтобы убрать её из обзора"
                    : "То, что важно видеть сразу"
            }
        }
        Rectangle {
            visible: root.controller.editingPins
            implicitWidth: pinHint.implicitWidth + 22
            implicitHeight: 32
            radius: 13
            color: root.style.sectionSurface

            LabelText {
                id: pinHint
                anchors.centerIn: parent
                text: root.controller.pinnedComponentIds.length + " закреплено"
                font.weight: Font.Medium
            }
        }
    }

    GridLayout {
        Layout.fillWidth: true
        columns: width > 820 ? 3 : (width > 560 ? 2 : 1)
        columnSpacing: 11
        rowSpacing: 11

        Repeater {
            model: root.controller.pinnedComponentIds
                .map(id => root.controller.componentById(id))
                .filter(item => item !== null)

            delegate: Rectangle {
                id: pinnedCard

                required property var modelData
                property bool active:
                    root.controller.componentActive(modelData)
                property bool installed:
                    root.controller.componentInstalled(modelData)
                property bool selected:
                    root.selectedComponentId === modelData.id

                Layout.fillWidth: true
                implicitHeight: 112
                radius: 24
                color: root.style.sectionSurface
                border.width: 1
                border.color: selected
                    ? Appearance.colors.colPrimary
                    : Qt.rgba(
                        root.style.ink.r,
                        root.style.ink.g,
                        root.style.ink.b,
                        0.06
                    )
                antialiasing: true

                Behavior on border.color {
                    ColorAnimation {
                        duration: root.style.motionNormal
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: root.style.motionCurve
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: Appearance.colors.colPrimary
                    opacity: pinnedCard.selected
                        ? 0.12 : (pinnedMouse.containsMouse ? 0.055 : 0)

                    Behavior on opacity {
                        OpacityAnimator {
                            duration: root.style.motionNormal
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: root.style.motionCurve
                        }
                    }
                }

                RowLayout {
                    anchors {
                        fill: parent
                        margins: 14
                    }
                    spacing: 11

                    IconDisc {
                        icon: pinnedCard.modelData.icon
                        accented: pinnedCard.active
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 3
                        LabelText {
                            Layout.fillWidth: true
                            text: pinnedCard.modelData.title
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                        }
                        MutedText {
                            Layout.fillWidth: true
                            text: pinnedCard.modelData.subtitle
                            elide: Text.ElideRight
                        }
                        RowLayout {
                            spacing: 6
                            Rectangle {
                                width: 7
                                height: 7
                                radius: 4
                                color: pinnedCard.active
                                    ? Appearance.colors.colPrimary
                                    : (pinnedCard.installed
                                        ? Appearance.colors.colError
                                        : root.style.mutedInk)
                            }
                            MutedText {
                                text: root.controller.componentStateText(
                                    pinnedCard.modelData
                                )
                            }
                        }
                    }
                    MaterialSymbol {
                        text: root.controller.editingPins
                            ? "keep_off" : "arrow_forward"
                        iconSize: 19
                        color: root.style.mutedInk
                    }
                }

                MouseArea {
                    id: pinnedMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.controller.editingPins) {
                            root.controller.togglePin(pinnedCard.modelData.id);
                            return;
                        }
                        root.componentRequested(
                            root.selectedComponentId === pinnedCard.modelData.id
                                ? "" : pinnedCard.modelData.id
                        );
                    }
                }
            }
        }
    }
}
