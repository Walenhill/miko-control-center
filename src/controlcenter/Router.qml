import QtQuick

QtObject {
    id: root

    required property var registry

    property string currentPageId: registry.defaultPageId
    property string networkSection: "overview"
    property string appearanceEditor: ""
    property string selectedComponentId: ""

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
        return nextPageId;
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
