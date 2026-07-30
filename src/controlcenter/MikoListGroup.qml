import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    required property var style
    default property alias rows: content.data
    property int padding: 8

    Layout.fillWidth: true
    implicitHeight: content.implicitHeight + padding * 2
    radius: style.radiusSection
    color: style.sectionSurface
    border.width: 1
    border.color: style.hairline
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
