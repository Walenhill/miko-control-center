import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    property var style: null
    readonly property var ui: style ? style : DefaultStyle

    required property var controller

    Layout.fillWidth: true
    spacing: 16

    readonly property var monitor: root.controller.selectedMonitor()
    readonly property real currentScale: (monitor && monitor.scale !== undefined) ? monitor.scale : 1
    readonly property int currentTransform: (monitor && monitor.transform !== undefined) ? monitor.transform : 0

    // Section 1: Modes and Refresh Rates
    MikoSectionHeader {
        style: root.ui
        title: I18n.tr("Разрешение и частота обновления")
        subtitle: I18n.tr("Переключение с безопасным 15-секундным таймером отката")
        badgeText: root.monitor ? root.monitor.name : ""
    }

    MikoSurface {
        Layout.fillWidth: true
        style: root.ui

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 14

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                MikoIconDisc {
                    style: root.ui
                    icon: "display_settings"
                    accented: true
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    StyledText {
                        text: I18n.tr("Доступные видеорежимы")
                        color: root.ui.ink
                        font.weight: Font.DemiBold
                        font.pixelSize: Appearance.font.pixelSize.normal
                    }

                    StyledText {
                        text: root.monitor
                            ? (root.monitor.width + "×" + root.monitor.height + " @ " + Math.round(root.monitor.refreshRate) + I18n.tr(" Гц (текущий)"))
                            : I18n.tr("Экран не выбран")
                        color: root.ui.mutedInk
                        font.pixelSize: Appearance.font.pixelSize.smaller
                    }
                }
            }

            Flow {
                Layout.fillWidth: true
                spacing: 8

                Repeater {
                    model: root.monitor
                        ? root.monitor.availableModes
                            .filter((item, index, values) => values.indexOf(item) === index)
                            .slice(0, 10)
                        : []

                    delegate: MikoButton {
                        required property string modelData
                        style: root.ui
                        icon: ""
                        text: modelData.replace("Hz", I18n.tr(" Гц"))

                        readonly property bool isCurrent: Boolean(root.monitor
                            && modelData.indexOf(root.monitor.width + "x" + root.monitor.height) === 0
                            && Math.abs(parseFloat(modelData.split("@")[1]) - root.monitor.refreshRate) < 1.0)

                        selected: isCurrent

                        onClicked: root.controller.runPreview([
                            "apply",
                            root.controller.selectedMonitor().name,
                            "--mode",
                            modelData.replace("Hz", "")
                        ])
                    }
                }
            }
        }
    }

    // Section 2: Scale and Orientation
    MikoSectionHeader {
        style: root.ui
        title: I18n.tr("Масштаб и ориентация")
        subtitle: I18n.tr("Текущий масштаб: ") + root.currentScale + "× · "
            + (root.currentTransform === 0 ? I18n.tr("Альбомная") : I18n.tr("Портретная"))
    }

    MikoSurface {
        Layout.fillWidth: true
        style: root.ui

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 16

            // Scale controls
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    MikoIconDisc {
                        style: root.ui
                        icon: "zoom_out_map"
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        StyledText {
                            text: I18n.tr("Масштабирование интерфейса")
                            color: root.ui.ink
                            font.weight: Font.DemiBold
                            font.pixelSize: Appearance.font.pixelSize.normal
                        }

                        StyledText {
                            text: I18n.tr("Коэффициент масштаба для текущего экрана")
                            color: root.ui.mutedInk
                            font.pixelSize: Appearance.font.pixelSize.smaller
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Repeater {
                        model: [0.75, 1, 1.25, 1.5, 2]

                        delegate: MikoButton {
                            required property real modelData
                            Layout.fillWidth: true
                            style: root.ui
                            icon: ""
                            text: modelData + "×"
                            enabled: root.monitor !== null
                            selected: Math.abs(root.currentScale - modelData) < 0.01
                            onClicked: root.controller.runPreview([
                                "apply",
                                root.controller.selectedMonitor().name,
                                "--scale",
                                String(modelData)
                            ])
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: root.ui.hairline
            }

            // Orientation controls
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    MikoIconDisc {
                        style: root.ui
                        icon: "screen_rotation"
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        StyledText {
                            text: I18n.tr("Ориентация экрана")
                            color: root.ui.ink
                            font.weight: Font.DemiBold
                            font.pixelSize: Appearance.font.pixelSize.normal
                        }

                        StyledText {
                            text: I18n.tr("Поворот рабочего пространства")
                            color: root.ui.mutedInk
                            font.pixelSize: Appearance.font.pixelSize.smaller
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    MikoButton {
                        Layout.fillWidth: true
                        style: root.ui
                        icon: "stay_current_landscape"
                        text: I18n.tr("Альбомная")
                        enabled: root.monitor !== null
                        selected: root.currentTransform === 0
                        onClicked: root.controller.runPreview([
                            "apply",
                            root.controller.selectedMonitor().name,
                            "--transform",
                            "0"
                        ])
                    }

                    MikoButton {
                        Layout.fillWidth: true
                        style: root.ui
                        icon: "stay_current_portrait"
                        text: I18n.tr("Портретная")
                        enabled: root.monitor !== null
                        selected: root.currentTransform === 1
                        onClicked: root.controller.runPreview([
                            "apply",
                            root.controller.selectedMonitor().name,
                            "--transform",
                            "1"
                        ])
                    }
                }
            }
        }
    }
}
