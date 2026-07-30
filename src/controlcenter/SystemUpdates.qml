import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    required property var controller
    required property var style

    readonly property int settingsContentWidth: 480

    Layout.topMargin: 6
    spacing: 10

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

    RowLayout {
        Layout.fillWidth: true

        LabelText {
            Layout.fillWidth: true
            text: "Обновления"
            font.pixelSize: Appearance.font.pixelSize.larger
            font.weight: Font.DemiBold
        }

        MutedText {
            text: "Последняя проверка: "
                + root.controller.updateLastChecked
        }
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: updateCenterContent.implicitHeight + 34
        radius: root.style.radiusSection
        color: root.style.sectionSurface
        border.width: 1
        border.color: Qt.rgba(
            root.style.ink.r,
            root.style.ink.g,
            root.style.ink.b,
            0.06
        )
        antialiasing: true

        ColumnLayout {
            id: updateCenterContent

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 17
            }
            spacing: 13

            RowLayout {
                Layout.fillWidth: true
                spacing: 13

                IconDisc {
                    icon: root.controller.updateDetailsState === "checking"
                        || root.controller.updateDetailsState === "installing"
                        ? "sync"
                        : root.controller.repositoryUpdates.length
                            + root.controller.aurUpdates.length > 0
                            ? "system_update" : "verified"
                    accented: root.controller.repositoryUpdates.length
                        + root.controller.aurUpdates.length > 0

                    RotationAnimation on rotation {
                        running:
                            root.controller.updateDetailsState === "checking"
                            || root.controller
                                .updateDetailsState === "installing"
                        from: 0
                        to: 360
                        duration: 900
                        loops: Animation.Infinite
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    spacing: 1

                    LabelText {
                        Layout.fillWidth: true
                        text:
                            root.controller
                                .updateDetailsState === "not-checked"
                            ? "Готово к проверке"
                            : root.controller.updateDetailsMessage
                        font.pixelSize: Appearance.font.pixelSize.larger
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                    }

                    MutedText {
                        Layout.fillWidth: true
                        text:
                            root.controller
                                .updateDetailsState === "installing"
                            ? "Подтверждения выбраны автоматически"
                                + " · база пакетов временно занята"
                            : root.controller.updateDetailsState === "error"
                                ? "Ничего не установлено — можно повторить"
                                    + " проверку"
                                : root.controller.repositoryUpdates.length
                                    + " из репозиториев · "
                                    + root.controller.aurUpdates.length
                                    + " из AUR"
                        elide: Text.ElideRight
                    }
                }

                SoftButton {
                    icon: "refresh"
                    text: root.controller.updateDetailsState === "checking"
                        ? "Проверяем…" : "Проверить"
                    enabled:
                        root.controller.updateDetailsState !== "checking"
                        && root.controller
                            .updateDetailsState !== "installing"
                    onClicked: root.controller.refreshUpdates()
                }

                SoftButton {
                    visible: root.controller.repositoryUpdates.length > 0
                    icon: "download"
                    text: "Обновить систему"
                    enabled:
                        root.controller.updateDetailsState !== "installing"
                    onClicked:
                        root.controller.installRepositoryUpdates()
                }

                SoftButton {
                    visible: root.controller.aurUpdates.length > 0
                    icon: "terminal"
                    text: "Обновить AUR"
                    enabled:
                        root.controller.updateDetailsState !== "installing"
                    onClicked: root.controller.installAurUpdates()
                }
            }

            Rectangle {
                visible: root.controller.repositoryUpdates.length
                    + root.controller.aurUpdates.length > 0
                Layout.fillWidth: true
                implicitHeight: updatePackageList.implicitHeight + 12
                radius: 20
                color: root.style.hoverSurface

                ColumnLayout {
                    id: updatePackageList

                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: 6
                    }
                    spacing: 0

                    Repeater {
                        model: {
                            const all =
                                root.controller.repositoryUpdates.concat(
                                    root.controller.aurUpdates
                                );
                            return root.controller.updateListExpanded
                                ? all : all.slice(0, 5);
                        }

                        delegate: Item {
                            id: updatePackageRow

                            required property var modelData

                            Layout.fillWidth: true
                            implicitWidth: root.settingsContentWidth
                            implicitHeight: 48

                            RowLayout {
                                anchors {
                                    fill: parent
                                    leftMargin: 10
                                    rightMargin: 10
                                }
                                spacing: 11

                                MaterialSymbol {
                                    text:
                                        updatePackageRow
                                            .modelData.source === "aur"
                                        ? "construction" : "package_2"
                                    iconSize: 18
                                    color: root.style.mutedInk
                                }

                                LabelText {
                                    Layout.fillWidth: true
                                    text: updatePackageRow.modelData.name
                                    font.weight: Font.Medium
                                    elide: Text.ElideRight
                                }

                                MutedText {
                                    text:
                                        updatePackageRow
                                            .modelData.currentVersion
                                        + " → "
                                        + updatePackageRow
                                            .modelData.nextVersion
                                }

                                Rectangle {
                                    implicitWidth:
                                        packageSourceLabel.implicitWidth + 18
                                    implicitHeight: 28
                                    radius: 12
                                    color: root.style.sectionSurface

                                    MutedText {
                                        id: packageSourceLabel

                                        anchors.centerIn: parent
                                        text:
                                            updatePackageRow
                                                .modelData.source === "aur"
                                            ? "AUR" : "Система"
                                    }
                                }
                            }
                        }
                    }

                    SoftButton {
                        visible: root.controller.repositoryUpdates.length
                            + root.controller.aurUpdates.length > 5
                        Layout.alignment: Qt.AlignHCenter
                        Layout.topMargin: 5
                        icon: root.controller.updateListExpanded
                            ? "expand_less" : "expand_more"
                        text: root.controller.updateListExpanded
                            ? "Свернуть"
                            : "Показать все ("
                                + (
                                    root.controller.repositoryUpdates.length
                                    + root.controller.aurUpdates.length
                                ) + ")"
                        onClicked: root.controller.toggleUpdateList()
                    }
                }
            }

            ColumnLayout {
                visible:
                    root.controller.recentPackageHistory.length > 0
                Layout.fillWidth: true
                spacing: 5

                LabelText {
                    text: "Недавние изменения"
                    font.weight: Font.DemiBold
                }

                Repeater {
                    model:
                        root.controller.recentPackageHistory.slice(0, 3)

                    delegate: MutedText {
                        required property string modelData

                        Layout.fillWidth: true
                        text: modelData.replace(
                            /^\[[^\]]+\]\s+\[ALPM\]\s+/, ""
                        )
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }
}
