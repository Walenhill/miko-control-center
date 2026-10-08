import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

MikoPageFlickable {
    id: root

    property var style: null
    readonly property var ui: style ? style : DefaultStyle

    required property var controller
    required property var navigation
    signal navigateRequested(string pageId)

    property string activeTab: "components"

    contentHeight: contentColumn.implicitHeight
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    Component.onCompleted: root.controller.active = true
    Component.onDestruction: root.controller.active = false

    function revealSection(section) {
        if (section === "diagnostics")
            activeTab = "diagnostics";
        else if (section === "all")
            activeTab = "all";
        else
            activeTab = "components";
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
                    id: "components",
                    title: I18n.tr("Компоненты"),
                    icon: "widgets",
                    badge: String(root.controller.activeServiceCount())
                },
                {
                    id: "all",
                    title: I18n.tr("Все службы"),
                    icon: "list",
                    badge: ""
                },
                {
                    id: "diagnostics",
                    title: I18n.tr("Журнал"),
                    icon: "description",
                    badge: ""
                }
            ]
            onTabSelected: (tabId) => {
                root.activeTab = tabId;
                root.scrollTo(0);
            }
        }

        // Tab 1: Pinned Key Components & Integrations
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 16
            visible: root.activeTab === "components"

            ServicesHeroSection {
                Layout.fillWidth: true
                controller: root.controller
                style: root.ui
            }

            ServicesPinnedSection {
                Layout.fillWidth: true
                controller: root.controller
                selectedComponentId: root.navigation.selectedComponentId
                style: root.ui
                onComponentRequested: componentId => {
                    root.navigation.selectedComponentId = componentId;
                }
            }

            ServicesInspectorSection {
                controller: root.controller
                selectedComponentId: root.navigation.selectedComponentId
                style: root.ui
                onNavigateRequested: pageId => root.navigateRequested(pageId)
            }

            ServicesIntegrationsSection {
                id: integrationsSection
                Layout.fillWidth: true
                controller: root.controller
                style: root.ui
                onNavigateRequested: pageId => root.navigateRequested(pageId)
            }
        }

        // Tab 2: All Systemd Services List
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 16
            visible: root.activeTab === "all"

            ServicesAllComponentsSection {
                controller: root.controller
                style: root.ui
                onComponentRequested: componentId => {
                    root.navigation.selectedComponentId = componentId;
                }
            }

            ServicesInspectorSection {
                controller: root.controller
                selectedComponentId: root.navigation.selectedComponentId
                style: root.ui
                onNavigateRequested: pageId => root.navigateRequested(pageId)
            }
        }

        // Tab 3: System Diagnostics and Journal Log
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 16
            visible: root.activeTab === "diagnostics"

            ServicesDiagnosticsSection {
                id: diagnosticsSection
                controller: root.controller
                style: root.ui
            }
        }
    }
}
