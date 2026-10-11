import QtQuick

// Session-only values, not cached page objects or controllers.
QtObject {
    property var pages: ({})

    function remember(pageId, item, router, appearance) {
        if (!item || typeof item.navigationSnapshot !== "function") return;
        const state = item.navigationSnapshot();
        state.networkSection = router.networkSection;
        state.appearanceEditor = router.appearanceEditor;
        state.appearanceSubsection = appearance.subsection;
        state.selectedComponentId = router.selectedComponentId;
        const next = Object.assign({}, pages);
        next[pageId] = state;
        pages = next;
    }

    function state(pageId) { return pages[pageId] || null; }
    function tab(pageId, fallback) {
        const saved = state(pageId);
        return saved && saved.tab ? saved.tab : fallback;
    }
}
