import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import qs.modules.common

MikoPageFlickable {
    id: root

    required property var audio
    required property var controller
    required property var effects
    required property var style

    property string activeTab: "devices"

    contentHeight: contentColumn.implicitHeight
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    function revealSection(section) {
        if (section === "mixer" || section === "scenes")
            activeTab = "mixer";
        else if (section === "tools" || section === "effects" || section === "balance")
            activeTab = "effects";
        else
            activeTab = "devices";
        scrollTo(0);
    }

    PwNodePeakMonitor {
        id: microphonePeak
        node: root.audio.source
        enabled: root.visible && root.activeTab === "devices"
    }

    ColumnLayout {
        id: contentColumn
        width: parent.width
        spacing: 18

        // Sub-navigation: iOS / "Оформление" style Segmented Capsule Tabs
        MikoSegmentedTabs {
            Layout.alignment: Qt.AlignHCenter
            style: root.style
            currentTab: root.activeTab
            model: [
                {
                    id: "devices",
                    title: I18n.tr("Устройства"),
                    icon: "headphones",
                    badge: Math.round((root.audio.value || 0) * 100) + "%"
                },
                {
                    id: "mixer",
                    title: I18n.tr("Микшер"),
                    icon: "tune",
                    badge: (root.audio.outputAppNodes && root.audio.outputAppNodes.length > 0)
                        ? String(root.audio.outputAppNodes.length) : ""
                },
                {
                    id: "effects",
                    title: I18n.tr("Эффекты"),
                    icon: "equalizer",
                    badge: (root.effects && root.effects.active) ? I18n.tr("Вкл") : ""
                }
            ]
            onTabSelected: (tabId) => {
                root.activeTab = tabId;
                root.scrollTo(0);
            }
        }

        // Tab 1: Master Volume & Audio Devices
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 16
            visible: root.activeTab === "devices"

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
        }

        // Tab 2: Application Volume Mixer & Sound Profiles/Scenes
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 16
            visible: root.activeTab === "mixer"

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
        }

        // Tab 3: EasyEffects Equalizer & Hearing Protection / Fine Tuning
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 16
            visible: root.activeTab === "effects"

            SoundTools {
                id: toolsSection
                controller: root.controller
                effects: root.effects
                style: root.style
            }
        }
    }
}
