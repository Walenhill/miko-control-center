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

    function openId(pageId, saved) {
        const requestedPageId = pageId === undefined || pageId === null
            ? "" : String(pageId).trim();
        const nextPageId = requestedPageId !== ""
            ? requestedPageId : registry.defaultPageId;
        networkSection = nextPageId === "network" && saved
            ? saved.networkSection || "overview" : "overview";
        appearanceEditor = nextPageId === "appearance" && saved
            ? saved.appearanceEditor || "" : "";
        selectedComponentId = nextPageId === "services" && saved
            ? saved.selectedComponentId || "" : "";
        focusTarget = "";
        currentPageId = nextPageId;
        return nextPageId;
    }

    function openTarget(target) {
        const pageId = (target && target.pageId) ? target.pageId : registry.defaultPageId;
        // Install the explicit destination before creating its page.
        networkSection = pageId === "network" && target.section ? target.section : "overview";
        appearanceEditor = pageId === "appearance" && target.section ? target.section : "";
        selectedComponentId = pageId === "services" && target.componentId ? target.componentId : "";
        focusTarget = (target && target.target) ? target.target : ((target && target.section) ? target.section : "");
        currentPageId = pageId;
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
