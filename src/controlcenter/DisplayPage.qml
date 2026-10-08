import QtQuick
import QtQuick.Layouts

MikoPageFlickable {
    id: root

    required property var controller
    required property var hyprlandData
    required property var hyprsunset
    required property var night
    required property var style

    property string activeTab: "topology"

    contentHeight: contentColumn.implicitHeight

    function revealSection(section) {
        if (section === "modes")
            activeTab = "modes";
        else if (section === "comfort")
            activeTab = "comfort";
        else
            activeTab = "topology";
        scrollTo(0);
    }

    ColumnLayout {
        id: contentColumn
        width: parent.width
        spacing: 18

        // Sub-navigation: iOS / "Оформление" style Segmented Capsule Tabs
        MikoSegmentedTabs {
            Layout.alignment: Qt.AlignHCenter
            style: root.style
            currentTab: root.activeTab
            model: [
                {
                    id: "topology",
                    title: I18n.tr("Топология"),
                    icon: "desktop_windows",
                    badge: (root.hyprlandData.monitors && root.hyprlandData.monitors.length > 0)
                        ? String(root.hyprlandData.monitors.length) : ""
                },
                {
                    id: "modes",
                    title: I18n.tr("Режимы"),
                    icon: "display_settings",
                    badge: ""
                },
                {
                    id: "comfort",
                    title: I18n.tr("Комфорт"),
                    icon: "bedtime",
                    badge: (root.hyprsunset && root.hyprsunset.temperatureActive) ? I18n.tr("Вкл") : ""
                }
            ]
            onTabSelected: (tabId) => {
                root.activeTab = tabId;
                root.scrollTo(0);
            }
        }

        // Global preview banner (visible across tabs if preview is active)
        DisplayPreviewBanner {
            active: root.controller.previewActive
            seconds: root.controller.previewSeconds
            rollback: () => root.controller.rollbackPreview()
            confirm: () => root.controller.confirmPreview()
            save: () => root.controller.savePreview()
            style: root.style
        }

        // Tab 1: Topology & Quick Scenes
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 16
            visible: root.activeTab === "topology"

            DisplayTopology {
                id: topologySection
                controller: root.controller
                hyprlandData: root.hyprlandData
                style: root.style
            }

            DisplayScenes {
                id: scenesSection
                controller: root.controller
                style: root.style
                wakeAll: () => root.controller.wakeAll()
            }
        }

        // Tab 2: Modes, Refresh Rates, Scale, Orientation
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 16
            visible: root.activeTab === "modes"

            DisplayModeControls {
                id: modesSection
                controller: root.controller
                style: root.style
            }
        }

        // Tab 3: Brightness, Night Light, Eye Comfort
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 16
            visible: root.activeTab === "comfort"

            DisplayComfort {
                id: comfortSection
                brightnessMonitor: root.controller.selectedBrightnessMonitor()
                hyprsunset: root.hyprsunset
                night: root.night
                style: root.style
            }
        }
    }
}
