import QtQuick
import QtQuick.Layouts

MikoPageFlickable {
    id: root

    required property var controller
    required property var style

    contentHeight: contentColumn.implicitHeight
    function revealSection(section) {
        const target = section === "autostart" ? autostartSection
            : section === "notifications" || section === "privacy"
                ? notificationsSection : processesSection;
        scrollTo(Math.max(0, target.y - 12));
    }
    Component.onCompleted: root.controller.active = true
    Component.onDestruction: root.controller.active = false

    ColumnLayout {
        id: contentColumn
        width: parent.width
        spacing: 16

        ApplicationsProcessList {
            id: processesSection
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
            id: autostartSection
            style: root.style
            entries: root.controller.autostartEntries
        }

        ApplicationsNotificationSettings {
            id: notificationsSection
            style: root.style
            timeoutSeconds:
                root.controller.notificationTimeoutSeconds
            onTimeoutChangeRequested: seconds =>
                root.controller.setNotificationTimeout(seconds)
        }
    }
}
