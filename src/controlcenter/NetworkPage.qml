import QtQuick

MikoPageFlickable {
    id: root

    required property var controller
    required property var network
    required property var navigation
    required property var style
    readonly property string section: navigation.networkSection

    function openSection(name) {
        root.navigation.networkSection = name;
    }

    contentHeight: sectionLoader.item?.implicitHeight ?? 0

    onSectionChanged:
        root.controller.portsActive = section === "ports"
    Component.onCompleted: {
        root.controller.active = true;
        root.controller.portsActive = section === "ports";
    }
    Component.onDestruction: {
        root.controller.active = false;
        root.controller.portsActive = false;
    }

    Loader {
        id: sectionLoader
        width: parent.width
        sourceComponent: root.section === "throne"
            ? throneSection
            : root.section === "ports"
                ? portsSection : overviewSection
    }

    Component {
        id: overviewSection
        NetworkOverview {
            controller: root.controller
            network: root.network
            style: root.style
            openSection: name => root.openSection(name)
            openNetworkSettings: () =>
                root.controller.openNetworkSettings()
        }
    }

    Component {
        id: throneSection
        NetworkThrone {
            controller: root.controller
            style: root.style
            openThrone: () => root.controller.openThrone()
        }
    }

    Component {
        id: portsSection
        NetworkPorts {
            controller: root.controller
            style: root.style
        }
    }
}
