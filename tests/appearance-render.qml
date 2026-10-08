import QtQuick
import QtQuick.Window
import Quickshell
import "controlcenter" as CC

// Opt-in non-activating render fixture: no controls are activated and no real
// generation is performed. Run against a copied source/runtime payload.
Window {
    id: root

    property QtObject router

    router: QtObject {
        property string appearanceEditor: Quickshell.env("MIKO_RENDER_EDITOR") || "fonts"
    }

    property QtObject preferences

    preferences: QtObject {
        property string language: "auto"
    }

    property CC.AppearanceController controller

    controller: CC.AppearanceController {
        router: root.router
    }

    width: 1000
    height: 800
    visible: true
    flags: Qt.Window | Qt.WindowDoesNotAcceptFocus | Qt.WindowTransparentForInput
    title: "Miko appearance render fixture"
    color: CC.DefaultStyle.windowSurface
    CC.AppearancePage {
        id: page

        anchors.fill: parent
        anchors.margins: 20
        controller: root.controller
        preferences: root.preferences
        style: CC.DefaultStyle
    }

    Timer {
        interval: 1200
        running: true
        onTriggered: page.grabToImage((result) => {
            if (!result.saveToFile(Quickshell.env("MIKO_RENDER_OUTPUT")))
                Qt.exit(1);

            console.info("[Miko render] complete");
            Qt.quit();
        })
    }

    Timer {
        interval: 5000
        running: true
        onTriggered: Qt.exit(1)
    }

}
