import QtQuick
import QtQuick.Controls
import qs.modules.common

Flickable {
    id: root

    property real wheelMultiplier: 1.7

    clip: true
    boundsBehavior: Flickable.StopAtBounds
    flickDeceleration: 3600
    maximumFlickVelocity: 6200
    focus: true

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
