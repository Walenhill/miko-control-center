import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    required property var controller
    required property var style

    width: parent ? parent.width : implicitWidth
    spacing: root.style.gapSection

    RowLayout {
        Layout.fillWidth: true
        StyledText {
            Layout.fillWidth: true
            text: "Порты и доступ"
            color: root.style.ink
            font.pixelSize: Appearance.font.pixelSize.larger
            font.weight: Font.DemiBold
        }
        StyledText {
            text: root.controller.listeningPorts.length
                + " слушающих сокетов"
            color: root.style.mutedInk
        }
        MikoButton {
            style: root.style
            icon: "refresh"
            text: ""
            implicitWidth: 42
            onClicked: root.controller.refreshPorts()
        }
    }

    MikoSurface {
        Layout.fillWidth: true
        implicitHeight: inspectorContent.implicitHeight + 30
        style: root.style
        accented: true

        ColumnLayout {
            id: inspectorContent
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 15
            spacing: 10
            RowLayout {
                Layout.fillWidth: true
                MikoIconDisc {
                    style: root.style
                    icon: "policy"
                    accented: true
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0
                    StyledText {
                        text: "Проверить конкретный порт"
                        color: root.style.ink
                        font.weight: Font.DemiBold
                    }
                    StyledText {
                        text: "Процесс, интерфейс, UFW и оценка риска"
                        color: root.style.mutedInk
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
                    style: root.style
                    icon: "search"
                    text: "Проверить"
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
                style: root.style
                accented: false

                ColumnLayout {
                    id: inspectionResult
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 12
                    spacing: 7
                    RowLayout {
                        Layout.fillWidth: true
                        MaterialSymbol {
                            text: root.controller.portInspection.listening
                                ? "sensors" : "do_not_disturb_on"
                            iconSize: 21
                            color: root.controller.portInspection.listening
                                ? Appearance.colors.colPrimary
                                : root.style.mutedInk
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.minimumWidth: 0
                            spacing: 0
                            StyledText {
                                Layout.fillWidth: true
                                text: root.controller.portInspection.listening
                                    ? "Порт "
                                        + root.controller.portInspection.query
                                        + " занят"
                                    : "Порт "
                                        + root.controller.portInspection.query
                                        + " никто не слушает"
                                color: root.style.ink
                                font.weight: Font.DemiBold
                                elide: Text.ElideRight
                            }
                            StyledText {
                                Layout.fillWidth: true
                                text: root.controller.portInspection.matches
                                        ?.length > 0
                                    ? root.controller.portInspection.matches[0]
                                        .service + " · "
                                        + root.controller.portInspection
                                            .matches[0].purpose
                                    : (root.controller.portInspection.known
                                        || "Известная служба не определена")
                                color: root.style.mutedInk
                                elide: Text.ElideRight
                            }
                        }
                        StyledText {
                            text: "TCP: "
                                + (root.controller.portInspection.tcp_firewall
                                    || "—") + " · UDP: "
                                + (root.controller.portInspection.udp_firewall
                                    || "—")
                            color: root.style.mutedInk
                        }
                    }

                    Repeater {
                        model: root.controller.portInspection.matches || []
                        StyledText {
                            required property var modelData
                            Layout.fillWidth: true
                            text: modelData.protocol.toUpperCase()
                                + " · " + modelData.address + " · "
                                + (modelData.process || "системная служба")
                                + (modelData.pid > 0
                                    ? " · PID " + modelData.pid : "")
                                + " · риск: "
                                + (modelData.risk === "high"
                                    ? "высокий"
                                    : modelData.risk === "medium"
                                        ? "нужна проверка" : "низкий")
                            color: root.style.mutedInk
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
                                ? "Высокий риск"
                                : root.controller.portInspection.assessment
                                        === "medium"
                                    ? "Стоит проверить" : "Низкий риск"
                            color: root.style.ink
                            font.weight: Font.DemiBold
                        }
                        StyledText {
                            Layout.fillWidth: true
                            text: root.controller.portInspection
                                .assessment_reason || ""
                            color: root.style.mutedInk
                            elide: Text.ElideRight
                        }
                    }

                    StyledText {
                        Layout.fillWidth: true
                        visible: root.controller.portActionMessage !== ""
                        text: root.controller.portActionMessage
                        color: root.style.mutedInk
                    }

                    Repeater {
                        model: ["tcp", "udp"]
                        RowLayout {
                            required property string modelData
                            Layout.fillWidth: true
                            StyledText {
                                Layout.fillWidth: true
                                text: modelData.toUpperCase()
                                color: root.style.ink
                                font.weight: Font.DemiBold
                            }
                            MikoButton {
                                style: root.style
                                icon: "lock_open"
                                text: "Разрешить " + modelData.toUpperCase()
                                onClicked: root.controller.changeFirewall(
                                    modelData, true
                                )
                            }
                            MikoButton {
                                style: root.style
                                icon: "block"
                                text: "Блокировать " + modelData.toUpperCase()
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
        style: root.style
        Repeater {
            model: root.controller.portListExpanded
                ? root.controller.listeningPorts
                : root.controller.listeningPorts.slice(0, 8)
            MikoListRow {
                required property var modelData
                required property int index
                style: root.style
                title: modelData.port + "/"
                    + modelData.protocol.toUpperCase() + " · "
                    + modelData.service
                subtitle: modelData.scope === "computer"
                    ? "Только этот компьютер"
                    : modelData.scope === "all"
                        ? "Все интерфейсы" : modelData.address
                icon: modelData.scope === "computer" ? "computer" : "lan"
                value: modelData.firewall === "allowed"
                    ? "UFW разрешает"
                    : modelData.firewall === "blocked"
                        ? "UFW блокирует"
                        : modelData.firewall === "blocked-default"
                            ? "UFW закрывает" : "Правило по умолчанию"
                dividerVisible: index < (
                    root.controller.portListExpanded
                        ? root.controller.listeningPorts.length
                        : Math.min(root.controller.listeningPorts.length, 8)
                ) - 1
            }
        }
    }

    MikoButton {
        visible: root.controller.listeningPorts.length > 8
        Layout.alignment: Qt.AlignHCenter
        style: root.style
        icon: root.controller.portListExpanded
            ? "expand_less" : "expand_more"
        text: root.controller.portListExpanded
            ? "Свернуть"
            : "Показать все ("
                + root.controller.listeningPorts.length + ")"
        onClicked: root.controller.portListExpanded =
            !root.controller.portListExpanded
    }
}
