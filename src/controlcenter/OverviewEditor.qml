import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    required property var preferences
    required property var style

    Layout.fillWidth: true
    spacing: 16

    readonly property var actionMeta: ({
        wifi: { title: "Wi-Fi", icon: "wifi" },
        bluetooth: { title: "Bluetooth", icon: "bluetooth" },
        power: { title: I18n.tr("Профиль питания"), icon: "speed" },
        notifications: { title: I18n.tr("Не беспокоить"), icon: "notifications" },
        night: { title: I18n.tr("Ночной свет"), icon: "nightlight" },
        displays: { title: I18n.tr("Настройки экрана"), icon: "desktop_windows" }
    })

    MikoSurface {
        Layout.fillWidth: true
        style: root.style

        ColumnLayout {
            anchors {
                fill: parent
                margins: 16
            }
            spacing: 14

            RowLayout {
                Layout.fillWidth: true

                MikoSectionHeader {
                    Layout.fillWidth: true
                    style: root.style
                    title: I18n.tr("Настройка дашборда")
                    subtitle: I18n.tr("Выберите видимость виджетов и блоков сводки")
                }

                MikoButton {
                    style: root.style
                    icon: "restart_alt"
                    text: I18n.tr("Сбросить")
                    onClicked: root.preferences.resetOverview()
                }

                MikoButton {
                    style: root.style
                    icon: "done"
                    text: I18n.tr("Готово")
                    selected: true
                    onClicked: root.preferences.overviewEditing = false
                }
            }

            GridLayout {
                Layout.fillWidth: true
                columns: width >= 840 ? 2 : 1
                columnSpacing: 10
                rowSpacing: 4

                MikoToggleRow {
                    style: root.style
                    title: I18n.tr("Приветствие")
                    subtitle: I18n.tr("Карточка состояния и приветствие")
                    icon: "waving_hand"
                    checked: root.preferences.showOverviewHero
                    onToggled: checked => root.preferences.setOverviewOption("hero", checked)
                }
                MikoToggleRow {
                    style: root.style
                    title: I18n.tr("Показатели")
                    subtitle: I18n.tr("CPU, память, сеть и диск")
                    icon: "monitoring"
                    checked: root.preferences.showOverviewMetrics
                    onToggled: checked => root.preferences.setOverviewOption("metrics", checked)
                }
                MikoToggleRow {
                    style: root.style
                    title: I18n.tr("Быстрые действия")
                    subtitle: I18n.tr("Переключатели на главной")
                    icon: "bolt"
                    checked: root.preferences.showOverviewQuickActions
                    onToggled: checked => root.preferences.setOverviewOption("quickActions", checked)
                }
                MikoToggleRow {
                    style: root.style
                    title: I18n.tr("Устройства")
                    subtitle: I18n.tr("Телефон и основной звук")
                    icon: "devices"
                    checked: root.preferences.showOverviewDevices
                    onToggled: checked => root.preferences.setOverviewOption("devices", checked)
                }
                MikoToggleRow {
                    style: root.style
                    title: I18n.tr("Требует внимания")
                    subtitle: I18n.tr("Обновления и предупреждения")
                    icon: "notification_important"
                    checked: root.preferences.showOverviewAttention
                    onToggled: checked => root.preferences.setOverviewOption("attention", checked)
                }
                MikoToggleRow {
                    style: root.style
                    title: I18n.tr("Компактный режим")
                    subtitle: I18n.tr("Меньше вертикальных отступов")
                    icon: "density_small"
                    checked: root.preferences.compactOverview
                    onToggled: checked => root.preferences.setOverviewOption("compact", checked)
                }
                MikoToggleRow {
                    style: root.style
                    title: I18n.tr("Меньше движения")
                    subtitle: I18n.tr("Отключить переходы страниц")
                    icon: "motion_photos_off"
                    checked: root.preferences.reducedMotion
                    onToggled: checked => root.preferences.setOverviewOption("reducedMotion", checked)
                }
            }
        }
    }

    MikoSurface {
        Layout.fillWidth: true
        style: root.style

        ColumnLayout {
            anchors {
                fill: parent
                margins: 16
            }
            spacing: 12

            MikoSectionHeader {
                style: root.style
                title: I18n.tr("Порядок быстрых действий")
                subtitle: I18n.tr("Настройка отображения и последовательности кнопок")
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Repeater {
                    model: root.preferences.quickActionOrder

                    delegate: MikoListRow {
                        required property string modelData
                        required property int index
                        style: root.style
                        Layout.fillWidth: true
                        icon: (root.actionMeta[modelData] && root.actionMeta[modelData].icon)
                            ? root.actionMeta[modelData].icon : "tune"
                        title: (root.actionMeta[modelData] && root.actionMeta[modelData].title)
                            ? root.actionMeta[modelData].title : modelData
                        subtitle: root.preferences.hiddenQuickActions.includes(modelData)
                            ? I18n.tr("Скрыто") : I18n.tr("Показывается")

                        RowLayout {
                            spacing: 6
                            MikoButton {
                                style: root.style
                                icon: root.preferences.hiddenQuickActions.includes(modelData)
                                    ? "visibility_off" : "visibility"
                                onClicked: root.preferences.setQuickActionVisible(
                                    modelData,
                                    root.preferences.hiddenQuickActions.includes(modelData)
                                )
                            }
                            MikoButton {
                                style: root.style
                                icon: "arrow_upward"
                                enabled: index > 0
                                onClicked: root.preferences.moveQuickAction(modelData, -1)
                            }
                            MikoButton {
                                style: root.style
                                icon: "arrow_downward"
                                enabled: index < root.preferences.quickActionOrder.length - 1
                                onClicked: root.preferences.moveQuickAction(modelData, 1)
                            }
                        }
                    }
                }
            }
        }
    }
}
