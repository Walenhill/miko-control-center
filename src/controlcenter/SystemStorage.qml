import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    required property var controller
    required property var style

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

    component SoftButton: MikoButton {
        style: root.style
    }

    component ListGroup: MikoListGroup {
        style: root.style
    }

    component ListRow: MikoListRow {
        style: root.style
    }

    component ProgressStrip: Rectangle {
        id: progressStrip

        property real value: 0
        property color fillColor: Appearance.colors.colPrimary

        implicitHeight: 7
        radius: 4
        color: root.style.controlSurface
        antialiasing: true

        Rectangle {
            width: parent.width * Math.max(
                0, Math.min(1, progressStrip.value)
            )
            height: parent.height
            radius: parent.radius
            color: progressStrip.fillColor
            antialiasing: true

            Behavior on width {
                NumberAnimation {
                    duration: root.style.motionNormal
                    easing.type: Easing.OutCubic
                }
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true

        LabelText {
            Layout.fillWidth: true
            text: "Хранилище"
            font.pixelSize: Appearance.font.pixelSize.larger
            font.weight: Font.DemiBold
        }

        SoftButton {
            icon: "refresh"
            text: ""
            implicitWidth: 42
            onClicked: root.controller.refreshDiskUsage()
        }
    }

    GridLayout {
        Layout.fillWidth: true
        columns: width > 600 ? 2 : 1
        columnSpacing: 10
        rowSpacing: 10

        Repeater {
            model: [
                {
                    title: "Система и Home",
                    subtitle: "ADATA NVMe · Btrfs",
                    free: root.controller.rootDiskFree,
                    used: root.controller.rootDiskUsed,
                    icon: "hard_drive"
                },
                {
                    title: "Архив",
                    subtitle: "WD 2 ТБ · Ext4",
                    free: root.controller.hddDiskFree,
                    used: root.controller.hddDiskUsed,
                    icon: "database"
                }
            ]

            delegate: Rectangle {
                required property var modelData

                Layout.fillWidth: true
                implicitHeight: 132
                radius: 23
                color: root.style.sectionSurface
                border.width: 1
                border.color: Qt.rgba(
                    root.style.ink.r,
                    root.style.ink.g,
                    root.style.ink.b,
                    0.055
                )
                antialiasing: true

                ColumnLayout {
                    anchors {
                        fill: parent
                        margins: 15
                    }
                    spacing: 6

                    RowLayout {
                        Layout.fillWidth: true

                        MaterialSymbol {
                            text: modelData.icon
                            iconSize: 21
                            color: root.style.mutedInk
                        }

                        LabelText {
                            Layout.fillWidth: true
                            text: modelData.title
                            font.weight: Font.DemiBold
                        }
                    }

                    MutedText {
                        text: modelData.subtitle
                    }

                    Item {
                        Layout.fillHeight: true
                    }

                    ProgressStrip {
                        Layout.fillWidth: true
                        value: modelData.used
                    }

                    MutedText {
                        text: modelData.free + " свободно"
                    }
                }
            }
        }
    }

    Item {
        Layout.fillWidth: true
        implicitHeight: storageToolsContent.implicitHeight

        ColumnLayout {
            id: storageToolsContent

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }
            spacing: 10

            RowLayout {
                Layout.fillWidth: true

                LabelText {
                    Layout.fillWidth: true
                    text: "Можно освободить"
                    font.weight: Font.DemiBold
                }

                MutedText {
                    text: root.controller.storageScanState === "checking"
                        ? "Считаем…"
                        : root.controller.storageActionMessage
                }

                SoftButton {
                    icon: "refresh"
                    text: ""
                    implicitWidth: 42
                    enabled: !root.controller.storageScanAction.running
                        && !root.controller.storageCleanupAction.running
                    onClicked: root.controller.refreshStorage()
                }
            }

            ListGroup {
                Repeater {
                    model: [
                        {
                            title: "Кэш пакетов",
                            subtitle: "Оставить две последние версии",
                            value: root.controller.packageCacheSize,
                            icon: "package_2",
                            action: "cache"
                        },
                        {
                            title: "Корзина",
                            subtitle: "Удалённые пользовательские файлы",
                            value: root.controller.trashSize,
                            icon: "delete",
                            action: "trash"
                        },
                        {
                            title: "Системный журнал",
                            subtitle: "Оставить записи за 14 дней",
                            value: root.controller.journalSize,
                            icon: "description",
                            action: "journal"
                        },
                        {
                            title: "Осиротевшие пакеты",
                            subtitle: root.controller.orphanPackages.length > 0
                                ? root.controller.orphanPackages.join(", ")
                                : "Ненужные зависимости не найдены",
                            value: String(
                                root.controller.orphanPackages.length
                            ),
                            icon: "inventory_2",
                            action: "orphans"
                        }
                    ]

                    delegate: ListRow {
                        id: cleanupItem

                        required property var modelData
                        required property int index

                        title: modelData.title
                        subtitle: modelData.subtitle
                        icon: modelData.icon
                        value: modelData.value
                        dividerVisible: index < 3

                        SoftButton {
                            icon: "cleaning_services"
                            text: ""
                            implicitWidth: 40
                            enabled:
                                root.controller.storageScanState === "ready"
                                && !root.controller
                                    .storageCleanupAction.running
                                && !(
                                    cleanupItem.modelData.action === "orphans"
                                    && root.controller
                                        .orphanPackages.length === 0
                                )
                            onClicked:
                                root.controller.requestStorageCleanup(
                                    cleanupItem.modelData.action
                                )
                        }
                    }
                }
            }
        }
    }
}
