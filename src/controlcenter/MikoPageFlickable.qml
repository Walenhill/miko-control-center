import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import qs.modules.common

Flickable {
    id: root

    property real wheelMultiplier: 1.7
    property real pendingScrollRestore: -1
    property bool edgeFadeEnabled: true
    property real edgeFadeSize: 36
    readonly property real effectiveFadeSize: Math.max(1, Math.min(edgeFadeSize, height / 4))
    readonly property real scrollExtent: Math.max(0, contentHeight - height)
    readonly property real topFadeStrength: Math.min(1, Math.max(0, contentY) / effectiveFadeSize)
    readonly property real bottomFadeStrength: Math.min(1, Math.max(0, scrollExtent - contentY) / effectiveFadeSize)

    function navigationSnapshot() {
        return {tab: typeof root.activeTab === "string" ? root.activeTab : "",
                scrollY: Math.max(0, contentY)};
    }

    function stopRestore() {
        pendingScrollRestore = -1;
        restoreDeadline.stop();
    }

    function restoreScroll(position) {
        scrollAnimation.stop();
        cancelFlick();
        pendingScrollRestore = Math.max(0, Number(position) || 0);
        restoreDeadline.restart();
        Qt.callLater(root.applyScrollRestore);
    }

    function applyScrollRestore() {
        if (pendingScrollRestore < 0) return;
        const maximum = Math.max(0, contentHeight - height);
        contentY = Math.min(maximum, pendingScrollRestore);
        if (maximum >= pendingScrollRestore) stopRestore();
    }

    onContentHeightChanged: if (pendingScrollRestore >= 0) Qt.callLater(root.applyScrollRestore)
    onHeightChanged: if (pendingScrollRestore >= 0) Qt.callLater(root.applyScrollRestore)
    onDraggingChanged: if (dragging) stopRestore()

    Timer {
        id: restoreDeadline
        interval: 1200
        onTriggered: root.pendingScrollRestore = -1
    }

    clip: true
    boundsBehavior: Flickable.StopAtBounds
    flickDeceleration: 3600
    maximumFlickVelocity: 6200
    focus: true

    // Mask the clipped viewport, not the full (potentially very tall) page.
    // Alpha-only fading reveals the existing material without painting a band
    // over it. Input remains unchanged; the corresponding fade is disabled at
    // each end, so the first/last content and scrollbar thumb stay readable.
    layer.enabled: edgeFadeEnabled && visible && scrollExtent > 1 && width > 0 && height > 0
    layer.effect: OpacityMask {
        maskSource: Item {
            width: root.width
            height: root.height
            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0; color: Qt.rgba(1, 1, 1, 1 - root.topFadeStrength) }
                    GradientStop { position: root.effectiveFadeSize / Math.max(1, root.height); color: "white" }
                    GradientStop { position: 1 - root.effectiveFadeSize / Math.max(1, root.height); color: "white" }
                    GradientStop { position: 1; color: Qt.rgba(1, 1, 1, 1 - root.bottomFadeStrength) }
                }
            }
        }
    }

    ScrollBar.vertical: ScrollBar {
        id: bar
        policy: ScrollBar.AsNeeded
        width: 7
        minimumSize: 0.08

        contentItem: Rectangle {
            implicitWidth: 5
            radius: Appearance.rounding.full
            color: bar.pressed
                ? Appearance.colors.colPrimaryActive
                : bar.hovered
                    ? Appearance.colors.colPrimaryHover
                    : Appearance.colors.colPrimary
            opacity: bar.active ? 0.82 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: Appearance.animation.elementMoveFast.duration
                    easing.type: Easing.OutCubic
                }
            }
        }
        background: Item {}
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        propagateComposedEvents: true
        onWheel: wheel => {
            root.stopRestore();
            const maximum = Math.max(0, root.contentHeight - root.height);
            const pixelDelta = wheel.pixelDelta.y;
            const delta = pixelDelta !== 0
                ? pixelDelta * 1.15
                : wheel.angleDelta.y * root.wheelMultiplier;
            scrollAnimation.stop();
            scrollAnimation.from = root.contentY;
            scrollAnimation.to = Math.max(
                0,
                Math.min(
                    maximum,
                    root.contentY - delta
                )
            );
            scrollAnimation.start();
            wheel.accepted = true;
        }
    }

    function scrollTo(position) {
        stopRestore();
        const maximum = Math.max(0, root.contentHeight - root.height);
        scrollAnimation.stop();
        scrollAnimation.from = root.contentY;
        scrollAnimation.to = Math.max(0, Math.min(maximum, position));
        scrollAnimation.start();
    }

    Keys.onPressed: event => {
        const maximum = Math.max(0, root.contentHeight - root.height);
        if (event.key === Qt.Key_Home) {
            root.scrollTo(0);
            event.accepted = true;
        } else if (event.key === Qt.Key_End) {
            root.scrollTo(maximum);
            event.accepted = true;
        } else if (event.key === Qt.Key_PageUp) {
            root.scrollTo(root.contentY - root.height * 0.82);
            event.accepted = true;
        } else if (event.key === Qt.Key_PageDown) {
            root.scrollTo(root.contentY + root.height * 0.82);
            event.accepted = true;
        }
    }

    NumberAnimation {
        id: scrollAnimation
        target: root
        property: "contentY"
        duration: 145
        easing.type: Easing.OutCubic
    }
}
