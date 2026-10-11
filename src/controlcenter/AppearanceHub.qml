import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    required property var controller
    required property var style

    Layout.fillWidth: true
    spacing: 22

    readonly property var paletteModes: [
        { title: I18n.tr("Авто"), value: "auto" },
        { title: I18n.tr("В контексте"), value: "scheme-content" },
        { title: I18n.tr("Выразительность"), value: "scheme-expressive" },
        { title: I18n.tr("Точность"), value: "scheme-fidelity" },
        { title: I18n.tr("Фруктовый салат"), value: "scheme-fruit-salad" },
        { title: I18n.tr("Монохром"), value: "scheme-monochrome" },
        { title: I18n.tr("Нейтральность"), value: "scheme-neutral" },
        { title: I18n.tr("Радуга"), value: "scheme-rainbow" },
        { title: I18n.tr("Тональное пятно"), value: "scheme-tonal-spot" }
    ]

    GridLayout {
        id: sceneGrid
        Layout.fillWidth: true
        columns: width >= 1040 ? 2 : 1
        columnSpacing: 24
        rowSpacing: 20

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 11

            RowLayout {
                Layout.fillWidth: true
                StyledText {
                    Layout.fillWidth: true
                    text: I18n.tr("Текущие обои")
                    color: root.style.ink
                    font.pixelSize: Appearance.font.pixelSize.larger
                    font.weight: Font.DemiBold
                }
                StyledText {
                    visible: sceneGrid.columns > 1
                    text: I18n.tr("Показываются целиком")
                    color: root.style.mutedInk
                    font.pixelSize: Appearance.font.pixelSize.smaller
                }
            }

            Rectangle {
                id: wallpaperFrame
                Layout.fillWidth: true
                implicitHeight: Math.round(width * 9 / 16)
                radius: root.style.radiusSection
                color: Appearance.colors.colLayer0
                border.width: 1
                border.color: root.style.hairline
                clip: true
                antialiasing: true

                StyledImage {
                    anchors.fill: parent
                    source: Config.options.background.wallpaperPath
                    fillMode: Image.PreserveAspectFit
                    cache: false
                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: Rectangle {
                            width: wallpaperFrame.width
                            height: wallpaperFrame.height
                            radius: wallpaperFrame.radius
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                MikoButton {
                    style: root.style
                    icon: "wallpaper"
                    text: I18n.tr("Выбрать обои")
                    enabled: !root.controller.busy
                    onClicked: root.controller.chooseWallpaper()
                }
                MikoButton {
                    style: root.style
                    icon: "ifl"
                    text: "Konachan"
                    enabled: !root.controller.busy
                    onClicked: root.controller.pickRandomWallpaper("konachan")
                }
                MikoButton {
                    style: root.style
                    icon: "casino"
                    text: "osu!"
                    enabled: !root.controller.busy
                    onClicked: root.controller.pickRandomWallpaper("osu")
                }
                Item { Layout.fillWidth: true }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            spacing: 13

            StyledText {
                text: I18n.tr("Цвет и материал")
                color: root.style.ink
                font.pixelSize: Appearance.font.pixelSize.larger
                font.weight: Font.DemiBold
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                Repeater {
                    model: [
                        { title: I18n.tr("Светлая"), icon: "light_mode", dark: false },
                        { title: I18n.tr("Тёмная"), icon: "dark_mode", dark: true }
                    ]
                    delegate: MikoButton {
                        required property var modelData
                        Layout.fillWidth: true
                        style: root.style
                        text: modelData.title
                        icon: modelData.icon
                        selected: root.controller.darkSelection === modelData.dark
                        enabled: !root.controller.materialIntegration.busy
                        onClicked: root.controller.setDarkMode(modelData.dark)
                    }
                }
            }

            MikoToggleRow {
                style: root.style
                title: I18n.tr("Прозрачность")
                subtitle: root.controller.materialMode === "off" ? I18n.tr("Интерфейс использует сплошные поверхности")
                    : root.controller.materialMode === "auto" ? I18n.tr("Авто · по обоям") : I18n.tr("Вручную · общий фон оболочки")
                icon: "ev_shadow"
                checked: Config.options.appearance.transparency.enable
                available: !root.controller.busy
                onToggled: checked =>
                    AppearanceChanges.setOption("appearance.transparency.enable", checked, title)
            }

            RowLayout {
                Layout.fillWidth: true
                StyledText {
                    Layout.fillWidth: true
                    text: I18n.tr("Характер палитры")
                    color: root.style.ink
                    font.pixelSize: Appearance.font.pixelSize.small
                    font.weight: Font.DemiBold
                }
                RowLayout {
                    spacing: 5
                    Repeater {
                        model: [
                            Appearance.colors.colPrimary,
                            Appearance.colors.colSecondary,
                            Appearance.colors.colTertiary,
                            Appearance.m3colors.m3surfaceContainerHighest
                        ]
                        delegate: Rectangle {
                            required property color modelData
                            width: 15
                            height: 15
                            radius: 8
                            color: modelData
                            border.width: 1
                            border.color: Qt.rgba(
                                root.style.ink.r, root.style.ink.g,
                                root.style.ink.b, 0.16
                            )
                        }
                    }
                }
            }

            Flow {
                Layout.fillWidth: true
                spacing: 7
                Repeater {
                    model: root.paletteModes
                    delegate: MikoButton {
                        required property var modelData
                        style: root.style
                        text: modelData.title
                        icon: ""
                        selected:
                            root.controller.paletteSelection === modelData.value
                        enabled: !root.controller.materialIntegration.busy
                        onClicked: root.controller.applyPalette(modelData.value)
                    }
                }
            }
            MikoButton {
                style: root.style; text: I18n.tr("Прозрачность и блюр"); icon: "blur_on"
                onClicked: root.controller.openEditor("materials")
            }
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 10
        StyledText {
            text: I18n.tr("Оболочка")
            color: root.style.ink
            font.pixelSize: Appearance.font.pixelSize.larger
            font.weight: Font.DemiBold
        }
        MikoListGroup {
            style: root.style
            Repeater {
                model: [
                    {
                        title: I18n.tr("Панель и экран"),
                        subtitle: (Config.options.bar.vertical
                            ? I18n.tr("Вертикальная") : I18n.tr("Горизонтальная"))
                            + I18n.tr(" · положение, автоскрытие и элементы"),
                        icon: "dock_to_bottom", editor: "bar"
                    },
                    {
                        title: I18n.tr("Интерфейс и поведение"),
                        subtitle: Config.options.appearance.fonts.main
                            + I18n.tr(" · dock, overview и экранные элементы"),
                        icon: "widgets", editor: "interface"
                    },
                    {
                        title: I18n.tr("Виджеты рабочего стола"),
                        subtitle: I18n.tr("Часы, погода и расположение"), icon: "schedule", editor: "widgets"
                    },
                    {
                        title: I18n.tr("Шрифты и типографика"),
                        subtitle: I18n.tr("Роли шрифтов и предпросмотр"), icon: "text_fields", editor: "fonts"
                    },
                    {
                        title: I18n.tr("Профили оформления"),
                        subtitle: I18n.tr("Сохранение и перенос внешнего вида"), icon: "palette", editor: "profiles"
                    }
                ]
                delegate: MikoListRow {
                    required property var modelData
                    required property int index
                    style: root.style
                    title: modelData.title
                    subtitle: modelData.subtitle
                    icon: modelData.icon
                    showChevron: true
                    interactive: true
                    dividerVisible: index < 4
                    onClicked: root.controller.openEditor(modelData.editor)
                }
            }
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 10
        StyledText {
            text: I18n.tr("Отдельные части")
            color: root.style.ink
            font.pixelSize: Appearance.font.pixelSize.larger
            font.weight: Font.DemiBold
        }
        MikoListGroup {
            style: root.style
            Repeater {
                model: [
                    {
                        title: I18n.tr("Уведомления"),
                        subtitle: Math.round(
                            Config.options.notifications.timeout / 1000
                        ) + I18n.tr(" сек. · монитор и история"),
                        icon: "notifications", editor: "notifications"
                    },
                    {
                        title: I18n.tr("Экран блокировки"),
                        subtitle: Config.options.lock.useHyprlock
                            ? "Hyprlock" : "Quickshell",
                        icon: "lock", editor: "lock"
                    },
                    {
                        title: I18n.tr("Дополнительно"),
                        subtitle: I18n.tr("Темизация приложений, parallax и терминал"),
                        icon: "tune", editor: "advanced"
                    }
                ]
                delegate: MikoListRow {
                    required property var modelData
                    required property int index
                    style: root.style
                    title: modelData.title
                    subtitle: modelData.subtitle
                    icon: modelData.icon
                    showChevron: true
                    interactive: true
                    dividerVisible: index < 2
                    onClicked: root.controller.openEditor(modelData.editor)
                }
            }
        }
    }
}
