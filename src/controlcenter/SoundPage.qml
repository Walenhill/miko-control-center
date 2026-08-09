import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire

MikoPageFlickable {
    id: root

    required property var audio
    required property var controller
    required property var effects
    required property var style

    contentHeight: contentColumn.implicitHeight
    function revealSection(section) {
        const target = section === "mixer" ? mixerSection
            : section === "scenes" ? scenesSection
            : section === "tools" ? toolsSection : masterSection;
        scrollTo(Math.max(0, target.y - 12));
    }

    PwNodePeakMonitor {
        id: microphonePeak
        node: root.audio.source
        enabled: true
    }

    ColumnLayout {
        id: contentColumn
        width: parent.width
        spacing: 16

        SoundMasterControls {
            id: masterSection
            audio: root.audio
            microphonePeak: microphonePeak.peak
            style: root.style
        }
        SoundDevices {
            audio: root.audio
            style: root.style
        }
        SoundAppMixer {
            id: mixerSection
            audio: root.audio
            controller: root.controller
            style: root.style
        }
        SoundScenes {
            id: scenesSection
            controller: root.controller
            style: root.style
        }
        SoundTools {
            id: toolsSection
            controller: root.controller
            effects: root.effects
            style: root.style
        }
    }
}
