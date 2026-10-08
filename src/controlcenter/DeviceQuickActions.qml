import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    property var style: null
    readonly property var ui: style ? style : DefaultStyle

    required property var kde

    Layout.fillWidth: true
    spacing: 12

    MikoSectionHeader {
        style: root.ui
        title: I18n.tr("Быстрые действия")
        subtitle: I18n.tr("Взаимодействие со смартфоном через KDE Connect")
        badgeText: root.kde.reachable ? I18n.tr("Доступно") : I18n.tr("Офлайн")
    }

    GridLayout {
        Layout.fillWidth: true
        columns: width > 700 ? 3 : 2
        columnSpacing: 12
        rowSpacing: 12

        Repeater {
            model: [
                { title: I18n.tr("Отправить файл"), subtitle: I18n.tr("Выбрать файл в диалоге"), icon: "upload_file", action: "file", enabled: root.kde.reachable },
                { title: I18n.tr("Буфер обмена"), subtitle: I18n.tr("Синхронизировать текст"), icon: "content_copy", action: "clipboard", enabled: root.kde.reachable },
                { title: I18n.tr("Найти телефон"), subtitle: I18n.tr("Включить громкий звонок"), icon: "notifications_active", action: "ring", enabled: root.kde.reachable },
                { title: "Ping", subtitle: I18n.tr("Проверить отклик устройства"), icon: "waving_hand", action: "ping", enabled: root.kde.reachable },
                { title: I18n.tr("Заблокировать"), subtitle: I18n.tr("Погасить экран смартфона"), icon: "lock", action: "lock", enabled: root.kde.reachable },
                { title: I18n.tr("Файлы телефона"), subtitle: I18n.tr("Файловый браузер (скоро)"), icon: "folder_open", action: "files", enabled: false }
            ]

            delegate: MikoSurface {
                id: actionCard
                required property var modelData

                Layout.fillWidth: true
                implicitHeight: 84
                style: root.ui
                interactive: actionCard.modelData.enabled
                opacity: actionCard.modelData.enabled ? 1 : 0.48

                RowLayout {
                    anchors {
                        fill: parent
                        margins: 14
                    }
                    spacing: 12

                    MikoIconDisc {
                        style: root.ui
                        icon: actionCard.modelData.icon
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        StyledText {
                            Layout.fillWidth: true
                            text: actionCard.modelData.title
                            color: root.ui.ink
                            font.weight: Font.DemiBold
                            font.pixelSize: Appearance.font.pixelSize.normal
                            elide: Text.ElideRight
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: actionCard.modelData.subtitle
                            color: root.ui.mutedInk
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            elide: Text.ElideRight
                        }
                    }

                    MaterialSymbol {
                        visible: actionCard.modelData.enabled
                        text: "arrow_forward"
                        iconSize: 18
                        color: root.ui.mutedInk
                        Layout.alignment: Qt.AlignVCenter
                    }
                }

                onClicked: {
                    switch (actionCard.modelData.action) {
                    case "file": root.kde.shareFile(); break;
                    case "clipboard": root.kde.sendClipboard(); break;
                    case "ring": root.kde.ring(); break;
                    case "ping": root.kde.ping(); break;
                    case "lock": root.kde.lockPhone(); break;
                    }
                }
            }
        }
    }
}
