import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

MikoSurface {
    id: root

    required property var audio
    required property var style
    property bool input: false

    readonly property var rawDevices: input ? audio.inputDevices : audio.outputDevices
    readonly property var activeDevice: input ? audio.source : audio.sink

    readonly property var devices: {
        if (!rawDevices || rawDevices.length === 0) return [];
        const seen = new Set();
        const result = [];
        if (activeDevice) {
            for (let i = 0; i < rawDevices.length; ++i) {
                const d = rawDevices[i];
                if (d && d.id === activeDevice.id) {
                    result.push(d);
                    const key = (d.nickname || "") + "::" + (d.description || "") + "::" + (d.name || "");
                    seen.add(key);
                    break;
                }
            }
        }
        for (let i = 0; i < rawDevices.length; ++i) {
            const d = rawDevices[i];
            if (!d) continue;
            if (activeDevice && d.id === activeDevice.id) continue;
            const key = (d.nickname || "") + "::" + (d.description || "") + "::" + (d.name || "");
            if (!seen.has(key)) {
                seen.add(key);
                result.push(d);
            }
        }
        return result;
    }

    function deviceIcon(node) {
        if (root.input) return "mic";
        const nick = (node && node.nickname) ? String(node.nickname) : "";
        const desc = (node && node.description) ? String(node.description) : "";
        const name = (nick + " " + desc).toLowerCase();
        if (name.indexOf("headset") !== -1 || name.indexOf("headphone") !== -1 || name.indexOf("наушник") !== -1)
            return "headphones";
        if (name.indexOf("hdmi") !== -1 || name.indexOf("displayport") !== -1 || name.indexOf("af24h1") !== -1 || name.indexOf("monitor") !== -1 || name.indexOf("tv") !== -1)
            return "desktop_windows";
        return "speaker";
    }

    Layout.fillWidth: true
    Layout.fillHeight: true
    implicitHeight: content.implicitHeight + 32

    ColumnLayout {
        id: content
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 16 }
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            MikoIconDisc {
                style: root.style
                icon: root.input ? "mic" : "speaker"
                accented: false
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0
                StyledText {
                    text: root.input ? I18n.tr("Откуда записывать") : I18n.tr("Куда воспроизводить")
                    color: root.style.ink
                    font.pixelSize: Appearance.font.pixelSize.small
                    font.weight: Font.DemiBold
                }
                StyledText {
                    text: root.devices.length + (root.input ? I18n.tr(" входов") : I18n.tr(" выходов"))
                    color: root.style.mutedInk
                    font.pixelSize: Appearance.font.pixelSize.smaller
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            Repeater {
                model: root.devices

                delegate: MikoSelectableRow {
                    id: deviceRow
                    required property var modelData

                    style: root.style
                    title: root.audio.friendlyDeviceName(modelData)
                    icon: root.deviceIcon(modelData)
                    selected: root.activeDevice && root.activeDevice.id === modelData.id
                    onClicked: {
                        if (root.input)
                            root.audio.setDefaultSource(modelData);
                        else
                            root.audio.setDefaultSink(modelData);
                    }
                }
            }
        }
    }
}
