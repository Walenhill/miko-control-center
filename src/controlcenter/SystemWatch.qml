import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

Rectangle {
    id: root

    property var style: null
    readonly property var ui: style ? style : DefaultStyle

    required property var controller

    signal sectionRequested(string section)
    signal navigateRequested(string pageId)

    implicitHeight: watchInboxContent.implicitHeight + 28
    radius: root.ui.radiusSection
    color: root.controller.watchActiveCount > 0
        ? root.ui.selectedCardBackground
        : root.ui.sectionSurface
    border.width: 1
    border.color: root.controller.watchEvents.some(
        event => !event.resolved && !event.ignored && event.severity === "critical"
    ) ? root.ui.alpha(Appearance.colors.colError, 0.40)
      : root.ui.hairline
    antialiasing: true

    ColumnLayout {
        id: watchInboxContent

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 16
        }
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            MikoIconDisc {
                style: root.ui
                icon: "visibility"
                accented: root.controller.watchActiveCount > 0
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                StyledText {
                    text: "Miko Watch"
                    color: root.ui.ink
                    font.pixelSize: Appearance.font.pixelSize.normal
                    font.weight: Font.DemiBold
                }

                StyledText {
                    text: root.controller.watchActiveCount > 0
                        ? root.controller.watchActiveCount + I18n.tr(" активных · ") + root.controller.watchUnreadCount + I18n.tr(" новых")
                        : I18n.tr("Новых системных событий нет") + (root.controller.watchIgnoredCount > 0 ? " · " + root.controller.watchIgnoredCount + I18n.tr(" скрыто") : "")
                    color: root.ui.mutedInk
                    font.pixelSize: Appearance.font.pixelSize.smaller
                }
            }

            StyledText {
                text: I18n.tr("Проверено ") + root.controller.watchLastScan
                color: root.ui.mutedInk
                font.pixelSize: Appearance.font.pixelSize.smaller
            }

            MikoButton {
                style: root.ui
                icon: "refresh"
                text: I18n.tr("Проверить")
                enabled: !root.controller.watchAction.running
                onClicked: root.controller.scanWatch()
            }

            MikoButton {
                style: root.ui
                visible: root.controller.watchUnreadCount > 0
                icon: "done_all"
                text: I18n.tr("Прочитано")
                onClicked: root.controller.markAllWatchRead()
            }

            MikoButton {
                style: root.ui
                visible: root.controller.watchIgnoredCount > 0
                icon: "visibility"
                text: I18n.tr("Вернуть скрытые")
                onClicked: root.controller.restoreIgnoredWatchEvents()
            }
        }

        Repeater {
            model: root.controller.watchEvents.filter(
                event => !event.resolved && !event.ignored
            ).slice(0, 4)

            delegate: Rectangle {
                id: watchEvent
                required property var modelData

                Layout.fillWidth: true
                implicitHeight: 64
                radius: root.ui.radiusControl
                color: root.ui.hoverSurface
                border.width: 1
                border.color: root.ui.hairline
                opacity: watchEvent.modelData.read ? 0.78 : 1
                antialiasing: true

                RowLayout {
                    anchors {
                        fill: parent
                        leftMargin: 14
                        rightMargin: 12
                    }
                    spacing: 12

                    MaterialSymbol {
                        text: watchEvent.modelData.severity === "critical" ? "error" : "warning"
                        iconSize: 20
                        color: watchEvent.modelData.severity === "critical"
                            ? Appearance.colors.colError
                            : Appearance.colors.colPrimary
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.minimumWidth: 0
                        spacing: 2

                        StyledText {
                            Layout.fillWidth: true
                            text: watchEvent.modelData.title
                            color: root.ui.ink
                            font.weight: watchEvent.modelData.read ? Font.Normal : Font.DemiBold
                            elide: Text.ElideRight
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: watchEvent.modelData.detail
                            color: root.ui.mutedInk
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            elide: Text.ElideRight
                        }
                    }

                    MikoButton {
                        style: root.ui
                        icon: "arrow_forward"
                        text: I18n.tr("Открыть")
                        onClicked: {
                            root.controller.markWatchEventRead(watchEvent.modelData.id);
                            const action = watchEvent.modelData.action;
                            if (action === "storage" || action === "updates")
                                root.sectionRequested(action);
                            else if (action === "services")
                                root.navigateRequested("services");
                            else if (action === "sound")
                                root.navigateRequested("sound");
                            else if (action === "network")
                                root.navigateRequested("network");
                        }
                    }

                    MikoButton {
                        style: root.ui
                        icon: "visibility_off"
                        text: I18n.tr("Скрыть")
                        onClicked: root.controller.ignoreWatchEvent(watchEvent.modelData.id)
                    }
                }
            }
        }
    }
}
