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

ApplicationWindow {
    id: root

    ControlCenter.MikoStyle {
        id: ui
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
    ControlCenter.Capabilities {
        id: capabilities
    }
    ControlCenter.AppearanceController {
        id: appearanceController
        router: router
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
        updates: Updates
        capabilities: capabilities
    }
    ControlCenter.ServicesController {
        id: servicesController
        environment: environment
        kdeConnect: KdeConnect
        easyEffects: EasyEffects
        capabilities: capabilities
    }

    width: 1180
    height: 760
    minimumWidth: 980
    minimumHeight: 660
    visible: true
    title: "Miko Control Center"
    color: Appearance.m3colors.m3background
    onClosing: Qt.quit()
    Component.onCompleted: MaterialThemeLoader.reapplyTheme()

    readonly property string currentPageId: router.currentPageId
    readonly property int currentPage: router.currentPage
    readonly property var currentPageData:
        pageRegistry.pageById(currentPageId)
    readonly property string pageTitle:
        currentPageData ? currentPageData.title : "Неизвестный раздел"
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
    property var filteredItems: pageRegistry.searchable
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
            root.openPageId("network");
            router.networkSection = ["overview", "throne", "ports"]
                .includes(section) ? section : "overview";
            root.show();
            root.raise();
            root.requestActivate();
        }

        function inspect(componentId: string): void {
            root.openPageId("services");
            router.selectedComponentId = componentId;
            root.show();
            root.raise();
            root.requestActivate();
        }

        function appearance(editor: string): void {
            root.openPageId("appearance");
            appearanceController.openEditor(editor);
            root.show();
            root.raise();
            root.requestActivate();
        }
    }

    function performSearch(text) {
        const query = text.trim().toLowerCase();
        filteredItems = query.length === 0 ? searchableItems : searchableItems.filter(item =>
            item.title.toLowerCase().includes(query) ||
            item.subtitle.toLowerCase().includes(query)
        );
    }

    function openPageId(pageId) {
        const resolvedPageId = router.openId(pageId);
        searchField.text = "";
        searchField.focus = false;
        Qt.callLater(() => {
            if (pageLoader.item
                    && typeof pageLoader.item.scrollTo === "function")
                pageLoader.item.scrollTo(0);
        });
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
    }

    Shortcut {
        sequences: ["Ctrl+F", "Ctrl+K"]
        onActivated: {
            searchField.forceActiveFocus();
            searchField.selectAll();
        }
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

    // One continuous wallpaper-derived atmosphere. Content controls the composition,
    // rather than being trapped in a stack of opaque containers.
    StyledImage {
        id: atmosphereSource
        anchors.fill: parent
        source: Config.options.background.wallpaperPath
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true
        // The image is only ever seen through a radius-64 blur. A fixed
        // downsample avoids decoding it again on every resize frame.
        sourceSize: Qt.size(768, 432)
        visible: false
    }
    FastBlur {
        anchors {
            fill: parent
            margins: -64
        }
        source: atmosphereSource
        radius: 64
        cached: true
    }
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(
            Appearance.m3colors.m3background.r,
            Appearance.m3colors.m3background.g,
            Appearance.m3colors.m3background.b,
            0.62
        )
    }
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop {
                position: 0
                color: Qt.rgba(
                    Appearance.m3colors.m3background.r,
                    Appearance.m3colors.m3background.g,
                    Appearance.m3colors.m3background.b,
                    0.96
                )
            }
            GradientStop { position: 0.42; color: "transparent" }
            GradientStop {
                position: 1
                color: Qt.rgba(
                    Appearance.colors.colPrimary.r,
                    Appearance.colors.colPrimary.g,
                    Appearance.colors.colPrimary.b,
                    0.08
                )
            }
        }
    }

    RowLayout {
        anchors {
            fill: parent
            margins: 10
        }
        spacing: 8

        Item {
            Layout.preferredWidth: 222
            Layout.fillHeight: true

            ColumnLayout {
                anchors {
                    fill: parent
                    margins: 10
                }
                spacing: 4

                RowLayout {
                    Layout.fillWidth: true
                    Layout.bottomMargin: 19
                    spacing: 12
                    IconDisc {
                        icon: "deployed_code"
                        accented: true
                    }
                    ColumnLayout {
                        spacing: 0
                        LabelText {
                            text: "Miko OS"
                            font.pixelSize: Appearance.font.pixelSize.larger
                            font.weight: Font.DemiBold
                        }
                        MutedText { text: "Центр управления" }
                    }
                }

                Repeater {
                    model: root.navigation
                    delegate: Rectangle {
                        id: navItem

                        required property var modelData
                        Layout.fillWidth: true
                        implicitHeight: 48
                        radius: Appearance.rounding.full
                        color: root.currentPageId === modelData.id
                            ? navMouse.pressed
                                ? ui.selectedSurfaceActive
                                : navMouse.containsMouse
                                    ? ui.selectedSurfaceHover
                                    : ui.selectedSurface
                            : navMouse.pressed
                                ? ui.activeSurface
                                : navMouse.containsMouse
                                    ? ui.hoverSurface
                                    : "transparent"
                        antialiasing: true
                        activeFocusOnTab: true
                        border.width: navItem.activeFocus
                            || root.currentPageId === modelData.id ? 1 : 0
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
                        RowLayout {
                            id: navContent
                            anchors {
                                fill: parent
                                leftMargin: 14
                                rightMargin: 12
                            }
                            spacing: 12
                            transform: Translate {
                                x: navMouse.containsMouse
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
                                Layout.preferredWidth: root.settingsIconRailWidth
                                Layout.fillHeight: true
                                MaterialSymbol {
                                    anchors.centerIn: parent
                                    text: modelData.icon
                                    iconSize: 20
                                    color: root.currentPageId === modelData.id
                                        ? ui.selectedInk : root.ink
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
                                Layout.fillWidth: true
                                text: modelData.title
                                font.weight: root.currentPageId === modelData.id
                                    ? Font.DemiBold : Font.Normal
                                color: root.currentPageId === modelData.id
                                    ? ui.selectedInk
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
                            onPressed: navItem.forceActiveFocus()
                            onClicked: root.openPageId(modelData.id)
                        }
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
                    spacing: 10
                    IconDisc { icon: "info" }
                    ColumnLayout {
                        spacing: 0
                        LabelText { text: SystemInfo.distroName; font.weight: Font.Medium }
                        MutedText { text: SystemInfo.desktopEnvironment }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: root.radiusWindow
            color: root.windowSurface
            border.width: 1
            border.color: root.hairline
            antialiasing: true
            clip: true

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
                        onClicked: root.navigateBack()
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        LabelText {
                            text: root.pageTitle
                            font.pixelSize: 28
                            font.weight: Font.DemiBold
                        }
                        MutedText {
                            text: root.pageSubtitle
                            font.pixelSize: Appearance.font.pixelSize.small
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: Math.min(310, Math.max(220, root.width * 0.27))
                        implicitHeight: 48
                        radius: 18
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
                            placeholderText: "Что хочешь настроить?"
                            color: root.ink
                            placeholderTextColor: root.mutedInk
                            font.family: Appearance.font.family.main
                            font.pixelSize: Appearance.font.pixelSize.small
                            background: Item {}
                            onTextChanged: root.performSearch(text)
                            onAccepted: {
                                if (root.filteredItems.length > 0)
                                    root.openPageId(
                                        root.filteredItems[0].pageId
                                    );
                            }
                        }
                    }

                    SoftButton {
                        icon: "close"
                        text: ""
                        implicitWidth: 44
                        onClicked: root.close()
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    // Search becomes a direct route to an action or section.
                    Rectangle {
                        anchors.fill: parent
                        visible: searchField.text.length > 0
                        radius: 24
                        color: Qt.rgba(
                            Appearance.colors.colLayer0.r,
                            Appearance.colors.colLayer0.g,
                            Appearance.colors.colLayer0.b,
                            0.94
                        )
                        z: 20

                        ListView {
                            anchors {
                                fill: parent
                                margins: 10
                            }
                            spacing: 4
                            clip: true
                            model: root.filteredItems
                            delegate: Rectangle {
                                required property var modelData
                                width: ListView.view.width
                                height: 68
                                radius: 18
                                color: resultMouse.containsMouse ? root.softSurface : "transparent"
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
                                        MutedText { text: modelData.subtitle }
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
                                    onClicked: root.openPageId(modelData.pageId)
                                }
                            }

                            LabelText {
                                anchors.centerIn: parent
                                visible: root.filteredItems.length === 0
                                text: "Пока ничего не найдено"
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
                        }
                        width: Math.min(parent.width, root.pageContentMaxWidth)
                        sourceComponent: root.pageComponents[root.currentPageId]
                            ?? unavailablePage
                        transform: Translate {
                            id: pageShift
                            y: 0
                        }
                        onLoaded: pageEntrance.restart()

                        ParallelAnimation {
                            id: pageEntrance
                            NumberAnimation {
                                target: pageLoader
                                property: "opacity"
                                from: 0.82
                                to: 1
                                duration: ui.motionEnter
                                easing.type: Easing.BezierSpline
                                easing.bezierCurve: ui.motionEnterCurve
                            }
                            NumberAnimation {
                                target: pageShift
                                property: "y"
                                from: 7
                                to: 0
                                duration: ui.motionEnter
                                easing.type: Easing.BezierSpline
                                easing.bezierCurve: ui.motionEnterCurve
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
            style: ui
            network: Network
            networkState: networkController
            resourceUsage: ResourceUsage
            updates: Updates
            kdeConnect: KdeConnect
            audio: Audio
            bluetoothStatus: BluetoothStatus
            hyprsunset: Hyprsunset
            systemState: systemController
            servicesState: servicesController
            applicationsState: applicationsController
            userName: SystemInfo.username
            screenCount: Quickshell.screens.length
            onToggleWifiRequested: Network.toggleWifi()
            onToggleBluetoothRequested: {
                if (Bluetooth.defaultAdapter)
                    Bluetooth.defaultAdapter.enabled =
                        !Bluetooth.defaultAdapter.enabled;
            }
            onCyclePowerProfileRequested: {
                const next = systemController.powerProfile === "balanced"
                    ? "performance"
                    : systemController.powerProfile === "performance"
                        ? "power-saver" : "balanced";
                systemController.setPowerProfile(next);
            }
            onToggleNotificationsRequested:
                applicationsController.toggleNotifications()
            onToggleNightLightRequested: Hyprsunset.toggleTemperature()
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
            controller: applicationsController
            style: ui
        }
    }

    Component {
        id: appearancePage
        ControlCenter.AppearancePage {
            controller: appearanceController
            style: ui
        }
    }

    Component {
        id: servicesPage
        ControlCenter.ServicesPage {
            controller: servicesController
            navigation: router
            style: ui
            onNavigateRequested: pageId => root.openPageId(pageId)
        }
    }

    Component {
        id: systemPage
        ControlCenter.SystemPage {
            controller: systemController
            style: ui
            onNavigateRequested: pageId => root.openPageId(pageId)
        }
    }

    Component {
        id: displaysPage
        ControlCenter.DisplayPage {
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
                        text: "Раздел недоступен"
                        font.pixelSize: Appearance.font.pixelSize.larger
                        font.weight: Font.DemiBold
                    }
                    MutedText {
                        Layout.fillWidth: true
                        text: "Для маршрута «" + root.currentPageId
                            + "» не зарегистрирован компонент."
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }
    }
}
