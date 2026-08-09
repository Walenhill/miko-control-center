import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root
    required property var controller
    required property var style
    spacing: 10

    RowLayout {
        Layout.fillWidth: true
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1
            StyledText {
                text: "Снимки настроек"
                color: root.style.ink
                font.pixelSize: Appearance.font.pixelSize.larger
                font.weight: Font.DemiBold
            }
            StyledText {
                text: "Только config.json оболочки и настройки центра"
                color: root.style.mutedInk
                font.pixelSize: Appearance.font.pixelSize.smaller
            }
        }
        MikoButton {
            style: root.style
            icon: "add"
            text: "Создать снимок"
            enabled: !root.controller.busy
            onClicked: root.controller.createSnapshot()
        }
    }

    MikoListGroup {
        style: root.style
        Layout.fillWidth: true
        Repeater {
            model: root.controller.snapshots
            delegate: MikoListRow {
                required property var modelData
                style: root.style
                icon: "restore"
                title: modelData.title
                subtitle: modelData.created + " · " + Math.max(1, Math.round(modelData.bytes / 1024)) + " КБ"
                MikoButton {
                    style: root.style
                    icon: "history"
                    text: "Восстановить"
                    onClicked: root.controller.requestRestore(modelData.path)
                }
            }
        }
        StyledText {
            visible: root.controller.snapshots.length === 0
            text: "Снимков пока нет"
            color: root.style.mutedInk
            padding: 18
        }
    }

    MikoSurface {
        visible: root.controller.pendingRestore !== ""
        accented: true
        style: root.style
        Layout.fillWidth: true
        implicitHeight: confirmRow.implicitHeight + 24
        RowLayout {
            id: confirmRow
            anchors { fill: parent; margins: 12 }
            StyledText {
                Layout.fillWidth: true
                text: "Заменить текущие настройки этим снимком?"
                color: root.style.selectedInk
            }
            MikoButton { style: root.style; text: "Отмена"; onClicked: root.controller.cancelRestore() }
            MikoButton { style: root.style; text: "Восстановить"; selected: true; onClicked: root.controller.confirmRestore() }
        }
    }

    StyledText {
        visible: root.controller.message !== ""
        Layout.fillWidth: true
        text: root.controller.message
        color: root.style.mutedInk
        font.pixelSize: Appearance.font.pixelSize.smaller
    }

    Component.onCompleted: root.controller.refresh()
}
