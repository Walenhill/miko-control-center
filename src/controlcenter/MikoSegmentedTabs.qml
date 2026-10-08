import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

Rectangle {
    id: root

    property var style: null
    readonly property var ui: style ? style : DefaultStyle

    required property var model
    required property string currentTab
    signal tabSelected(string tabId)

    implicitHeight: 44
    implicitWidth: tabRow.implicitWidth + 8
    radius: Appearance.rounding.full
    color: root.ui.sectionSurface
    border.width: 1
    border.color: root.ui.hairline
    antialiasing: true

    RowLayout {
        id: tabRow
        anchors.fill: parent
        anchors.margins: 4
        spacing: 4

        Repeater {
            id: tabRepeater
            model: root.model

            delegate: Rectangle {
                id: tabButton
                required property var modelData
                required property int index
                activeFocusOnTab: true
                Accessible.role: Accessible.PageTab
                Accessible.name: modelData.title
                Accessible.selected: isSelected
                border.width: activeFocus ? 2 : 0
                border.color: root.ui.focusRing
                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                        root.tabSelected(modelData.id);
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Left || event.key === Qt.Key_Right) {
                        const step = event.key === Qt.Key_Right ? 1 : -1;
                        const next = (index + step + tabRepeater.count) % tabRepeater.count;
                        tabRepeater.itemAt(next).forceActiveFocus(Qt.TabFocusReason);
                        root.tabSelected(root.model[next].id);
                        event.accepted = true;
                    }
                }
                readonly property bool isSelected: root.currentTab === modelData.id
                readonly property bool isHovered: tabMouse.containsMouse

                Layout.fillHeight: true
                Layout.preferredWidth: tabContent.implicitWidth + 28
                radius: Appearance.rounding.full

                color: isSelected
                    ? root.ui.selectedSurface
                    : (isHovered ? root.ui.hoverSurface : "transparent")
                antialiasing: true

                Behavior on color {
                    ColorAnimation {
                        duration: root.ui.motionFast
                        easing.type: Easing.OutCubic
                    }
                }

                RowLayout {
                    id: tabContent
                    anchors.centerIn: parent
                    spacing: 7

                    MaterialSymbol {
                        visible: tabButton.modelData.icon !== undefined && tabButton.modelData.icon !== ""
                        text: tabButton.modelData.icon ? tabButton.modelData.icon : ""
                        iconSize: 18
                        color: tabButton.isSelected ? root.ui.selectedInk : (tabButton.isHovered ? root.ui.ink : root.ui.mutedInk)
                        Layout.alignment: Qt.AlignVCenter
                    }

                    StyledText {
                        text: tabButton.modelData.title
                        color: tabButton.isSelected ? root.ui.selectedInk : (tabButton.isHovered ? root.ui.ink : root.ui.mutedInk)
                        font.pixelSize: Appearance.font.pixelSize.small
                        font.weight: tabButton.isSelected ? Font.DemiBold : Font.Medium
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Rectangle {
                        visible: tabButton.modelData.badge !== undefined && tabButton.modelData.badge !== ""
                        implicitWidth: badgeText.implicitWidth + 12
                        implicitHeight: 18
                        radius: Appearance.rounding.full
                        color: tabButton.isSelected
                            ? Qt.rgba(root.ui.selectedInk.r, root.ui.selectedInk.g, root.ui.selectedInk.b, 0.22)
                            : root.ui.controlSurface

                        StyledText {
                            id: badgeText
                            anchors.centerIn: parent
                            text: tabButton.modelData.badge ? String(tabButton.modelData.badge) : ""
                            color: tabButton.isSelected ? root.ui.selectedInk : root.ui.mutedInk
                            font.pixelSize: Appearance.font.pixelSize.smaller - 2
                            font.weight: Font.DemiBold
                        }
                    }
                }

                MouseArea {
                    id: tabMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.tabSelected(tabButton.modelData.id)
                }
            }
        }
    }
}
