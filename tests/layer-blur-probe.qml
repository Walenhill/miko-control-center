// Opt-in compositor visual QA. No shell settings or preferences are written.
import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland

Scope {
    id: root
    readonly property var probeScreen: Quickshell.screens.find(screen => screen.name === Quickshell.env("MIKO_PROBE_SCREEN")) || Quickshell.screens[0]
    property real bodyAlpha: {
        const value = Number(Quickshell.env("MIKO_PROBE_ALPHA") || "0.2");
        return Number.isFinite(value) ? Math.max(0, Math.min(1, value)) : 0.2;
    }
    PanelWindow {
        screen: root.probeScreen
        anchors { top: true; left: true }
        margins { top: 100; left: 40 }
        implicitWidth: 400
        implicitHeight: 240
        exclusiveZone: 0
        WlrLayershell.namespace: "miko-blur-pattern"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        color: "#ffffff"
        Repeater {
            model: 1500
            Rectangle {
                required property int index
                x: (index % 50) * 8
                y: Math.floor(index / 50) * 8
                width: 8
                height: 8
                color: (index + Math.floor(index / 50)) % 2 ? "#eff5ff" : "#263b65"
            }
        }
    }
    PanelWindow {
        screen: root.probeScreen
        anchors { top: true; left: true }
        margins { top: 100; left: 40 }
        implicitWidth: 400
        implicitHeight: 240
        exclusiveZone: 0
        WlrLayershell.namespace: "quickshell:blurProbe"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        color: "transparent"
        RectangularShadow {
            anchors.fill: surface
            radius: surface.radius
            blur: 9
            offset: Qt.vector2d(0, 1)
            spread: 1
            color: Qt.rgba(0, 0, 0, 0.3)
            cached: true
        }
        Rectangle {
            id: surface
            anchors.fill: parent
            anchors.margins: 20
            radius: 18
            color: Qt.rgba(0.12, 0.12, 0.15, root.bodyAlpha)
        }
    }
    Timer {
        interval: 120000
        running: true
        onTriggered: Qt.quit()
    }
}
