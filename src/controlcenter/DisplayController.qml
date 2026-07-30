import QtQuick
import Quickshell.Io

QtObject {
    id: root

    required property var hyprlandData
    required property var brightness
    required property string displayControl

    property int selectedIndex: 0
    property bool previewActive: false
    property int previewSeconds: 0
    property string actionMessage: ""
    property bool actionNeedsConfirm: false

    function selectedMonitor() {
        return root.hyprlandData.monitors.length > root.selectedIndex
            ? root.hyprlandData.monitors[root.selectedIndex]
            : null;
    }

    function selectedBrightnessMonitor() {
        const monitor = root.selectedMonitor();
        if (!monitor)
            return null;
        return root.brightness.monitors.find(
            item => item.screen.name === monitor.name
        ) ?? null;
    }

    function bounds() {
        const monitors = root.hyprlandData.monitors;
        if (monitors.length === 0)
            return ({ minX: 0, minY: 0, width: 1, height: 1 });
        const minX = Math.min(...monitors.map(item => item.x));
        const minY = Math.min(...monitors.map(item => item.y));
        const maxX = Math.max(...monitors.map(item => item.x + item.width));
        const maxY = Math.max(...monitors.map(item => item.y + item.height));
        return ({
            minX: minX,
            minY: minY,
            width: Math.max(1, maxX - minX),
            height: Math.max(1, maxY - minY)
        });
    }

    function runPreview(arguments) {
        root.actionMessage = "Применяем временно…";
        root.actionNeedsConfirm = true;
        actionProcess.exec([root.displayControl].concat(arguments));
    }

    function confirmPreview() {
        confirmProcess.exec([root.displayControl, "confirm"]);
        root.previewActive = false;
        root.previewSeconds = 0;
        root.actionMessage = "Изменения оставлены до перезапуска Hyprland";
    }

    function savePreview() {
        confirmProcess.exec([root.displayControl, "save"]);
        root.previewActive = false;
        root.previewSeconds = 0;
        root.actionMessage = "Схема сохранена в пользовательский override";
    }

    function rollbackPreview() {
        root.actionMessage = "Возвращаем прежнюю схему…";
        root.actionNeedsConfirm = false;
        actionProcess.exec([root.displayControl, "rollback"]);
    }

    function refresh() {
        root.hyprlandData.updateMonitors();
    }

    function wakeAll() {
        if (!wakeAllProcess.running) {
            wakeAllProcess.exec([
                root.displayControl, "dpms", "on"
            ]);
        }
    }

    property Process actionProcess: Process {
        onExited: (exitCode) => {
            root.hyprlandData.updateMonitors();
            if (exitCode === 0) {
                if (root.actionNeedsConfirm) {
                    root.previewActive = true;
                    root.previewSeconds = 15;
                    root.actionMessage =
                        "Проверь изображение и подтверди изменения";
                } else {
                    root.previewActive = false;
                    root.previewSeconds = 0;
                    root.actionMessage = "Прежняя схема восстановлена";
                }
            } else {
                root.actionMessage =
                    "Не удалось изменить конфигурацию экранов";
            }
        }
    }

    property Process confirmProcess: Process {}
    property Process wakeProcess: Process {
        id: wakeAllProcess
    }

    property Timer previewTimer: Timer {
        interval: 1000
        repeat: true
        running: root.previewActive
        onTriggered: {
            root.previewSeconds--;
            if (root.previewSeconds <= 0) {
                root.previewActive = false;
                root.rollbackPreview();
            }
        }
    }
}
