import QtQuick
import Quickshell
// scripts/smoke.sh places this harness in the temporary source root.
import "controlcenter" as CC

QtObject {
    id: root
    property int phase: 0
    property QtObject router: QtObject { property string appearanceEditor: "" }
    property QtObject colors: QtObject { property bool darkmode: true }
    property QtObject loader: QtObject {
        function reapplyTheme() { root.colors.darkmode = controller.runningMode === "dark"; }
    }
    property CC.AppearanceController controller: CC.AppearanceController {
        router: root.router
        configuration: ({appearance: {palette: {type: "auto", accentColor: ""}}, background: {wallpaperPath: "fixture.png"}})
        themeState: root.colors
        themeLoader: root.loader
        generationScript: Qt.resolvedUrl("theme-generator.sh").toString().replace("file://", "")
    }
    property CC.AppearanceHub appearance: CC.AppearanceHub {
        width: 940
        controller: root.controller
        style: CC.DefaultStyle
    }
    property CC.AppearanceChangeStatus status: CC.AppearanceChangeStatus {
        width: 940
        controller: root.controller
        style: CC.DefaultStyle
    }
    property CC.AppearanceProfilesEditor profileEditor: CC.AppearanceProfilesEditor {
        width: 940
        controller: root.controller
        style: CC.DefaultStyle
    }
    property CC.MikoStyle materialStyle: CC.MikoStyle {
        transparencySettings: ({enable: true, automatic: false, backgroundTransparency: 0.42, contentTransparency: 0.72})
        automaticBackground: 0.15
        automaticContent: 0.9
    }
    property CC.MikoButton textButton: CC.MikoButton {
        style: CC.DefaultStyle
        text: "Fixture"
        icon: "settings"
        width: 150
        height: 42
    }
    property CC.MikoButton iconButton: CC.MikoButton {
        style: CC.DefaultStyle
        icon: "close"
        width: 42
        height: 42
    }
    property CC.MikoSwitch sharedSwitch: CC.MikoSwitch {
        style: CC.DefaultStyle
    }
    property CC.MikoPageFlickable scrollViewport: CC.MikoPageFlickable {
        width: 480
        height: 300
        contentHeight: 900
    }
    property CC.MikoStepperRow stepper: CC.MikoStepperRow {
        width: 480
        height: 64
        style: CC.DefaultStyle
        title: "Fixture"
        minimum: 0
        maximum: 1
        value: 0
        onChanged: value => root.stepper.value = value
    }
    function findButton(item, icon) {
        if (item.icon === icon && typeof item.clicked === "function") return item;
        const children = item.children || [];
        for (const child of children) {
            const result = findButton(child, icon);
            if (result) return result;
        }
        return null;
    }

    function findToggle(item, title) {
        if (item.title === title && typeof item.toggled === "function") return item;
        const children = item.children || [];
        for (let i = 0; i < children.length; ++i) {
            const found = findToggle(children[i], title);
            if (found) return found;
        }
        return null;
    }

    function check(value, message) {
        if (!value) { console.error("[Miko appearance test]", message); Qt.exit(1); }
    }

    property Timer steps: Timer {
        interval: 60
        running: true
        repeat: true
        onTriggered: {
            if (root.phase === 0) {
                const viewport = root.scrollViewport;
                root.check(viewport.layer.enabled && viewport.topFadeStrength === 0 && viewport.bottomFadeStrength === 1, "scroll fade at start");
                viewport.contentY = 18;
                root.check(viewport.topFadeStrength === 0.5 && viewport.bottomFadeStrength === 1, "scroll fade should ramp near start");
                viewport.contentY = viewport.scrollExtent;
                root.check(viewport.topFadeStrength === 1 && viewport.bottomFadeStrength === 0, "last content must not fade");
                viewport.edgeFadeEnabled = false;
                root.check(!viewport.layer.enabled, "scroll fade opt-out");
                viewport.edgeFadeEnabled = true;
                viewport.contentHeight = 300;
                viewport.contentY = 0;
                root.check(!viewport.layer.enabled && viewport.topFadeStrength === 0 && viewport.bottomFadeStrength === 0, "short pages should not allocate a fade layer");
                viewport.height = 60;
                root.check(viewport.effectiveFadeSize === 15, "fade should fit small viewports");
                root.check(root.textButton.radius === CC.DefaultStyle.radiusControl && root.iconButton.radius === 21, "button shape contract");
                root.sharedSwitch.toggle();
                root.check(root.sharedSwitch.checked, "shared switch cannot toggle");
                const minus = root.findButton(root.stepper, "remove");
                const plus = root.findButton(root.stepper, "add");
                root.check(minus && plus && !minus.enabled && plus.enabled, "stepper minimum state");
                plus.clicked();
                root.check(root.stepper.value === 1 && minus.enabled && !plus.enabled, "stepper maximum state");
                minus.clicked();
                root.check(root.stepper.value === 0, "stepper decrement");
                root.check(Math.abs(root.materialStyle.windowSurface.a - 0.58) < 0.01, "window alpha capped");
                root.check(Math.abs(root.materialStyle.sectionSurface.a - 0.28) < 0.01 && Math.abs(root.materialStyle.controlSurface.a - 0.28) < 0.01, "surface alpha capped");
                const rgb = [root.materialStyle.sectionSurface.r, root.materialStyle.sectionSurface.g, root.materialStyle.sectionSurface.b];
                root.materialStyle.transparencySettings = {enable: true, automatic: false, backgroundTransparency: 0.2, contentTransparency: 0.1};
                root.check(rgb.every((value, i) => Math.abs(value - [root.materialStyle.sectionSurface.r, root.materialStyle.sectionSurface.g, root.materialStyle.sectionSurface.b][i]) < 0.001), "transparency changed RGB");
                root.materialStyle.transparencySettings = {enable: false, automatic: true};
                root.check(root.materialStyle.windowSurface.a === 1 && root.materialStyle.sectionSurface.a === 1, "off not opaque");
                controller.applyPalette("scheme-expressive");
                controller.applyPalette("scheme-fidelity");
                controller.setDarkMode(false);
                root.check(controller.paletteSelection === "scheme-fidelity" && !controller.darkSelection, "pending selection");
                root.check(controller.appliedPalette === "auto", "requested palette shown as applied");
                root.phase = 1;
            } else if (root.phase === 1 && !controller.busy) {
                root.check(root.status.implicitHeight > 20, "appearance status has no height");
                root.check(controller.appliedPalette === "scheme-fidelity" && !root.colors.darkmode, "debounce result");
                root.check(CC.AppearanceChanges.entries.length === 1 && controller.canUndo, "theme history");
                controller.applyPalette("scheme-expressive");
                root.phase = 2;
            } else if (root.phase === 2 && controller.runningPalette !== "") {
                controller.applyPalette("scheme-content");
                controller.setDarkMode(true);
                root.phase = 3;
            } else if (root.phase === 3 && !controller.busy) {
                root.check(controller.appliedPalette === "scheme-content" && root.colors.darkmode, "latest queued selection");
                root.check(CC.AppearanceChanges.entries.length === 2, "queue recorded as one change");
                controller.undoLastChange();
                root.phase = 4;
            } else if (root.phase === 4 && !controller.busy) {
                root.check(controller.appliedPalette === "scheme-fidelity" && !root.colors.darkmode, "undo generated theme");
                root.check(CC.AppearanceChanges.entries.length === 1, "undo history consumed");
                controller.applyPalette("scheme-rainbow");
                root.phase = 5;
            } else if (root.phase === 5 && !controller.busy) {
                root.check(controller.generationFailed, "failure status");
                root.check(controller.configuration.appearance.palette.type === "scheme-fidelity", "failed selection retained");
                root.check(CC.AppearanceChanges.entries.length === 1, "failed change recorded");
                CC.AppearanceChanges.configuration = {bar: {bottom: false, vertical: false}, appearance: {transparency: {enable: false}}};
                const toggle = root.findToggle(root.appearance, CC.I18n.tr("Прозрачность"));
                root.check(toggle !== null, "appearance toggle not found");
                toggle.toggled(true);
                root.check(CC.AppearanceChanges.latest.label === toggle.title, "setting label missing");
                controller.undoLastChange();
                root.check(!CC.AppearanceChanges.configuration.appearance.transparency.enable, "appearance toggle undo");
                CC.AppearanceChanges.setOptions({"bar.bottom": true, "bar.vertical": true}, "fixture");
                root.check(controller.canUndo, "grouped setting cannot undo");
                controller.undoLastChange();
                root.check(!CC.AppearanceChanges.configuration.bar.bottom && !CC.AppearanceChanges.configuration.bar.vertical, "grouped setting undo");
                CC.AppearanceChanges.setOption("bar.bottom", true);
                CC.AppearanceChanges.configuration = {bar: {bottom: false, vertical: false}};
                root.check(!controller.canUndo, "external option change would be overwritten");
                CC.AppearanceChanges.remove(CC.AppearanceChanges.latest.id);
                controller.configuration = {appearance: {palette: {type: "scheme-neutral"}}, background: {wallpaperPath: "fixture.png"}};
                root.check(!controller.canUndo, "external change would be overwritten");
                for (let i = 0; i < 24; ++i)
                    CC.AppearanceChanges.setOption("bar.bottom", i % 2 === 0);
                root.check(CC.AppearanceChanges.entries.length === 20, "unbounded history");
                CC.AppearanceChanges.entries = [];
                controller.configuration = {appearance: {palette: {type: "scheme-neutral", accentColor: ""}}, background: {wallpaperPath: "fixture.png"}, dock: {height: 48}};
                CC.AppearanceChanges.configuration = controller.configuration;
                controller.appliedTheme = null;
                controller.applyAccent("#112233");
                root.phase = 6;
            } else if (root.phase === 6 && controller.runningPalette !== "") {
                controller.applyAccent("#445566");
                controller.setDarkMode(true);
                root.phase = 7;
            } else if (root.phase === 7 && !controller.busy) {
                root.check(controller.accentSelection === "#445566" && root.colors.darkmode, "accent queue result");
                root.check(controller.canUndo && CC.AppearanceChanges.latest.kind === "theme", "accent history");
                controller.undoLastChange();
                root.phase = 8;
            } else if (root.phase === 8 && !controller.busy) {
                root.check(controller.accentSelection === "" && !root.colors.darkmode, "accent clear undo");
                controller.applyProfile({format: "miko-appearance", version: 1, name: "Fixture",
                    options: {"dock.height": 80}, theme: {palette: "scheme-content", dark: true, accent: "#ABCDEF"}}, []);
                root.phase = 9;
            } else if (root.phase === 9 && !controller.busy) {
                root.check(controller.configuration.dock.height === 80 && controller.accentSelection === "#ABCDEF", "profile applied");
                root.check(CC.AppearanceChanges.latest.kind === "profile" && controller.canUndo, "profile grouped history");
                controller.undoLastChange();
                root.phase = 10;
            } else if (root.phase === 10 && !controller.busy) {
                root.check(controller.configuration.dock.height === 48 && controller.accentSelection === "" && !root.colors.darkmode, "profile grouped undo");
                controller.applyProfile({format: "miko-appearance", version: 1, name: "Failure",
                    options: {"dock.height": 80}, theme: {palette: "scheme-rainbow", dark: true, accent: "#ABCDEF"}}, []);
                root.phase = 11;
            } else if (root.phase === 11 && !controller.busy) {
                root.check(controller.generationFailed && controller.configuration.dock.height === 48 && controller.accentSelection === "", "failed profile changed options");
                controller.applyProfile({format: "miko-appearance", version: 1, name: "External",
                    options: {"dock.height": 80}, theme: {palette: "scheme-content", dark: true, accent: "#ABCDEF"}}, []);
                controller.configuration.dock.height = 66;
                root.phase = 12;
            } else if (root.phase === 12 && !controller.busy && root.profileEditor.ready) {
                root.check(controller.generationFailed && controller.configuration.dock.height === 66, "profile overwrote external change");
                root.profileEditor.add({format: "miko-appearance", version: 1, name: "Storage fixture", options: {"dock.height": 60}});
                root.check(root.profileEditor.profiles.length === 1 && root.profileEditor.selected.name === "Storage fixture", "profile storage add");
                let duplicateRejected = false;
                try { root.profileEditor.add(root.profileEditor.selected); } catch (error) { duplicateRejected = true; }
                root.check(duplicateRejected, "duplicate profile allowed");
                root.check(controller.configuration.dock.height === 66, "profile import changed config");
                root.phase = 13;
            } else if (root.phase === 13 && root.profileEditor.ready) {
                console.info("[Miko appearance test] complete");
                Qt.quit();
            }
        }
    }
    property Timer deadline: Timer {
        interval: 12000
        running: true
        onTriggered: { console.error("[Miko appearance test] timed out", root.phase); Qt.exit(1); }
    }
}
