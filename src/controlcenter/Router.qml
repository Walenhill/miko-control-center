import QtQuick

QtObject {
    id: root

    required property var registry

    property string currentPageId: registry.defaultPageId
    property string networkSection: "overview"
    property string appearanceEditor: ""
    property string selectedComponentId: ""
    property string focusTarget: ""

    readonly property int currentPage: registry.indexOf(currentPageId)
    readonly property bool canGoBack:
        (currentPageId === "network" && networkSection !== "overview")
        || (currentPageId === "appearance" && appearanceEditor !== "")
        || (currentPageId === "services" && selectedComponentId !== "")

    function openId(pageId) {
        const requestedPageId = pageId === undefined || pageId === null
            ? "" : String(pageId).trim();
        const nextPageId = requestedPageId !== ""
            ? requestedPageId : registry.defaultPageId;
        currentPageId = nextPageId;
        // Entering a sidebar destination always means its root. Dedicated IPC
        // methods set a deeper destination immediately afterwards when needed.
        if (nextPageId === "network")
            networkSection = "overview";
        appearanceEditor = "";
        selectedComponentId = "";
        focusTarget = "";
        return nextPageId;
    }

    function openTarget(target) {
        const pageId = (target && target.pageId) ? target.pageId : registry.defaultPageId;
        openId(pageId);
        focusTarget = (target && target.target) ? target.target : ((target && target.section) ? target.section : "");
        if (pageId === "network" && target && target.section)
            networkSection = target.section;
        if (pageId === "appearance" && target && target.section)
            appearanceEditor = target.section;
        if (pageId === "services" && target && target.componentId)
            selectedComponentId = target.componentId;
        return pageId;
    }

    // Backward-compatible route kept for the public IPC open(int).
    function open(page) {
        return openId(registry.idAt(page));
    }

    function back() {
        if (currentPageId === "network" && networkSection !== "overview") {
            networkSection = "overview";
            return true;
        }
        if (currentPageId === "appearance" && appearanceEditor !== "") {
            appearanceEditor = "";
            return true;
        }
        if (currentPageId === "services" && selectedComponentId !== "") {
            selectedComponentId = "";
            return true;
        }
        return false;
    }
}
