import QtQuick
import QtQuick.Layouts
import qs.modules.common

MikoPageFlickable {
    id: root

    property var style: null
    readonly property var ui: style ? style : DefaultStyle

    required property var controller
    required property var kde
    required property var audio
    required property var bluetooth
    required property var bluetoothStatus
    signal navigateRequested(string pageId)

    property string activeTab: "phone"

    contentHeight: contentColumn.implicitHeight

    function revealSection(section) {
        if (section === "connections")
            activeTab = "connections";
        else if (section === "usb")
            activeTab = "usb";
        else
            activeTab = "phone";
        scrollTo(0);
    }

    Component.onCompleted: root.controller.ensureLoaded()

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
                    id: "phone",
                    title: I18n.tr("Телефон"),
                    icon: "smartphone",
                    badge: root.kde.reachable ? I18n.tr("Онлайн") : ""
                },
                {
                    id: "connections",
                    title: I18n.tr("Подключения"),
                    icon: "headphones",
                    badge: (root.bluetoothStatus && root.bluetoothStatus.connectedDevices && root.bluetoothStatus.connectedDevices.length > 0)
                        ? String(root.bluetoothStatus.connectedDevices.length) : ""
                },
                {
                    id: "usb",
                    title: I18n.tr("USB"),
                    icon: "usb",
                    badge: (root.controller.usbDevices && root.controller.usbDevices.length > 0)
                        ? String(root.controller.usbDevices.length) : ""
                }
            ]
            onTabSelected: (tabId) => {
                root.activeTab = tabId;
                root.scrollTo(0);
            }
        }

        // Tab 1: KDE Connect Phone Hero & Quick Actions
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 16
            visible: root.activeTab === "phone"

            DevicePhoneHero {
                id: phoneSection
                kde: root.kde
                style: root.ui
            }

            DeviceQuickActions {
                kde: root.kde
                style: root.ui
            }
        }

        // Tab 2: Audio Sink & Bluetooth Connections
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 16
            visible: root.activeTab === "connections"

            DeviceConnections {
                id: connectionsSection
                audio: root.audio
                bluetooth: root.bluetooth
                bluetoothStatus: root.bluetoothStatus
                style: root.ui
                openSound: () => root.navigateRequested("sound")
                openBluetoothManager: () => root.controller.openBluetoothManager()
            }
        }

        // Tab 3: Connected USB Devices
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 16
            visible: root.activeTab === "usb"

            DeviceUsbList {
                id: usbSection
                devices: root.controller.usbDevices
                busy: root.controller.usbBusy
                errorMessage: root.controller.usbError
                style: root.ui
                onRefreshRequested: root.controller.refreshUsb()
            }
        }
    }
}
