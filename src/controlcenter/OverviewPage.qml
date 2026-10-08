import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

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
    required property var preferences
    required property var operations

    signal toggleWifiRequested()
    signal toggleBluetoothRequested()
    signal cyclePowerProfileRequested()
    signal toggleNotificationsRequested()
    signal toggleNightLightRequested()
    signal navigateRequested(string pageId)

    property string activeTab: root.preferences.overviewEditing ? "customize" : "summary"

    onActiveTabChanged: {
        if (activeTab !== "customize" && root.preferences.overviewEditing) {
            root.preferences.overviewEditing = false;
        }
    }

    readonly property bool attentionVisible:
        systemState.watchActiveCount > 0
        || updates.count > 0 || systemState.rootDiskUsed >= 0.88
        || !servicesState.diagnosticHealthy
    readonly property var firstWatchEvent: systemState.watchEvents.filter(
        event => !event.resolved && !event.ignored
    )[0]

    contentHeight: contentColumn.implicitHeight
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    Component.onCompleted: {
        root.systemState.ensureOverviewLoaded();
        root.networkState.ensureLoaded();
        root.applicationsState.ensureNotificationLoaded();
        root.servicesState.ensureLoaded();
    }

    ColumnLayout {
        id: contentColumn
        width: parent.width
        spacing: 18

        // Unified Sub-navigation Segmented Capsule Tabs
        MikoSegmentedTabs {
            Layout.alignment: Qt.AlignHCenter
            style: root.style
            currentTab: root.activeTab
            model: [
                {
                    id: "summary",
                    title: I18n.tr("Сводка"),
                    icon: "dashboard",
                    badge: root.attentionVisible ? I18n.tr("Внимание") : ""
                },
                {
                    id: "actions",
                    title: I18n.tr("Быстрые действия"),
                    icon: "bolt",
                    badge: ""
                },
                {
                    id: "customize",
                    title: I18n.tr("Настройка"),
                    icon: "tune",
                    badge: ""
                }
            ]
            onTabSelected: (tabId) => {
                root.activeTab = tabId;
                if (tabId === "customize")
                    root.preferences.overviewEditing = true;
                else
                    root.preferences.overviewEditing = false;
                root.scrollTo(0);
            }
        }

        // Tab 1: Dashboard Summary
        ColumnLayout {
            Layout.fillWidth: true
            spacing: root.preferences.compactOverview ? 10 : 16
            visible: root.activeTab === "summary"

            OverviewHero {
                visible: root.preferences.showOverviewHero
                style: root.style
                userName: root.userName
                connectionSummary: (root.network.ethernet
                    ? I18n.tr("Интернет работает")
                    : (root.network.networkName || I18n.tr("Сеть не подключена")))
                    + (root.kdeConnect.reachable ? I18n.tr(" · телефон на связи") : "")
                powerProfile: root.systemState.powerProfile
                cpuUsage: root.resourceUsage.cpuUsage
                memoryUsage: root.resourceUsage.memoryUsedPercentage
                activeIssueCount: root.systemState.watchActiveCount
                updateCount: root.updates.count
            }

            OverviewMetrics {
                visible: root.preferences.showOverviewMetrics
                style: root.style
                cpuUsage: root.resourceUsage.cpuUsage
                memoryUsage: root.resourceUsage.memoryUsedPercentage
                networkValue: root.network.ethernet
                    ? "LAN" : (root.network.networkName || I18n.tr("Нет"))
                networkIcon: root.network.materialSymbol
                diskFree: root.systemState.rootDiskFree
                diskUsed: root.systemState.rootDiskUsed
            }

            OverviewQuickActions {
                visible: root.preferences.showOverviewQuickActions
                style: root.style
                wifiAvailable: root.networkState.wifiHardwareAvailable
                wifiEnabled: root.network.wifiEnabled
                wifiName: root.network.networkName || ""
                bluetoothAvailable: root.bluetoothStatus.available
                bluetoothEnabled: root.bluetoothStatus.enabled
                bluetoothConnected: root.bluetoothStatus.connected
                bluetoothDeviceCount: root.bluetoothStatus.activeDeviceCount
                powerProfile: root.systemState.powerProfile
                notificationsSilent: root.applicationsState.notificationsSilent
                nightLightActive: root.hyprsunset.temperatureActive
                screenCount: root.screenCount
                actionOrder: root.preferences.quickActionOrder
                hiddenActions: root.preferences.hiddenQuickActions
                onToggleWifiRequested: root.toggleWifiRequested()
                onToggleBluetoothRequested: root.toggleBluetoothRequested()
                onCyclePowerProfileRequested: root.cyclePowerProfileRequested()
                onToggleNotificationsRequested: root.toggleNotificationsRequested()
                onToggleNightLightRequested: root.toggleNightLightRequested()
                onDisplaySettingsRequested: root.navigateRequested("displays")
            }

            OverviewStatusCards {
                visible: root.preferences.showOverviewDevices
                    || (root.preferences.showOverviewAttention && root.attentionVisible)
                style: root.style
                phoneReachable: root.kdeConnect.reachable
                phoneName: root.kdeConnect.deviceName || I18n.tr("Телефон")
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
                        || I18n.tr("Miko Watch нашёл событие"))
                    : root.updates.count > 0
                        ? root.updates.count + I18n.tr(" обновлений доступно")
                        : root.systemState.rootDiskUsed >= 0.88
                            ? I18n.tr("Заканчивается место") : I18n.tr("Диагностика нашла проблему")
                attentionSubtitle: root.systemState.watchUnreadCount > 0
                    ? root.systemState.watchUnreadCount
                        + I18n.tr(" новых событий внутри центра управления")
                    : I18n.tr("Открыть подробности и выбрать действие")
                attentionPage: root.systemState.watchActiveCount > 0
                    || root.updates.count > 0
                    || root.systemState.rootDiskUsed >= 0.88
                        ? "system" : "services"
                showDevices: root.preferences.showOverviewDevices
                showAttention: root.preferences.showOverviewAttention
                onNavigateRequested: pageId => root.navigateRequested(pageId)
            }
        }

        // Tab 2: Dedicated Quick Actions View
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 16
            visible: root.activeTab === "actions"

            OverviewQuickActions {
                Layout.fillWidth: true
                style: root.style
                wifiAvailable: root.networkState.wifiHardwareAvailable
                wifiEnabled: root.network.wifiEnabled
                wifiName: root.network.networkName || ""
                bluetoothAvailable: root.bluetoothStatus.available
                bluetoothEnabled: root.bluetoothStatus.enabled
                bluetoothConnected: root.bluetoothStatus.connected
                bluetoothDeviceCount: root.bluetoothStatus.activeDeviceCount
                powerProfile: root.systemState.powerProfile
                notificationsSilent: root.applicationsState.notificationsSilent
                nightLightActive: root.hyprsunset.temperatureActive
                screenCount: root.screenCount
                actionOrder: root.preferences.quickActionOrder
                hiddenActions: [] // Show all actions in dedicated tab
                onToggleWifiRequested: root.toggleWifiRequested()
                onToggleBluetoothRequested: root.toggleBluetoothRequested()
                onCyclePowerProfileRequested: root.cyclePowerProfileRequested()
                onToggleNotificationsRequested: root.toggleNotificationsRequested()
                onToggleNightLightRequested: root.toggleNightLightRequested()
                onDisplaySettingsRequested: root.navigateRequested("displays")
            }

            // Quick Audio & Hardware Volume Surface in Actions tab
            MikoSurface {
                Layout.fillWidth: true
                style: root.style

                ColumnLayout {
                    anchors {
                        fill: parent
                        margins: 16
                    }
                    spacing: 12

                    MikoSectionHeader {
                        style: root.style
                        title: I18n.tr("Громкость системы")
                        subtitle: root.audio.sink
                            ? root.audio.friendlyDeviceName(root.audio.sink)
                            : I18n.tr("Основной аудиовыход")
                        badgeText: Math.round((root.audio.value || 0) * 100) + "%"
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        MikoButton {
                            style: root.style
                            icon: (root.audio.sink && root.audio.sink.audio.muted)
                                ? "volume_off" : "volume_up"
                            selected: root.audio.sink ? root.audio.sink.audio.muted : false
                            onClicked: {
                                if (root.audio.sink)
                                    root.audio.sink.audio.muted = !root.audio.sink.audio.muted;
                            }
                        }

                        StyledText {
                            text: (root.audio.sink && root.audio.sink.audio.muted)
                                ? I18n.tr("Звук заглушён")
                                : (Math.round((root.audio.value || 0) * 100) + "%")
                            color: root.style.ink
                            font.pixelSize: Appearance.font.pixelSize.normal
                            font.weight: Font.Medium
                        }

                        Item { Layout.fillWidth: true }

                        MikoButton {
                            style: root.style
                            icon: "headphones"
                            text: I18n.tr("Настройки звука")
                            onClicked: root.navigateRequested("sound")
                        }
                    }
                }
            }
        }

        // Tab 3: Overview Customizer / Widgets
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 16
            visible: root.activeTab === "customize"

            OverviewEditor {
                Layout.fillWidth: true
                preferences: root.preferences
                style: root.style
            }
        }
    }
}
