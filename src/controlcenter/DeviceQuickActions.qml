import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    required property var kde
    required property var style

    Layout.fillWidth: true
    spacing: 10

    StyledText {
        text: "Быстрые действия"
        color: root.style.ink
        font.pixelSize: Appearance.font.pixelSize.larger
        font.weight: Font.DemiBold
        Layout.topMargin: 4
    }

    GridLayout {
        Layout.fillWidth: true
        columns: width > 700 ? 3 : 2
        columnSpacing: 10
        rowSpacing: 10

        Repeater {
            model: [
                { title: "Отправить файл", subtitle: "Выбрать или бросить", icon: "upload_file", action: "file", enabled: root.kde.reachable },
                { title: "Буфер обмена", subtitle: "Передать текст", icon: "content_copy", action: "clipboard", enabled: root.kde.reachable },
                { title: "Найти телефон", subtitle: "Включить звонок", icon: "notifications_active", action: "ring", enabled: root.kde.reachable },
                { title: "Ping", subtitle: "Передать привет", icon: "waving_hand", action: "ping", enabled: root.kde.reachable },
                { title: "Заблокировать", subtitle: "Погасить экран", icon: "lock", action: "lock", enabled: root.kde.reachable },
                { title: "Файлы телефона", subtitle: "Скоро · файловый мост", icon: "folder_open", action: "files", enabled: false }
            ]
            delegate: Rectangle {
                id: actionCard
                required property var modelData

                Layout.fillWidth: true
                implicitHeight: 86
                radius: 22
                color: !modelData.enabled
                    ? Qt.rgba(root.style.sectionSurface.r, root.style.sectionSurface.g,
                              root.style.sectionSurface.b, 0.45)
                    : (pointer.containsMouse ? root.style.hoverSurface : root.style.sectionSurface)
                border.width: 1
                border.color: root.style.hairline
                opacity: modelData.enabled ? 1 : 0.52
                antialiasing: true

                Behavior on color { ColorAnimation { duration: root.style.motionFast } }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 13
                    spacing: 11
                    MikoIconDisc { style: root.style; icon: actionCard.modelData.icon }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        StyledText {
                            Layout.fillWidth: true
                            text: actionCard.modelData.title
                            color: root.style.ink
                            font.weight: Font.Medium
                            elide: Text.ElideRight
                        }
                        StyledText {
                            Layout.fillWidth: true
                            text: actionCard.modelData.subtitle
                            color: root.style.mutedInk
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            elide: Text.ElideRight
                        }
                    }
                }
                MouseArea {
                    id: pointer
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: actionCard.modelData.enabled
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: {
                        switch (actionCard.modelData.action) {
                        case "file": root.kde.shareFile(); break
                        case "clipboard": root.kde.sendClipboard(); break
                        case "ring": root.kde.ring(); break
                        case "ping": root.kde.ping(); break
                        case "lock": root.kde.lockPhone(); break
                        }
                    }
                }
            }
        }
    }
}
