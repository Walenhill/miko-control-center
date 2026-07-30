import QtQuick
import QtQuick.Layouts

MikoPageFlickable {
    id: root

    required property var style
    required property var network
    required property var networkState
    required property var resourceUsage
    required property var updates
    required property var kdeConnect
    required property var audio
    required property var bluetoothStatus
    required property var hyprsunset
    required property var systemState
    required property var servicesState
    required property var applicationsState
    required property string userName
    required property int screenCount

    signal toggleWifiRequested()
    signal toggleBluetoothRequested()
    signal cyclePowerProfileRequested()
    signal toggleNotificationsRequested()
    signal toggleNightLightRequested()
    signal navigateRequested(string pageId)

    readonly property bool attentionVisible:
        systemState.watchActiveCount > 0
        || updates.count > 0 || systemState.rootDiskUsed >= 0.88
        || !servicesState.diagnosticHealthy
    readonly property var firstWatchEvent: systemState.watchEvents.filter(
        event => !event.resolved && !event.ignored
    )[0]

    contentHeight: contentColumn.implicitHeight
    Component.onCompleted: {
        root.systemState.ensureOverviewLoaded();
        root.networkState.ensureLoaded();
        root.applicationsState.ensureNotificationLoaded();
        root.servicesState.ensureLoaded();
    }

    ColumnLayout {
        id: contentColumn
        width: parent.width
        spacing: 16

        OverviewHero {
            style: root.style
            userName: root.userName
            connectionSummary: (root.network.ethernet
                ? "Интернет работает"
                : (root.network.networkName || "Сеть не подключена"))
                + (root.kdeConnect.reachable ? " · телефон на связи" : "")
            powerProfile: root.systemState.powerProfile
            cpuUsage: root.resourceUsage.cpuUsage
            memoryUsage: root.resourceUsage.memoryUsedPercentage
            activeIssueCount: root.systemState.watchActiveCount
            updateCount: root.updates.count
        }

        OverviewMetrics {
            style: root.style
            cpuUsage: root.resourceUsage.cpuUsage
            memoryUsage: root.resourceUsage.memoryUsedPercentage
            networkValue: root.network.ethernet
                ? "LAN" : (root.network.networkName || "Нет")
            networkIcon: root.network.materialSymbol
            diskFree: root.systemState.rootDiskFree
            diskUsed: root.systemState.rootDiskUsed
        }

        OverviewQuickActions {
            style: root.style
            wifiAvailable: root.networkState.wifiHardwareAvailable
            wifiEnabled: root.network.wifiEnabled
            wifiName: root.network.networkName || ""
            bluetoothAvailable: root.bluetoothStatus.available
            bluetoothEnabled: root.bluetoothStatus.enabled
            bluetoothConnected: root.bluetoothStatus.connected
            bluetoothDeviceCount: root.bluetoothStatus.activeDeviceCount
            powerProfile: root.systemState.powerProfile
            notificationsSilent:
                root.applicationsState.notificationsSilent
            nightLightActive: root.hyprsunset.temperatureActive
            screenCount: root.screenCount
            onToggleWifiRequested: root.toggleWifiRequested()
            onToggleBluetoothRequested: root.toggleBluetoothRequested()
            onCyclePowerProfileRequested: root.cyclePowerProfileRequested()
            onToggleNotificationsRequested: root.toggleNotificationsRequested()
            onToggleNightLightRequested: root.toggleNightLightRequested()
            onDisplaySettingsRequested:
                root.navigateRequested("displays")
        }

        OverviewStatusCards {
            style: root.style
            phoneReachable: root.kdeConnect.reachable
            phoneName: root.kdeConnect.deviceName || "Телефон"
            phoneBattery: root.kdeConnect.batteryCharge
            audioAvailable: !!root.audio.sink
            audioMuted: root.audio.sink ? root.audio.sink.audio.muted : false
            audioName: root.audio.sink
                ? root.audio.friendlyDeviceName(root.audio.sink) : ""
            audioVolume: root.audio.value
            attentionVisible: root.attentionVisible
            attentionIcon: root.systemState.watchActiveCount > 0
                ? "visibility" : root.updates.count > 0
                    ? "system_update"
                    : root.systemState.rootDiskUsed >= 0.88
                        ? "hard_drive" : "build_circle"
            attentionTitle: root.systemState.watchActiveCount > 0
                ? ((root.firstWatchEvent && root.firstWatchEvent.title)
                    || "Miko Watch нашёл событие")
                : root.updates.count > 0
                    ? root.updates.count + " обновлений доступно"
                    : root.systemState.rootDiskUsed >= 0.88
                        ? "Заканчивается место" : "Диагностика нашла проблему"
            attentionSubtitle: root.systemState.watchUnreadCount > 0
                ? root.systemState.watchUnreadCount
                    + " новых событий внутри центра управления"
                : "Открыть подробности и выбрать действие"
            attentionPage: root.systemState.watchActiveCount > 0
                || root.updates.count > 0
                || root.systemState.rootDiskUsed >= 0.88
                    ? "system" : "services"
            onNavigateRequested: pageId =>
                root.navigateRequested(pageId)
        }
    }
}
