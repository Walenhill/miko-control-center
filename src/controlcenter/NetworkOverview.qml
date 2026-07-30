import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    required property var controller
    required property var network
    required property var style
    required property var openNetworkSettings
    required property var openSection

    width: parent ? parent.width : implicitWidth
    spacing: root.style.gapSection

    GridLayout {
        Layout.fillWidth: true
        columns: width > 820 ? 2 : 1
        columnSpacing: 12
        rowSpacing: 12

        MikoSurface {
            Layout.fillWidth: true
            implicitHeight: 154
            style: root.style
            accented: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 10
                RowLayout {
                    Layout.fillWidth: true
                    MikoIconDisc {
                        style: root.style
                        icon: root.network.ethernet
                            ? "lan" : root.network.materialSymbol
                        accented: true
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.minimumWidth: 0
                        spacing: 0
                        StyledText {
                            text: "Интернет"
                            color: root.style.ink
                            font.weight: Font.DemiBold
                        }
                        StyledText {
                            Layout.fillWidth: true
                            text: root.network.ethernet
                                ? "Проводное подключение"
                                : (root.network.networkName || "Не подключено")
                            color: root.style.mutedInk
                            elide: Text.ElideRight
                        }
                    }
                    Rectangle {
                        implicitWidth: internetState.implicitWidth + 22
                        implicitHeight: 34
                        radius: 14
                        color: root.style.controlSurface
                        StyledText {
                            id: internetState
                            anchors.centerIn: parent
                            text: root.network.ethernet
                                || root.network.wifiStatus === "connected"
                                ? "На связи" : "Нет сети"
                            color: root.style.ink
                            font.weight: Font.Medium
                        }
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
                            ? "Ethernet работает без ошибок"
                            : "Wi-Fi: " + root.network.wifiStatus
                        color: root.style.mutedInk
                        elide: Text.ElideRight
                    }
                    MikoButton {
                        style: root.style
                        icon: "settings"
                        text: "Подробности"
                        onClicked: root.openNetworkSettings()
                    }
                }
            }
        }

        MikoSurface {
            Layout.fillWidth: true
            implicitHeight: 154
            style: root.style

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 10
                RowLayout {
                    Layout.fillWidth: true
                    MikoIconDisc {
                        style: root.style
                        icon: root.controller.tunnelActive
                            ? "vpn_lock" : "vpn_key_off"
                        accented: root.controller.tunnelActive
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.minimumWidth: 0
                        spacing: 0
                        StyledText {
                            text: "Защищённое соединение"
                            color: root.style.ink
                            font.weight: Font.DemiBold
                        }
                        StyledText {
                            Layout.fillWidth: true
                            text: root.controller.tunnelActive
                                ? root.controller.tunnelName
                                : "Туннель не обнаружен"
                            color: root.style.mutedInk
                            elide: Text.ElideRight
                        }
                    }
                    Rectangle {
                        implicitWidth: tunnelState.implicitWidth + 22
                        implicitHeight: 34
                        radius: 14
                        color: root.controller.tunnelActive
                            ? root.style.accentContainer
                            : root.style.controlSurface
                        StyledText {
                            id: tunnelState
                            anchors.centerIn: parent
                            text: root.controller.tunnelActive
                                ? "Активно" : "Выключено"
                            color: root.controller.tunnelActive
                                ? root.style.accentContainerInk : root.style.ink
                            font.weight: Font.Medium
                        }
                    }
                }
                Item { Layout.fillHeight: true }
                RowLayout {
                    Layout.fillWidth: true
                    MaterialSymbol {
                        text: "info"
                        iconSize: 18
                        color: root.style.mutedInk
                    }
                    StyledText {
                        Layout.fillWidth: true
                        text: root.controller.snapshot.throne?.running
                            ? (root.controller.snapshot.throne.profile
                                || "Throne Core") + " · "
                                + (root.controller.snapshot.throne.route
                                    || "маршрут по умолчанию")
                            : root.controller.tunnelActive
                                ? "Трафик проходит через внешний TUN-интерфейс"
                                : "Можно подключить VPN или прокси-туннель"
                        color: root.style.mutedInk
                        elide: Text.ElideRight
                    }
                    MikoButton {
                        visible: root.controller.snapshot.throne?.installed
                            || root.controller.tunnelName === "throne-tun"
                        style: root.style
                        icon: "arrow_forward"
                        text: "Подробнее"
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
            style: root.style
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 7
                RowLayout {
                    Layout.fillWidth: true
                    MikoIconDisc {
                        style: root.style
                        icon: "route"
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        StyledText {
                            text: "Текущий маршрут"
                            color: root.style.ink
                            font.weight: Font.DemiBold
                        }
                        StyledText {
                            text: (root.controller.snapshot.connection || "—")
                                + " · "
                                + (root.controller.snapshot.interface || "—")
                            color: root.style.mutedInk
                        }
                    }
                    MikoButton {
                        style: root.style
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
                                "Локальный IP"],
                            [root.controller.snapshot.gateway || "—", "Шлюз"],
                            [root.controller.snapshot.dns?.join(", ") || "—",
                                "DNS"]
                        ]
                        ColumnLayout {
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.minimumWidth: 0
                            spacing: 0
                            StyledText {
                                Layout.fillWidth: true
                                text: modelData[0]
                                color: root.style.ink
                                font.weight: Font.Medium
                                elide: Text.ElideRight
                            }
                            StyledText {
                                text: modelData[1]
                                color: root.style.mutedInk
                                font.pixelSize:
                                    Appearance.font.pixelSize.smaller
                            }
                        }
                    }
                }
            }
        }

        MikoSurface {
            Layout.fillWidth: true
            implicitHeight: 132
            style: root.style
            border.color: root.controller.snapshot.packet_loss > 0
                ? Qt.rgba(Appearance.colors.colError.r,
                    Appearance.colors.colError.g,
                    Appearance.colors.colError.b, 0.36)
                : root.style.hairline
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 7
                RowLayout {
                    Layout.fillWidth: true
                    MikoIconDisc {
                        style: root.style
                        icon: root.controller.snapshot.online
                            ? "speed" : "signal_disconnected"
                        accented: root.controller.snapshot.online ?? false
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        StyledText {
                            text: "Качество соединения"
                            color: root.style.ink
                            font.weight: Font.DemiBold
                        }
                        StyledText {
                            text: root.controller.snapshot.online
                                ? "Интернет и DNS отвечают"
                                : "Нет ответа от внешней сети"
                            color: root.style.mutedInk
                        }
                    }
                    StyledText {
                        text: "Проверено " + root.controller.lastChecked
                        color: root.style.mutedInk
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
                                    && root.controller.snapshot.latency_ms
                                        !== undefined
                                    ? Math.round(
                                        root.controller.snapshot.latency_ms
                                    ) + " мс" : "—",
                                "Интернет"
                            ],
                            [
                                (root.controller.snapshot.packet_loss ?? 100)
                                    + "%",
                                "Потери"
                            ],
                            [
                                root.controller.snapshot.dns_ok
                                    ? Math.round(
                                        root.controller.snapshot.dns_ms
                                    ) + " мс" : "ошибка",
                                "DNS-запрос"
                            ]
                        ]
                        ColumnLayout {
                            required property var modelData
                            Layout.fillWidth: true
                            spacing: 0
                            StyledText {
                                text: modelData[0]
                                color: root.style.ink
                                font.weight: Font.Medium
                            }
                            StyledText {
                                text: modelData[1]
                                color: root.style.mutedInk
                                font.pixelSize:
                                    Appearance.font.pixelSize.smaller
                            }
                        }
                    }
                }
            }
        }
    }

    StyledText {
        Layout.topMargin: 4
        text: "Wi-Fi"
        color: root.style.ink
        font.pixelSize: Appearance.font.pixelSize.larger
        font.weight: Font.DemiBold
    }

    MikoSurface {
        Layout.fillWidth: true
        implicitHeight: wifiContent.implicitHeight + 30
        style: root.style

        ColumnLayout {
            id: wifiContent
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 15
            spacing: 12
            RowLayout {
                Layout.fillWidth: true
                MikoIconDisc {
                    style: root.style
                    icon: root.network.wifiEnabled ? "wifi" : "wifi_off"
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0
                    StyledText {
                        text: "Wi-Fi"
                        color: root.style.ink
                        font.weight: Font.Medium
                    }
                    StyledText {
                        text: !root.controller.wifiHardwareAvailable
                            ? "Адаптер недоступен или выключен"
                            : (root.network.networkName
                                || root.network.wifiStatus)
                        color: root.style.mutedInk
                    }
                }
                MikoButton {
                    visible: root.controller.wifiHardwareAvailable
                    style: root.style
                    icon: root.network.wifiEnabled
                        ? "toggle_on" : "toggle_off"
                    text: root.network.wifiEnabled
                        ? "Включён" : "Выключен"
                    onClicked: root.network.toggleWifi()
                }
                MikoButton {
                    visible: root.controller.wifiHardwareAvailable
                        && root.network.wifiEnabled
                    style: root.style
                    icon: "refresh"
                    text: ""
                    implicitWidth: 42
                    onClicked: root.network.rescanWifi()
                }
            }
            Repeater {
                model: root.network.friendlyWifiNetworks.slice(0, 5)
                delegate: Rectangle {
                    id: wifiRow
                    required property var modelData
                    Layout.fillWidth: true
                    implicitHeight: 54
                    radius: root.style.radiusControl
                    color: wifiPointer.pressed
                        ? root.style.activeSurface
                        : wifiPointer.containsMouse
                            ? root.style.hoverSurface : "transparent"
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        MaterialSymbol {
                            text: wifiRow.modelData.active
                                ? "wifi" : "network_wifi"
                            iconSize: 19
                            color: wifiRow.modelData.active
                                ? Appearance.colors.colPrimary : root.style.ink
                        }
                        StyledText {
                            Layout.fillWidth: true
                            text: wifiRow.modelData.ssid
                            color: root.style.ink
                            font.weight: wifiRow.modelData.active
                                ? Font.DemiBold : Font.Normal
                            elide: Text.ElideRight
                        }
                        StyledText {
                            text: wifiRow.modelData.strength + "%"
                            color: root.style.mutedInk
                        }
                    }
                    MouseArea {
                        id: wifiPointer
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (wifiRow.modelData.active)
                                root.network.disconnectWifiNetwork();
                            else
                                root.network.connectToWifiNetwork(
                                    wifiRow.modelData
                                );
                        }
                    }
                }
            }
        }
    }

    MikoListGroup {
        style: root.style
        MikoListRow {
            style: root.style
            title: "Порты и firewall"
            subtitle: root.controller.listeningPorts.length
                + " активных портов · UFW включён"
            icon: "policy"
            showChevron: true
            dividerVisible: false
            interactive: true
            onClicked: root.openSection("ports")
        }
    }
}
