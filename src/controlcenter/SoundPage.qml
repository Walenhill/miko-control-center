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
            audio: root.audio
            microphonePeak: microphonePeak.peak
            style: root.style
        }
        SoundDevices {
            audio: root.audio
            style: root.style
        }
        SoundAppMixer {
            audio: root.audio
            controller: root.controller
            style: root.style
        }
        SoundScenes {
            controller: root.controller
            style: root.style
        }
        SoundTools {
            controller: root.controller
            effects: root.effects
            style: root.style
        }
    }
}
