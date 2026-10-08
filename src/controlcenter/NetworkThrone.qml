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
    required property var openThrone

    readonly property var throne: (controller && controller.snapshot && controller.snapshot.throne) ? controller.snapshot.throne : ({})

    width: parent ? parent.width : implicitWidth
    spacing: root.ui.gapSection

    MikoSectionHeader {
        style: root.ui
        title: "Throne VPN"
        subtitle: (root.throne && root.throne.running)
            ? I18n.tr("Core работает · TUN подключён")
            : I18n.tr("Core не запущен")

        RowLayout {
            spacing: 8

            MikoBadge {
                style: root.ui
                text: (root.throne && root.throne.running) ? I18n.tr("Защищено") : I18n.tr("Неактивно")
                tone: (root.throne && root.throne.running) ? "success" : "neutral"
                icon: (root.throne && root.throne.running) ? "vpn_lock" : "vpn_key_off"
            }

            MikoButton {
                style: root.ui
                icon: "open_in_new"
                text: root.controller.throneAvailable
                    ? I18n.tr("Открыть Throne") : I18n.tr("Throne недоступен")
                enabled: root.controller.throneAvailable
                onClicked: root.openThrone()
            }

            MikoButton {
                style: root.ui
                icon: "refresh"
                text: I18n.tr("Обновить")
                onClicked: root.controller.refreshSnapshot()
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
            implicitHeight: 176
            style: root.ui

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 8

                StyledText {
                    text: I18n.tr("Активная конфигурация")
                    color: root.ui.ink
                    font.weight: Font.DemiBold
                }

                Repeater {
                    model: [
                        [I18n.tr("Профиль"), (root.throne && root.throne.profile) ? root.throne.profile : "—"],
                        [I18n.tr("Протокол"), ((root.throne && root.throne.profile_type) ? root.throne.profile_type : "—").toUpperCase()],
                        [I18n.tr("Группа"), (root.throne && root.throne.group) ? root.throne.group : "—"],
                        [I18n.tr("Маршрут"), (root.throne && root.throne.route) ? root.throne.route : "—"]
                    ]

                    RowLayout {
                        required property var modelData
                        Layout.fillWidth: true

                        StyledText {
                            Layout.preferredWidth: 110
                            text: modelData[0]
                            color: root.ui.mutedInk
                        }
                        StyledText {
                            Layout.fillWidth: true
                            text: modelData[1]
                            color: root.ui.ink
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
            style: root.ui

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 8

                StyledText {
                    text: I18n.tr("Движок и локальная сеть")
                    color: root.ui.ink
                    font.weight: Font.DemiBold
                }

                Repeater {
                    model: [
                        ["Throne", (root.throne && root.throne.package_version) ? root.throne.package_version : "—"],
                        ["Core", "sing-box + Xray"],
                        ["SOCKS", (root.throne && root.throne.socks_port)
                            ? "127.0.0.1:" + root.throne.socks_port
                            : I18n.tr("выключен")],
                        ["Live API", (root.throne && root.throne.live && root.throne.live.reachable)
                            ? I18n.tr("подключён")
                            : (root.throne && root.throne.live && root.throne.live.configured)
                                ? I18n.tr("ждёт применения") : I18n.tr("выключен")]
                    ]

                    RowLayout {
                        required property var modelData
                        Layout.fillWidth: true

                        StyledText {
                            Layout.fillWidth: true
                            text: modelData[0]
                            color: root.ui.mutedInk
                        }
                        StyledText {
                            text: modelData[1]
                            color: root.ui.ink
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
        style: root.ui

        ColumnLayout {
            id: trafficModes
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 16
            spacing: 12

            StyledText {
                text: I18n.tr("Как сейчас проходит трафик")
                color: root.ui.ink
                font.weight: Font.DemiBold
            }

            Flow {
                Layout.fillWidth: true
                spacing: 8

                Repeater {
                    model: [
                        ["TUN", root.throne ? root.throne.tun : false],
                        ["Strict route", root.throne ? root.throne.strict_route : false],
                        ["DNS routing", root.throne ? root.throne.dns_routing : false],
                        ["DNS cache", root.throne ? root.throne.dns_cache : false],
                        ["System proxy", root.throne ? root.throne.system_proxy : false],
                        ["IPv6", root.throne ? root.throne.ipv6 : false],
                        ["AdBlock", root.throne ? root.throne.adblock : false]
                    ]

                    MikoBadge {
                        required property var modelData
                        style: root.ui
                        text: modelData[0] + (modelData[1] ? I18n.tr(" · вкл") : I18n.tr(" · выкл"))
                        tone: modelData[1] ? "accent" : "neutral"
                        icon: modelData[1] ? "check" : ""
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
                [(root.throne && root.throne.profiles !== undefined) ? root.throne.profiles : 0, I18n.tr("профилей")],
                [(root.throne && root.throne.groups !== undefined) ? root.throne.groups : 0, I18n.tr("группы")],
                [(root.throne && root.throne.routes !== undefined) ? root.throne.routes : 0, I18n.tr("маршрута")],
                [root.controller.formatBytes(
                    ((root.throne && root.throne.traffic_down) ? root.throne.traffic_down : 0)
                        + ((root.throne && root.throne.traffic_up) ? root.throne.traffic_up : 0)
                ), I18n.tr("учтено трафика")]
            ]

            MikoSurface {
                required property var modelData
                Layout.fillWidth: true
                implicitHeight: 78
                style: root.ui

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 1

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: String(modelData[0])
                        color: root.ui.ink
                        font.pixelSize: Appearance.font.pixelSize.large
                        font.weight: Font.DemiBold
                    }
                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: modelData[1]
                        color: root.ui.mutedInk
                        font.pixelSize: Appearance.font.pixelSize.smaller
                    }
                }
            }
        }
    }

    GridLayout {
        visible: (root.throne && root.throne.live && root.throne.live.reachable) ? true : false
        Layout.fillWidth: true
        columns: width > 820 ? 3 : 1
        columnSpacing: 10
        rowSpacing: 10

        Repeater {
            model: [
                [
                    "download",
                    root.controller.formatBytes(
                        (root.throne && root.throne.live && root.throne.live.download_rate) ? root.throne.live.download_rate : 0
                    ) + I18n.tr("/с"),
                    I18n.tr("Сейчас получает")
                ],
                [
                    "upload",
                    root.controller.formatBytes(
                        (root.throne && root.throne.live && root.throne.live.upload_rate) ? root.throne.live.upload_rate : 0
                    ) + I18n.tr("/с"),
                    I18n.tr("Сейчас отправляет")
                ],
                [
                    "lan",
                    (root.throne && root.throne.live && root.throne.live.connections) ? root.throne.live.connections : 0,
                    I18n.tr("Активных соединений")
                ]
            ]

            MikoSurface {
                required property var modelData
                Layout.fillWidth: true
                implicitHeight: 82
                style: root.ui

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 10

                    MaterialSymbol {
                        text: modelData[0]
                        iconSize: 21
                        color: Appearance.colors.colPrimary
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        StyledText {
                            text: String(modelData[1])
                            color: root.ui.ink
                            font.pixelSize: Appearance.font.pixelSize.large
                            font.weight: Font.DemiBold
                        }
                        StyledText {
                            text: modelData[2]
                            color: root.ui.mutedInk
                            font.pixelSize: Appearance.font.pixelSize.smaller
                        }
                    }
                }
            }
        }
    }

    MikoListGroup {
        visible: (root.throne && root.throne.live && root.throne.live.top_processes && root.throne.live.top_processes.length > 0) ? true : false
        style: root.ui

        Repeater {
            model: (root.throne && root.throne.live && root.throne.live.top_processes) ? root.throne.live.top_processes : []

            delegate: MikoListRow {
                required property var modelData
                required property int index

                style: root.ui
                title: modelData.name
                subtitle: I18n.tr("Использует защищённый маршрут")
                icon: "network_check"
                value: root.controller.formatBytes(modelData.traffic)
                dividerVisible: index < ((root.throne && root.throne.live && root.throne.live.top_processes) ? root.throne.live.top_processes.length : 0) - 1
            }
        }
    }

    MikoSurface {
        Layout.fillWidth: true
        implicitHeight: 74
        style: root.ui
        softAccent: !(root.throne && root.throne.clash_api_port)

        RowLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 12

            MaterialSymbol {
                text: "monitoring"
                iconSize: 22
                color: Appearance.colors.colPrimary
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                spacing: 1

                StyledText {
                    text: I18n.tr("Живые соединения и скорость")
                    color: root.ui.ink
                    font.weight: Font.Medium
                }
                StyledText {
                    Layout.fillWidth: true
                    text: (root.throne && root.throne.live && root.throne.live.reachable)
                        ? I18n.tr("Данные поступают из Throne Core")
                        : (root.throne && root.throne.live && root.throne.live.configured)
                            ? I18n.tr("API настроен и включится при следующем переподключении профиля")
                            : I18n.tr("Clash API выключен в Throne — система его сама не меняет")
                    color: root.ui.mutedInk
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    elide: Text.ElideRight
                }
            }

            MikoButton {
                style: root.ui
                icon: "settings"
                text: I18n.tr("Настроить")
                onClicked: root.openThrone()
            }
        }
    }
}
