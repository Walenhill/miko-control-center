import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    required property var controller
    required property var style

    Layout.fillWidth: true
    spacing: 18

    MikoSegmentedTabs {
        Layout.alignment: Qt.AlignHCenter
        style: root.style
        currentTab: root.controller.subsection
        model: [
            {
                id: "form",
                title: I18n.tr("Форма"),
                icon: "tune"
            },
            {
                id: "behavior",
                title: I18n.tr("Поведение"),
                icon: "motion_sensor_active"
            },
            {
                id: "elements",
                title: I18n.tr("Элементы"),
                icon: "widgets"
            },
            {
                id: "workspaces",
                title: I18n.tr("Рабочие столы"),
                icon: "grid_view"
            }
        ]
        onTabSelected: (tabId) => {
            root.controller.subsection = tabId;
        }
    }

    AppearanceBarForm {
        visible: root.controller.subsection === "form"
        style: root.style
    }
    AppearanceBarBehavior {
        visible: root.controller.subsection === "behavior"
        style: root.style
    }
    AppearanceBarElements {
        visible: root.controller.subsection === "elements"
        style: root.style
    }
    AppearanceBarWorkspaces {
        visible: root.controller.subsection === "workspaces"
        style: root.style
    }
}
