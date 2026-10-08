import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    property var style: null
    readonly property var ui: style ? style : DefaultStyle

    required property var entries
    signal refreshRequested()

    Layout.fillWidth: true
    spacing: 14

    MikoSectionHeader {
        style: root.ui
        title: I18n.tr("Автозапуск")
        subtitle: I18n.tr("Приложения и фоновые процессы, запускаемые при входе в систему")

        RowLayout {
            spacing: 8

            MikoBadge {
                style: root.ui
                text: (root.entries ? root.entries.length : 0) + I18n.tr(" записей")
                tone: "neutral"
            }

            MikoButton {
                style: root.ui
                icon: "refresh"
                text: I18n.tr("Обновить")
                onClicked: root.refreshRequested()
            }
        }
    }

    MikoListGroup {
        visible: root.entries && root.entries.length > 0
        style: root.ui

        Repeater {
            model: root.entries

            delegate: MikoListRow {
                id: rowDelegate
                required property var modelData
                required property int index

                style: root.ui
                title: rowDelegate.modelData.name ? rowDelegate.modelData.name : I18n.tr("Без названия")
                subtitle: rowDelegate.modelData.execLine ? rowDelegate.modelData.execLine : ""
                icon: "rocket_launch"
                dividerVisible: rowDelegate.index < (root.entries ? root.entries.length - 1 : 0)

                MikoBadge {
                    style: root.ui
                    text: I18n.tr("Активно")
                    tone: "success"
                    icon: "check"
                }
            }
        }
    }

    MikoSurface {
        visible: !root.entries || root.entries.length === 0
        style: root.ui
        Layout.fillWidth: true
        implicitHeight: 88

        RowLayout {
            anchors.centerIn: parent
            spacing: 10

            MaterialSymbol {
                text: "rocket_launch"
                iconSize: 22
                color: root.ui.mutedInk
            }
            StyledText {
                text: I18n.tr("Активных записей автозапуска не найдено")
                color: root.ui.mutedInk
                font.pixelSize: Appearance.font.pixelSize.small
            }
        }
    }
}
