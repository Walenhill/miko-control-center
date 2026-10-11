import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

MikoSettingsGroup {
    id: root

    readonly property var installedFonts: Qt.fontFamilies().slice().sort()
    property string role: "main"
    readonly property string optionPath: role === "clock" ? "background.widgets.clock.digital.font.family" : "appearance.fonts." + role
    property string family: currentFamily()
    readonly property var matches: installedFonts.filter((name) => {
        return name.toLowerCase().includes(fontSearch.text.toLowerCase());
    })

    function currentFamily() {
        return role === "clock" ? Config.options.background.widgets.clock.digital.font.family : Config.options.appearance.fonts[role];
    }

    Layout.fillWidth: true
    onRoleChanged: family = currentFamily()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 14

        MikoSectionHeader {
            style: root.style
            title: I18n.tr("Шрифты по ролям")
            subtitle: I18n.tr("Предпросмотр не меняет систему; применяй выбранный шрифт отдельно")
        }

        MikoChoiceRow {
            style: root.style
            title: I18n.tr("Роль шрифта")
            value: root.role
            choices: [{
                "title": I18n.tr("Основной"),
                "value": "main"
            }, {
                "title": I18n.tr("Числа"),
                "value": "numbers"
            }, {
                "title": I18n.tr("Заголовки"),
                "value": "title"
            }, {
                "title": I18n.tr("Чтение"),
                "value": "reading"
            }, {
                "title": I18n.tr("Выразительный"),
                "value": "expressive"
            }, {
                "title": I18n.tr("Моноширинный"),
                "value": "monospace"
            }, {
                "title": "Nerd Icons",
                "value": "iconNerd"
            }, {
                "title": I18n.tr("Цифровые часы"),
                "value": "clock"
            }]
            onSelected: (value) => {
                return root.role = value;
            }
        }

        MikoTextField {
            id: fontSearch

            style: root.style
            Layout.fillWidth: true
            placeholderText: I18n.tr("Найти установленный шрифт")
        }

        ListView {
            id: fontList

            Layout.fillWidth: true
            Layout.preferredHeight: 220
            clip: true
            model: root.matches
            reuseItems: true

            ScrollBar.vertical: ScrollBar {
            }

            delegate: Rectangle {
                required property string modelData

                width: fontList.width
                height: 42
                radius: root.style.radiusControl
                color: root.family === modelData ? root.style.selectedSurface : "transparent"

                StyledText {
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 24
                    elide: Text.ElideRight
                    text: parent.modelData
                    font.family: parent.modelData
                    color: root.family === parent.modelData ? root.style.selectedInk : root.style.ink
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: root.family = parent.modelData
                }

            }

        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: sample.implicitHeight + 32
            radius: root.style.radiusSection
            color: root.style.controlSurface

            ColumnLayout {
                id: sample

                anchors.fill: parent
                anchors.margins: 16
                spacing: 8

                StyledText {
                    Layout.fillWidth: true
                    text: I18n.tr("Красота в деталях · Beauty in details")
                    font.family: root.family
                    font.pixelSize: 30
                    color: root.style.ink
                    wrapMode: Text.WordWrap
                }

                StyledText {
                    Layout.fillWidth: true
                    text: I18n.tr("Aa Бб 0123456789 · @ # & { }")
                    font.family: root.family
                    font.pixelSize: 20
                    color: root.style.mutedInk
                    wrapMode: Text.WordWrap
                }

                StyledText {
                    Layout.fillWidth: true
                    text: root.family
                    color: root.style.mutedInk
                    elide: Text.ElideRight
                }

            }

        }

        MikoButton {
            style: root.style
            icon: "check"
            text: I18n.tr("Применить шрифт")
            enabled: root.installedFonts.includes(root.family) && root.family !== root.currentFamily()
            onClicked: AppearanceChanges.setOption(root.optionPath, root.family, I18n.tr("Шрифт: {role}", {
                "role": root.role
            }))
        }

        StyledText {
            Layout.fillWidth: true
            color: root.style.mutedInk
            wrapMode: Text.WordWrap
            text: I18n.tr("Профиль не устанавливает шрифты. Для Nerd Icons выбирай семейство с нужными значками")
        }

    }

}
