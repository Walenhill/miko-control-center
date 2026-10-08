//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import Quickshell.Bluetooth
import Quickshell.Services.Pipewire
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import "controlcenter" as ControlCenter
import "controlcenter/SearchIndex.js" as SearchIndex

ApplicationWindow {
    id: root
    readonly property bool renderTest: Quickshell.env("MIKO_CONTROL_CENTER_RENDER_TEST") === "1"
    readonly property bool smokeTest: renderTest || Quickshell.env("MIKO_CONTROL_CENTER_SMOKE_TEST") === "1"

    ControlCenter.MikoStyle {
        id: ui
        reducedMotion: controlState.reducedMotion
    }
    ControlCenter.Environment {
        id: environment
    }
    ControlCenter.PageRegistry {
        id: pageRegistry
    }
    ControlCenter.Router {
        id: router
        registry: pageRegistry
    }
    ControlCenter.NavigationMemory { id: navigationMemory }
    property var pendingDestination: null
    property int navigationRevision: 0

    function initialTab(pageId, fallback) {
        if (pendingDestination && pendingDestination.pageId === pageId)
            return pageRegistry.tabForTarget(pageId, pendingDestination.target || pendingDestination.section || "") || fallback;
        return navigationMemory.tab(pageId, fallback);
    }

    function rememberPage() {
        navigationMemory.remember(currentPageId, pageLoader.item, router, appearanceController);
    }

    function restorePagePosition() {
        const item = pageLoader.item;
        const revision = navigationRevision;
        const destination = pendingDestination;
        const saved = navigationMemory.state(currentPageId);
        Qt.callLater(() => {
            if (!item || item !== pageLoader.item || revision !== navigationRevision) return;
            if (destination) {
                if (typeof item.revealSection === "function")
                    item.revealSection(destination.target || destination.section || "");
                else if (typeof item.restoreScroll === "function") item.restoreScroll(0);
            } else if (saved && typeof item.restoreScroll === "function") {
                item.restoreScroll(saved.scrollY);
            }
        });
    }
    ControlCenter.Capabilities {
        id: capabilities
    }
    ControlCenter.ControlCenterState {
        id: controlState
        environment: environment
    }
    Binding {
        target: ControlCenter.I18n
        property: "preference"
        value: controlState.language
    }
    ControlCenter.OperationCenter {
        id: operationCenter
        environment: environment
    }
    ControlCenter.AppearanceController {
        id: appearanceController
        router: router
        onThemeFailed: message => operationCenter.showMessage(
            ControlCenter.I18n.tr("Оформление"), message, "error", "", null
        )
    }
    ControlCenter.AudioController {
        id: audioController
        audio: Audio
        effects: EasyEffects
        capabilities: capabilities
    }
    ControlCenter.DisplayController {
        id: displayController
        hyprlandData: HyprlandData
        brightness: Brightness
        displayControl: environment.displayControl
    }
    ControlCenter.NetworkController {
        id: networkController
        environment: environment
        capabilities: capabilities
        networkSettingsCommand: Config.options.apps.network
    }
    ControlCenter.ApplicationsController {
        id: applicationsController
        capabilities: capabilities
    }
    ControlCenter.DevicesController {
        id: devicesController
        capabilities: capabilities
        bluetoothManagerCommand: Config.options.apps.bluetooth
    }
    ControlCenter.SystemController {
        id: systemController
        environment: environment
        automaticUpdates: !root.smokeTest
        capabilities: capabilities
    }
    QtObject {
        id: updateSummary
        readonly property int count: systemController.availableUpdateCount
    }
    ControlCenter.SystemTelemetryController {
        id: telemetryController
        environment: environment
    }
    ControlCenter.SystemSnapshotsController {
        id: snapshotsController
        environment: environment
    }
    ControlCenter.ServicesController {
        id: servicesController
        environment: environment
        kdeConnect: KdeConnect
        easyEffects: EasyEffects
        capabilities: capabilities
    }
    ControlCenter.OperationBridge {
        operations: operationCenter
        system: systemController
        services: servicesController
        network: networkController
        applications: applicationsController
        kdeConnect: KdeConnect
    }

    width: 1180
    height: 760
    minimumWidth: 980
    minimumHeight: 660
    visible: !smokeTest
    title: "Miko Control Center"
    color: "transparent"
    onClosing: Qt.quit()
    Component.onCompleted: {
        if (!smokeTest) MaterialThemeLoader.reapplyTheme();
    }

    Timer {
        interval: 250
        running: root.smokeTest && !root.renderTest && controlState.ready && capabilities.ready
        repeat: true
        property int step: 0
        property real savedScroll: 0
        property var routes: ["overview", "network", "sound", "displays", "devices", "appearance", "system", "services", "applications"]
        function check(value, message) {
            if (!value) { console.error("[Miko smoke]", message); Qt.exit(1); }
        }
        onTriggered: {
            if (step === 0) check(root.color.a === 0, "Window clear color hides native transparency");
            if (step < routes.length * 2) {
                controlState.setLanguage(step < routes.length ? "ru_RU" : "en_US");
                root.openPageId(routes[step % routes.length]);
                if (pageLoader.status !== Loader.Ready) {
                    console.error("[Miko smoke] Page did not load:", routes[step % routes.length]);
                    Qt.exit(1);
                }
                ++step;
            } else if (step === 18) {
                root.openDestination({pageId: "sound", target: "mixer"});
                ++step;
            } else if (step === 19) {
                check(pageLoader.item.activeTab === "mixer", "explicit sound target");
                root.openPageId("overview");
                root.openPageId("sound");
                check(pageLoader.item.activeTab === "mixer", "remembered sound tab");
                root.openDestination({pageId: "appearance", section: "bar"});
                appearanceController.subsection = "behavior";
                ++step;
            } else if (step === 20) {
                pageLoader.item.restoreScroll(Math.min(80, Math.max(0, pageLoader.item.contentHeight - pageLoader.item.height)));
                ++step;
            } else if (step === 21) {
                savedScroll = pageLoader.item.contentY;
                root.openPageId("overview");
                ++step;
            } else if (step === 22) {
                root.openPageId("appearance");
                ++step;
            } else if (step === 23) {
                check(appearanceController.editor === "bar" && appearanceController.subsection === "behavior", "remembered appearance subsection");
                check(Math.abs(pageLoader.item.contentY - savedScroll) < 1, "remembered scroll");
                root.openDestination({pageId: "appearance", section: "wallpaper"});
                ++step;
            } else if (step === 24) {
                check(appearanceController.editor === "wallpaper" && pageLoader.item.contentY === 0, "explicit route overrides memory");
                searchField.text = "sound";
                ++step;
            } else if (step === 25) {
                const index = root.filteredItems.findIndex(item => item.target === "mixer");
                check(index >= 0, "localized search category");
                searchResults.currentIndex = 0;
                root.moveSearchSelection(1);
                check(searchResults.currentIndex === 1, "search down selection");
                root.moveSearchSelection(-1);
                check(searchResults.currentIndex === 0, "search up selection");
                searchResults.currentIndex = index;
                root.acceptSelectedSearchResult();
                ++step;
            } else if (step === 26) {
                check(router.currentPageId === "sound" && pageLoader.item.activeTab === "mixer", "selected search result route");
                searchField.text = "no-such-option";
                root.moveSearchSelection(1);
                root.acceptSelectedSearchResult();
                check(root.filteredItems.length === 0, "empty search");
                ++step;
            } else if (step < 37) {
                const editors = ["wallpaper", "materials", "widgets", "fonts", "profiles"];
                controlState.setLanguage(step < 32 ? "ru_RU" : "en_US");
                root.openDestination({pageId: "appearance", section: editors[(step - 27) % 5]});
                check(pageLoader.status === Loader.Ready, "appearance editor page load");
                ++step;
            } else {
                console.info("[Miko smoke] navigation memory and search complete");
                console.info("[Miko smoke] appearance editors complete");
                console.info("[Miko smoke] complete");
                Qt.quit();
            }
        }
    }

    readonly property string currentPageId: router.currentPageId
    readonly property int currentPage: router.currentPage
    readonly property var currentPageData:
        pageRegistry.pageById(currentPageId)
    readonly property string pageTitle:
        currentPageData ? currentPageData.title : ControlCenter.I18n.tr("Неизвестный раздел")
    readonly property string pageSubtitle:
        currentPageData ? currentPageData.subtitle : currentPageId
    property color ink: ui.ink
    property color mutedInk: ui.mutedInk
    // One surface contract, sourced from the same live Matugen palette as the shell.
    readonly property color windowSurface: ui.windowSurface
    readonly property color sectionSurface: ui.sectionSurface
    readonly property color hairline: ui.hairline
    property color softSurface: sectionSurface
    readonly property int radiusWindow: ui.radiusWindow
    readonly property int radiusSection: ui.radiusSection
    readonly property int pageInset: width < 1080 ? 18 : 24
    readonly property int motionNormal: ui.motionNormal
    readonly property var motionCurve: ui.motionCurve
    readonly property int settingsIconRailWidth: 32
    readonly property bool sidebarHardCompact: width < 1080
    readonly property bool sidebarResponsiveCompact: width < 1280
    property bool sidebarExpandedOverride: false
    readonly property bool sidebarCompact:
        controlState.sidebarCompact
        || sidebarHardCompact
        || (sidebarResponsiveCompact && !sidebarExpandedOverride)
    readonly property int sidebarWidth: sidebarCompact ? 78 : 222
    onSidebarResponsiveCompactChanged: {
        if (!sidebarResponsiveCompact)
            sidebarExpandedOverride = false;
    }

    function toggleSidebar() {
        if (sidebarHardCompact)
            return;
        if (sidebarResponsiveCompact) {
            if (controlState.sidebarCompact)
                controlState.setSidebarCompact(false);
            sidebarExpandedOverride = sidebarCompact;
            return;
        }
        controlState.setSidebarCompact(!controlState.sidebarCompact);
    }
    readonly property int pageContentMaxWidth: 1180
    readonly property bool hasPageBack: router.canGoBack
    readonly property var navigation: pageRegistry.pages
    readonly property var pageComponents: ({
        "overview": overviewPage,
        "network": networkPage,
        "sound": soundPage,
        "displays": displaysPage,
        "devices": devicesPage,
        "appearance": appearancePage,
        "system": systemPage,
        "services": servicesPage,
        "applications": applicationsPage
    })
    readonly property var searchableItems: pageRegistry.searchable
    readonly property var filteredItems: SearchIndex.search(searchableItems, searchField.text, pageRegistry.pages)
    IpcHandler {
        target: "controlCenter"

        function show(): void {
            root.show();
            root.raise();
            root.requestActivate();
        }

        function open(page: int): void {
            root.openPage(page);
            root.show();
            root.raise();
            root.requestActivate();
        }

        function route(pageId: string): void {
            root.openPageId(pageId);
            root.show();
            root.raise();
            root.requestActivate();
        }

        function network(section: string): void {
            root.openDestination({pageId: "network", section: ["overview", "throne", "ports"]
                .includes(section) ? section : "overview"});
            root.show();
            root.raise();
            root.requestActivate();
        }

        function inspect(componentId: string): void {
            root.openDestination({pageId: "services", componentId: componentId});
            root.show();
            root.raise();
            root.requestActivate();
        }

        function appearance(editor: string): void {
            root.openDestination({pageId: "appearance", section:
                appearanceController.editors[editor] ? editor : ""});
            root.show();
            root.raise();
            root.requestActivate();
        }

        function sound(tab: string): void {
            root.openDestination({pageId: "sound", target: tab});
            root.show();
            root.raise();
            root.requestActivate();
        }

        function devices(tab: string): void {
            root.openDestination({pageId: "devices", target: tab});
            root.show();
            root.raise();
            root.requestActivate();
        }

        function system(tab: string): void {
            root.openDestination({pageId: "system", target: tab});
            root.show();
            root.raise();
            root.requestActivate();
        }

        function display(tab: string): void {
            root.openDestination({pageId: "displays", target: tab});
            root.show();
            root.raise();
            root.requestActivate();
        }

        function operations(): void {
            operationCenter.drawerOpen = true;
            root.show();
            root.raise();
            root.requestActivate();
        }

        function sidebar(): void {
            root.toggleSidebar();
        }

        function language(code: string): void {
            const normalized = String(code || "").replace("-", "_");
            controlState.setLanguage(
                ["auto", "ru_RU", "en_US"].includes(normalized)
                    ? normalized : "auto"
            );
        }
    }

    function performSearch(text) {
        searchResults.currentIndex = filteredItems.length ? 0 : -1;
        Qt.callLater(() => searchResults.positionViewAtBeginning());
    }

    function moveSearchSelection(delta) {
        const count = filteredItems.length;
        if (!count) { searchResults.currentIndex = -1; return; }
        searchResults.currentIndex = (searchResults.currentIndex + delta + count) % count;
        searchResults.positionViewAtIndex(searchResults.currentIndex, ListView.Contain);
    }

    function acceptSelectedSearchResult() {
        if (searchResults.currentIndex >= 0 && searchResults.currentIndex < filteredItems.length)
            openSearchResult(filteredItems[searchResults.currentIndex]);
    }

    function openSearchResult(item) {
        if (!item)
            return;
        controlState.rememberSearch(searchField.text);
        openDestination(item);
    }

    function openDestination(item) {
        const samePage = item.pageId === currentPageId;
        rememberPage();
        ++navigationRevision;
        pendingDestination = item;
        router.openTarget(item);
        searchField.text = "";
        searchField.focus = false;
        if (samePage) restorePagePosition();
    }

    function openPageId(pageId) {
        if (pageId === currentPageId) {
            searchField.text = "";
            searchField.focus = false;
            return pageId;
        }
        rememberPage();
        ++navigationRevision;
        pendingDestination = null;
        const saved = navigationMemory.state(pageId);
        const resolvedPageId = router.openId(pageId, saved);
        if (saved && pageId === "appearance")
            appearanceController.subsection = saved.appearanceSubsection || "form";
        searchField.text = "";
        searchField.focus = false;
        return resolvedPageId;
    }

    // Transitional adapter for the public open(int) IPC and older page signals.
    // New routes should always pass a PageRegistry id.
    function openPage(destination) {
        if (typeof destination === "number")
            return openPageId(pageRegistry.idAt(destination));
        return openPageId(destination);
    }

    function navigateBack() {
        router.back();
        if (pageLoader.item && typeof pageLoader.item.restoreScroll === "function")
            pageLoader.item.restoreScroll(0);
    }

    Shortcut {
        sequences: ["Ctrl+F", "Ctrl+K"]
        onActivated: {
            searchField.forceActiveFocus();
            searchField.selectAll();
        }
    }
    Shortcut {
        sequence: "Ctrl+B"
        onActivated: root.toggleSidebar()
    }
    Shortcut {
        sequence: "Alt+Left"
        enabled: root.hasPageBack
        onActivated: root.navigateBack()
    }
    Shortcut {
        sequence: "Escape"
        onActivated: {
            if (searchField.text.length > 0 || searchField.activeFocus) {
                searchField.text = "";
                searchField.focus = false;
                pageLoader.forceActiveFocus();
            } else if (root.hasPageBack) {
                root.navigateBack();
            } else {
                root.close();
            }
        }
    }


    component LabelText: StyledText {
        color: root.ink
        font.pixelSize: Appearance.font.pixelSize.small
    }

    component MutedText: StyledText {
        color: root.mutedInk
        font.pixelSize: Appearance.font.pixelSize.smaller
    }

    component IconDisc: ControlCenter.MikoIconDisc {
        style: ui
    }

    component SoftButton: ControlCenter.MikoButton {
        style: ui
    }

    ControlCenter.MikoConfirmDialog {
        anchors.fill: parent
        visible: systemController.cleanupConfirmVisible
        style: ui
        icon: "cleaning_services"
        title: systemController.cleanupConfirmTitle
        description: systemController.cleanupConfirmDescription
        confirmIcon: "delete_sweep"
        onCancelled: systemController.cancelCleanup()
        onConfirmed: systemController.confirmCleanup()
    }

    Item {
        id: windowPlane
        objectName: "mikoWindowPlane"
        anchors.fill: parent

        // One material background. Native compositor blur sees the desktop behind
        // the window; no opaque clear color or wallpaper copy hides it.
        Rectangle {
            anchors.fill: parent
            radius: root.radiusWindow
            color: root.windowSurface
            border.width: 1
            border.color: root.hairline
        }

        RowLayout {
            id: appLayout
            anchors {
                fill: parent
                margins: 10
            }
            spacing: 8

            Item {
                Layout.preferredWidth: root.sidebarWidth
                Layout.fillHeight: true
                clip: true

                Behavior on Layout.preferredWidth {
                    NumberAnimation {
                        duration: controlState.reducedMotion ? 0 : ui.motionNormal
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: ui.motionCurve
                    }
                }

                ColumnLayout {
                    anchors {
                        fill: parent
                        margins: 10
                    }
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.bottomMargin: 19
                        spacing: 8
                        Rectangle {
                            id: brandButton
                            Layout.preferredWidth: 44
                            Layout.preferredHeight: 44
                            Layout.alignment: Qt.AlignHCenter
                            radius: ui.radiusIcon
                            color: brandMouse.pressed
                                ? ui.selectedSurfaceActive
                                : brandMouse.containsMouse
                                    ? ui.selectedSurfaceHover
                                    : ui.selectedSurface
                            border.width: 0
                            border.color: ui.alpha(ui.selectedSurface, 0.42)
                            antialiasing: true

                            Behavior on color {
                                ColorAnimation {
                                    duration: ui.motionFast
                                    easing.type: Easing.BezierSpline
                                    easing.bezierCurve: ui.motionCurve
                                }
                            }

                            MaterialSymbol {
                                anchors.centerIn: parent
                                text: "deployed_code"
                                iconSize: 22
                                fill: 1
                                color: ui.selectedInk
                            }

                            Rectangle {
                                visible: !root.sidebarHardCompact
                                anchors {
                                    right: parent.right
                                    bottom: parent.bottom
                                    rightMargin: -1
                                    bottomMargin: -1
                                }
                                width: 17
                                height: 17
                                radius: Appearance.rounding.full
                                color: ui.controlSurface
                                border.width: 1
                                border.color: ui.strongHairline
                                MaterialSymbol {
                                    anchors.centerIn: parent
                                    text: root.sidebarCompact
                                        ? "chevron_right" : "chevron_left"
                                    iconSize: 13
                                    color: ui.ink
                                }
                            }

                            MouseArea {
                                id: brandMouse
                                anchors.fill: parent
                                enabled: !root.sidebarHardCompact
                                hoverEnabled: true
                                cursorShape: enabled
                                    ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: root.toggleSidebar()
                            }
                            ToolTip.visible: brandMouse.containsMouse
                                && brandMouse.enabled
                            ToolTip.text: root.sidebarCompact
                                ? ControlCenter.I18n.tr("Развернуть меню") : ControlCenter.I18n.tr("Свернуть меню")
                        }
                        ColumnLayout {
                            visible: !root.sidebarCompact
                            Layout.fillWidth: true
                            Layout.minimumWidth: 0
                            spacing: 0
                            LabelText {
                                Layout.fillWidth: true
                                text: "Miko OS"
                                elide: Text.ElideRight
                                font.pixelSize: Appearance.font.pixelSize.larger
                                font.weight: Font.DemiBold
                            }
                            MutedText {
                                Layout.fillWidth: true
                                text: ControlCenter.I18n.tr("Центр управления")
                                elide: Text.ElideRight
                            }
                        }
                    }

                    Repeater {
                        model: root.navigation
                        delegate: Rectangle {
                            id: navItem

                            required property var modelData
                            Layout.fillWidth: !root.sidebarCompact
                            Layout.preferredWidth: root.sidebarCompact ? 48 : -1
                            Layout.alignment: Qt.AlignHCenter
                            implicitHeight: 48
                            radius: ui.radiusNavigation
                            color: root.currentPageId === modelData.id
                                ? navMouse.pressed
                                    ? ui.selectedCardHover
                                    : navMouse.containsMouse
                                        ? ui.selectedCardHover
                                        : ui.selectedCardBackground
                                : navMouse.pressed
                                    ? ui.activeSurface
                                    : navMouse.containsMouse
                                        ? ui.hoverSurface
                                        : "transparent"
                            antialiasing: true
                            activeFocusOnTab: true
                            border.width: navItem.activeFocus ? 2 : 0
                            border.color: navItem.activeFocus
                                ? ui.focusRing
                                : ui.alpha(ui.selectedSurface, 0.42)

                            Behavior on color {
                                ColorAnimation {
                                    duration: root.motionNormal
                                    easing.type: Easing.BezierSpline
                                    easing.bezierCurve: root.motionCurve
                                }
                            }
                            Rectangle {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                width: 3
                                height: 20
                                radius: 1.5
                                visible: root.currentPageId === navItem.modelData.id
                                color: ui.selectedSurface
                            }
                            RowLayout {
                                id: navContent
                                anchors {
                                    fill: parent
                                    leftMargin: root.sidebarCompact ? 0 : 14
                                    rightMargin: root.sidebarCompact ? 0 : 12
                                }
                                spacing: 12
                                transform: Translate {
                                    x: navMouse.containsMouse
                                        && !root.sidebarCompact
                                        && root.currentPageId !== modelData.id ? 2 : 0
                                    Behavior on x {
                                        NumberAnimation {
                                            duration: ui.motionFast
                                            easing.type: Easing.BezierSpline
                                            easing.bezierCurve: ui.motionCurve
                                        }
                                    }
                                }
                                Item {
                                    Layout.preferredWidth: root.sidebarCompact
                                        ? navItem.width : root.settingsIconRailWidth
                                    Layout.fillHeight: true
                                    MaterialSymbol {
                                        anchors.centerIn: parent
                                        text: modelData.icon
                                        iconSize: 20
                                        color: root.currentPageId === modelData.id
                                            ? ui.selectedSurface : root.ink
                                        fill: root.currentPageId === modelData.id ? 1 : 0
                                        Behavior on color {
                                            ColorAnimation {
                                                duration: root.motionNormal
                                                easing.type: Easing.BezierSpline
                                                easing.bezierCurve: root.motionCurve
                                            }
                                        }
                                    }
                                }
                                LabelText {
                                    visible: !root.sidebarCompact
                                    Layout.fillWidth: true
                                    text: modelData.title
                                    font.weight: root.currentPageId === modelData.id
                                        ? Font.DemiBold : Font.Normal
                                    color: root.currentPageId === modelData.id
                                        ? ui.selectedSurface
                                        : root.ink
                                    Behavior on color {
                                        ColorAnimation {
                                            duration: root.motionNormal
                                            easing.type: Easing.BezierSpline
                                            easing.bezierCurve: root.motionCurve
                                        }
                                    }
                                }
                            }
                            MouseArea {
                                id: navMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.openPageId(modelData.id)
                            }
                            ToolTip.visible: root.sidebarCompact
                                && navMouse.containsMouse
                            ToolTip.text: modelData.title
                            Keys.onPressed: event => {
                                if (event.key === Qt.Key_Return
                                        || event.key === Qt.Key_Enter
                                        || event.key === Qt.Key_Space) {
                                    root.openPageId(modelData.id);
                                    event.accepted = true;
                                }
                            }
                        }
                    }
                    Item { Layout.fillHeight: true }
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 10
                        IconDisc { icon: "info" }
                        ColumnLayout {
                            visible: !root.sidebarCompact
                            spacing: 0
                            LabelText { text: SystemInfo.distroName; font.weight: Font.Medium }
                            MutedText { text: SystemInfo.desktopEnvironment }
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                // The content is part of the single window plane, not a window inside it.
                clip: true

                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.topMargin: root.pageInset
                    anchors.bottomMargin: root.pageInset
                    width: 1
                    color: root.hairline
                }

                ColumnLayout {
                    anchors {
                        fill: parent
                        margins: root.pageInset
                    }
                    spacing: 18

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        SoftButton {
                            visible: root.hasPageBack
                            icon: "arrow_back"
                            text: ""
                            implicitWidth: 44
                            implicitHeight: 44
                            onClicked: root.navigateBack()
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            LabelText {
                                text: root.pageTitle
                                font.pixelSize: 26
                                font.weight: Font.Medium
                            }
                            MutedText {
                                text: root.pageSubtitle
                                font.pixelSize: Appearance.font.pixelSize.small
                            }
                        }

                        Rectangle {
                            Layout.preferredWidth: Math.min(310, Math.max(220, root.width * 0.27))
                            implicitHeight: 48
                            radius: ui.radiusControl
                            color: root.softSurface
                            border.width: searchField.activeFocus ? 2 : 1
                            border.color: searchField.activeFocus
                                ? Appearance.colors.colPrimary
                                : Qt.rgba(root.ink.r, root.ink.g, root.ink.b, 0.08)
                            antialiasing: true

                            MaterialSymbol {
                                anchors {
                                    left: parent.left
                                    verticalCenter: parent.verticalCenter
                                    leftMargin: 15
                                }
                                text: "search"
                                iconSize: 21
                                color: root.mutedInk
                            }
                            TextField {
                                id: searchField
                                anchors {
                                    fill: parent
                                    leftMargin: 45
                                    rightMargin: 10
                                }
                                placeholderText: ControlCenter.I18n.tr("Что хочешь настроить?")
                                color: root.ink
                                placeholderTextColor: root.mutedInk
                                font.family: Appearance.font.family.main
                                font.pixelSize: Appearance.font.pixelSize.small
                                background: Item {}
                                onTextChanged: root.performSearch(text)
                                onAccepted: {
                                    root.acceptSelectedSearchResult();
                                }
                                Keys.onPressed: event => {
                                    if (event.key === Qt.Key_Down || event.key === Qt.Key_Up) {
                                        root.moveSearchSelection(event.key === Qt.Key_Down ? 1 : -1);
                                        event.accepted = true;
                                    }
                                }
                            }
                        }

                        SoftButton {
                            icon: operationCenter.activeCount > 0
                                ? "progress_activity" : "task_alt"
                            text: operationCenter.activeCount > 0
                                ? String(operationCenter.activeCount) : ""
                            implicitWidth: operationCenter.activeCount > 0 ? 58 : 44
                            implicitHeight: 44
                            onClicked: operationCenter.drawerOpen = true
                        }

                        SoftButton {
                            icon: "close"
                            text: ""
                            implicitWidth: 44
                            implicitHeight: 44
                            onClicked: root.close()
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        ControlCenter.AppearanceChangeStatus {
                            id: appearanceStatus
                            anchors.top: parent.top
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: Math.min(parent.width, root.pageContentMaxWidth)
                            height: implicitHeight
                            visible: root.currentPageId === "appearance"
                                && appearanceController.statusText !== ""
                            controller: appearanceController
                            style: ui
                        }

                        // Search becomes a direct route to an action or section.
                        Rectangle {
                            anchors.fill: parent
                            visible: searchField.text.length > 0
                            radius: ui.radiusSection
                            color: Qt.rgba(
                                Appearance.colors.colLayer0.r,
                                Appearance.colors.colLayer0.g,
                                Appearance.colors.colLayer0.b,
                                0.94
                            )
                            z: 20

                            ListView {
                                id: searchResults
                                anchors {
                                    fill: parent
                                    margins: 10
                                }
                                spacing: 4
                                clip: true
                                model: root.filteredItems
                                currentIndex: count > 0 ? 0 : -1
                                reuseItems: true
                                onCountChanged: currentIndex = count > 0 ? 0 : -1
                                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                                delegate: Rectangle {
                                    id: searchResult
                                    required property var modelData
                                    required property int index
                                    width: ListView.view.width
                                    height: 68
                                    radius: ui.radiusControl
                                    color: ListView.isCurrentItem ? ui.accentSubtle
                                        : resultMouse.containsMouse ? root.softSurface : "transparent"
                                    border.width: ListView.isCurrentItem ? 1 : 0
                                    border.color: ui.accentSubtleBorder
                                    Accessible.role: Accessible.ListItem
                                    Accessible.name: modelData.category + ": " + modelData.title
                                    Accessible.selected: ListView.isCurrentItem
                                    Behavior on color {
                                        ColorAnimation {
                                            duration: ui.motionFast
                                            easing.type: Easing.BezierSpline
                                            easing.bezierCurve: ui.motionCurve
                                        }
                                    }

                                    RowLayout {
                                        anchors {
                                            fill: parent
                                            leftMargin: 12
                                            rightMargin: 14
                                        }
                                        spacing: 13
                                        IconDisc { icon: modelData.icon }
                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 1
                                            LabelText { text: modelData.title; font.weight: Font.Medium }
                                            MutedText { text: modelData.category + " · " + modelData.subtitle }
                                        }
                                        MaterialSymbol {
                                            text: "arrow_forward"
                                            iconSize: 19
                                            color: root.mutedInk
                                        }
                                    }
                                    MouseArea {
                                        id: resultMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onEntered: searchResults.currentIndex = searchResult.index
                                        onClicked: root.openSearchResult(modelData)
                                    }
                                }

                                LabelText {
                                    anchors.centerIn: parent
                                    visible: root.filteredItems.length === 0
                                    text: ControlCenter.I18n.tr("Пока ничего не найдено")
                                    color: root.mutedInk
                                }
                            }
                        }

                        Loader {
                            id: pageLoader
                            anchors {
                                top: parent.top
                                bottom: parent.bottom
                                horizontalCenter: parent.horizontalCenter
                                topMargin: appearanceStatus.visible ? appearanceStatus.height + 12 : 0
                            }
                            width: Math.min(parent.width, root.pageContentMaxWidth)
                            sourceComponent: root.pageComponents[root.currentPageId]
                                ?? unavailablePage
                            transform: Translate {
                                id: pageShift
                                y: 0
                            }
                            onLoaded: {
                                root.restorePagePosition();
                                pageEntrance.restart();
                            }

                            ParallelAnimation {
                                id: pageEntrance
                                NumberAnimation {
                                    target: pageLoader
                                    property: "opacity"
                                    from: 0.82
                                    to: 1
                                    duration: controlState.reducedMotion ? 0 : ui.motionEnter
                                    easing.type: Easing.BezierSpline
                                    easing.bezierCurve: ui.motionEnterCurve
                                }
                                NumberAnimation {
                                    target: pageShift
                                    property: "y"
                                    from: 7
                                    to: 0
                                    duration: controlState.reducedMotion ? 0 : ui.motionEnter
                                    easing.type: Easing.BezierSpline
                                    easing.bezierCurve: ui.motionEnterCurve
                                }
                            }
                        }
                    }
                }
            }
        }

    }

    Component {
        id: overviewPage
        ControlCenter.OverviewPage {
            activeTab: root.initialTab("overview", controlState.overviewEditing ? "customize" : "summary")
            style: ui
            network: Network
            networkState: networkController
            resourceUsage: ResourceUsage
            updates: updateSummary
            kdeConnect: KdeConnect
            audio: Audio
            bluetoothStatus: BluetoothStatus
            hyprsunset: Hyprsunset
            systemState: systemController
            servicesState: servicesController
            applicationsState: applicationsController
            preferences: controlState
            operations: operationCenter
            userName: SystemInfo.username
            screenCount: Quickshell.screens.length
            onToggleWifiRequested: {
                Network.toggleWifi();
                operationCenter.showMessage(
                    "Wi-Fi", ControlCenter.I18n.tr("Состояние переключено"), "wifi", "", null
                );
            }
            onToggleBluetoothRequested: {
                if (Bluetooth.defaultAdapter)
                    Bluetooth.defaultAdapter.enabled =
                        !Bluetooth.defaultAdapter.enabled;
                operationCenter.showMessage(
                    "Bluetooth", ControlCenter.I18n.tr("Состояние переключено"),
                    "bluetooth", "", null
                );
            }
            onCyclePowerProfileRequested: {
                const next = systemController.powerProfile === "balanced"
                    ? "performance"
                    : systemController.powerProfile === "performance"
                        ? "power-saver" : "balanced";
                systemController.setPowerProfile(next);
                operationCenter.showMessage(
                    ControlCenter.I18n.tr("Профиль питания"), next, "speed", "", null
                );
            }
            onToggleNotificationsRequested: {
                applicationsController.toggleNotifications();
                operationCenter.showMessage(
                    ControlCenter.I18n.tr("Уведомления"), ControlCenter.I18n.tr("Режим изменён"), "notifications", "", null
                );
            }
            onToggleNightLightRequested: {
                Hyprsunset.toggleTemperature();
                operationCenter.showMessage(
                    ControlCenter.I18n.tr("Ночной свет"), ControlCenter.I18n.tr("Состояние переключено"), "bedtime", "", null
                );
            }
            onNavigateRequested: pageId => root.openPageId(pageId)
        }
    }

    Component {
        id: networkPage
        ControlCenter.NetworkPage {
            controller: networkController
            network: Network
            navigation: router
            style: ui
        }
    }

    Component {
        id: applicationsPage
        ControlCenter.ApplicationsPage {
            activeTab: root.initialTab("applications", "processes")
            controller: applicationsController
            style: ui
        }
    }

    Component {
        id: appearancePage
        ControlCenter.AppearancePage {
            controller: appearanceController
            preferences: controlState
            style: ui
        }
    }

    Component {
        id: servicesPage
        ControlCenter.ServicesPage {
            activeTab: root.initialTab("services", "components")
            controller: servicesController
            navigation: router
            style: ui
            onNavigateRequested: pageId => root.openPageId(pageId)
        }
    }

    Component {
        id: systemPage
        ControlCenter.SystemPage {
            activeTab: root.initialTab("system", "performance")
            controller: systemController
            telemetry: telemetryController
            snapshots: snapshotsController
            style: ui
            onNavigateRequested: pageId => root.openPageId(pageId)
        }
    }

    Component {
        id: displaysPage
        ControlCenter.DisplayPage {
            activeTab: root.initialTab("displays", "topology")
            controller: displayController
            hyprlandData: HyprlandData
            hyprsunset: Hyprsunset
            night: Config.options.light.night
            style: ui
        }
    }

    Component {
        id: devicesPage
        ControlCenter.DevicesPage {
            activeTab: root.initialTab("devices", "phone")
            controller: devicesController
            kde: KdeConnect
            audio: Audio
            bluetooth: Bluetooth
            bluetoothStatus: BluetoothStatus
            style: ui
            onNavigateRequested: pageId => root.openPageId(pageId)
        }
    }

    Component {
        id: soundPage
        ControlCenter.SoundPage {
            activeTab: root.initialTab("sound", "devices")
            audio: Audio
            controller: audioController
            effects: EasyEffects
            style: ui
        }
    }

    Component {
        id: unavailablePage
        Item {
            Rectangle {
                anchors.centerIn: parent
                width: Math.min(parent.width - 32, 520)
                height: 156
                radius: root.radiusSection
                color: root.sectionSurface
                border.width: 1
                border.color: root.hairline
                antialiasing: true

                ColumnLayout {
                    anchors {
                        fill: parent
                        margins: 22
                    }
                    spacing: 6
                    MaterialSymbol {
                        text: "error"
                        iconSize: 24
                        color: Appearance.colors.colPrimary
                    }
                    LabelText {
                        Layout.fillWidth: true
                        text: ControlCenter.I18n.tr("Раздел недоступен")
                        font.pixelSize: Appearance.font.pixelSize.larger
                        font.weight: Font.DemiBold
                    }
                    MutedText {
                        Layout.fillWidth: true
                        text: ControlCenter.I18n.tr("Для маршрута «") + root.currentPageId
                            + ControlCenter.I18n.tr("» не зарегистрирован компонент.")
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }
    }

    ControlCenter.OperationDrawer {
        anchors.fill: parent
        operations: operationCenter
        style: ui
        blurSource: appLayout
    }

    ControlCenter.MikoSnackbar {
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: 24
        }
        operations: operationCenter
        style: ui
    }
}
