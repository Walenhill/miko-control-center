import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

Rectangle {
    id: root

    property var style: null
    readonly property var ui: style ? style : DefaultStyle

    required property string text
    property string icon: ""
    property string tone: "neutral" // "neutral" | "accent" | "warning" | "success"

    readonly property color toneBg: tone === "accent"
        ? root.ui.selectedCardBackground
        : tone === "warning"
            ? root.ui.alpha(Appearance.colors.colError, 0.16)
            : tone === "success"
                ? root.ui.alpha(Appearance.colors.colPrimary, 0.16)
                : root.ui.controlSurface

    readonly property color toneBorder: tone === "accent"
        ? root.ui.selectedCardBorder
        : tone === "warning"
            ? root.ui.alpha(Appearance.colors.colError, 0.38)
            : tone === "success"
                ? root.ui.alpha(Appearance.colors.colPrimary, 0.38)
                : root.ui.hairline

    readonly property color toneInk: tone === "accent"
        ? root.ui.selectedSurface
        : tone === "warning"
            ? Appearance.colors.colError
            : tone === "success"
                ? Appearance.colors.colPrimary
                : root.ui.mutedInk

    implicitHeight: 28
    implicitWidth: row.implicitWidth + 18
    radius: Appearance.rounding.full
    color: toneBg
    border.width: 1
    border.color: toneBorder
    antialiasing: true

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 5

        MaterialSymbol {
            visible: root.icon !== ""
            text: root.icon
            iconSize: 15
            color: root.toneInk
            Layout.alignment: Qt.AlignVCenter
        }

        StyledText {
            text: root.text
            color: root.toneInk
            font.pixelSize: Appearance.font.pixelSize.smaller
            font.weight: Font.Medium
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
