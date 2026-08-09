import QtQuick
import QtQuick.Layouts

MikoPageFlickable {
    id: root

    required property var controller
    required property var navigation
    required property var style
    signal navigateRequested(string pageId)

    contentHeight: contentColumn.implicitHeight
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    Component.onCompleted: root.controller.active = true
    Component.onDestruction: root.controller.active = false
    function revealSection(section) {
        const target = section === "diagnostics"
            ? diagnosticsSection : integrationsSection;
        scrollTo(Math.max(0, target.y - 12));
    }

    ColumnLayout {
        id: contentColumn

        width: parent.width
        spacing: 18

        ServicesHeroSection {
            Layout.fillWidth: true
            controller: root.controller
            style: root.style
        }

        ServicesPinnedSection {
            Layout.fillWidth: true
            controller: root.controller
            selectedComponentId: root.navigation.selectedComponentId
            style: root.style
            onComponentRequested: componentId => {
                root.navigation.selectedComponentId = componentId;
            }
        }

        ServicesInspectorSection {
            controller: root.controller
            selectedComponentId: root.navigation.selectedComponentId
            style: root.style
            onNavigateRequested: pageId => root.navigateRequested(pageId)
        }

        ServicesAllComponentsSection {
            controller: root.controller
            style: root.style
            onComponentRequested: componentId => {
                root.navigation.selectedComponentId = componentId;
            }
        }

        ServicesIntegrationsSection {
            id: integrationsSection
            Layout.fillWidth: true
            controller: root.controller
            style: root.style
            onNavigateRequested: pageId => root.navigateRequested(pageId)
        }

        ServicesDiagnosticsSection {
            id: diagnosticsSection
            controller: root.controller
            style: root.style
        }
    }
}
