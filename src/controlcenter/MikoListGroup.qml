import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property var style: null
    readonly property var ui: style ? style : DefaultStyle
    default property alias rows: content.data
    property int padding: 8

    Layout.fillWidth: true
    implicitHeight: content.implicitHeight + padding * 2
    radius: root.ui.radiusSection
    color: root.ui.sectionSurface
    border.width: 1
    border.color: root.ui.hairline
    antialiasing: true
    clip: true

    ColumnLayout {
        id: content
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: root.padding
        }
        spacing: 0
    }
}
