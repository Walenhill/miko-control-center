import QtQuick
import QtQuick.Layouts
import qs.modules.common

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

    contentHeight: contentColumn.implicitHeight

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

    ColumnLayout {
        id: contentColumn
        width: parent.width
        spacing: 18

        MikoSegmentedTabs {
            Layout.alignment: Qt.AlignHCenter
            style: root.style
            currentTab: root.section === "throne" || root.section === "ports" ? root.section : "overview"
            model: [
                {
                    id: "overview",
                    title: I18n.tr("Обзор сети"),
                    icon: "lan"
                },
                {
                    id: "throne",
                    title: "Throne VPN",
                    icon: "vpn_lock",
                    badge: root.controller.tunnelActive ? I18n.tr("Активен") : ""
                },
                {
                    id: "ports",
                    title: I18n.tr("Порты и UFW"),
                    icon: "policy",
                    badge: (root.controller.listeningPorts && root.controller.listeningPorts.length > 0)
                        ? String(root.controller.listeningPorts.length) : ""
                }
            ]
            onTabSelected: tabId => root.openSection(tabId)
        }

        Loader {
            id: sectionLoader
            Layout.fillWidth: true
            sourceComponent: root.section === "throne"
                ? throneSection
                : root.section === "ports"
                    ? portsSection : overviewSection
        }
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
