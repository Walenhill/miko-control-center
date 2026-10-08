import QtQuick
import Quickshell.Io
import qs.modules.common

QtObject {
    id: root
    required property var themeController
    property var state: ({})
    property bool available: false
    property bool detected: false
    property bool pendingRefresh: false
    property string message: ""
    property string jobKind: ""
    property var blurBefore: null
    property var blurAfter: null
    property var undoEntry: null
    readonly property bool busy: action.running
    signal actionFinished(string kind, bool success)
    readonly property var modes: state.modes || []
    readonly property var activePreset: modes.find(mode => mode.id === state.activeMode) || null
    readonly property bool presetModified: {
        if (!activePreset) return false;
        const preset = activePreset.illogical || {}, live = Config.options.appearance.transparency;
        if (live.enable !== preset.transparencyEnable || live.automatic !== preset.transparencyAutomatic) return true;
        if (!live.automatic && (Math.abs(live.backgroundTransparency - preset.backgroundTransparency) > 0.001 || Math.abs(live.contentTransparency - preset.contentTransparency) > 0.001)) return true;
        const blur = activePreset.blur || {}, current = state.blur || {};
        return Object.keys(blur).filter(key => key.startsWith("decoration:blur:")).some(key =>
            String(current[key.split(":").pop()]) !== String(blur[key]));
    }
    function refresh() {
        if (!detected) return;
        if (inspection.running) { pendingRefresh = true; return; }
        inspection.running = true;
    }
    function launch(kind, args) {
        if (!available || busy || themeController.busy) return false;
        jobKind = kind;
        message = I18n.tr("Применяется оформление…");
        action.command = ["miko-theme"].concat(args);
        action.running = true;
        return true;
    }
    function applyPreset(id) {
        if (!modes.some(mode => mode.id === id) || !/^[a-zA-Z0-9_-]{1,64}$/.test(id)) return;
        launch("preset", ["mode", id]);
    }
    function syncColors() { launch("colors", ["sync", "--quiet"]); }
    function rollback() { launch("preset", ["rollback"]); }
    function sameBlur(a, b) { return a && b && ["enabled", "size", "passes"].every(key => a[key] === b[key]); }
    function canUndoBlur(entry) { return available && !busy && entry && entry.kind === "blur" && sameBlur(state.blur, entry.after); }
    function applyBlur(enabled, size, passes, entry) {
        const before = state.blur;
        if (!state.blurSupported || !before || typeof enabled !== "boolean" || size < 1 || size > 16 || passes < 1 || passes > 4) return;
        const after = {enabled: enabled, size: Math.round(size), passes: Math.round(passes)};
        if (sameBlur(before, after)) return;
        if (!launch("blur", ["blur", "--enabled", String(enabled), "--size", String(after.size), "--passes", String(after.passes), "--expect", JSON.stringify(before)])) return;
        blurBefore = Object.assign({}, before);
        blurAfter = after;
        undoEntry = entry || null;
    }
    function undoBlur(entry) {
        if (canUndoBlur(entry)) applyBlur(entry.before.enabled, entry.before.size, entry.before.passes, entry);
    }
    property Process detection: Process {
        command: ["sh", "-c", "command -v miko-theme >/dev/null 2>&1"]
        running: true
        onExited: (code, status) => {
            if (code === 0) { root.detected = true; root.refresh(); }
            else root.message = I18n.tr("miko-theme не установлен; настройки оболочки доступны отдельно");
        }
    }
    property Process inspection: Process {
        command: ["miko-theme", "inspect"]
        stdout: StdioCollector { id: inspectionOutput }
        onExited: (code, status) => {
            try {
                if (code !== 0 || inspectionOutput.text.length > 131072) throw new Error("inspection failed");
                const value = JSON.parse(inspectionOutput.text);
                if (value.protocol !== 1 || !Array.isArray(value.modes)
                    || typeof value.blurSupported !== "boolean" || typeof value.canRollback !== "boolean"
                    || !value.modes.every(mode => mode && typeof mode.name === "string" && /^[a-zA-Z0-9_-]{1,64}$/.test(mode.id))
                    || (value.blurSupported && (!value.blur || typeof value.blur.enabled !== "boolean"
                        || !Number.isInteger(value.blur.size) || !Number.isInteger(value.blur.passes))))
                    throw new Error("unsupported protocol");
                root.state = value;
                root.available = true;
            } catch (error) {
                root.available = false;
                root.message = I18n.tr("miko-theme недоступен или требует обновления интеграции");
            }
            if (root.pendingRefresh) { root.pendingRefresh = false; Qt.callLater(root.refresh); }
        }
    }
    property Process action: Process {
        stdout: StdioCollector { id: actionOutput }
        stderr: StdioCollector { id: actionErrors }
        onExited: (code, status) => {
            if (code === 0) {
                root.message = I18n.tr("Оформление применено");
                if (root.jobKind === "blur") {
                    if (root.undoEntry) AppearanceChanges.remove(root.undoEntry.id);
                    else AppearanceChanges.record({kind: "blur", before: root.blurBefore, after: root.blurAfter, label: I18n.tr("Размытие фона")});
                } else if (root.jobKind === "preset") {
                    // Presets touch external applications: do not imply that
                    // the ordinary option-only undo restores those effects.
                    AppearanceChanges.record({kind: "external", label: I18n.tr("Пресет miko-theme")});
                }
            } else {
                root.message = I18n.tr("Не удалось полностью применить оформление") + "\n" + (actionErrors.text || actionOutput.text).trim().slice(-1500);
                root.themeController.themeFailed(root.message);
            }
            root.undoEntry = null;
            root.actionFinished(root.jobKind, code === 0);
            root.refresh();
        }
    }
}
