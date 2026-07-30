import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    required property var controller
    required property var style
    signal navigateRequested(string pageId)

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

    component SoftButton: MikoButton {
        style: root.style
    }

    function integrationInstalled(id) {
        const state = controller.integrationStates[id];
        return state !== undefined && state.installed === true;
    }

    function integrationVersion(id) {
        const state = controller.integrationStates[id];
        return state !== undefined && state.version !== undefined
            ? state.version : "";
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.topMargin: 3

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            LabelText {
                text: "Интеграции"
                font.pixelSize: Appearance.font.pixelSize.larger
                font.weight: Font.DemiBold
            }
            MutedText {
                text: "Возможности, которые можно добавить к системе"
            }
        }
        SoftButton {
            icon: "add_circle"
            text: root.controller.showCatalog
                ? "Закрыть каталог" : "Добавить интеграцию"
            onClicked: root.controller.toggleCatalog()
        }
    }

    GridLayout {
        Layout.fillWidth: true
        columns: width > 760 ? 2 : 1
        columnSpacing: 11
        rowSpacing: 11

        Repeater {
            model: root.controller.integrationCatalog.filter(item =>
                root.controller.showCatalog
                    || root.integrationInstalled(item.id)
            )

            delegate: Rectangle {
                id: integrationCard

                required property var modelData
                property bool installed:
                    root.integrationInstalled(modelData.id)

                Layout.fillWidth: true
                implicitHeight: 118
                radius: 24
                color: integrationMouse.containsMouse
                    ? root.style.hoverSurface : root.style.sectionSurface
                border.width: 1
                border.color: Qt.rgba(
                    root.style.ink.r,
                    root.style.ink.g,
                    root.style.ink.b,
                    0.06
                )

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
                        margins: 14
                    }
                    spacing: 12

                    IconDisc {
                        icon: integrationCard.modelData.icon
                        accented: integrationCard.installed
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        LabelText {
                            text: integrationCard.modelData.title
                            font.weight: Font.DemiBold
                        }
                        MutedText {
                            text: integrationCard.modelData.subtitle
                        }
                        MutedText {
                            text: integrationCard.installed
                                ? "Установлено · "
                                    + root.integrationVersion(
                                        integrationCard.modelData.id
                                    )
                                : "Доступно из "
                                    + integrationCard.modelData.source
                        }
                    }
                    SoftButton {
                        icon: integrationCard.installed
                            ? "arrow_forward" : "download"
                        text: integrationCard.installed
                            ? "Открыть" : "Установить"
                        onClicked: {
                            if (integrationCard.installed) {
                                if (integrationCard.modelData.pageId !== "") {
                                    root.navigateRequested(
                                        integrationCard.modelData.pageId
                                    );
                                }
                                return;
                            }
                            root.controller.installIntegration(
                                integrationCard.modelData
                            );
                        }
                    }
                }

                MouseArea {
                    id: integrationMouse
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton
                    hoverEnabled: true
                }
            }
        }
    }
}
