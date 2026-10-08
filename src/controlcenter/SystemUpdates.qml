import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    property var style: null
    readonly property var ui: style ? style : DefaultStyle

    required property var controller

    spacing: 14

    MikoSectionHeader {
        style: root.ui
        title: I18n.tr("Обновления ПО")
        subtitle: I18n.tr("Последняя проверка: ") + (root.controller.updateLastChecked || "—")
        badgeText: (root.controller.availableUpdateCount > 0)
            ? (root.controller.availableUpdateCount + I18n.tr(" доступно"))
            : (root.controller.updateDetailsState === "ready" ? I18n.tr("Проверено") : "—")
        actionText: root.controller.updateDetailsState === "checking" ? I18n.tr("Проверяем…") : I18n.tr("Проверить")
        actionIcon: "refresh"
        actionEnabled: root.controller.updateDetailsState !== "checking" && root.controller.updateDetailsState !== "installing"
        onActionClicked: root.controller.refreshUpdates()
    }

    MikoSurface {
        style: root.ui
        Layout.fillWidth: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 14

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                MikoIconDisc {
                    style: root.ui
                    icon: (root.controller.updateDetailsState === "checking" || root.controller.updateDetailsState === "installing")
                        ? "sync"
                        : root.controller.updateDetailsState === "error" ? "error"
                        : (root.controller.repositoryUpdates.length + root.controller.aurUpdates.length > 0
                            ? "system_update" : "verified")
                    accented: (root.controller.repositoryUpdates.length + root.controller.aurUpdates.length > 0)

                    RotationAnimation on rotation {
                        running: root.visible && !root.ui.reducedMotion
                            && (root.controller.updateDetailsState === "checking" || root.controller.updateDetailsState === "installing")
                        from: 0; to: 360; duration: 900; loops: Animation.Infinite
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    spacing: 2

                    StyledText {
                        Layout.fillWidth: true
                        text: root.controller.updateDetailsState === "not-checked"
                            ? I18n.tr("Готово к проверке")
                            : (root.controller.updateDetailsMessage || "")
                        color: root.ui.ink
                        font.weight: Font.DemiBold
                        font.pixelSize: Appearance.font.pixelSize.normal
                        elide: Text.ElideRight
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: root.controller.updateDetailsState === "installing"
                            ? I18n.tr("Выполняется установка обновлений…")
                            : (root.controller.updateDetailsState === "error"
                                ? I18n.tr("Ошибка при получении списка пакетов")
                                : (root.controller.repositoryUpdates.length + I18n.tr(" из репозиториев · ")
                                   + root.controller.aurUpdates.length + I18n.tr(" из AUR")))
                        color: root.ui.mutedInk
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        elide: Text.ElideRight
                    }
                }

                MikoButton {
                    visible: root.controller.repositoryUpdates.length > 0
                    style: root.ui
                    icon: "download"
                    text: I18n.tr("Обновить систему")
                    selected: true
                    enabled: root.controller.updateDetailsState !== "installing"
                    onClicked: root.controller.installRepositoryUpdates()
                }

                MikoButton {
                    visible: root.controller.aurUpdates.length > 0
                    style: root.ui
                    icon: "terminal"
                    text: I18n.tr("Обновить AUR")
                    enabled: root.controller.updateDetailsState !== "installing"
                    onClicked: root.controller.installAurUpdates()
                }
            }

            // Package list if available
            Rectangle {
                visible: root.controller.repositoryUpdates.length + root.controller.aurUpdates.length > 0
                Layout.fillWidth: true
                implicitHeight: updatePackageList.implicitHeight + 16
                radius: root.ui.radiusControl
                color: root.ui.hoverSurface
                border.width: 1
                border.color: root.ui.hairline

                ColumnLayout {
                    id: updatePackageList
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: 8
                    }
                    spacing: 4

                    ListView {
                        Layout.fillWidth: true
                        implicitHeight: Math.min(count * 48, root.controller.updateListExpanded ? 360 : 240)
                        clip: true
                        reuseItems: true
                        spacing: 4
                        boundsBehavior: Flickable.StopAtBounds
                        ScrollBar.vertical: ScrollBar {}
                        model: {
                            const all = root.controller.repositoryUpdates.concat(root.controller.aurUpdates);
                            return root.controller.updateListExpanded ? all : all.slice(0, 5);
                        }

                        delegate: Item {
                            id: updatePackageRow
                            required property var modelData

                            width: ListView.view.width
                            height: 44

                            RowLayout {
                                anchors {
                                    fill: parent
                                    leftMargin: 12
                                    rightMargin: 12
                                }
                                spacing: 10

                                MaterialSymbol {
                                    text: updatePackageRow.modelData.source === "aur" ? "construction" : "package_2"
                                    iconSize: 18
                                    color: root.ui.mutedInk
                                }

                                StyledText {
                                    Layout.fillWidth: true
                                    text: updatePackageRow.modelData.name
                                    color: root.ui.ink
                                    font.weight: Font.Medium
                                    elide: Text.ElideRight
                                }

                                StyledText {
                                    text: updatePackageRow.modelData.currentVersion + " → " + updatePackageRow.modelData.nextVersion
                                    color: root.ui.mutedInk
                                    font.pixelSize: Appearance.font.pixelSize.smaller
                                }

                                MikoBadge {
                                    style: root.ui
                                    text: updatePackageRow.modelData.source === "aur" ? "AUR" : I18n.tr("Система")
                                    tone: updatePackageRow.modelData.source === "aur" ? "warning" : "accent"
                                }
                            }
                        }
                    }

                    MikoButton {
                        visible: root.controller.repositoryUpdates.length + root.controller.aurUpdates.length > 5
                        Layout.alignment: Qt.AlignHCenter
                        Layout.topMargin: 4
                        style: root.ui
                        icon: root.controller.updateListExpanded ? "expand_less" : "expand_more"
                        text: root.controller.updateListExpanded
                            ? I18n.tr("Свернуть")
                            : I18n.tr("Показать все (") + (root.controller.repositoryUpdates.length + root.controller.aurUpdates.length) + ")"
                        onClicked: root.controller.toggleUpdateList()
                    }
                }
            }

            // Recent history
            ColumnLayout {
                visible: Boolean(root.controller.recentPackageHistory && root.controller.recentPackageHistory.length > 0)
                Layout.fillWidth: true
                spacing: 6

                StyledText {
                    text: I18n.tr("Недавние изменения")
                    color: root.ui.ink
                    font.weight: Font.DemiBold
                    font.pixelSize: Appearance.font.pixelSize.smaller
                }

                Repeater {
                    model: root.controller.recentPackageHistory ? root.controller.recentPackageHistory.slice(0, 3) : []

                    delegate: StyledText {
                        required property string modelData
                        Layout.fillWidth: true
                        text: modelData.replace(/^\[[^\]]+\]\s+\[ALPM\]\s+/, "")
                        color: root.ui.mutedInk
                        font.pixelSize: Appearance.font.pixelSize.smallest
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }
}
