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
        { title: "Авто", value: "auto" },
        { title: "В контексте", value: "scheme-content" },
        { title: "Выразительность", value: "scheme-expressive" },
        { title: "Точность", value: "scheme-fidelity" },
        { title: "Фруктовый салат", value: "scheme-fruit-salad" },
        { title: "Монохром", value: "scheme-monochrome" },
        { title: "Нейтральность", value: "scheme-neutral" },
        { title: "Радуга", value: "scheme-rainbow" },
        { title: "Тональное пятно", value: "scheme-tonal-spot" }
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
                    text: "Текущие обои"
                    color: root.style.ink
                    font.pixelSize: Appearance.font.pixelSize.larger
                    font.weight: Font.DemiBold
                }
                StyledText {
                    visible: sceneGrid.columns > 1
                    text: "Показываются целиком"
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
                    text: "Выбрать обои"
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
                text: "Цвет и материал"
                color: root.style.ink
                font.pixelSize: Appearance.font.pixelSize.larger
                font.weight: Font.DemiBold
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                Repeater {
                    model: [
                        { title: "Светлая", icon: "light_mode", dark: false },
                        { title: "Тёмная", icon: "dark_mode", dark: true }
                    ]
                    delegate: MikoButton {
                        required property var modelData
                        Layout.fillWidth: true
                        style: root.style
                        text: modelData.title
                        icon: modelData.icon
                        selected: Appearance.m3colors.darkmode === modelData.dark
                        onClicked: root.controller.setDarkMode(modelData.dark)
                    }
                }
            }

            MikoToggleRow {
                style: root.style
                title: "Прозрачность"
                subtitle: Config.options.appearance.transparency.enable
                    ? "Обои проходят через поверхности интерфейса"
                    : "Интерфейс использует сплошные поверхности"
                icon: "ev_shadow"
                checked: Config.options.appearance.transparency.enable
                onToggled: checked =>
                    Config.options.appearance.transparency.enable = checked
            }

            RowLayout {
                Layout.fillWidth: true
                StyledText {
                    Layout.fillWidth: true
                    text: "Характер палитры"
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
                            Config.options.appearance.palette.type === modelData.value
                        onClicked: root.controller.applyPalette(modelData.value)
                    }
                }
            }
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 10
        StyledText {
            text: "Оболочка"
            color: root.style.ink
            font.pixelSize: Appearance.font.pixelSize.larger
            font.weight: Font.DemiBold
        }
        MikoListGroup {
            style: root.style
            Repeater {
                model: [
                    {
                        title: "Панель и экран",
                        subtitle: (Config.options.bar.vertical
                            ? "Вертикальная" : "Горизонтальная")
                            + " · положение, автоскрытие и элементы",
                        icon: "dock_to_bottom", editor: "bar"
                    },
                    {
                        title: "Интерфейс и поведение",
                        subtitle: Config.options.appearance.fonts.main
                            + " · dock, overview и экранные элементы",
                        icon: "widgets", editor: "interface"
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
                    dividerVisible: index < 1
                    onClicked: root.controller.openEditor(modelData.editor)
                }
            }
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 10
        StyledText {
            text: "Отдельные части"
            color: root.style.ink
            font.pixelSize: Appearance.font.pixelSize.larger
            font.weight: Font.DemiBold
        }
        MikoListGroup {
            style: root.style
            Repeater {
                model: [
                    {
                        title: "Уведомления",
                        subtitle: Math.round(
                            Config.options.notifications.timeout / 1000
                        ) + " сек. · монитор и история",
                        icon: "notifications", editor: "notifications"
                    },
                    {
                        title: "Экран блокировки",
                        subtitle: Config.options.lock.useHyprlock
                            ? "Hyprlock" : "Quickshell",
                        icon: "lock", editor: "lock"
                    },
                    {
                        title: "Дополнительно",
                        subtitle: "Темизация приложений, parallax и терминал",
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
