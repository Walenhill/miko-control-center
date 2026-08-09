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
    readonly property bool busy: randomWallpaperProcess.running
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
            title: "Обои и цвета",
            subtitle: "Источники, палитра и Material You",
            icon: "wallpaper"
        },
        bar: {
            title: "Панель",
            subtitle: "Положение, поведение и содержимое панели",
            icon: "dock_to_bottom"
        },
        interface: {
            title: "Интерфейс",
            subtitle: "Dock, overview, шрифты и экранные элементы",
            icon: "widgets"
        },
        notifications: {
            title: "Уведомления",
            subtitle: "Время показа и расположение",
            icon: "notifications"
        },
        lock: {
            title: "Экран блокировки",
            subtitle: "Безопасность, фон и поведение",
            icon: "lock"
        },
        advanced: {
            title: "Дополнительно",
            subtitle: "Темизация приложений и эффекты рабочего стола",
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
            title: "Оформление",
            subtitle: "Обои, панель и интерфейс",
            icon: "palette"
        };
    }

    function chooseWallpaper() {
        Quickshell.execDetached([
            "bash", "-c", Directories.wallpaperSwitchScriptPath
        ]);
    }

    function pickRandomWallpaper(source) {
        const scripts = {
            konachan: `${Directories.scriptPath}/colors/random/random_konachan_wall.sh`,
            osu: `${Directories.scriptPath}/colors/random/random_osu_wall.sh`
        };
        if (scripts[source] === undefined || randomWallpaperProcess.running)
            return;
        randomWallpaperProcess.scriptPath = scripts[source];
        randomWallpaperProcess.running = true;
    }

    function setDarkMode(dark) {
        Quickshell.execDetached([
            "bash", "-c",
            `${Directories.wallpaperSwitchScriptPath} --mode ${dark ? "dark" : "light"} --noswitch`
        ]);
    }

    function applyPalette(value) {
        // Config writes are asynchronous. Passing the value explicitly keeps
        // switchwall from reading the previous value, while the single worker
        // prevents older generators from finishing after a newer choice.
        queuedPalette = value;
        Config.options.appearance.palette.type = value;
        paletteDelay.restart();
    }

    function startPaletteJob() {
        if (paletteProcess.running || queuedPalette === "")
            return;
        runningPalette = queuedPalette;
        queuedPalette = "";
        paletteProcess.command = [
            Directories.wallpaperSwitchScriptPath,
            "--noswitch",
            "--type",
            runningPalette
        ];
        paletteProcess.running = true;
    }

    property Process randomWallpaperProcess: Process {
        property string scriptPath: ""
        command: ["bash", "-c", scriptPath]
    }

    property Timer paletteDelay: Timer {
        interval: 140
        repeat: false
        onTriggered: root.startPaletteJob()
    }

    property Process paletteProcess: Process {
        onExited: (exitCode, exitStatus) => {
            root.runningPalette = "";
            MaterialThemeLoader.reapplyTheme();
            if (root.queuedPalette !== "")
                Qt.callLater(root.startPaletteJob);
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
