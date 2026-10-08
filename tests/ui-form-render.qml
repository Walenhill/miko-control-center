import QtQuick
import QtQuick.Window
import Quickshell
import "controlcenter" as CC

// Isolated, input-transparent render of the actual composition root. It does
// not click controls, generate themes, or use the user's control-center state.
QtObject {
    id: root
    property var app: null
    property var viewport: null
    property int phase: 0
    property Timer capture: Timer {
        interval: 800
        running: true
        repeat: true
        onTriggered: {
            if (!root.app) {
                const component = Qt.createComponent("control-center.qml");
                if (component.status !== Component.Ready) {
                    console.error(component.errorString());
                    Qt.exit(1);
                    return;
                }
                root.app = component.createObject(null, {
                    width: Number(Quickshell.env("MIKO_RENDER_WIDTH")) || 1320,
                    height: Number(Quickshell.env("MIKO_RENDER_HEIGHT")) || 860,
                    flags: Qt.Window | Qt.FramelessWindowHint | Qt.WindowDoesNotAcceptFocus | Qt.WindowTransparentForInput,
                    visible: true
                });
                if (!root.app) { Qt.exit(1); return; }
                root.app.openDestination({pageId: Quickshell.env("MIKO_RENDER_PAGE") || "appearance", section: Quickshell.env("MIKO_RENDER_EDITOR") || "materials"});
                return;
            }
            if (root.phase === 0) {
                const pages = [];
                function findPages(item) {
                    if (item instanceof CC.MikoPageFlickable) pages.push(item);
                    for (const child of item.children || []) findPages(child);
                }
                findPages(root.app.contentItem);
                const page = pages.find(item => item.visible && item.height > 0);
                if (!page) { console.error("Visible scroll viewport not found"); Qt.exit(1); return; }
                root.viewport = page;
                const scroll = Quickshell.env("MIKO_RENDER_SCROLL");
                page.restoreScroll(scroll === "end" ? Math.max(0, page.contentHeight - page.height) : Number(scroll) || 0);
                root.phase = 1;
                return;
            }
            capture.stop();
            const scroll = Quickshell.env("MIKO_RENDER_SCROLL");
            if (scroll === "end" && Math.abs(root.viewport.contentHeight - root.viewport.height - root.viewport.contentY) > 1) {
                console.error("Render did not reach scroll end"); Qt.exit(1); return;
            }
            const plane = root.app.contentItem.children.find(item => item.objectName === "mikoWindowPlane");
            if (!plane) { console.error("Window plane not found"); Qt.exit(1); return; }
            plane.grabToImage(result => {
                if (!result.saveToFile(Quickshell.env("MIKO_RENDER_OUTPUT"))) { Qt.exit(1); return; }
                console.info("[Miko UI render] complete");
                Qt.quit();
            });
        }
    }
    property Timer deadline: Timer {
        interval: 10000
        running: true
        onTriggered: Qt.exit(1)
    }
}
