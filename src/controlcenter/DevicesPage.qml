import QtQuick
import QtQuick.Layouts

MikoPageFlickable {
    id: root

    required property var controller
    required property var kde
    required property var audio
    required property var bluetooth
    required property var bluetoothStatus
    required property var style
    signal navigateRequested(string pageId)

    contentHeight: contentColumn.implicitHeight
    function revealSection(section) {
        const target = section === "connections" ? connectionsSection
            : section === "usb" ? usbSection : phoneSection;
        scrollTo(Math.max(0, target.y - 12));
    }
    Component.onCompleted: root.controller.ensureLoaded()

    ColumnLayout {
        id: contentColumn
        width: parent.width
        spacing: 16

        DevicePhoneHero {
            id: phoneSection
            kde: root.kde
            style: root.style
        }
        DeviceQuickActions {
            kde: root.kde
            style: root.style
        }
        DeviceConnections {
            id: connectionsSection
            audio: root.audio
            bluetooth: root.bluetooth
            bluetoothStatus: root.bluetoothStatus
            style: root.style
            openSound: () => root.navigateRequested("sound")
            openBluetoothManager: () =>
                root.controller.openBluetoothManager()
        }
        DeviceUsbList {
            id: usbSection
            devices: root.controller.usbDevices
            busy: root.controller.usbBusy
            errorMessage: root.controller.usbError
            style: root.style
            onRefreshRequested: root.controller.refreshUsb()
        }
    }
}
