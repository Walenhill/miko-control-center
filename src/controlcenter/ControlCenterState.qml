import QtQuick
import Quickshell.Io

QtObject {
    id: root

    required property var environment

    property bool ready: false
    property string language: "auto"
    property bool overviewEditing: false
    property bool reducedMotion: false
    property bool sidebarCompact: false
    property bool showOverviewHero: true
    property bool showOverviewMetrics: true
    property bool showOverviewQuickActions: true
    property bool showOverviewDevices: true
    property bool showOverviewAttention: true
    property bool compactOverview: false
    property var quickActionOrder: [
        "wifi", "bluetooth", "power", "notifications", "night", "displays"
    ]
    property var hiddenQuickActions: []
    property var recentSearches: []

    readonly property var defaultQuickActionOrder: [
        "wifi", "bluetooth", "power", "notifications", "night", "displays"
    ]

    function snapshot() {
        return {
            version: 3,
            language,
            reducedMotion,
            sidebarCompact,
            overview: {
                showHero: showOverviewHero,
                showMetrics: showOverviewMetrics,
                showQuickActions: showOverviewQuickActions,
                showDevices: showOverviewDevices,
                showAttention: showOverviewAttention,
                compact: compactOverview,
                quickActionOrder,
                hiddenQuickActions
            },
            recentSearches
        };
    }

    function save() {
        preferencesFile.setText(JSON.stringify(snapshot(), null, 2));
    }

    function applySaved(saved) {
        const overview = saved && saved.overview ? saved.overview : {};
        language = (saved && ["auto", "ru_RU", "en_US"].includes(saved.language))
            ? saved.language : "auto";
        reducedMotion = Boolean(saved && saved.reducedMotion === true);
        sidebarCompact = Boolean(saved && saved.sidebarCompact === true);
        showOverviewHero = overview.showHero !== false;
        showOverviewMetrics = overview.showMetrics !== false;
        showOverviewQuickActions = overview.showQuickActions !== false;
        showOverviewDevices = overview.showDevices !== false;
        showOverviewAttention = overview.showAttention !== false;
        compactOverview = overview.compact === true;
        const order = Array.isArray(overview.quickActionOrder)
            ? overview.quickActionOrder.filter(id => defaultQuickActionOrder.includes(id))
            : [];
        quickActionOrder = order.concat(
            defaultQuickActionOrder.filter(id => !order.includes(id))
        );
        hiddenQuickActions = Array.isArray(overview.hiddenQuickActions)
            ? overview.hiddenQuickActions.filter(id => defaultQuickActionOrder.includes(id))
            : [];
        recentSearches = (saved && Array.isArray(saved.recentSearches))
            ? saved.recentSearches.slice(0, 6) : [];
    }

    function setOverviewOption(name, value) {
        if (name === "hero") showOverviewHero = value;
        else if (name === "metrics") showOverviewMetrics = value;
        else if (name === "quickActions") showOverviewQuickActions = value;
        else if (name === "devices") showOverviewDevices = value;
        else if (name === "attention") showOverviewAttention = value;
        else if (name === "compact") compactOverview = value;
        else if (name === "reducedMotion") reducedMotion = value;
        save();
    }

    function setSidebarCompact(value) {
        sidebarCompact = value === true;
        save();
    }

    function setLanguage(value) {
        const next = ["auto", "ru_RU", "en_US"].includes(value)
            ? value : "auto";
        if (language === next)
            return;
        language = next;
        save();
    }

    function setQuickActionVisible(id, visible) {
        hiddenQuickActions = visible
            ? hiddenQuickActions.filter(item => item !== id)
            : Array.from(new Set(hiddenQuickActions.concat([id])));
        save();
    }

    function moveQuickAction(id, offset) {
        const current = quickActionOrder.indexOf(id);
        const target = Math.max(0, Math.min(
            quickActionOrder.length - 1, current + offset
        ));
        if (current < 0 || current === target)
            return;
        const next = quickActionOrder.slice();
        next.splice(current, 1);
        next.splice(target, 0, id);
        quickActionOrder = next;
        save();
    }

    function rememberSearch(query) {
        const text = String(query || "").trim();
        if (text.length < 2)
            return;
        recentSearches = [text].concat(
            recentSearches.filter(item => item !== text)
        ).slice(0, 6);
        save();
    }

    function resetOverview() {
        showOverviewHero = true;
        showOverviewMetrics = true;
        showOverviewQuickActions = true;
        showOverviewDevices = true;
        showOverviewAttention = true;
        compactOverview = false;
        quickActionOrder = defaultQuickActionOrder.slice();
        hiddenQuickActions = [];
        save();
    }

    property Process ensureDirectory: Process {
        command: ["mkdir", "-p", root.environment.controlCenterState]
        running: true
        onExited: preferencesFile.reload()
    }

    property FileView preferences: FileView {
        id: preferencesFile
        path: root.environment.preferencesState
        onLoaded: {
            try {
                root.applySaved(JSON.parse(preferencesFile.text()));
            } catch (error) {
                console.warn("[Control Center] Invalid preferences:", error);
            }
            root.ready = true;
        }
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound) {
                root.ready = true;
                root.save();
            }
        }
    }
}
