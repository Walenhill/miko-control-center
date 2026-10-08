import QtQuick
import Quickshell
import Quickshell.Io
import qs.services
import qs.modules.common

QtObject {
    id: root

    required property var router
    property string subsection: "form"
    readonly property string editor: router.appearanceEditor
    readonly property Process randomProcess: randomWallpaperProcess
    readonly property bool busy: randomWallpaperProcess.running || wallpaperPicker.running || paletteBusy
    property string queuedMode: ""
    property string paletteMessage: ""
    property bool generationFailed: false
    signal themeFailed(string message)
    property string queuedPalette: ""
    property string runningPalette: ""
    readonly property string paletteSelection: queuedPalette !== ""
        ? queuedPalette
        : runningPalette !== ""
            ? runningPalette
            : Config.options.appearance.palette.type
    readonly property bool paletteBusy:
        paletteDelay.running || paletteProcess.running

    readonly property var editors: ({
        wallpaper: {
            title: I18n.tr("Обои и цвета"),
            subtitle: I18n.tr("Источники, палитра и Material You"),
            icon: "wallpaper"
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
            wallpaperPicker.exec([Directories.wallpaperSwitchScriptPath]);
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
        queuedMode = dark ? "dark" : "light";
        paletteMessage = "";
        paletteDelay.restart();
    }

    function applyPalette(value) {
        // Config writes are asynchronous. Passing the value explicitly keeps
        // switchwall from reading the previous value, while the single worker
        // prevents older generators from finishing after a newer choice.
        queuedPalette = value;
        paletteMessage = "";
        Config.options.appearance.palette.type = value;
        paletteDelay.restart();
    }

    function startPaletteJob() {
        if (paletteProcess.running || randomWallpaperProcess.running || wallpaperPicker.running
                || (queuedPalette === "" && queuedMode === ""))
            return;
        runningPalette = queuedPalette || Config.options.appearance.palette.type;
        queuedPalette = "";
        const command = [
            Directories.wallpaperSwitchScriptPath,
            "--noswitch",
            "--type",
            runningPalette
        ];
        if (queuedMode !== "") command.push("--mode", queuedMode);
        queuedMode = "";
        paletteProcess.command = command;
        paletteProcess.running = true;
    }

    property Process randomWallpaperProcess: Process {
        property string scriptPath: ""
        command: ["bash", "-c", scriptPath]
        onExited: (code, status) => root.generationFinished(code)
    }

    property Process wallpaperPicker: Process {
        onExited: (code, status) => root.generationFinished(code)
    }

    function generationFinished(code) {
        generationFailed = code !== 0;
        if (generationFailed) {
            paletteMessage = I18n.tr("Не удалось применить оформление. Повтори попытку.");
            themeFailed(paletteMessage);
        } else {
            MaterialThemeLoader.reapplyTheme();
        }
        if (queuedPalette !== "" || queuedMode !== "")
            Qt.callLater(root.startPaletteJob);
    }

    property Timer paletteDelay: Timer {
        interval: 140
        repeat: false
        onTriggered: root.startPaletteJob()
    }

    property Process paletteProcess: Process {
        onExited: (exitCode, exitStatus) => {
            root.runningPalette = "";
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
}
