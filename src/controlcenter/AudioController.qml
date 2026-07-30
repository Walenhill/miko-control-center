import QtQuick
import Quickshell.Io
import qs.modules.common

QtObject {
    id: root

    required property var audio
    required property var effects
    required property var capabilities

    property real balance: 0
    property string activeScene: "custom"
    property string actionMessage: ""
    readonly property bool effectsInstallBusy: easyEffectsInstall.running
    readonly property bool effectsInstallAvailable:
        !capabilities.ready || capabilities.has("pacman")

    function installEffects() {
        if (!effectsInstallAvailable) {
            actionMessage =
                "Автоустановка доступна только при наличии pacman";
            return;
        }
        if (!easyEffectsInstall.running) {
            easyEffectsInstall.exec([
                "pkexec", "pacman", "-S", "--needed", "--noconfirm",
                "easyeffects"
            ]);
        }
    }

    function groupedApps() {
        const groups = {};
        root.audio.outputAppNodes.forEach(node => {
            const name = root.audio.appNodeDisplayName(node);
            if (!groups[name])
                groups[name] = { name: name, nodes: [] };
            groups[name].nodes.push(node);
        });
        return Object.keys(groups).sort().map(name => groups[name]);
    }

    function applyBalance(value) {
        if (!root.audio.sink)
            return;
        root.balance = Math.max(-1, Math.min(1, value));
        const base = Math.round(root.audio.value * 100);
        const left = Math.round(base * (root.balance > 0 ? 1 - root.balance : 1));
        const right = Math.round(base * (root.balance < 0 ? 1 + root.balance : 1));
        balanceAction.exec([
            "pactl", "set-sink-volume", root.audio.sink.name,
            left + "%", right + "%"
        ]);
        root.activeScene = "custom";
    }

    function applyScene(scene) {
        if (!root.audio.sink || !root.audio.source)
            return;
        root.activeScene = scene;
        Config.options.audio.protection.enable = scene !== "open";
        if (scene === "night") {
            root.audio.sink.audio.volume = 0.28;
            Config.options.audio.protection.maxAllowed = 60;
            Config.options.audio.protection.maxAllowedIncrease = 8;
        } else if (scene === "focus") {
            root.audio.sink.audio.volume = 0.48;
            Config.options.audio.protection.maxAllowed = 78;
            Config.options.audio.protection.maxAllowedIncrease = 10;
        } else {
            Config.options.audio.protection.maxAllowed = 100;
            Config.options.audio.protection.maxAllowedIncrease = 20;
        }
    }

    property Process balanceAction: Process {
        onExited: (exitCode) => {
            root.actionMessage = exitCode === 0
                ? "" : "Не удалось изменить баланс";
        }
    }

    property Process installEffectsAction: Process {
        id: easyEffectsInstall
        onRunningChanged: {
            if (running)
                root.actionMessage = "Устанавливаем EasyEffects…";
        }
        onExited: (exitCode, exitStatus) => {
            root.actionMessage = exitCode === 0
                ? "EasyEffects установлен"
                : "Установка отменена или завершилась с ошибкой";
            root.effects.fetchAvailability();
            root.effects.fetchActiveState();
        }
    }
}
