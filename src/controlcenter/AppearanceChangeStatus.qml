import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

MikoSurface {
    id: root
    flat: true
    required property var controller
    Layout.fillWidth: true
    visible: controller.statusText !== ""
    implicitHeight: Math.max(48, statusContent.implicitHeight + 28)
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: root.ui.hairline
    }

    RowLayout {
        id: statusContent
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10
        MaterialSymbol {
            iconSize: 20
            text: root.controller.busy ? "hourglass_top"
                : root.controller.generationFailed ? "error" : "check_circle"
            color: root.ui.ink
        }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 3
            StyledText {
                Layout.fillWidth: true
                text: root.controller.statusText
                color: root.ui.ink
                wrapMode: Text.WordWrap
                font.pixelSize: Appearance.font.pixelSize.small
                Accessible.role: Accessible.StaticText
            }
            StyledText {
                Layout.fillWidth: true
                visible: root.controller.busy && root.controller.paletteSelection !== root.controller.appliedPalette
                text: I18n.tr("Выбор отмечен сразу; цвета появятся после генерации")
                color: root.ui.mutedInk
                wrapMode: Text.WordWrap
                font.pixelSize: Appearance.font.pixelSize.smaller
            }
            StyledText {
                Layout.fillWidth: true
                visible: !root.controller.busy && root.controller.latestChange !== null && !root.controller.canUndo
                text: I18n.tr("Настройка изменена извне — возврат недоступен")
                color: root.ui.mutedInk
                wrapMode: Text.WordWrap
                font.pixelSize: Appearance.font.pixelSize.smaller
            }
        }
        MikoButton {
            style: root.ui
            icon: "undo"
            text: I18n.tr("Вернуть прошлое значение")
            visible: root.controller.latestChange !== null
            enabled: root.controller.canUndo
            onClicked: root.controller.undoLastChange()
        }
    }
}
