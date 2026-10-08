import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    required property var style
    property int screenIndex: 0
    readonly property var screen: Quickshell.screens[screenIndex] || Quickshell.screens[0]
    readonly property real screenWidth: screen ? screen.width : 1920
    readonly property real screenHeight: screen ? screen.height : 1080
    readonly property var clock: Config.options.background.widgets.clock
    readonly property string prefix: "background.widgets.clock."

    function setClock(key, value, label) {
        AppearanceChanges.setOption(prefix + key, value, label);
    }

    Layout.fillWidth: true
    spacing: 16

    MikoSettingsGroup {
        Layout.fillWidth: true
        style: root.style

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            MikoSectionHeader {
                style: root.style
                title: I18n.tr("Расположение виджетов")
                subtitle: I18n.tr("Схематичный предпросмотр; перетащи часы или погоду для свободного расположения")
            }

            MikoChoiceRow {
                style: root.style
                title: I18n.tr("Экран для предпросмотра")
                value: String(root.screenIndex)
                choices: Quickshell.screens.map((screen, index) => {
                    return ({
                        "title": screen.name,
                        "value": String(index)
                    });
                })
                onSelected: (value) => {
                    return root.screenIndex = Number(value);
                }
            }

            Item {
                Layout.fillWidth: true
                implicitHeight: Math.min(width * root.screenHeight / root.screenWidth, 320)

                Rectangle {
                    id: preview

                    anchors.centerIn: parent
                    width: Math.min(parent.width, parent.height * root.screenWidth / root.screenHeight)
                    height: parent.height
                    radius: root.style.radiusSection
                    color: root.style.windowSurface
                    clip: true

                    Image {
                        anchors.fill: parent
                        source: Config.options.background.thumbnailPath || Config.options.background.wallpaperPath
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        sourceSize.width: 900
                    }

                    Repeater {
                        model: ["clock", "weather"]

                        delegate: Rectangle {
                            id: marker

                            required property string modelData
                            readonly property var settings: Config.options.background.widgets[modelData]
                            function restorePosition() {
                                marker.x = Qt.binding(() => Math.max(0, Math.min(preview.width - marker.width, marker.settings.x / root.screenWidth * preview.width)));
                                marker.y = Qt.binding(() => Math.max(0, Math.min(preview.height - marker.height, marker.settings.y / root.screenHeight * preview.height)));
                            }

                            opacity: settings.enable ? 1 : 0.55
                            width: Math.min(preview.width / 3, modelData === "clock" ? 150 : 95)
                            height: 76
                            x: Math.max(0, Math.min(preview.width - width, settings.x / root.screenWidth * preview.width))
                            y: Math.max(0, Math.min(preview.height - height, settings.y / root.screenHeight * preview.height))
                            radius: root.style.radiusControl
                            color: root.style.accentContainer
                            border.width: 1
                            border.color: root.style.selectedSurface

                            StyledText {
                                anchors.centerIn: parent
                                color: root.style.accentContainerInk
                                text: marker.modelData === "clock" ? "12:34" : "☁ 20°"
                                font.pixelSize: marker.modelData === "clock" ? 30 : 22
                                font.family: marker.modelData === "clock" && root.clock.style === "digital" ? root.clock.digital.font.family : Appearance.font.family.main
                            }

                            MouseArea {
                                property real startX: 0
                                property real startY: 0

                                anchors.fill: parent
                                preventStealing: true
                                onCanceled: marker.restorePosition()
                                onPressed: {
                                    startX = marker.x;
                                    startY = marker.y;
                                }
                                drag.target: marker
                                drag.minimumX: 0
                                drag.minimumY: 0
                                drag.maximumX: preview.width - marker.width
                                drag.maximumY: preview.height - marker.height
                                onReleased: {
                                    if (Math.abs(marker.x - startX) < 1 && Math.abs(marker.y - startY) < 1)
                                        return ;

                                    const values = {
                                    }, path = "background.widgets." + marker.modelData + ".";
                                    values[path + "x"] = Math.round(marker.x / preview.width * root.screenWidth);
                                    values[path + "y"] = Math.round(marker.y / preview.height * root.screenHeight);
                                    values[path + "placementStrategy"] = "free";
                                    AppearanceChanges.setOptions(values, I18n.tr("Расположение виджетов"));
                                    marker.restorePosition();
                                }
                            }

                        }

                    }

                }

            }

            StyledText {
                Layout.fillWidth: true
                text: I18n.tr("Координаты общие для экранов. Профили не переносят позиции и локальные обои")
                color: root.style.mutedInk
                wrapMode: Text.WordWrap
            }

        }

    }

    MikoSettingsGroup {
        Layout.fillWidth: true
        style: root.style

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 14

            MikoSectionHeader {
                style: root.style
                title: I18n.tr("Часы рабочего стола")
            }

            MikoToggleRow {
                style: root.style
                title: I18n.tr("Показывать часы")
                checked: root.clock.enable
                onToggled: (checked) => {
                    return root.setClock("enable", checked, title);
                }
            }

            MikoToggleRow {
                style: root.style
                title: I18n.tr("Только при блокировке")
                checked: root.clock.showOnlyWhenLocked
                onToggled: (checked) => {
                    return root.setClock("showOnlyWhenLocked", checked, title);
                }
            }

            MikoChoiceRow {
                style: root.style
                title: I18n.tr("Стиль часов")
                value: root.clock.style
                choices: [{
                    "title": I18n.tr("Фигурные"),
                    "value": "cookie"
                }, {
                    "title": I18n.tr("Цифровые"),
                    "value": "digital"
                }]
                onSelected: (value) => {
                    return root.setClock("style", value, title);
                }
            }

            MikoChoiceRow {
                style: root.style
                title: I18n.tr("Часы на экране блокировки")
                value: root.clock.styleLocked
                choices: [{
                    "title": I18n.tr("Фигурные"),
                    "value": "cookie"
                }, {
                    "title": I18n.tr("Цифровые"),
                    "value": "digital"
                }]
                onSelected: (value) => {
                    return root.setClock("styleLocked", value, title);
                }
            }

            MikoChoiceRow {
                style: root.style
                title: I18n.tr("Размещение часов")
                value: root.clock.placementStrategy
                choices: [{
                    "title": I18n.tr("Свободно"),
                    "value": "free"
                }, {
                    "title": I18n.tr("Спокойная область обоев"),
                    "value": "leastBusy"
                }, {
                    "title": I18n.tr("Насыщенная область обоев"),
                    "value": "mostBusy"
                }]
                onSelected: (value) => {
                    return root.setClock("placementStrategy", value, title);
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                visible: root.clock.style === "digital"

                Repeater {
                    model: [{
                        "key": "showDate",
                        "title": I18n.tr("Показывать дату")
                    }, {
                        "key": "vertical",
                        "title": I18n.tr("Вертикальное время")
                    }, {
                        "key": "adaptiveAlignment",
                        "title": I18n.tr("Адаптивное выравнивание")
                    }, {
                        "key": "animateChange",
                        "title": I18n.tr("Анимация смены цифр")
                    }]

                    delegate: MikoToggleRow {
                        required property var modelData

                        style: root.style
                        title: modelData.title
                        checked: root.clock.digital[modelData.key]
                        onToggled: (checked) => {
                            return root.setClock("digital." + modelData.key, checked, title);
                        }
                    }

                }

                Repeater {
                    model: [{
                        "key": "size",
                        "title": I18n.tr("Размер цифр"),
                        "min": 24,
                        "max": 180,
                        "step": 2
                    }, {
                        "key": "weight",
                        "title": I18n.tr("Насыщенность цифр"),
                        "min": 100,
                        "max": 900,
                        "step": 50
                    }, {
                        "key": "width",
                        "title": I18n.tr("Ширина цифр"),
                        "min": 25,
                        "max": 200,
                        "step": 5
                    }, {
                        "key": "roundness",
                        "title": I18n.tr("Округлость цифр"),
                        "min": 0,
                        "max": 100,
                        "step": 5
                    }]

                    delegate: MikoStepperRow {
                        required property var modelData

                        style: root.style
                        title: modelData.title
                        value: root.clock.digital.font[modelData.key]
                        minimum: modelData.min
                        maximum: modelData.max
                        step: modelData.step
                        onChanged: (value) => {
                            return root.setClock("digital.font." + modelData.key, value, title);
                        }
                    }

                }

                StyledText {
                    Layout.fillWidth: true
                    text: I18n.tr("Оси начертания работают только у шрифтов, которые их поддерживают")
                    color: root.style.mutedInk
                    wrapMode: Text.WordWrap
                }

            }

            ColumnLayout {
                Layout.fillWidth: true
                visible: root.clock.style === "cookie"

                MikoStepperRow {
                    style: root.style
                    title: I18n.tr("Лепестки циферблата")
                    value: root.clock.cookie.sides
                    minimum: 3
                    maximum: 40
                    onChanged: (value) => {
                        return root.setClock("cookie.sides", value, title);
                    }
                }

                Repeater {
                    model: [{
                        "key": "dialNumberStyle",
                        "title": I18n.tr("Метки циферблата"),
                        "choices": [{
                            "title": I18n.tr("Точки"),
                            "value": "dots"
                        }, {
                            "title": I18n.tr("Числа"),
                            "value": "numbers"
                        }, {
                            "title": I18n.tr("Все"),
                            "value": "full"
                        }, {
                            "title": I18n.tr("Нет"),
                            "value": "none"
                        }]
                    }, {
                        "key": "hourHandStyle",
                        "title": I18n.tr("Часовая стрелка"),
                        "choices": [{
                            "title": I18n.tr("Классическая"),
                            "value": "classic"
                        }, {
                            "title": I18n.tr("Заливка"),
                            "value": "fill"
                        }, {
                            "title": I18n.tr("Контур"),
                            "value": "hollow"
                        }, {
                            "title": I18n.tr("Скрыть"),
                            "value": "hide"
                        }]
                    }, {
                        "key": "minuteHandStyle",
                        "title": I18n.tr("Минутная стрелка"),
                        "choices": [{
                            "title": I18n.tr("Классическая"),
                            "value": "classic"
                        }, {
                            "title": I18n.tr("Тонкая"),
                            "value": "thin"
                        }, {
                            "title": I18n.tr("Средняя"),
                            "value": "medium"
                        }, {
                            "title": I18n.tr("Широкая"),
                            "value": "bold"
                        }, {
                            "title": I18n.tr("Скрыть"),
                            "value": "hide"
                        }]
                    }, {
                        "key": "secondHandStyle",
                        "title": I18n.tr("Секундная стрелка"),
                        "choices": [{
                            "title": I18n.tr("Точка"),
                            "value": "dot"
                        }, {
                            "title": I18n.tr("Линия"),
                            "value": "line"
                        }, {
                            "title": I18n.tr("Классическая"),
                            "value": "classic"
                        }, {
                            "title": I18n.tr("Скрыть"),
                            "value": "hide"
                        }]
                    }, {
                        "key": "dateStyle",
                        "title": I18n.tr("Стиль даты"),
                        "choices": [{
                            "title": I18n.tr("Рамка"),
                            "value": "border"
                        }, {
                            "title": I18n.tr("Прямоугольник"),
                            "value": "rect"
                        }, {
                            "title": I18n.tr("Пузырь"),
                            "value": "bubble"
                        }, {
                            "title": I18n.tr("Скрыть"),
                            "value": "hide"
                        }]
                    }]

                    delegate: MikoChoiceRow {
                        required property var modelData

                        style: root.style
                        title: modelData.title
                        choices: modelData.choices
                        value: root.clock.cookie[modelData.key]
                        onSelected: (value) => {
                            return root.setClock("cookie." + modelData.key, value, title);
                        }
                    }

                }

                MikoToggleRow {
                    style: root.style
                    title: I18n.tr("Дата внутри часов")
                    checked: root.clock.cookie.dateInClock
                    onToggled: (checked) => {
                        return root.setClock("cookie.dateInClock", checked, title);
                    }
                }

                MikoToggleRow {
                    style: root.style
                    title: I18n.tr("Часовые риски")
                    checked: root.clock.cookie.hourMarks
                    onToggled: (checked) => {
                        return root.setClock("cookie.hourMarks", checked, title);
                    }
                }

                MikoToggleRow {
                    style: root.style
                    title: I18n.tr("Синусоидальная форма")
                    checked: root.clock.cookie.useSineCookie
                    onToggled: (checked) => {
                        return root.setClock("cookie.useSineCookie", checked, title);
                    }
                }

                MikoToggleRow {
                    style: root.style
                    title: I18n.tr("Постоянное вращение")
                    subtitle: I18n.tr("Непрерывная анимация повышает расход GPU")
                    checked: root.clock.cookie.constantlyRotate
                    onToggled: (checked) => {
                        return root.setClock("cookie.constantlyRotate", checked, title);
                    }
                }

            }

        }

    }

    MikoSettingsGroup {
        Layout.fillWidth: true
        style: root.style

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            MikoSectionHeader {
                style: root.style
                title: I18n.tr("Погода и цитата")
            }

            MikoToggleRow {
                style: root.style
                title: I18n.tr("Погода на рабочем столе")
                checked: Config.options.background.widgets.weather.enable
                onToggled: (checked) => {
                    return AppearanceChanges.setOption("background.widgets.weather.enable", checked, title);
                }
            }

            MikoChoiceRow {
                style: root.style
                title: I18n.tr("Размещение погоды")
                value: Config.options.background.widgets.weather.placementStrategy
                choices: [{
                    "title": I18n.tr("Свободно"),
                    "value": "free"
                }, {
                    "title": I18n.tr("Спокойная область обоев"),
                    "value": "leastBusy"
                }, {
                    "title": I18n.tr("Насыщенная область обоев"),
                    "value": "mostBusy"
                }]
                onSelected: (value) => {
                    return AppearanceChanges.setOption("background.widgets.weather.placementStrategy", value, title);
                }
            }

            MikoToggleRow {
                style: root.style
                title: I18n.tr("Цитата под фигурными часами")
                checked: root.clock.quote.enable
                onToggled: (checked) => {
                    return root.setClock("quote.enable", checked, title);
                }
            }

            MikoTextField {
                id: quoteInput

                style: root.style
                Layout.fillWidth: true
                text: root.clock.quote.text
                maximumLength: 500
                placeholderText: I18n.tr("Текст цитаты")
            }

            MikoButton {
                style: root.style
                text: I18n.tr("Сохранить цитату")
                icon: "check"
                enabled: quoteInput.text !== root.clock.quote.text
                onClicked: root.setClock("quote.text", quoteInput.text, I18n.tr("Цитата"))
            }

        }

    }

}
