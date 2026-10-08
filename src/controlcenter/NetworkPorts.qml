import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    property var style: null
    readonly property var ui: style ? style : DefaultStyle

    required property var controller

    width: parent ? parent.width : implicitWidth
    spacing: root.ui.gapSection

    MikoSectionHeader {
        style: root.ui
        title: I18n.tr("Порты и доступ")
        subtitle: I18n.tr("Сетевая безопасность, оценка рисков и правила firewall")

        RowLayout {
            spacing: 8

            MikoBadge {
                style: root.ui
                text: (root.controller.listeningPorts ? root.controller.listeningPorts.length : 0) + I18n.tr(" сокетов")
                tone: "neutral"
            }

            MikoButton {
                style: root.ui
                icon: "refresh"
                text: ""
                implicitWidth: 42
                onClicked: root.controller.refreshPorts()
            }
        }
    }

    MikoSurface {
        Layout.fillWidth: true
        implicitHeight: inspectorContent.implicitHeight + 30
        style: root.ui
        softAccent: true

        ColumnLayout {
            id: inspectorContent
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 16
            spacing: 12

            RowLayout {
                Layout.fillWidth: true

                MikoIconDisc {
                    style: root.ui
                    icon: "policy"
                    accented: true
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1

                    StyledText {
                        text: I18n.tr("Проверить конкретный порт")
                        color: root.ui.ink
                        font.weight: Font.DemiBold
                    }
                    StyledText {
                        text: I18n.tr("Процесс, интерфейс, UFW и оценка риска")
                        color: root.ui.mutedInk
                        font.pixelSize: Appearance.font.pixelSize.smaller
                    }
                }

                TextField {
                    id: portInput
                    Layout.preferredWidth: 150
                    placeholderText: "1–65535"
                    inputMethodHints: Qt.ImhDigitsOnly
                    validator: IntValidator { bottom: 1; top: 65535 }
                    onAccepted: inspectButton.clicked()
                }

                MikoButton {
                    id: inspectButton
                    style: root.ui
                    icon: "search"
                    text: I18n.tr("Проверить")
                    opacity: portInput.acceptableInput
                        && !root.controller.portQueryBusy ? 1 : 0.45
                    onClicked: if (portInput.acceptableInput
                            && !root.controller.portQueryBusy)
                        root.controller.inspectPort(portInput.text)
                }
            }

            MikoSurface {
                visible: root.controller.portInspection.query !== undefined
                Layout.fillWidth: true
                implicitHeight: inspectionResult.implicitHeight + 24
                style: root.ui

                ColumnLayout {
                    id: inspectionResult
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 14
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true

                        MaterialSymbol {
                            text: root.controller.portInspection.listening
                                ? "sensors" : "do_not_disturb_on"
                            iconSize: 21
                            color: root.controller.portInspection.listening
                                ? Appearance.colors.colPrimary
                                : root.ui.mutedInk
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.minimumWidth: 0
                            spacing: 1

                            StyledText {
                                Layout.fillWidth: true
                                text: root.controller.portInspection.listening
                                    ? I18n.tr("Порт ")
                                        + root.controller.portInspection.query
                                        + I18n.tr(" занят")
                                    : I18n.tr("Порт ")
                                        + root.controller.portInspection.query
                                        + I18n.tr(" никто не слушает")
                                color: root.ui.ink
                                font.weight: Font.DemiBold
                                elide: Text.ElideRight
                            }

                            StyledText {
                                Layout.fillWidth: true
                                text: (root.controller.portInspection.matches && root.controller.portInspection.matches.length > 0)
                                    ? root.controller.portInspection.matches[0].service + " · "
                                        + root.controller.portInspection.matches[0].purpose
                                    : (root.controller.portInspection.known
                                        || I18n.tr("Известная служба не определена"))
                                color: root.ui.mutedInk
                                elide: Text.ElideRight
                            }
                        }

                        MikoBadge {
                            style: root.ui
                            text: "TCP: " + (root.controller.portInspection.tcp_firewall || "—")
                                + " · UDP: " + (root.controller.portInspection.udp_firewall || "—")
                            tone: "neutral"
                        }
                    }

                    Repeater {
                        model: root.controller.portInspection.matches || []
                        StyledText {
                            required property var modelData
                            Layout.fillWidth: true
                            text: modelData.protocol.toUpperCase()
                                + " · " + modelData.address + " · "
                                + (modelData.process || I18n.tr("системная служба"))
                                + (modelData.pid > 0
                                    ? " · PID " + modelData.pid : "")
                                + I18n.tr(" · риск: ")
                                + (modelData.risk === "high"
                                    ? I18n.tr("высокий")
                                    : modelData.risk === "medium"
                                        ? I18n.tr("нужна проверка") : I18n.tr("низкий"))
                            color: root.ui.mutedInk
                            font.pixelSize: Appearance.font.pixelSize.smaller
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        MaterialSymbol {
                            text: root.controller.portInspection.assessment
                                    === "high"
                                ? "dangerous"
                                : root.controller.portInspection.assessment
                                        === "medium"
                                    ? "warning" : "verified_user"
                            iconSize: 19
                            color: root.controller.portInspection.assessment
                                    === "high"
                                ? Appearance.colors.colError
                                : Appearance.colors.colPrimary
                        }
                        StyledText {
                            text: root.controller.portInspection.assessment
                                    === "high"
                                ? I18n.tr("Высокий риск")
                                : root.controller.portInspection.assessment
                                        === "medium"
                                    ? I18n.tr("Стоит проверить") : I18n.tr("Низкий риск")
                            color: root.ui.ink
                            font.weight: Font.DemiBold
                        }
                        StyledText {
                            Layout.fillWidth: true
                            text: root.controller.portInspection
                                .assessment_reason || ""
                            color: root.ui.mutedInk
                            elide: Text.ElideRight
                        }
                    }

                    StyledText {
                        Layout.fillWidth: true
                        visible: root.controller.portActionMessage !== ""
                        text: root.controller.portActionMessage
                        color: root.ui.mutedInk
                    }

                    Repeater {
                        model: ["tcp", "udp"]
                        RowLayout {
                            required property string modelData
                            Layout.fillWidth: true
                            StyledText {
                                Layout.fillWidth: true
                                text: modelData.toUpperCase()
                                color: root.ui.ink
                                font.weight: Font.DemiBold
                            }
                            MikoButton {
                                style: root.ui
                                icon: "lock_open"
                                text: I18n.tr("Разрешить ") + modelData.toUpperCase()
                                onClicked: root.controller.changeFirewall(
                                    modelData, true
                                )
                            }
                            MikoButton {
                                style: root.ui
                                icon: "block"
                                text: I18n.tr("Блокировать ") + modelData.toUpperCase()
                                onClicked: root.controller.changeFirewall(
                                    modelData, false
                                )
                            }
                        }
                    }
                }
            }
        }
    }

    MikoListGroup {
        style: root.ui
        Repeater {
            model: root.controller.portListExpanded
                ? root.controller.listeningPorts
                : (root.controller.listeningPorts ? root.controller.listeningPorts.slice(0, 8) : [])
            delegate: MikoListRow {
                id: portDelegate
                required property var modelData
                required property int index
                style: root.ui
                title: portDelegate.modelData.port + "/"
                    + portDelegate.modelData.protocol.toUpperCase() + " · "
                    + portDelegate.modelData.service
                subtitle: portDelegate.modelData.scope === "computer"
                    ? I18n.tr("Только этот компьютер")
                    : portDelegate.modelData.scope === "all"
                        ? I18n.tr("Все интерфейсы") : portDelegate.modelData.address
                icon: portDelegate.modelData.scope === "computer" ? "computer" : "lan"
                dividerVisible: portDelegate.index < (
                    root.controller.portListExpanded
                        ? (root.controller.listeningPorts ? root.controller.listeningPorts.length : 0)
                        : Math.min(root.controller.listeningPorts ? root.controller.listeningPorts.length : 0, 8)
                ) - 1

                MikoBadge {
                    style: root.ui
                    text: portDelegate.modelData.firewall === "allowed"
                        ? I18n.tr("Разрешён")
                        : portDelegate.modelData.firewall === "blocked"
                            ? I18n.tr("Заблокирован")
                            : portDelegate.modelData.firewall === "blocked-default"
                                ? I18n.tr("Закрыт") : I18n.tr("По умолчанию")
                    tone: portDelegate.modelData.firewall === "allowed"
                        ? "success"
                        : portDelegate.modelData.firewall === "blocked"
                            ? "warning" : "neutral"
                    icon: portDelegate.modelData.firewall === "allowed" ? "check" : portDelegate.modelData.firewall === "blocked" ? "block" : "lock"
                }
            }
        }
    }

    MikoButton {
        visible: root.controller.listeningPorts && root.controller.listeningPorts.length > 8
        Layout.alignment: Qt.AlignHCenter
        style: root.ui
        icon: root.controller.portListExpanded
            ? "expand_less" : "expand_more"
        text: root.controller.portListExpanded
            ? I18n.tr("Свернуть")
            : I18n.tr("Показать все (")
                + root.controller.listeningPorts.length + ")"
        onClicked: root.controller.portListExpanded =
            !root.controller.portListExpanded
    }
}
