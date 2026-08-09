import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

MikoSurface {
    id: root

    required property var preferences
    implicitHeight: content.implicitHeight + 32
    accented: true

    readonly property var actionMeta: ({
        wifi: { title: "Wi-Fi", icon: "wifi" },
        bluetooth: { title: "Bluetooth", icon: "bluetooth" },
        power: { title: "Профиль питания", icon: "speed" },
        notifications: { title: "Не беспокоить", icon: "notifications" },
        night: { title: "Ночной свет", icon: "nightlight" },
        displays: { title: "Настройки экрана", icon: "desktop_windows" }
    })

    ColumnLayout {
        id: content
        anchors {
            fill: parent
            margins: 16
        }
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            StyledText {
                Layout.fillWidth: true
                text: "Настроить обзор"
                color: root.style.ink
                font.pixelSize: Appearance.font.pixelSize.larger
                font.weight: Font.DemiBold
            }
            MikoButton {
                style: root.style
                icon: "restart_alt"
                text: "Сбросить"
                onClicked: root.preferences.resetOverview()
            }
            MikoButton {
                style: root.style
                icon: "done"
                text: "Готово"
                selected: true
                onClicked: root.preferences.overviewEditing = false
            }
        }

        GridLayout {
            Layout.fillWidth: true
            columns: width >= 840 ? 2 : 1
            columnSpacing: 10
            rowSpacing: 8

            MikoToggleRow {
                style: root.style
                title: "Приветствие"
                subtitle: "Большая карточка состояния"
                icon: "waving_hand"
                checked: root.preferences.showOverviewHero
                onToggled: checked => root.preferences.setOverviewOption("hero", checked)
            }
            MikoToggleRow {
                style: root.style
                title: "Показатели"
                subtitle: "CPU, память, сеть и диск"
                icon: "monitoring"
                checked: root.preferences.showOverviewMetrics
                onToggled: checked => root.preferences.setOverviewOption("metrics", checked)
            }
            MikoToggleRow {
                style: root.style
                title: "Быстрые действия"
                subtitle: "Переключатели на главной"
                icon: "bolt"
                checked: root.preferences.showOverviewQuickActions
                onToggled: checked => root.preferences.setOverviewOption("quickActions", checked)
            }
            MikoToggleRow {
                style: root.style
                title: "Устройства"
                subtitle: "Телефон и основной звук"
                icon: "devices"
                checked: root.preferences.showOverviewDevices
                onToggled: checked => root.preferences.setOverviewOption("devices", checked)
            }
            MikoToggleRow {
                style: root.style
                title: "Требует внимания"
                subtitle: "Обновления и здоровье системы"
                icon: "notification_important"
                checked: root.preferences.showOverviewAttention
                onToggled: checked => root.preferences.setOverviewOption("attention", checked)
            }
            MikoToggleRow {
                style: root.style
                title: "Компактный режим"
                subtitle: "Меньше вертикальных отступов"
                icon: "density_small"
                checked: root.preferences.compactOverview
                onToggled: checked => root.preferences.setOverviewOption("compact", checked)
            }
            MikoToggleRow {
                style: root.style
                title: "Меньше движения"
                subtitle: "Отключить переходы страниц"
                icon: "motion_photos_off"
                checked: root.preferences.reducedMotion
                onToggled: checked => root.preferences.setOverviewOption("reducedMotion", checked)
            }
        }

        StyledText {
            text: "Порядок быстрых действий"
            color: root.style.ink
            font.weight: Font.Medium
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
                    icon: root.actionMeta[modelData]?.icon || "tune"
                    title: root.actionMeta[modelData]?.title || modelData
                    subtitle: root.preferences.hiddenQuickActions.includes(modelData)
                        ? "Скрыто" : "Показывается"

                    RowLayout {
                        spacing: 5
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
