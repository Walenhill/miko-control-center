import QtQuick
import QtQuick.Layouts
import qs.modules.common

MikoPageFlickable {
    id: root

    required property var controller
    required property var style

    property string activeTab: "processes"

    contentHeight: contentColumn.implicitHeight

    function revealSection(section) {
        if (section === "autostart")
            activeTab = "autostart";
        else if (section === "notifications" || section === "privacy")
            activeTab = "notifications";
        else
            activeTab = "processes";
        scrollTo(0);
    }

    Component.onCompleted: root.controller.active = true
    Component.onDestruction: root.controller.active = false

    Binding {
        target: root.controller
        property: "processesVisible"
        value: root.visible && root.activeTab === "processes"
        restoreMode: Binding.RestoreBindingOrValue
    }

    ColumnLayout {
        id: contentColumn
        width: parent.width
        spacing: 18

        // Sub-navigation: iOS/macOS / "Оформление" style Segmented Capsule Tabs
        MikoSegmentedTabs {
            Layout.alignment: Qt.AlignHCenter
            style: root.style
            currentTab: root.activeTab
            model: [
                {
                    id: "processes",
                    title: I18n.tr("Процессы"),
                    icon: "apps",
                    badge: (root.controller.runningApplications && root.controller.runningApplications.length > 0)
                        ? String(root.controller.runningApplications.length) : ""
                },
                {
                    id: "autostart",
                    title: I18n.tr("Автозапуск"),
                    icon: "rocket_launch",
                    badge: (root.controller.autostartEntries && root.controller.autostartEntries.length > 0)
                        ? String(root.controller.autostartEntries.length) : ""
                },
                {
                    id: "notifications",
                    title: I18n.tr("Уведомления"),
                    icon: "notifications",
                    badge: root.controller.notificationsSilent ? I18n.tr("Тишина") : ""
                }
            ]
            onTabSelected: tabId => root.activeTab = tabId
        }

        ApplicationsProcessList {
            visible: root.activeTab === "processes"
            style: root.style
            applications: root.controller.runningApplications
            selectedPid: root.controller.selectedPid
            actionMessage: root.controller.actionMessage
            actionRunning: root.controller.actionRunning
            onSelectionRequested: pid =>
                root.controller.selectedPid = pid
            onStopRequested: pid => root.controller.stop(pid)
            onRefreshRequested: () => root.controller.refreshProcesses()
        }

        ApplicationsAutostart {
            visible: root.activeTab === "autostart"
            style: root.style
            entries: root.controller.autostartEntries
            onRefreshRequested: () => root.controller.refreshAutostart()
        }

        ApplicationsNotificationSettings {
            visible: root.activeTab === "notifications"
            style: root.style
            timeoutSeconds: root.controller.notificationTimeoutSeconds
            notificationsSilent: root.controller.notificationsSilent
            onTimeoutChangeRequested: seconds =>
                root.controller.setNotificationTimeout(seconds)
            onToggleSilentRequested: () =>
                root.controller.toggleNotifications()
        }
    }
}
