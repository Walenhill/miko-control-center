import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    property var style: null
    readonly property var ui: style ? style : DefaultStyle

    required property var controller
    spacing: 12

    MikoSectionHeader {
        style: root.ui
        title: I18n.tr("Снимки настроек системы")
        subtitle: I18n.tr("Резервные копии конфигурации config.json и параметров интерфейса")
        badgeText: (root.controller.snapshots && root.controller.snapshots.length > 0)
            ? String(root.controller.snapshots.length) : "0"
        actionText: I18n.tr("Создать снимок")
        actionIcon: "add"
        actionEnabled: !root.controller.busy
        onActionClicked: root.controller.createSnapshot()
    }

    MikoListGroup {
        style: root.ui
        Layout.fillWidth: true

        Repeater {
            model: root.controller.snapshots || []

            delegate: MikoListRow {
                required property var modelData
                style: root.ui
                icon: "restore"
                title: modelData.title
                subtitle: modelData.created + " · " + Math.max(1, Math.round(modelData.bytes / 1024)) + I18n.tr(" КБ")

                MikoButton {
                    style: root.ui
                    icon: "history"
                    text: I18n.tr("Восстановить")
                    onClicked: root.controller.requestRestore(modelData.path)
                }
            }
        }

        StyledText {
            visible: !root.controller.snapshots || root.controller.snapshots.length === 0
            text: I18n.tr("Снимков конфигурации пока нет")
            color: root.ui.mutedInk
            padding: 18
        }
    }

    // Pending restore confirmation banner
    MikoSurface {
        visible: Boolean(root.controller.pendingRestore && root.controller.pendingRestore !== "")
        style: root.ui
        Layout.fillWidth: true

        RowLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 12

            MaterialSymbol {
                text: "warning"
                iconSize: 22
                color: Appearance.colors.colPrimary
            }

            StyledText {
                Layout.fillWidth: true
                text: I18n.tr("Заменить текущую конфигурацию выбранным снимком?")
                color: root.ui.ink
                font.weight: Font.Medium
            }

            MikoButton {
                style: root.ui
                text: I18n.tr("Отмена")
                onClicked: root.controller.cancelRestore()
            }

            MikoButton {
                style: root.ui
                text: I18n.tr("Восстановить")
                selected: true
                onClicked: root.controller.confirmRestore()
            }
        }
    }

    StyledText {
        visible: Boolean(root.controller.message && root.controller.message !== "")
        Layout.fillWidth: true
        text: root.controller.message || ""
        color: root.ui.mutedInk
        font.pixelSize: Appearance.font.pixelSize.smaller
    }

}
