import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    property var style: null
    readonly property var ui: style ? style : DefaultStyle

    required property var controller

    spacing: 16

    // Section 1: Disks
    MikoSectionHeader {
        style: root.ui
        title: I18n.tr("Дисковые накопители")
        subtitle: I18n.tr("Состояние файловых систем и свободное пространство")
        actionText: I18n.tr("Обновить")
        actionIcon: "refresh"
        onActionClicked: root.controller.refreshDiskUsage()
    }

    GridLayout {
        Layout.fillWidth: true
        columns: width > 600 ? 2 : 1
        columnSpacing: 12
        rowSpacing: 12

        Repeater {
            model: [
                {
                    title: I18n.tr("Система и Home"),
                    subtitle: "ADATA NVMe · Btrfs",
                    free: root.controller.rootDiskFree,
                    used: root.controller.rootDiskUsed,
                    icon: "hard_drive"
                },
                {
                    title: I18n.tr("Архив"),
                    subtitle: I18n.tr("WD 2 ТБ · Ext4"),
                    free: root.controller.hddDiskFree,
                    used: root.controller.hddDiskUsed,
                    icon: "database"
                }
            ]

            delegate: MikoSurface {
                required property var modelData

                Layout.fillWidth: true
                style: root.ui

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 12

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        MikoIconDisc {
                            style: root.ui
                            icon: modelData.icon
                            accented: true
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            StyledText {
                                text: modelData.title
                                color: root.ui.ink
                                font.weight: Font.DemiBold
                                font.pixelSize: Appearance.font.pixelSize.normal
                            }

                            StyledText {
                                text: modelData.subtitle
                                color: root.ui.mutedInk
                                font.pixelSize: Appearance.font.pixelSize.smaller
                            }
                        }

                        MikoBadge {
                            style: root.ui
                            text: Math.round(modelData.used * 100) + "%"
                            tone: modelData.used > 0.90 ? "warning" : "accent"
                        }
                    }

                    MikoProgressBar {
                        Layout.fillWidth: true
                        style: root.ui
                        value: Math.max(0, Math.min(1, modelData.used))
                        tone: modelData.used > 0.90 ? "warning" : "accent"
                    }

                    StyledText {
                        text: modelData.free + I18n.tr(" свободно")
                        color: root.ui.mutedInk
                        font.pixelSize: Appearance.font.pixelSize.smaller
                    }
                }
            }
        }
    }

    // Section 2: Cleanup Tools
    MikoSectionHeader {
        style: root.ui
        title: I18n.tr("Очистка и освобождение места")
        subtitle: root.controller.storageScanState === "checking"
            ? I18n.tr("Выполняется сканирование…")
            : (root.controller.storageActionMessage || I18n.tr("Удаление временных кэшей и пакетов"))
        actionText: I18n.tr("Сканировать")
        actionIcon: "refresh"
        actionEnabled: !root.controller.storageScanAction.running && !root.controller.storageCleanupAction.running
        onActionClicked: root.controller.refreshStorage()
    }

    MikoListGroup {
        style: root.ui
        Layout.fillWidth: true

        Repeater {
            model: [
                {
                    title: I18n.tr("Кэш пакетов Pacman"),
                    subtitle: I18n.tr("Оставить две последние версии пакетов"),
                    value: root.controller.packageCacheSize,
                    icon: "package_2",
                    action: "cache"
                },
                {
                    title: I18n.tr("Корзина пользователя"),
                    subtitle: I18n.tr("Удалённые файлы и документы"),
                    value: root.controller.trashSize,
                    icon: "delete",
                    action: "trash"
                },
                {
                    title: I18n.tr("Системный журнал Systemd"),
                    subtitle: I18n.tr("Оставить логи за последние 14 дней"),
                    value: root.controller.journalSize,
                    icon: "description",
                    action: "journal"
                },
                {
                    title: I18n.tr("Осиротевшие зависимости"),
                    subtitle: root.controller.orphanPackages.length > 0
                        ? root.controller.orphanPackages.join(", ")
                        : I18n.tr("Ненужные пакеты не обнаружены"),
                    value: String(root.controller.orphanPackages.length),
                    icon: "inventory_2",
                    action: "orphans"
                }
            ]

            delegate: MikoListRow {
                id: cleanupItem
                required property var modelData
                required property int index

                style: root.ui
                title: modelData.title
                subtitle: modelData.subtitle
                icon: modelData.icon
                value: modelData.value
                dividerVisible: index < 3

                MikoButton {
                    style: root.ui
                    icon: "cleaning_services"
                    text: I18n.tr("Очистить")
                    enabled: root.controller.storageScanState === "ready"
                        && !root.controller.storageCleanupAction.running
                        && !(cleanupItem.modelData.action === "orphans" && root.controller.orphanPackages.length === 0)
                    onClicked: root.controller.requestStorageCleanup(cleanupItem.modelData.action)
                }
            }
        }
    }
}
