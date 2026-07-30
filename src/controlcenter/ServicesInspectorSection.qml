import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

Rectangle {
    id: root

    required property var controller
    required property var style
    required property string selectedComponentId
    signal navigateRequested(string pageId)

    property var componentData: null
    property real revealProgress: 0
    readonly property bool compact: width < 760

    visible: revealProgress > 0.001
    Layout.fillWidth: true
    implicitHeight: Math.round((compact ? 260 : 210) * revealProgress)
    opacity: Math.min(1, revealProgress * 1.7)
    radius: root.style.radiusSection
    color: root.style.hoverSurface
    border.width: 1
    border.color: Qt.rgba(
        root.style.ink.r,
        root.style.ink.g,
        root.style.ink.b,
        0.08
    )
    antialiasing: true
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

    function syncComponent() {
        if (selectedComponentId !== "") {
            componentData = controller.componentById(selectedComponentId);
            revealProgress = 1;
            return;
        }
        revealProgress = 0;
        inspectorClearTimer.restart();
    }

    function componentValue(name, fallbackValue) {
        if (!componentData
                || componentData[name] === undefined
                || componentData[name] === null) {
            return fallbackValue;
        }
        return componentData[name];
    }

    function serviceEnabledText() {
        const unit = componentValue("unit", "");
        if (unit === "")
            return "не требуется";
        const state = controller.serviceStates[unit];
        return state !== undefined && state.enabled !== undefined
            ? state.enabled : "неизвестно";
    }

    onSelectedComponentIdChanged: syncComponent()
    Component.onCompleted: syncComponent()

    Behavior on revealProgress {
        NumberAnimation {
            duration: root.style.motionSlow
            easing.type: Easing.BezierSpline
            easing.bezierCurve: root.style.motionCurve
        }
    }

    Timer {
        id: inspectorClearTimer
        interval: root.style.motionSlow + 30
        onTriggered: {
            if (root.selectedComponentId === "")
                root.componentData = null;
        }
    }

    RowLayout {
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 19
        }
        height: root.compact ? 222 : 172
        spacing: 18

        ColumnLayout {
            Layout.preferredWidth: root.compact ? 205 : 270
            Layout.fillHeight: true
            spacing: 7

            RowLayout {
                spacing: 12
                IconDisc {
                    icon: root.componentValue("icon", "extension")
                    accented: root.controller.componentActive(
                        root.componentData
                    )
                }
                ColumnLayout {
                    spacing: 0
                    LabelText {
                        text: root.componentValue("title", "")
                        font.pixelSize: Appearance.font.pixelSize.normal
                        font.weight: Font.DemiBold
                    }
                    MutedText {
                        text: root.componentValue("technicalName", "")
                    }
                }
            }
            MutedText {
                Layout.fillWidth: true
                Layout.topMargin: 5
                text: root.componentValue("subtitle", "")
                wrapMode: Text.Wrap
            }
            Item {
                Layout.fillHeight: true
            }
            RowLayout {
                spacing: 7
                Rectangle {
                    width: 8
                    height: 8
                    radius: 4
                    color: root.controller.componentActive(root.componentData)
                        ? Appearance.colors.colPrimary
                        : Appearance.colors.colError
                }
                LabelText {
                    text: root.controller.componentStateText(
                        root.componentData
                    )
                    font.weight: Font.Medium
                }
            }
        }

        Rectangle {
            Layout.fillHeight: true
            width: 1
            color: Qt.rgba(
                root.style.ink.r,
                root.style.ink.g,
                root.style.ink.b,
                0.08
            )
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 11

            LabelText {
                text: "Что известно"
                font.weight: Font.DemiBold
            }
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 20
                rowSpacing: 10

                MutedText {
                    text: "Источник"
                }
                LabelText {
                    text: root.componentValue("kind", "") === "integration"
                        ? "Пакет системы" : "Пользовательская служба"
                    font.weight: Font.Medium
                }
                MutedText {
                    text: "Автозапуск"
                }
                LabelText {
                    text: root.serviceEnabledText()
                    font.weight: Font.Medium
                }
                MutedText {
                    text: "Состояние"
                }
                LabelText {
                    text: root.controller.componentStateText(
                        root.componentData
                    )
                    font.weight: Font.Medium
                }
            }
            Item {
                Layout.fillHeight: true
            }
            GridLayout {
                Layout.fillWidth: true
                columns: root.compact ? 2 : 4
                columnSpacing: 8
                rowSpacing: 8

                SoftButton {
                    Layout.fillWidth: true
                    visible: root.componentValue("pageId", "") !== ""
                    icon: "tune"
                    text: "Настроить"
                    onClicked: root.navigateRequested(
                        root.componentData.pageId
                    )
                }
                SoftButton {
                    Layout.fillWidth: true
                    visible: root.componentValue("unit", "") !== ""
                    icon: root.controller.componentActive(root.componentData)
                        ? "restart_alt" : "play_arrow"
                    text: root.controller.componentActive(root.componentData)
                        ? "Перезапустить" : "Запустить"
                    onClicked: root.controller.restartUserService(
                        root.componentData.unit
                    )
                }
                SoftButton {
                    Layout.fillWidth: true
                    visible: root.componentValue("unit", "") !== ""
                    icon: "article"
                    text: "Журнал"
                    onClicked: root.controller.openServiceJournal(
                        root.componentData.unit
                    )
                }
                SoftButton {
                    Layout.fillWidth: true
                    icon: root.controller.pinnedComponentIds.includes(
                        root.componentValue("id", "")
                    ) ? "keep_off" : "keep"
                    text: root.controller.pinnedComponentIds.includes(
                        root.componentValue("id", "")
                    ) ? "Убрать" : "Закрепить"
                    onClicked: root.controller.togglePin(
                        root.componentData.id
                    )
                }
            }
        }
    }
}
