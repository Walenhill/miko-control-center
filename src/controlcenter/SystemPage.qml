import QtQuick
import QtQuick.Layouts
import qs.modules.common.widgets

MikoPageFlickable {
    id: root

    required property var controller
    required property var telemetry
    required property var snapshots
    required property var style

    signal navigateRequested(string pageId)

    contentHeight: contentColumn.implicitHeight
    clip: true
    boundsBehavior: Flickable.StopAtBounds
    Component.onCompleted: root.controller.active = true
    Component.onDestruction: root.controller.active = false

    function revealSection(section) {
        const target = section === "watch"
            ? watchSection
            : section === "performance"
                ? performanceSection
                : section === "telemetry"
                ? telemetrySection
                : section === "snapshots"
                    ? snapshotsSection
                    : section === "storage"
            ? storageSection
            : section === "updates"
                ? updatesSection
                : null;
        if (target)
            scrollTo(Math.max(0, target.y - 12));
    }

    ColumnLayout {
        id: contentColumn

        width: parent.width
        spacing: 16

        SystemHero {
            Layout.fillWidth: true
            controller: root.controller
            style: root.style
        }

        SystemWatch {
            id: watchSection
            Layout.fillWidth: true
            controller: root.controller
            style: root.style
            onSectionRequested: section => root.revealSection(section)
            onNavigateRequested: pageId => root.navigateRequested(pageId)
        }

        SystemPerformance {
            id: performanceSection
            Layout.fillWidth: true
            controller: root.controller
            style: root.style
        }

        SystemPower {
            Layout.fillWidth: true
            controller: root.controller
            style: root.style
        }

        SystemTelemetry {
            id: telemetrySection
            Layout.fillWidth: true
            controller: root.telemetry
            style: root.style
            Component.onCompleted: root.telemetry.refresh()
        }

        SystemSnapshots {
            id: snapshotsSection
            Layout.fillWidth: true
            controller: root.snapshots
            style: root.style
        }

        SystemStorage {
            id: storageSection

            Layout.fillWidth: true
            controller: root.controller
            style: root.style
        }

        SystemUpdates {
            id: updatesSection

            Layout.fillWidth: true
            controller: root.controller
            style: root.style
        }
    }
}
