import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

Rectangle {
    id: root

    required property var controller
    required property var style

    signal sectionRequested(string section)
    signal navigateRequested(string pageId)

    implicitHeight: watchInboxContent.implicitHeight + 28
    radius: root.style.radiusSection
    color: root.controller.watchActiveCount > 0
        ? Qt.rgba(
            Appearance.colors.colPrimary.r,
            Appearance.colors.colPrimary.g,
            Appearance.colors.colPrimary.b,
            0.13
        )
        : root.style.sectionSurface
    border.width: 1
    border.color: root.controller.watchEvents.some(
        event => !event.resolved && !event.ignored
            && event.severity === "critical"
    ) ? Qt.rgba(
        Appearance.colors.colError.r,
        Appearance.colors.colError.g,
        Appearance.colors.colError.b,
        0.42
    ) : Qt.rgba(
        root.style.ink.r,
        root.style.ink.g,
        root.style.ink.b,
        0.06
    )
    antialiasing: true

    component LabelText: StyledText {
        color: root.style.ink
        font.pixelSize: Appearance.font.pixelSize.small
    }

    component MutedText: StyledText {
        color: root.style.mutedInk
        font.pixelSize: Appearance.font.pixelSize.smaller
    }

    component IconDisc: MikoIconDisc {
        style: root.style
    }

    component SoftButton: MikoButton {
        style: root.style
    }

    ColumnLayout {
        id: watchInboxContent

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 14
        }
        spacing: 8

        RowLayout {
            Layout.fillWidth: true

            IconDisc {
                icon: "visibility"
                accented: root.controller.watchActiveCount > 0
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                LabelText {
                    text: "Miko Watch"
                    font.pixelSize: Appearance.font.pixelSize.larger
                    font.weight: Font.DemiBold
                }

                MutedText {
                    text: root.controller.watchActiveCount > 0
                        ? root.controller.watchActiveCount
                            + " активных · "
                            + root.controller.watchUnreadCount + " новых"
                        : "Новых системных событий нет"
                            + (root.controller.watchIgnoredCount > 0
                                ? " · "
                                    + root.controller.watchIgnoredCount
                                    + " скрыто"
                                : "")
                }
            }

            MutedText {
                text: "Проверено " + root.controller.watchLastScan
            }

            SoftButton {
                icon: "refresh"
                text: "Проверить"
                enabled: !root.controller.watchAction.running
                onClicked: root.controller.scanWatch()
            }

            SoftButton {
                visible: root.controller.watchUnreadCount > 0
                icon: "done_all"
                text: "Прочитано"
                onClicked: root.controller.markAllWatchRead()
            }

            SoftButton {
                visible: root.controller.watchIgnoredCount > 0
                icon: "visibility"
                text: "Вернуть скрытые"
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
                implicitHeight: 68
                radius: 19
                color: root.style.hoverSurface
                opacity: watchEvent.modelData.read ? 0.78 : 1

                RowLayout {
                    anchors {
                        fill: parent
                        leftMargin: 13
                        rightMargin: 10
                    }
                    spacing: 11

                    MaterialSymbol {
                        text: watchEvent.modelData.severity === "critical"
                            ? "error" : "warning"
                        iconSize: 21
                        color: watchEvent.modelData.severity === "critical"
                            ? Appearance.colors.colError
                            : Appearance.colors.colPrimary
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.minimumWidth: 0
                        spacing: 0

                        LabelText {
                            Layout.fillWidth: true
                            text: watchEvent.modelData.title
                            font.weight: watchEvent.modelData.read
                                ? Font.Normal : Font.DemiBold
                            elide: Text.ElideRight
                        }

                        MutedText {
                            Layout.fillWidth: true
                            text: watchEvent.modelData.detail
                            elide: Text.ElideRight
                        }
                    }

                    SoftButton {
                        icon: "arrow_forward"
                        text: "Открыть"
                        onClicked: {
                            root.controller.markWatchEventRead(
                                watchEvent.modelData.id
                            );
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

                    SoftButton {
                        icon: "visibility_off"
                        text: "Не напоминать"
                        onClicked: root.controller.ignoreWatchEvent(
                            watchEvent.modelData.id
                        )
                    }
                }
            }
        }
    }
}
