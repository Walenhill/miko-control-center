import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

Rectangle {
    id: root

    required property bool active
    required property int seconds
    required property var rollback
    required property var confirm
    required property var save
    required property var style

    visible: active
    Layout.fillWidth: true
    implicitHeight: 76
    radius: 22
    color: Qt.rgba(Appearance.colors.colPrimary.r, Appearance.colors.colPrimary.g,
                   Appearance.colors.colPrimary.b, 0.18)
    border.width: 1
    border.color: Qt.rgba(Appearance.colors.colPrimary.r, Appearance.colors.colPrimary.g,
                          Appearance.colors.colPrimary.b, 0.32)
    antialiasing: true

    RowLayout {
        anchors.fill: parent
        anchors.margins: 14
        MikoIconDisc { style: root.style; icon: "preview"; accented: true }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            StyledText { text: "Оставить новую схему?"; color: root.style.ink; font.weight: Font.DemiBold }
            StyledText {
                text: "Автовозврат через " + root.seconds + " сек."
                color: root.style.mutedInk
                font.pixelSize: Appearance.font.pixelSize.smaller
            }
        }
        MikoButton { style: root.style; icon: "undo"; text: "Вернуть"; onClicked: root.rollback() }
        MikoButton { style: root.style; icon: "check"; text: "До перезапуска"; onClicked: root.confirm() }
        MikoButton { style: root.style; icon: "save"; text: "Сохранить"; onClicked: root.save() }
    }
}
