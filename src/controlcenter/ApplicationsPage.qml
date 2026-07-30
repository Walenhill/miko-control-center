import QtQuick
import QtQuick.Layouts

MikoPageFlickable {
    id: root

    required property var controller
    required property var style

    contentHeight: contentColumn.implicitHeight
    Component.onCompleted: root.controller.active = true
    Component.onDestruction: root.controller.active = false

    ColumnLayout {
        id: contentColumn
        width: parent.width
        spacing: 16

        ApplicationsProcessList {
            style: root.style
            applications: root.controller.runningApplications
            selectedPid: root.controller.selectedPid
            actionMessage: root.controller.actionMessage
            actionRunning: root.controller.actionRunning
            onSelectionRequested: pid =>
                root.controller.selectedPid = pid
            onStopRequested: pid => root.controller.stop(pid)
        }

        ApplicationsAutostart {
            style: root.style
            entries: root.controller.autostartEntries
        }

        ApplicationsNotificationSettings {
            style: root.style
            timeoutSeconds:
                root.controller.notificationTimeoutSeconds
            onTimeoutChangeRequested: seconds =>
                root.controller.setNotificationTimeout(seconds)
        }
    }
}
