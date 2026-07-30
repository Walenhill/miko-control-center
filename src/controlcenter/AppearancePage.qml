import QtQuick
import QtQuick.Layouts

MikoPageFlickable {
    id: root

    required property var controller
    required property var style

    contentHeight: contentColumn.implicitHeight

    ColumnLayout {
        id: contentColumn
        width: parent.width
        spacing: 16

        AppearanceHub {
            visible: root.controller.editor === ""
            controller: root.controller
            style: root.style
        }

        ColumnLayout {
            visible: root.controller.editor !== ""
            Layout.fillWidth: true
            Layout.maximumWidth: 980
            Layout.alignment: Qt.AlignHCenter
            spacing: 16

            AppearanceEditorHeader {
                controller: root.controller
                style: root.style
            }
            AppearanceWallpaperEditor {
                visible: root.controller.editor === "wallpaper"
                controller: root.controller
                style: root.style
            }
            AppearanceBarEditor {
                visible: root.controller.editor === "bar"
                controller: root.controller
                style: root.style
            }
            AppearanceInterfaceEditor {
                visible: root.controller.editor === "interface"
                style: root.style
            }
            AppearanceNotificationsEditor {
                visible: root.controller.editor === "notifications"
                style: root.style
            }
            AppearanceLockEditor {
                visible: root.controller.editor === "lock"
                style: root.style
            }
            AppearanceAdvancedEditor {
                visible: root.controller.editor === "advanced"
                style: root.style
            }
        }
    }
}
