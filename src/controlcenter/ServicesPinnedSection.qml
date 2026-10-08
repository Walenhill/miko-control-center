import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    property var style: null
    readonly property var ui: style ? style : DefaultStyle

    required property var controller
    required property string selectedComponentId
    signal componentRequested(string componentId)

    spacing: 14

    MikoSectionHeader {
        style: root.ui
        title: I18n.tr("Ключевые компоненты")
        subtitle: root.controller.editingPins
            ? I18n.tr("Нажмите на карточку, чтобы убрать её из обзора")
            : I18n.tr("Службы с быстрым доступом к состоянию и логам")
        badgeText: root.controller.editingPins
            ? (root.controller.pinnedComponentIds.length + I18n.tr(" закреплено"))
            : ""
    }

    GridLayout {
        Layout.fillWidth: true
        columns: width > 820 ? 3 : (width > 560 ? 2 : 1)
        columnSpacing: 12
        rowSpacing: 12

        Repeater {
            model: root.controller.pinnedComponentIds
                .map(id => root.controller.componentById(id))
                .filter(item => item !== null)

            delegate: Rectangle {
                id: pinnedCard
                required property var modelData
                readonly property bool active: root.controller.componentActive(modelData)
                readonly property bool installed: root.controller.componentInstalled(modelData)
                readonly property bool selected: root.selectedComponentId === modelData.id

                Layout.fillWidth: true
                implicitHeight: 116
                radius: root.ui.radiusSection
                color: selected
                    ? root.ui.selectedCardBackground
                    : (pinnedMouse.containsMouse ? root.ui.hoverSurface : root.ui.sectionSurface)
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
                    anchors {
                        fill: parent
                        margins: 14
                    }
                    spacing: 12

                    MikoIconDisc {
                        style: root.ui
                        icon: pinnedCard.modelData.icon
                        accented: pinnedCard.active
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 3

                        StyledText {
                            Layout.fillWidth: true
                            text: pinnedCard.modelData.title
                            color: root.ui.ink
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: pinnedCard.modelData.subtitle
                            color: root.ui.mutedInk
                            font.pixelSize: Appearance.font.pixelSize.smaller
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
                                    : (pinnedCard.installed ? Appearance.colors.colError : root.ui.mutedInk)
                            }

                            StyledText {
                                text: root.controller.componentStateText(pinnedCard.modelData)
                                color: root.ui.mutedInk
                                font.pixelSize: Appearance.font.pixelSize.smallest
                            }
                        }
                    }

                    MaterialSymbol {
                        text: root.controller.editingPins ? "keep_off" : (pinnedCard.selected ? "expand_less" : "arrow_forward")
                        iconSize: 18
                        color: pinnedCard.selected ? Appearance.colors.colPrimary : root.ui.mutedInk
                        Layout.alignment: Qt.AlignVCenter
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
                        root.componentRequested(root.selectedComponentId === pinnedCard.modelData.id ? "" : pinnedCard.modelData.id);
                    }
                }
            }
        }
    }
}
