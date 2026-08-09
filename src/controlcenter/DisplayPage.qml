import QtQuick
import QtQuick.Layouts

MikoPageFlickable {
    id: root

    required property var controller
    required property var hyprlandData
    required property var hyprsunset
    required property var night
    required property var style

    contentHeight: contentColumn.implicitHeight
    function revealSection(section) {
        const target = section === "modes" ? modesSection
            : section === "scenes" ? scenesSection
            : section === "comfort" ? comfortSection : topologySection;
        scrollTo(Math.max(0, target.y - 12));
    }

    ColumnLayout {
        id: contentColumn
        width: parent.width
        spacing: 16

        DisplayTopology {
            id: topologySection
            controller: root.controller
            hyprlandData: root.hyprlandData
            style: root.style
        }

        DisplayPreviewBanner {
            active: root.controller.previewActive
            seconds: root.controller.previewSeconds
            rollback: () => root.controller.rollbackPreview()
            confirm: () => root.controller.confirmPreview()
            save: () => root.controller.savePreview()
            style: root.style
        }

        DisplayModeControls {
            id: modesSection
            controller: root.controller
            style: root.style
        }

        DisplayScenes {
            id: scenesSection
            controller: root.controller
            style: root.style
            wakeAll: () => root.controller.wakeAll()
        }

        DisplayComfort {
            id: comfortSection
            brightnessMonitor: root.controller.selectedBrightnessMonitor()
            hyprsunset: root.hyprsunset
            night: root.night
            style: root.style
        }
    }
}
