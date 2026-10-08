import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    property var style: null
    readonly property var ui: style ? style : DefaultStyle

    required property var controller
    required property var network
    required property var openNetworkSettings
    required property var openSection

    width: parent ? parent.width : implicitWidth
    spacing: root.ui.gapSection

    GridLayout {
        Layout.fillWidth: true
        columns: width > 820 ? 2 : 1
        columnSpacing: 12
        rowSpacing: 12

        MikoSurface {
            Layout.fillWidth: true
            implicitHeight: 154
            style: root.ui
            softAccent: root.network.ethernet || root.network.wifiStatus === "connected"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true

                    MikoIconDisc {
                        style: root.ui
                        icon: root.network.ethernet
                            ? "lan" : root.network.materialSymbol
                        accented: root.network.ethernet || root.network.wifiStatus === "connected"
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.minimumWidth: 0
                        spacing: 1

                        StyledText {
                            text: I18n.tr("Интернет")
                            color: root.ui.ink
                            font.weight: Font.DemiBold
                        }
                        StyledText {
                            Layout.fillWidth: true
                            text: root.network.ethernet
                                ? I18n.tr("Проводное подключение")
                                : (root.network.networkName || I18n.tr("Не подключено"))
                            color: root.ui.mutedInk
                            elide: Text.ElideRight
                        }
                    }

                    MikoBadge {
                        style: root.ui
                        text: (root.network.ethernet || root.network.wifiStatus === "connected")
                            ? I18n.tr("На связи") : I18n.tr("Нет сети")
                        tone: (root.network.ethernet || root.network.wifiStatus === "connected")
                            ? "success" : "neutral"
                        icon: (root.network.ethernet || root.network.wifiStatus === "connected")
                            ? "check_circle" : "signal_wifi_off"
                    }
                }

                Item { Layout.fillHeight: true }

                RowLayout {
                    Layout.fillWidth: true

                    MaterialSymbol {
                        text: "check_circle"
                        iconSize: 18
                        color: Appearance.colors.colPrimary
                    }
                    StyledText {
                        Layout.fillWidth: true
                        text: root.network.ethernet
                            ? I18n.tr("Ethernet работает без ошибок")
                            : "Wi-Fi: " + root.network.wifiStatus
                        color: root.ui.mutedInk
                        elide: Text.ElideRight
                    }
                    MikoButton {
                        style: root.ui
                        icon: "settings"
                        text: I18n.tr("Подробности")
                        onClicked: root.openNetworkSettings()
                    }
                }
            }
        }

        MikoSurface {
            Layout.fillWidth: true
            implicitHeight: 154
            style: root.ui
            softAccent: root.controller.tunnelActive

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true

                    MikoIconDisc {
                        style: root.ui
                        icon: root.controller.tunnelActive
                            ? "vpn_lock" : "vpn_key_off"
                        accented: root.controller.tunnelActive
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.minimumWidth: 0
                        spacing: 1

                        StyledText {
                            text: I18n.tr("Защищённое соединение")
                            color: root.ui.ink
                            font.weight: Font.DemiBold
                        }
                        StyledText {
                            Layout.fillWidth: true
                            text: root.controller.tunnelActive
                                ? root.controller.tunnelName
                                : I18n.tr("Туннель не обнаружен")
                            color: root.ui.mutedInk
                            elide: Text.ElideRight
                        }
                    }

                    MikoBadge {
                        style: root.ui
                        text: root.controller.tunnelActive ? I18n.tr("Активно") : I18n.tr("Выключено")
                        tone: root.controller.tunnelActive ? "accent" : "neutral"
                        icon: root.controller.tunnelActive ? "vpn_lock" : "vpn_key_off"
                    }
                }

                Item { Layout.fillHeight: true }

                RowLayout {
                    Layout.fillWidth: true

                    MaterialSymbol {
                        text: "info"
                        iconSize: 18
                        color: root.ui.mutedInk
                    }
                    StyledText {
                        Layout.fillWidth: true
                        text: (root.controller.snapshot && root.controller.snapshot.throne && root.controller.snapshot.throne.running)
                            ? (root.controller.snapshot.throne.profile
                                || "Throne Core") + " · "
                                + (root.controller.snapshot.throne.route
                                    || I18n.tr("маршрут по умолчанию"))
                            : root.controller.tunnelActive
                                ? I18n.tr("Трафик проходит через внешний TUN-интерфейс")
                                : I18n.tr("Можно подключить VPN или прокси-туннель")
                        color: root.ui.mutedInk
                        elide: Text.ElideRight
                    }
                    MikoButton {
                        visible: (root.controller.snapshot && root.controller.snapshot.throne && root.controller.snapshot.throne.installed)
                            || root.controller.tunnelName === "throne-tun"
                        style: root.ui
                        icon: "arrow_forward"
                        text: I18n.tr("Подробнее")
                        onClicked: root.openSection("throne")
                    }
                }
            }
        }
    }

    GridLayout {
        Layout.fillWidth: true
        columns: width > 820 ? 2 : 1
        columnSpacing: 12
        rowSpacing: 12

        MikoSurface {
            Layout.fillWidth: true
            implicitHeight: 132
            style: root.ui

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true

                    MikoIconDisc {
                        style: root.ui
                        icon: "route"
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        StyledText {
                            text: I18n.tr("Текущий маршрут")
                            color: root.ui.ink
                            font.weight: Font.DemiBold
                        }
                        StyledText {
                            text: (root.controller.snapshot.connection || "—")
                                + " · "
                                + (root.controller.snapshot.interface || "—")
                            color: root.ui.mutedInk
                        }
                    }

                    MikoButton {
                        style: root.ui
                        icon: "refresh"
                        text: ""
                        implicitWidth: 42
                        onClicked: root.controller.refreshSnapshot()
                    }
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 3
                    columnSpacing: 12

                    Repeater {
                        model: [
                            [root.controller.snapshot.local_ip || "—",
                                I18n.tr("Локальный IP")],
                            [root.controller.snapshot.gateway || "—", I18n.tr("Шлюз")],
                            [(root.controller.snapshot.dns && root.controller.snapshot.dns.join ? root.controller.snapshot.dns.join(", ") : "—"),
                                "DNS"]
                        ]

                        ColumnLayout {
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.minimumWidth: 0
                            spacing: 1

                            StyledText {
                                Layout.fillWidth: true
                                text: modelData[0]
                                color: root.ui.ink
                                font.weight: Font.Medium
                                elide: Text.ElideRight
                            }
                            StyledText {
                                text: modelData[1]
                                color: root.ui.mutedInk
                                font.pixelSize: Appearance.font.pixelSize.smaller
                            }
                        }
                    }
                }
            }
        }

        MikoSurface {
            Layout.fillWidth: true
            implicitHeight: 132
            style: root.ui
            border.color: (root.controller.snapshot.packet_loss > 0)
                ? Qt.rgba(Appearance.colors.colError.r,
                    Appearance.colors.colError.g,
                    Appearance.colors.colError.b, 0.36)
                : root.ui.hairline

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true

                    MikoIconDisc {
                        style: root.ui
                        icon: root.controller.snapshot.online
                            ? "speed" : "signal_disconnected"
                        accented: root.controller.snapshot.online ? true : false
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        StyledText {
                            text: I18n.tr("Качество соединения")
                            color: root.ui.ink
                            font.weight: Font.DemiBold
                        }
                        StyledText {
                            text: root.controller.snapshot.online
                                ? I18n.tr("Интернет и DNS отвечают")
                                : I18n.tr("Нет ответа от внешней сети")
                            color: root.ui.mutedInk
                        }
                    }

                    StyledText {
                        text: I18n.tr("Проверено ") + root.controller.lastChecked
                        color: root.ui.mutedInk
                        font.pixelSize: Appearance.font.pixelSize.smaller
                    }
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 3

                    Repeater {
                        model: [
                            [
                                root.controller.snapshot.latency_ms !== null
                                    && root.controller.snapshot.latency_ms !== undefined
                                    ? Math.round(root.controller.snapshot.latency_ms) + I18n.tr(" мс") : "—",
                                I18n.tr("Интернет")
                            ],
                            [
                                (root.controller.snapshot.packet_loss !== undefined && root.controller.snapshot.packet_loss !== null
                                    ? root.controller.snapshot.packet_loss : 100) + "%",
                                I18n.tr("Потери")
                            ],
                            [
                                root.controller.snapshot.dns_ok
                                    ? Math.round(root.controller.snapshot.dns_ms) + I18n.tr(" мс") : I18n.tr("ошибка"),
                                I18n.tr("DNS-запрос")
                            ]
                        ]

                        ColumnLayout {
                            required property var modelData
                            Layout.fillWidth: true
                            spacing: 1

                            StyledText {
                                text: modelData[0]
                                color: root.ui.ink
                                font.weight: Font.Medium
                            }
                            StyledText {
                                text: modelData[1]
                                color: root.ui.mutedInk
                                font.pixelSize: Appearance.font.pixelSize.smaller
                            }
                        }
                    }
                }
            }
        }
    }

    MikoSectionHeader {
        style: root.ui
        title: "Wi-Fi"
        subtitle: !root.controller.wifiHardwareAvailable
            ? I18n.tr("Адаптер недоступен или выключен")
            : (root.network.networkName || root.network.wifiStatus)

        RowLayout {
            spacing: 8

            MikoButton {
                visible: root.controller.wifiHardwareAvailable
                style: root.ui
                icon: root.network.wifiEnabled ? "toggle_on" : "toggle_off"
                text: root.network.wifiEnabled ? I18n.tr("Включён") : I18n.tr("Выключен")
                onClicked: root.network.toggleWifi()
            }

            MikoButton {
                visible: root.controller.wifiHardwareAvailable && root.network.wifiEnabled
                style: root.ui
                icon: "refresh"
                text: ""
                implicitWidth: 42
                onClicked: root.network.rescanWifi()
            }
        }
    }

    MikoListGroup {
        visible: root.network.wifiEnabled && root.network.friendlyWifiNetworks && root.network.friendlyWifiNetworks.length > 0
        style: root.ui

        Repeater {
            model: root.network.friendlyWifiNetworks ? root.network.friendlyWifiNetworks.slice(0, 6) : []

            delegate: MikoListRow {
                id: wifiDelegate
                required property var modelData
                required property int index

                style: root.ui
                title: wifiDelegate.modelData.ssid
                subtitle: wifiDelegate.modelData.active
                    ? I18n.tr("Подключено · уровень сигнала ") + wifiDelegate.modelData.strength + "%"
                    : I18n.tr("Уровень сигнала ") + wifiDelegate.modelData.strength + "%"
                icon: wifiDelegate.modelData.active ? "wifi" : "network_wifi"
                interactive: true
                dividerVisible: wifiDelegate.index < Math.min(root.network.friendlyWifiNetworks.length, 6) - 1

                MikoBadge {
                    style: root.ui
                    text: wifiDelegate.modelData.active ? I18n.tr("Подключено") : (wifiDelegate.modelData.strength + "%")
                    tone: wifiDelegate.modelData.active ? "success" : "neutral"
                    icon: wifiDelegate.modelData.active ? "check" : ""
                }

                onClicked: {
                    if (wifiDelegate.modelData.active)
                        root.network.disconnectWifiNetwork();
                    else
                        root.network.connectToWifiNetwork(wifiDelegate.modelData);
                }
            }
        }
    }

    MikoListGroup {
        style: root.ui

        MikoListRow {
            style: root.ui
            title: I18n.tr("Порты и firewall")
            subtitle: (root.controller.listeningPorts ? root.controller.listeningPorts.length : 0)
                + I18n.tr(" активных портов · UFW и открытые сокеты")
            icon: "policy"
            showChevron: true
            dividerVisible: false
            interactive: true
            onClicked: root.openSection("ports")
        }
    }
}
