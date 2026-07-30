import QtQuick
import QtQuick.Layouts
import qs.modules.common.widgets

MikoPageFlickable {
    id: root

    required property var controller
    required property var style

    signal navigateRequested(string pageId)

    contentHeight: contentColumn.implicitHeight
    clip: true
    boundsBehavior: Flickable.StopAtBounds
    Component.onCompleted: root.controller.active = true
    Component.onDestruction: root.controller.active = false

    function revealSection(section) {
        const target = section === "storage"
            ? storageSection
            : section === "updates"
                ? updatesSection
                : null;
        if (target)
            contentY = Math.max(0, target.y - 12);
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
            Layout.fillWidth: true
            controller: root.controller
            style: root.style
            onSectionRequested: section => root.revealSection(section)
            onNavigateRequested: pageId => root.navigateRequested(pageId)
        }

        SystemPerformance {
            Layout.fillWidth: true
            controller: root.controller
            style: root.style
        }

        SystemPower {
            Layout.fillWidth: true
            controller: root.controller
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
