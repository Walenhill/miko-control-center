import QtQuick
import Quickshell
import Quickshell.Io
import qs.services
import qs.modules.common
import "AppearanceUndo.js" as Undo
import "AppearanceProfiles.js" as Profiles

QtObject {
    id: root

    required property var router
    // Dependencies can be replaced by a regression harness without touching
    // the user's theme or running the real generator.
    property var configuration: Config.options
    property var themeState: Appearance.m3colors
    property var themeLoader: MaterialThemeLoader
    property string generationScript: Directories.wallpaperSwitchScriptPath
    readonly property var materialIntegration: materials
    property MaterialIntegration materials: MaterialIntegration { themeController: root }
    property string subsection: "form"
    readonly property string editor: router.appearanceEditor
    readonly property string materialMode: !configuration.appearance.transparency?.enable ? "off"
        : configuration.appearance.transparency.automatic ? "auto" : "manual"
    function setMaterialMode(mode) {
        if (busy || !["off", "auto", "manual"].includes(mode)) return;
        const values = {"appearance.transparency.enable": mode !== "off"};
        if (mode !== "off") values["appearance.transparency.automatic"] = mode === "auto";
        AppearanceChanges.setOptions(values, I18n.tr("Прозрачность оболочки"));
    }
    readonly property Process randomProcess: randomWallpaperProcess
    readonly property bool busy: randomWallpaperProcess.running || wallpaperPicker.running || paletteBusy || materials.busy
    property string queuedMode: ""
    property string paletteMessage: ""
    property bool generationFailed: false
    signal themeFailed(string message)
    property string queuedPalette: ""
    property string runningPalette: ""
    property string runningMode: ""
    property var desiredTheme: null
    property var appliedTheme: null
    property var transactionBefore: null
    property var undoEntry: null
    property bool queuedAccent: false
    property string runningAccent: ""
    property var profileOptions: null
    property var profileChanges: []
    property string profileName: ""
    readonly property bool optionsLocked: profileOptions !== null || (undoEntry !== null && undoEntry.kind === "profile")
    readonly property var latestChange: AppearanceChanges.latest
    readonly property bool canUndo: !busy && latestChange !== null && (
        latestChange.kind === "options" ? AppearanceChanges.optionsCanUndo(latestChange)
        : latestChange.kind === "blur" ? materials.canUndoBlur(latestChange)
        : (latestChange.kind === "theme" || latestChange.kind === "profile")
            && Undo.equal(themeSnapshot(), latestChange.after)
            && (latestChange.kind !== "profile" || Undo.matches(configuration, latestChange.changes)))
    readonly property string accentSelection: desiredTheme !== null ? desiredTheme.accent
        : root.configuration.appearance.palette.accentColor || ""
    readonly property bool darkSelection: desiredTheme !== null
        ? desiredTheme.dark : appliedTheme !== null ? appliedTheme.dark : root.themeState.darkmode
    readonly property string configuredPalette: root.configuration.appearance.palette.type
    onConfiguredPaletteChanged: {
        if (!busy && appliedTheme !== null && appliedTheme.palette !== configuredPalette)
            appliedTheme = null;
    }
    readonly property string appliedPalette: appliedTheme !== null
        ? appliedTheme.palette : root.configuration.appearance.palette.type
    readonly property string statusText: busy ? I18n.tr("Применяется оформление…")
        : paletteMessage !== "" ? paletteMessage
        : latestChange !== null ? latestChange.label
            ? I18n.tr("Применено: {setting}", {setting: latestChange.label})
            : I18n.tr("Последнее изменение применено") : ""
    readonly property string paletteSelection: queuedPalette !== ""
        ? queuedPalette
        : runningPalette !== ""
            ? runningPalette
            : root.configuration.appearance.palette.type
    readonly property bool paletteBusy:
        paletteDelay.running || paletteProcess.running || queuedPalette !== "" || queuedMode !== "" || queuedAccent

    function themeSnapshot() {
        return {palette: root.configuration.appearance.palette.type,
            dark: root.themeState.darkmode,
            accent: root.configuration.appearance.palette.accentColor || "",
            wallpaper: root.configuration.background.wallpaperPath};
    }

    function beginThemeChange() {
        if (transactionBefore === null) {
            transactionBefore = themeSnapshot();
            appliedTheme = Object.assign({}, transactionBefore);
        }
        if (desiredTheme === null) desiredTheme = themeSnapshot();
        generationFailed = false;
        paletteMessage = "";
    }

    function undoLastChange() {
        const entry = latestChange;
        if (!canUndo) return;
        if (entry.kind === "blur") { materials.undoBlur(entry); return; }
        if (entry.kind === "options") {
            AppearanceChanges.undoOptions(entry);
            paletteMessage = I18n.tr("Предыдущее значение восстановлено");
            return;
        }
        beginThemeChange();
        undoEntry = entry;
        desiredTheme = Object.assign({}, entry.before);
        queuedPalette = desiredTheme.palette;
        queuedMode = desiredTheme.dark ? "dark" : "light";
        queuedAccent = true;
        root.configuration.appearance.palette.type = desiredTheme.palette;
        root.configuration.appearance.palette.accentColor = desiredTheme.accent;
        paletteDelay.restart();
    }

    function applyAccent(value) {
        if (materials.busy) return;
        if (undoEntry !== null || profileOptions !== null) return;
        value = String(value).trim().toUpperCase();
        if ((value !== "" && !/^#[0-9A-F]{6}$/.test(value)) || accentSelection === value) return;
        beginThemeChange();
        desiredTheme = Object.assign({}, desiredTheme, {accent: value});
        queuedAccent = true;
        root.configuration.appearance.palette.accentColor = value;
        paletteDelay.restart();
    }

    function applyProfile(profile, availableFonts) {
        if (busy) return {skipped: [], busy: true};
        const plan = Profiles.plan(profile, configuration, availableFonts);
        if (!plan.theme) {
            AppearanceChanges.setOptions(plan.options, profile.name);
            return plan;
        }
        beginThemeChange();
        profileOptions = plan.options;
        profileChanges = Undo.changes(configuration, plan.options);
        profileName = profile.name;
        desiredTheme = Object.assign({}, desiredTheme, plan.theme);
        queuedPalette = desiredTheme.palette;
        queuedMode = desiredTheme.dark ? "dark" : "light";
        queuedAccent = true;
        configuration.appearance.palette.type = desiredTheme.palette;
        configuration.appearance.palette.accentColor = desiredTheme.accent;
        paletteDelay.restart();
        return plan;
    }

    readonly property var editors: ({
        wallpaper: {
            title: I18n.tr("Обои и цвета"),
            subtitle: I18n.tr("Источники, палитра и Material You"),
            icon: "wallpaper"
        },
        materials: {
            title: I18n.tr("Прозрачность и блюр"),
            subtitle: I18n.tr("Материалы оболочки, compositor и miko-theme"), icon: "blur_on"
        },
        bar: {
            title: I18n.tr("Панель"),
            subtitle: I18n.tr("Положение, поведение и содержимое панели"),
            icon: "dock_to_bottom"
        },
        interface: {
            title: I18n.tr("Интерфейс"),
            subtitle: I18n.tr("Dock, overview, шрифты и экранные элементы"),
            icon: "widgets"
        },
        notifications: {
            title: I18n.tr("Уведомления"),
            subtitle: I18n.tr("Время показа и расположение"),
            icon: "notifications"
        },
        lock: {
            title: I18n.tr("Экран блокировки"),
            subtitle: I18n.tr("Безопасность, фон и поведение"),
            icon: "lock"
        },
        advanced: {
            title: I18n.tr("Дополнительно"),
            subtitle: I18n.tr("Темизация приложений и эффекты рабочего стола"),
            icon: "tune"
        },
        widgets: {
            title: I18n.tr("Виджеты рабочего стола"),
            subtitle: I18n.tr("Часы, погода и расположение"), icon: "widgets"
        },
        fonts: {
            title: I18n.tr("Шрифты и типографика"),
            subtitle: I18n.tr("Роли шрифтов и предпросмотр"), icon: "text_fields"
        },
        profiles: {
            title: I18n.tr("Профили оформления"),
            subtitle: I18n.tr("Сохранение и перенос внешнего вида"), icon: "palette"
        }
    })

    function openEditor(name) {
        if (editors[name] === undefined)
            return;
        router.appearanceEditor = name;
    }

    function closeEditor() {
        router.appearanceEditor = "";
    }

    function editorMeta(name = editor) {
        return editors[name] ?? {
            title: I18n.tr("Оформление"),
            subtitle: I18n.tr("Обои, панель и интерфейс"),
            icon: "palette"
        };
    }

    function chooseWallpaper() {
        if (!busy)
            wallpaperPicker.exec([root.generationScript]);
    }

    function pickRandomWallpaper(source) {
        const scripts = {
            konachan: `${Directories.scriptPath}/colors/random/random_konachan_wall.sh`,
            osu: `${Directories.scriptPath}/colors/random/random_osu_wall.sh`
        };
        if (scripts[source] === undefined || busy)
            return;
        randomWallpaperProcess.scriptPath = scripts[source];
        randomWallpaperProcess.running = true;
    }

    function setDarkMode(dark) {
        if (materials.busy) return;
        if (undoEntry !== null || profileOptions !== null) return;
        if (darkSelection === dark) return;
        beginThemeChange();
        desiredTheme = Object.assign({}, desiredTheme, {dark: dark});
        queuedMode = dark ? "dark" : "light";
        paletteDelay.restart();
    }

    function applyPalette(value) {
        if (materials.busy) return;
        if (undoEntry !== null || profileOptions !== null) return;
        const allowed = ["auto", "scheme-content", "scheme-expressive", "scheme-fidelity",
            "scheme-fruit-salad", "scheme-monochrome", "scheme-neutral", "scheme-rainbow", "scheme-tonal-spot"];
        if (!allowed.includes(value) || paletteSelection === value) return;
        beginThemeChange();
        desiredTheme = Object.assign({}, desiredTheme, {palette: value});
        // Config writes are asynchronous. Passing the value explicitly keeps
        // switchwall from reading the previous value, while the single worker
        // prevents older generators from finishing after a newer choice.
        queuedPalette = value;
        root.configuration.appearance.palette.type = value;
        paletteDelay.restart();
    }

    function startPaletteJob() {
        if (paletteProcess.running || randomWallpaperProcess.running || wallpaperPicker.running
                || (queuedPalette === "" && queuedMode === "" && !queuedAccent))
            return;
        runningPalette = desiredTheme.palette;
        runningMode = desiredTheme.dark ? "dark" : "light";
        runningAccent = desiredTheme.accent || "";
        queuedPalette = "";
        const command = [
            root.generationScript,
            "--noswitch",
            "--type",
            runningPalette,
            "--mode", runningMode,
            "--color", runningAccent || "clear"
        ];
        queuedMode = "";
        queuedAccent = false;
        paletteProcess.command = command;
        paletteProcess.running = true;
    }

    property Process randomWallpaperProcess: Process {
        property string scriptPath: ""
        command: ["bash", "-c", scriptPath]
        onExited: (code, status) => root.externalGenerationFinished(code)
    }

    property Process wallpaperPicker: Process {
        onExited: (code, status) => root.externalGenerationFinished(code)
    }

    function externalGenerationFinished(code) {
        if (materials.available) materials.refresh();
        generationFailed = code !== 0;
        if (generationFailed) {
            paletteMessage = I18n.tr("Не удалось применить оформление. Повтори попытку.");
            themeFailed(paletteMessage);
        } else {
            root.themeLoader.reapplyTheme();
            appliedTheme = null;
            paletteMessage = I18n.tr("Оформление применено");
        }
        if (queuedPalette !== "" || queuedMode !== "" || queuedAccent)
            Qt.callLater(root.startPaletteJob);
    }

    function generationFinished(code) {
        if (materials.available) materials.refresh();
        generationFailed = code !== 0;
        if (code === 0) {
            appliedTheme = {palette: runningPalette, dark: runningMode === "dark", accent: runningAccent,
                wallpaper: root.configuration.background.wallpaperPath};
            root.themeLoader.reapplyTheme();
        }
        runningPalette = "";
        runningMode = "";
        if (queuedPalette !== "" || queuedMode !== "" || queuedAccent) {
            Qt.callLater(root.startPaletteJob);
            return;
        }
        if (code !== 0) {
            // Do not present the requested palette as a successfully applied one.
            root.configuration.appearance.palette.type = appliedTheme !== null
                ? appliedTheme.palette : transactionBefore.palette;
            root.configuration.appearance.palette.accentColor = appliedTheme !== null
                ? appliedTheme.accent : transactionBefore.accent;
            paletteMessage = I18n.tr("Не удалось применить оформление. Повтори попытку.");
            themeFailed(paletteMessage);
            if (undoEntry === null && appliedTheme !== null && !Undo.equal(transactionBefore, appliedTheme))
                AppearanceChanges.record({kind: "theme", before: transactionBefore, after: appliedTheme});
        } else if (undoEntry !== null) {
            if (undoEntry.kind === "profile" && !Undo.matches(configuration, undoEntry.changes)) {
                generationFailed = true;
                paletteMessage = I18n.tr("Настройки изменились снаружи; их значения не перезаписаны");
                if (!Undo.equal(transactionBefore, appliedTheme))
                    AppearanceChanges.record({kind: "theme", before: transactionBefore, after: appliedTheme});
                themeFailed(paletteMessage);
            } else {
                if (undoEntry.kind === "profile") Undo.write(configuration, undoEntry.changes, "before");
                AppearanceChanges.remove(undoEntry.id);
                paletteMessage = I18n.tr("Предыдущее значение восстановлено");
            }
        } else if (profileOptions !== null) {
            if (!Undo.matches(configuration, profileChanges, "before")) {
                generationFailed = true;
                paletteMessage = I18n.tr("Настройки изменились снаружи; их значения не перезаписаны");
                if (!Undo.equal(transactionBefore, appliedTheme))
                    AppearanceChanges.record({kind: "theme", before: transactionBefore, after: appliedTheme});
                themeFailed(paletteMessage);
            } else {
                Undo.write(configuration, profileChanges, "after");
                if (profileChanges.length || !Undo.equal(transactionBefore, appliedTheme))
                    AppearanceChanges.record({kind: "profile", before: transactionBefore,
                        after: appliedTheme, changes: profileChanges, label: profileName});
                paletteMessage = I18n.tr("Применено: {setting}", {setting: profileName});
            }
        } else {
            if (transactionBefore !== null && !Undo.equal(transactionBefore, appliedTheme))
                AppearanceChanges.record({kind: "theme", before: transactionBefore, after: appliedTheme});
            paletteMessage = I18n.tr("Оформление применено");
        }
        transactionBefore = null;
        desiredTheme = null;
        undoEntry = null;
        profileOptions = null;
        profileChanges = [];
        profileName = "";
    }

    property Timer paletteDelay: Timer {
        interval: 140
        repeat: false
        onTriggered: root.startPaletteJob()
    }

    property Process paletteProcess: Process {
        onExited: (exitCode, exitStatus) => {
            root.generationFinished(exitCode);
        }
    }

    property Connections routeWatch: Connections {
        target: root.router
        function onAppearanceEditorChanged() {
            if (root.router.appearanceEditor === "bar")
                root.subsection = "form";
        }
    }

    property Connections changeWatch: Connections {
        target: AppearanceChanges
        function onEntriesChanged() {
            if (root.latestChange && root.latestChange.kind === "options") {
                root.paletteMessage = "";
                root.generationFailed = false;
            }
        }
    }

    property Connections themeWatch: Connections {
        target: root.themeState
        function onDarkmodeChanged() {
            if (!root.busy && root.appliedTheme !== null && root.appliedTheme.dark !== root.themeState.darkmode)
                root.appliedTheme = null;
        }
    }
}
