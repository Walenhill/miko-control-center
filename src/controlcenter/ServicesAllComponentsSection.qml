import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

MikoSurface {
    id: root

    required property var controller
    required property var style
    signal componentRequested(string componentId)

    Layout.fillWidth: true

    ColumnLayout {
        anchors {
            fill: parent
            margins: 16
        }
        spacing: 14

        MikoSectionHeader {
            style: root.style
            title: I18n.tr("Все службы и компоненты")
            subtitle: I18n.tr("Системные возможности, фоновые демоны и порталы рабочего стола")
            badgeText: String(root.controller.allServiceComponents().length)
        }

        GridLayout {
            id: componentsGrid
            Layout.fillWidth: true
            columns: width > 760 ? 2 : 1
            columnSpacing: 10
            rowSpacing: 10

            Repeater {
                model: root.controller.allServiceComponents()

                delegate: MikoSurface {
                    id: componentRow
                    required property var modelData
                    Layout.fillWidth: true
                    implicitHeight: 66
                    style: root.style
                    interactive: true

                    RowLayout {
                        anchors {
                            fill: parent
                            margins: 12
                        }
                        spacing: 12

                        MikoIconDisc {
                            style: root.style
                            icon: componentRow.modelData.icon
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            StyledText {
                                text: componentRow.modelData.title
                                color: root.style.ink
                                font.pixelSize: Appearance.font.pixelSize.normal
                                font.weight: Font.Medium
                            }
                            StyledText {
                                text: root.controller.componentStateText(
                                    componentRow.modelData
                                )
                                color: root.style.mutedInk
                                font.pixelSize: Appearance.font.pixelSize.smaller
                            }
                        }

                        MaterialSymbol {
                            text: root.controller.pinnedComponentIds.includes(
                                componentRow.modelData.id
                            ) ? "keep" : "keep_off"
                            iconSize: 18
                            color: root.controller.pinnedComponentIds.includes(
                                componentRow.modelData.id
                            ) ? root.style.selectedInk : root.style.mutedInk
                        }
                    }

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
