pragma Singleton

import QtQuick
import qs.modules.common
import "AppearanceUndo.js" as Undo

QtObject {
    property var configuration: Config.options
    property var entries: []
    property int nextId: 1
    readonly property var latest: entries.length ? entries[entries.length - 1] : null

    function record(entry) {
        entry.id = nextId++;
        entries = entries.concat([entry]).slice(-20);
    }

    function setOption(path, value, label) {
        const values = {};
        values[path] = value;
        setOptions(values, label);
    }

    function setOptions(values, label) {
        const list = Undo.changes(configuration, values);
        if (!list.length) return;
        Undo.write(configuration, list, "after");
        record({kind: "options", changes: list, label: label || ""});
    }

    function optionsCanUndo(entry) {
        return entry && entry.kind === "options" && Undo.matches(configuration, entry.changes);
    }

    function undoOptions(entry) {
        if (!optionsCanUndo(entry)) return false;
        Undo.write(configuration, entry.changes, "before");
        remove(entry.id);
        return true;
    }

    function remove(id) { entries = entries.filter(entry => entry.id !== id); }
}
