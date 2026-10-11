import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.modules.common
import qs.modules.common.widgets

MikoSettingsGroup {
    id: root

    required property var controller
    property bool showAccent: true
    readonly property var integration: controller.materialIntegration
    property bool pickerAvailable: false
    property string pickerMessage: ""

    Layout.fillWidth: true

    Process {
        command: ["sh", "-c", "command -v hyprpicker >/dev/null 2>&1"]
        running: true
        onExited: (code, status) => {
            return root.pickerAvailable = code === 0;
        }
    }

    Process {
        id: picker

        command: ["hyprpicker", "--no-fancy", "--format=hex"]
        onExited: (code, status) => {
            if (code !== 0)
                root.pickerMessage = I18n.tr("Выбор цвета отменён или недоступен");

        }

        stdout: StdioCollector {
            onStreamFinished: {
                const value = text.trim();
                if (/^#[0-9a-f]{6}$/i.test(value)) {
                    accentInput.text = value.toUpperCase();
                    root.pickerMessage = "";
                }
            }
        }

    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 14

        ColumnLayout {
            Layout.fillWidth: true
            visible: root.showAccent
            spacing: 14

            MikoSectionHeader {
                style: root.style
                title: I18n.tr("Свой акцент")
                subtitle: I18n.tr("Material You строит гармоничную палитру из выбранного цвета")
            }

            RowLayout {
                Layout.fillWidth: true

                Rectangle {
                    width: 40
                    height: 40
                    radius: 20
                    color: accentInput.acceptableInput && accentInput.text !== "" ? accentInput.text : root.style.selectedSurface
                    border.width: 1
                    border.color: root.style.hairline
                }

                MikoTextField {
                    id: accentInput

                    Layout.fillWidth: true
                    style: root.style
                    text: root.controller.accentSelection
                    placeholderText: "#RRGGBB"
                    maximumLength: 7
                    onAccepted: {
                        if (acceptableInput)
                            root.controller.applyAccent(text);

                    }

                    validator: RegularExpressionValidator {
                        regularExpression: /^#[0-9a-fA-F]{6}$/
                    }

                }

                MikoButton {
                    style: root.style
                    text: I18n.tr("Применить")
                    icon: "check"
                    enabled: accentInput.acceptableInput && !root.controller.busy
                    onClicked: root.controller.applyAccent(accentInput.text)
                }

            }

            Flow {
                Layout.fillWidth: true
                spacing: 8

                MikoButton {
                    style: root.style
                    text: I18n.tr("Из обоев")
                    icon: "wallpaper"
                    selected: root.controller.accentSelection === ""
                    enabled: !root.controller.busy
                    onClicked: root.controller.applyAccent("")
                }

                MikoButton {
                    style: root.style
                    text: I18n.tr("Пипетка")
                    icon: "colorize"
                    enabled: root.pickerAvailable && !picker.running && !root.controller.busy
                    onClicked: picker.running = true
                }

            }

            StyledText {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                color: root.style.mutedInk
                text: root.pickerMessage || (!root.pickerAvailable ? I18n.tr("Для пипетки нужен hyprpicker; HEX работает без него") : I18n.tr("Выбранный пипеткой цвет применяется после подтверждения"))
            }

        }

        MikoSectionHeader {
            style: root.style
            title: I18n.tr("Материал поверхностей")
        }

        MikoChoiceRow {
            style: root.style
            title: I18n.tr("Прозрачность оболочки")
            value: root.controller.materialMode
            enabled: !root.controller.busy
            choices: [{
                "title": I18n.tr("Выключено"),
                "value": "off"
            }, {
                "title": I18n.tr("Авто"),
                "value": "auto"
            }, {
                "title": I18n.tr("Вручную"),
                "value": "manual"
            }]
            onSelected: (value) => {
                return root.controller.setMaterialMode(value);
            }
        }

        StyledText {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            color: root.style.mutedInk
            text: I18n.tr("Фактически: фон {background}%, внутренние поверхности {content}%", {
                "background": Math.round((1 - root.style.backgroundOpacity) * 100),
                "content": Math.round((1 - root.style.contentOpacity) * 100)
            })
        }

        ColumnLayout {
            Layout.fillWidth: true
            visible: root.controller.materialMode === "manual"
            enabled: !root.controller.busy

            MikoStepperRow {
                style: root.style
                title: I18n.tr("Фон окна и панелей")
                icon: "wallpaper"
                value: Math.round(Config.options.appearance.transparency.backgroundTransparency * 100)
                minimum: 0
                maximum: 80
                step: 5
                suffix: "%"
                onChanged: (value) => {
                    return AppearanceChanges.setOption("appearance.transparency.backgroundTransparency", value / 100, title);
                }
            }

            MikoStepperRow {
                style: root.style
                title: I18n.tr("Внутренние поверхности")
                icon: "layers"
                value: Math.round(Config.options.appearance.transparency.contentTransparency * 100)
                minimum: 0
                maximum: 90
                step: 5
                suffix: "%"
                onChanged: (value) => {
                    return AppearanceChanges.setOption("appearance.transparency.contentTransparency", value / 100, title);
                }
            }

        }

        StyledText {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            color: root.style.mutedInk
            text: I18n.tr("Общие настройки оболочки. Текст, значки и активные акценты остаются непрозрачными. Палитра не меняется")
        }

        MaterialIntegrationEditor {
            Layout.fillWidth: true
            style: root.style
            controller: root.controller
        }

    }

}
