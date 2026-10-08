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
    required property var actionOrder
    required property var hiddenActions

    signal toggleWifiRequested()
    signal toggleBluetoothRequested()
    signal cyclePowerProfileRequested()
    signal toggleNotificationsRequested()
    signal toggleNightLightRequested()
    signal displaySettingsRequested()

    function metadata(id) {
        if (id === "wifi") return {
            title: "Wi-Fi",
            subtitle: root.wifiAvailable
                ? (root.wifiName || I18n.tr("Не подключён")) : I18n.tr("Нет адаптера"),
            icon: root.wifiEnabled ? "wifi" : "wifi_off",
            active: root.wifiEnabled,
            available: root.wifiAvailable
        };
        if (id === "bluetooth") return {
            title: "Bluetooth",
            subtitle: root.bluetoothConnected
                ? root.bluetoothDeviceCount + I18n.tr(" подключено") : I18n.tr("Нет устройств"),
            icon: root.bluetoothEnabled ? "bluetooth" : "bluetooth_disabled",
            active: root.bluetoothEnabled,
            available: root.bluetoothAvailable
        };
        if (id === "power") return {
            title: I18n.tr("Профиль питания"),
            subtitle: root.powerProfile === "performance"
                ? I18n.tr("Производительность")
                : root.powerProfile === "power-saver" ? I18n.tr("Экономия") : I18n.tr("Баланс"),
            icon: root.powerProfile === "performance" ? "rocket_launch"
                : root.powerProfile === "power-saver" ? "eco" : "speed",
            active: root.powerProfile === "performance",
            available: root.powerProfile !== "unavailable"
        };
        if (id === "notifications") return {
            title: I18n.tr("Не беспокоить"),
            subtitle: root.notificationsSilent
                ? I18n.tr("Уведомления приглушены") : I18n.tr("Уведомления активны"),
            icon: root.notificationsSilent
                ? "notifications_paused" : "notifications",
            active: root.notificationsSilent,
            available: true
        };
        if (id === "night") return {
            title: I18n.tr("Ночной свет"),
            subtitle: root.nightLightActive
                ? I18n.tr("Тёплые цвета включены") : I18n.tr("Обычная температура"),
            icon: root.nightLightActive ? "nightlight" : "light_mode",
            active: root.nightLightActive,
            available: true
        };
        return {
            title: I18n.tr("Настройки экрана"),
            subtitle: root.screenCount + I18n.tr(" подключено"),
            icon: "desktop_windows",
            active: false,
            available: true
        };
    }

    function trigger(id) {
        if (id === "wifi") root.toggleWifiRequested();
        else if (id === "bluetooth") root.toggleBluetoothRequested();
        else if (id === "power") root.cyclePowerProfileRequested();
        else if (id === "notifications") root.toggleNotificationsRequested();
        else if (id === "night") root.toggleNightLightRequested();
        else if (id === "displays") root.displaySettingsRequested();
    }

    readonly property var visibleActions: actionOrder.filter(
        id => !hiddenActions.includes(id)
    )

    Layout.fillWidth: true
    spacing: 12

    MikoSectionHeader {
        style: root.style
        title: I18n.tr("Быстрые действия")
        subtitle: I18n.tr("Быстрое переключение беспроводных сетей, профилей и режимов экрана")
    }

    GridLayout {
        Layout.fillWidth: true
        columns: width >= 900 ? 3 : 2
        columnSpacing: 9
        rowSpacing: 9

        Repeater {
            model: root.visibleActions

            delegate: OverviewActionCard {
                required property string modelData
                readonly property var actionData: root.metadata(modelData)
                style: root.style
                title: actionData.title
                subtitle: actionData.subtitle
                icon: actionData.icon
                active: actionData.active
                available: actionData.available
                onClicked: root.trigger(modelData)
            }
        }
    }
}
