import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

MikoPageFlickable {
    id: root

    property var style: null
    readonly property var ui: style ? style : DefaultStyle

    required property var controller
    required property var telemetry
    required property var snapshots
    signal navigateRequested(string pageId)

    property string activeTab: "performance"

    contentHeight: contentColumn.implicitHeight
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    Component.onCompleted: {
        root.controller.activeSection = root.activeTab;
        root.controller.active = true;
    }
    Component.onDestruction: root.controller.active = false

    onActiveTabChanged: loadActiveTab()
    function loadActiveTab() {
        root.controller.ensureSectionLoaded(activeTab);
        if (activeTab === "storage")
            root.snapshots.refresh();
        if (activeTab === "updates" && !root.telemetry.initialized)
            root.telemetry.refresh();
    }

    function revealSection(section) {
        if (section === "storage" || section === "snapshots")
            activeTab = "storage";
        else if (section === "updates" || section === "telemetry")
            activeTab = "updates";
        else
            activeTab = "performance";
        scrollTo(0);
    }

    ColumnLayout {
        id: contentColumn
        width: parent.width
        spacing: 18

        // Sub-navigation: iOS / "Оформление" style Segmented Capsule Tabs
        MikoSegmentedTabs {
            Layout.alignment: Qt.AlignHCenter
            style: root.ui
            currentTab: root.activeTab
            model: [
                {
                    id: "performance",
                    title: I18n.tr("Мониторинг"),
                    icon: "speed",
                    badge: root.controller.watchActiveCount > 0 ? String(root.controller.watchActiveCount) : ""
                },
                {
                    id: "storage",
                    title: I18n.tr("Накопители"),
                    icon: "hard_drive",
                    badge: ""
                },
                {
                    id: "updates",
                    title: I18n.tr("Обновления"),
                    icon: "system_update",
                    badge: root.controller.availableUpdateCount > 0 ? String(root.controller.availableUpdateCount) : ""
                }
            ]
            onTabSelected: (tabId) => {
                root.activeTab = tabId;
                root.scrollTo(0);
            }
        }

        // Tab 1: Performance Monitoring & Hardware Specs
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 16
            visible: root.activeTab === "performance"

            SystemHero {
                Layout.fillWidth: true
                controller: root.controller
                style: root.ui
            }

            SystemWatch {
                id: watchSection
                Layout.fillWidth: true
                controller: root.controller
                style: root.ui
                onSectionRequested: section => root.revealSection(section)
                onNavigateRequested: pageId => root.navigateRequested(pageId)
            }

            SystemPerformance {
                id: performanceSection
                Layout.fillWidth: true
                controller: root.controller
                style: root.ui
            }

            SystemPower {
                Layout.fillWidth: true
                controller: root.controller
                style: root.ui
            }
        }

        // Tab 2: Storage Drives & Configuration Snapshots
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 16
            visible: root.activeTab === "storage"

            SystemStorage {
                id: storageSection
                Layout.fillWidth: true
                controller: root.controller
                style: root.ui
            }

            SystemSnapshots {
                id: snapshotsSection
                Layout.fillWidth: true
                controller: root.snapshots
                style: root.ui
            }
        }

        // Tab 3: Software Updates & System Telemetry
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 16
            visible: root.activeTab === "updates"

            SystemUpdates {
                id: updatesSection
                Layout.fillWidth: true
                controller: root.controller
                style: root.ui
            }

            SystemTelemetry {
                id: telemetrySection
                Layout.fillWidth: true
                controller: root.telemetry
                style: root.ui
            }
        }
    }
}
