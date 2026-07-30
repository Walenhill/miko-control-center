import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    required property var controller
    required property var style
    required property var openThrone

    readonly property var throne: controller.snapshot.throne || ({})

    width: parent ? parent.width : implicitWidth
    spacing: root.style.gapSection

    RowLayout {
        Layout.fillWidth: true
        MikoIconDisc {
            style: root.style
            icon: root.throne.running ? "vpn_lock" : "vpn_key_off"
            accented: root.throne.running ?? false
        }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1
            StyledText {
                text: "Throne"
                color: root.style.ink
                font.pixelSize: Appearance.font.pixelSize.large
                font.weight: Font.DemiBold
            }
            StyledText {
                text: root.throne.running
                    ? "Core работает · TUN подключён"
                    : "Core не запущен"
                color: root.style.mutedInk
            }
        }
        Rectangle {
            implicitWidth: stateLabel.implicitWidth + 24
            implicitHeight: 36
            radius: 15
            color: root.throne.running
                ? root.style.accentContainer : root.style.controlSurface
            StyledText {
                id: stateLabel
                anchors.centerIn: parent
                text: root.throne.running ? "Защищено" : "Неактивно"
                color: root.throne.running
                    ? root.style.accentContainerInk : root.style.ink
                font.weight: Font.Medium
            }
        }
        MikoButton {
            style: root.style
            icon: "open_in_new"
            text: root.controller.throneAvailable
                ? "Открыть Throne" : "Throne недоступен"
            enabled: root.controller.throneAvailable
            onClicked: root.openThrone()
        }
        MikoButton {
            style: root.style
            icon: "refresh"
            text: "Обновить"
            onClicked: root.controller.refreshSnapshot()
        }
    }

    GridLayout {
        Layout.fillWidth: true
        columns: width > 820 ? 2 : 1
        columnSpacing: 12
        rowSpacing: 12

        MikoSurface {
            Layout.fillWidth: true
            implicitHeight: 176
            style: root.style
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 17
                spacing: 9
                StyledText {
                    text: "Активная конфигурация"
                    color: root.style.ink
                    font.weight: Font.DemiBold
                }
                Repeater {
                    model: [
                        ["Профиль", root.throne.profile || "—"],
                        ["Протокол",
                            (root.throne.profile_type || "—").toUpperCase()],
                        ["Группа", root.throne.group || "—"],
                        ["Маршрут", root.throne.route || "—"]
                    ]
                    RowLayout {
                        required property var modelData
                        Layout.fillWidth: true
                        StyledText {
                            Layout.preferredWidth: 110
                            text: modelData[0]
                            color: root.style.mutedInk
                        }
                        StyledText {
                            Layout.fillWidth: true
                            text: modelData[1]
                            color: root.style.ink
                            font.weight: Font.Medium
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignRight
                        }
                    }
                }
            }
        }

        MikoSurface {
            Layout.fillWidth: true
            implicitHeight: 176
            style: root.style
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 17
                spacing: 9
                StyledText {
                    text: "Движок и локальная сеть"
                    color: root.style.ink
                    font.weight: Font.DemiBold
                }
                Repeater {
                    model: [
                        ["Throne", root.throne.package_version || "—"],
                        ["Core", "sing-box + Xray"],
                        ["SOCKS", root.throne.socks_port
                            ? "127.0.0.1:" + root.throne.socks_port
                            : "выключен"],
                        ["Live API", root.throne.live?.reachable
                            ? "подключён"
                            : root.throne.live?.configured
                                ? "ждёт применения" : "выключен"]
                    ]
                    RowLayout {
                        required property var modelData
                        Layout.fillWidth: true
                        StyledText {
                            Layout.fillWidth: true
                            text: modelData[0]
                            color: root.style.mutedInk
                        }
                        StyledText {
                            text: modelData[1]
                            color: root.style.ink
                            font.weight: Font.Medium
                        }
                    }
                }
            }
        }
    }

    MikoSurface {
        Layout.fillWidth: true
        implicitHeight: trafficModes.implicitHeight + 32
        style: root.style
        ColumnLayout {
            id: trafficModes
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 16
            spacing: 10
            StyledText {
                text: "Как сейчас проходит трафик"
                color: root.style.ink
                font.weight: Font.DemiBold
            }
            Flow {
                Layout.fillWidth: true
                spacing: 8
                Repeater {
                    model: [
                        ["TUN", root.throne.tun],
                        ["Strict route", root.throne.strict_route],
                        ["DNS routing", root.throne.dns_routing],
                        ["DNS cache", root.throne.dns_cache],
                        ["System proxy", root.throne.system_proxy],
                        ["IPv6", root.throne.ipv6],
                        ["AdBlock", root.throne.adblock]
                    ]
                    Rectangle {
                        required property var modelData
                        implicitWidth: modeLabel.implicitWidth + 24
                        implicitHeight: 36
                        radius: 15
                        color: modelData[1]
                            ? root.style.accentContainer
                            : root.style.controlSurface
                        StyledText {
                            id: modeLabel
                            anchors.centerIn: parent
                            text: modelData[0]
                                + (modelData[1] ? " · вкл" : " · выкл")
                            color: modelData[1]
                                ? root.style.accentContainerInk : root.style.ink
                            font.weight: Font.Medium
                        }
                    }
                }
            }
        }
    }

    GridLayout {
        Layout.fillWidth: true
        columns: width > 820 ? 4 : 2
        columnSpacing: 10
        rowSpacing: 10
        Repeater {
            model: [
                [root.throne.profiles ?? 0, "профилей"],
                [root.throne.groups ?? 0, "группы"],
                [root.throne.routes ?? 0, "маршрута"],
                [root.controller.formatBytes(
                    (root.throne.traffic_down ?? 0)
                        + (root.throne.traffic_up ?? 0)
                ), "учтено трафика"]
            ]
            MikoSurface {
                required property var modelData
                Layout.fillWidth: true
                implicitHeight: 78
                style: root.style
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 1
                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: modelData[0]
                        color: root.style.ink
                        font.pixelSize: Appearance.font.pixelSize.large
                        font.weight: Font.DemiBold
                    }
                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: modelData[1]
                        color: root.style.mutedInk
                        font.pixelSize: Appearance.font.pixelSize.smaller
                    }
                }
            }
        }
    }

    GridLayout {
        visible: root.throne.live?.reachable ?? false
        Layout.fillWidth: true
        columns: width > 820 ? 3 : 1
        columnSpacing: 10
        rowSpacing: 10
        Repeater {
            model: [
                [
                    "download",
                    root.controller.formatBytes(
                        root.throne.live?.download_rate ?? 0
                    ) + "/с",
                    "Сейчас получает"
                ],
                [
                    "upload",
                    root.controller.formatBytes(
                        root.throne.live?.upload_rate ?? 0
                    ) + "/с",
                    "Сейчас отправляет"
                ],
                [
                    "lan",
                    root.throne.live?.connections ?? 0,
                    "Активных соединений"
                ]
            ]
            MikoSurface {
                required property var modelData
                Layout.fillWidth: true
                implicitHeight: 82
                style: root.style
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    MaterialSymbol {
                        text: modelData[0]
                        iconSize: 21
                        color: Appearance.colors.colPrimary
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        StyledText {
                            text: modelData[1]
                            color: root.style.ink
                            font.pixelSize: Appearance.font.pixelSize.large
                            font.weight: Font.DemiBold
                        }
                        StyledText {
                            text: modelData[2]
                            color: root.style.mutedInk
                            font.pixelSize: Appearance.font.pixelSize.smaller
                        }
                    }
                }
            }
        }
    }

    MikoListGroup {
        visible: (root.throne.live?.top_processes?.length ?? 0) > 0
        style: root.style
        Repeater {
            model: root.throne.live?.top_processes ?? []
            MikoListRow {
                required property var modelData
                required property int index
                style: root.style
                title: modelData.name
                subtitle: "Использует защищённый маршрут"
                icon: "network_check"
                value: root.controller.formatBytes(modelData.traffic)
                dividerVisible: index < (
                    root.throne.live?.top_processes?.length ?? 0
                ) - 1
            }
        }
    }

    MikoSurface {
        Layout.fillWidth: true
        implicitHeight: 74
        style: root.style
        accented: !root.throne.clash_api_port
        RowLayout {
            anchors.fill: parent
            anchors.margins: 15
            MaterialSymbol {
                text: "monitoring"
                iconSize: 22
                color: Appearance.colors.colPrimary
            }
            ColumnLayout {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                spacing: 0
                StyledText {
                    text: "Живые соединения и скорость"
                    color: root.style.ink
                    font.weight: Font.Medium
                }
                StyledText {
                    Layout.fillWidth: true
                    text: root.throne.live?.reachable
                        ? "Данные поступают из Throne Core"
                        : root.throne.live?.configured
                            ? "API настроен и включится при следующем переподключении профиля"
                            : "Clash API выключен в Throne — система его сама не меняет"
                    color: root.style.mutedInk
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    elide: Text.ElideRight
                }
            }
            MikoButton {
                style: root.style
                icon: "settings"
                text: "Настроить"
                onClicked: root.openThrone()
            }
        }
    }
}
