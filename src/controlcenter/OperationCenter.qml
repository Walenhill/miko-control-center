import QtQuick
import Quickshell.Io

QtObject {
    id: root
    required property var environment

    property var tasks: []
    property var history: []
    property bool drawerOpen: false
    property string snackbarTitle: ""
    property string snackbarMessage: ""
    property string snackbarIcon: "info"
    property string snackbarAction: ""
    property var snackbarCallback: null
    property int serial: 0

    readonly property int activeCount: tasks.filter(
        task => task.state === "running"
    ).length
    readonly property bool snackbarVisible: snackbarTitle !== ""

    signal changed()

    function begin(key, title, subtitle, cancellable) {
        const existing = tasks.findIndex(task => task.key === key);
        const item = {
            key,
            title,
            subtitle: subtitle || "",
            state: "running",
            progress: -1,
            cancellable: cancellable === true,
            startedAt: Date.now(),
            finishedAt: 0,
            details: ""
        };
        const next = tasks.slice();
        if (existing >= 0)
            next[existing] = item;
        else
            next.unshift(item);
        tasks = next;
        changed();
        return key;
    }

    function update(key, subtitle, progress, details) {
        const index = tasks.findIndex(task => task.key === key);
        if (index < 0)
            return;
        const next = tasks.slice();
        next[index] = Object.assign({}, next[index], {
            subtitle: subtitle === undefined ? next[index].subtitle : subtitle,
            progress: progress === undefined ? next[index].progress : progress,
            details: details === undefined ? next[index].details : details
        });
        tasks = next;
        changed();
    }

    function finish(key, success, message, details) {
        const index = tasks.findIndex(task => task.key === key);
        if (index < 0)
            return;
        const result = Object.assign({}, tasks[index], {
            state: success ? "success" : "error",
            subtitle: message || tasks[index].subtitle,
            progress: success ? 1 : tasks[index].progress,
            details: details || tasks[index].details,
            finishedAt: Date.now()
        });
        const next = tasks.slice();
        next[index] = result;
        tasks = next;
        history = [result].concat(history.filter(item => item.key !== key)).slice(0, 20);
        historyFile.setText(JSON.stringify({ version: 1, history }, null, 2));
        showMessage(
            result.title,
            result.subtitle,
            success ? "check_circle" : "error",
            "",
            null
        );
        changed();
    }

    function remove(key) {
        tasks = tasks.filter(task => task.key !== key);
        changed();
    }

    function clearFinished() {
        tasks = tasks.filter(task => task.state === "running");
        changed();
    }

    function showMessage(title, message, icon, action, callback) {
        snackbarTitle = title || "";
        snackbarMessage = message || "";
        snackbarIcon = icon || "info";
        snackbarAction = action || "";
        snackbarCallback = callback || null;
        snackbarTimer.restart();
    }

    function hideMessage() {
        snackbarTimer.stop();
        snackbarTitle = "";
        snackbarMessage = "";
        snackbarAction = "";
        snackbarCallback = null;
    }

    function triggerSnackbarAction() {
        if (typeof snackbarCallback === "function")
            snackbarCallback();
        hideMessage();
    }

    property Timer snackbarTimeout: Timer {
        id: snackbarTimer
        interval: 5200
        onTriggered: root.hideMessage()
    }

    property FileView persistedHistory: FileView {
        id: historyFile
        path: root.environment.operationHistoryState
        onLoaded: {
            try {
                const saved = JSON.parse(historyFile.text());
                root.history = Array.isArray(saved.history)
                    ? saved.history.slice(0, 20) : [];
                root.tasks = root.history.slice();
            } catch (error) {
                console.warn("[Control Center] Invalid operation history:", error);
            }
        }
    }
}
