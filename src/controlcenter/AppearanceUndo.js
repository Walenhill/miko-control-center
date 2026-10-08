.pragma library

function equal(a, b) { return JSON.stringify(a) === JSON.stringify(b); }

function target(options, path) {
    var parts = path.split(".");
    var key = parts.pop();
    var parent = options;
    for (var i = 0; i < parts.length; ++i) {
        if (!parent || parent[parts[i]] === undefined) return null;
        parent = parent[parts[i]];
    }
    return parent && parent[key] !== undefined ? {parent: parent, key: key} : null;
}

function changes(options, values) {
    return Object.keys(values).map(function(path) {
        var field = target(options, path);
        if (!field) throw new Error("Unknown appearance option: " + path);
        return {path: path, before: field.parent[field.key], after: values[path]};
    }).filter(function(change) { return !equal(change.before, change.after); });
}

function matches(options, list, direction) {
    return list.every(function(change) {
        var field = target(options, change.path);
        return field && equal(field.parent[field.key], change[direction || "after"]);
    });
}

function write(options, list, direction) {
    list.forEach(function(change) {
        var field = target(options, change.path);
        if (!field) throw new Error("Missing appearance option: " + change.path);
        field.parent[field.key] = change[direction];
    });
}
