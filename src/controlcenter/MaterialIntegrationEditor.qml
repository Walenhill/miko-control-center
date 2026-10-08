import QtQuick
import QtQuick.Layouts
import qs.modules.common.widgets

ColumnLayout {
    id: root

    required property var style
    required property var controller
    readonly property var integration: controller.materialIntegration
    property bool draftDirty: false
    property bool blurEnabled: true
    property int blurSize: 6
    property int blurPasses: 2
    property string confirmedPreset: ""

    function loadBlur() {
        const blur = integration.state.blur || {
        };
        if (typeof blur.enabled === "boolean")
            blurEnabled = blur.enabled;

        if (blur.size !== undefined)
            blurSize = blur.size;

        if (blur.passes !== undefined)
            blurPasses = blur.passes;

    }

    Component.onCompleted: {
        loadBlur();
        integration.refresh();
    }
    spacing: 12

    Connections {
        function onActionFinished(kind, success) {
            if (kind === "blur" && success)
                root.draftDirty = false;
        }
        function onStateChanged() {
            if (!root.draftDirty)
                root.loadBlur();

        }

        target: root.integration
    }

    MikoSectionHeader {
        style: root.style
        title: I18n.tr("Размытие фона")
    }

    StyledText {
        Layout.fillWidth: true
        color: root.style.mutedInk
        wrapMode: Text.WordWrap
        text: I18n.tr("Нативный блюр Hyprland за окнами, без копии обоев. Параметры общие для compositor, не только для центра")
    }

    ColumnLayout {
        Layout.fillWidth: true
        enabled: root.integration.available && root.integration.state.blurSupported && !root.controller.busy
        opacity: enabled ? 1 : 0.45

        MikoToggleRow {
            style: root.style
            title: I18n.tr("Размывать фон")
            icon: "blur_on"
            checked: root.blurEnabled
            onToggled: (checked) => {
                root.blurEnabled = checked;
                root.draftDirty = true;
            }
        }

        MikoStepperRow {
            style: root.style
            title: I18n.tr("Сила блюра")
            value: root.blurSize
            minimum: 1
            maximum: 16
            onChanged: (value) => {
                root.blurSize = value;
                root.draftDirty = true;
            }
        }

        MikoStepperRow {
            style: root.style
            title: I18n.tr("Проходы блюра")
            subtitle: I18n.tr("Больше проходов — выше нагрузка GPU")
            value: root.blurPasses
            minimum: 1
            maximum: 4
            onChanged: (value) => {
                root.blurPasses = value;
                root.draftDirty = true;
            }
        }

        RowLayout {
            MikoButton {
                style: root.style
                text: I18n.tr("Применить блюр")
                icon: "check"
                enabled: root.draftDirty && !root.integration.sameBlur({enabled: root.blurEnabled, size: root.blurSize, passes: root.blurPasses}, root.integration.state.blur)
                onClicked: {
                    root.integration.applyBlur(root.blurEnabled, root.blurSize, root.blurPasses);
                }
            }

            MikoButton {
                style: root.style
                text: I18n.tr("Перечитать")
                icon: "refresh"
                onClicked: {
                    root.draftDirty = false;
                    root.integration.refresh();
                }
            }

        }

    }

    StyledText {
        Layout.fillWidth: true
        color: root.style.mutedInk
        wrapMode: Text.WordWrap
        text: root.integration.state.blur && root.integration.state.blur.enabled !== undefined ? I18n.tr("Сейчас: блюр {enabled}, сила {size}, проходов {passes}", {
            "enabled": root.integration.state.blur.enabled ? I18n.tr("Включен") : I18n.tr("Выключено"),
            "size": root.integration.state.blur.size,
            "passes": root.integration.state.blur.passes
        }) : I18n.tr("Состояние compositor пока неизвестно")
    }

    MikoSectionHeader {
        style: root.style
        title: "miko-theme"
        subtitle: root.integration.available ? (root.integration.state.activeMode || "") + (root.integration.presetModified ? I18n.tr(" · ручные изменения") : "") : I18n.tr("Не подключён")
    }

    StyledText {
        Layout.fillWidth: true
        color: root.style.mutedInk
        wrapMode: Text.WordWrap
        text: I18n.tr("Обновление цветов сохраняет прозрачность и блюр. Пресет меняет стиль включённых приложений и настройки оболочки — подтверди вторым нажатием")
    }

    Flow {
        Layout.fillWidth: true
        spacing: 6

        Repeater {
            model: root.integration.modes

            delegate: MikoButton {
                required property var modelData

                style: root.style
                enabled: !root.controller.busy
                text: root.confirmedPreset === modelData.id ? I18n.tr("Применить {preset}?", {
                    "preset": modelData.name
                }) : modelData.name
                selected: root.integration.state.activeMode === modelData.id && !root.integration.presetModified
                onClicked: {
                    if (root.confirmedPreset !== modelData.id) {
                        root.confirmedPreset = modelData.id;
                        return ;
                    }
                    root.draftDirty = false;
                    root.integration.applyPreset(modelData.id);
                    root.confirmedPreset = "";
                }
            }

        }

    }

    Flow {
        Layout.fillWidth: true
        spacing: 6

        MikoButton {
            style: root.style
            text: I18n.tr("Обновить цвета приложений")
            icon: "sync"
            enabled: root.integration.available && !root.controller.busy
            onClicked: root.integration.syncColors()
        }

        MikoButton {
            style: root.style
            text: root.confirmedPreset === "rollback" ? I18n.tr("Подтвердить возврат стиля") : I18n.tr("Вернуть стиль miko-theme")
            enabled: root.integration.available && root.integration.state.canRollback && !root.controller.busy
            onClicked: {
                if (root.confirmedPreset !== "rollback") {
                    root.confirmedPreset = "rollback";
                    return ;
                }
                root.integration.rollback();
                root.confirmedPreset = "";
                root.draftDirty = false;
            }
        }

    }

    StyledText {
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
        color: root.style.mutedInk
        text: root.integration.message
    }

    StyledText {
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
        color: root.style.mutedInk
        visible: Boolean(root.integration.state.lastApply && root.integration.state.lastApply.ok === false)
        text: I18n.tr("Часть приложений не обновлена; подробности: miko-theme status")
    }

}
