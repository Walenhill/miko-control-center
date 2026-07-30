import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    required property var style
    required property bool wifiAvailable
    required property bool wifiEnabled
    required property string wifiName
    required property bool bluetoothAvailable
    required property bool bluetoothEnabled
    required property bool bluetoothConnected
    required property int bluetoothDeviceCount
    required property string powerProfile
    required property bool notificationsSilent
    required property bool nightLightActive
    required property int screenCount

    signal toggleWifiRequested()
    signal toggleBluetoothRequested()
    signal cyclePowerProfileRequested()
    signal toggleNotificationsRequested()
    signal toggleNightLightRequested()
    signal displaySettingsRequested()

    Layout.fillWidth: true
    spacing: 10

    RowLayout {
        Layout.fillWidth: true

        StyledText {
            Layout.fillWidth: true
            text: "Быстрые действия"
            color: root.style.ink
            font.pixelSize: Appearance.font.pixelSize.larger
            font.weight: Font.DemiBold
        }
        StyledText {
            text: "То, что обычно нужно прямо сейчас"
            color: root.style.mutedInk
            font.pixelSize: Appearance.font.pixelSize.smaller
        }
    }

    GridLayout {
        Layout.fillWidth: true
        columns: width >= 900 ? 3 : 2
        columnSpacing: 9
        rowSpacing: 9

        OverviewActionCard {
            style: root.style
            title: "Wi-Fi"
            subtitle: root.wifiAvailable
                ? (root.wifiName || "Не подключён") : "Нет адаптера"
            icon: root.wifiEnabled ? "wifi" : "wifi_off"
            active: root.wifiEnabled
            available: root.wifiAvailable
            onClicked: root.toggleWifiRequested()
        }
        OverviewActionCard {
            style: root.style
            title: "Bluetooth"
            subtitle: root.bluetoothConnected
                ? root.bluetoothDeviceCount + " подключено" : "Нет устройств"
            icon: root.bluetoothEnabled ? "bluetooth" : "bluetooth_disabled"
            active: root.bluetoothEnabled
            available: root.bluetoothAvailable
            onClicked: root.toggleBluetoothRequested()
        }
        OverviewActionCard {
            style: root.style
            title: "Профиль питания"
            subtitle: root.powerProfile === "performance"
                ? "Производительность"
                : root.powerProfile === "power-saver" ? "Экономия" : "Баланс"
            icon: root.powerProfile === "performance" ? "rocket_launch"
                : root.powerProfile === "power-saver" ? "eco" : "speed"
            active: root.powerProfile === "performance"
            onClicked: root.cyclePowerProfileRequested()
        }
        OverviewActionCard {
            style: root.style
            title: "Не беспокоить"
            subtitle: root.notificationsSilent
                ? "Уведомления приглушены" : "Уведомления активны"
            icon: root.notificationsSilent
                ? "notifications_paused" : "notifications"
            active: root.notificationsSilent
            onClicked: root.toggleNotificationsRequested()
        }
        OverviewActionCard {
            style: root.style
            title: "Ночной свет"
            subtitle: root.nightLightActive
                ? "Тёплые цвета включены" : "Обычная температура"
            icon: root.nightLightActive ? "nightlight" : "light_mode"
            active: root.nightLightActive
            onClicked: root.toggleNightLightRequested()
        }
        OverviewActionCard {
            style: root.style
            title: "Настройки экрана"
            subtitle: root.screenCount + " подключено"
            icon: "desktop_windows"
            onClicked: root.displaySettingsRequested()
        }
    }
}
