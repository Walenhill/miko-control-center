import "AppearanceProfiles.js" as Profiles
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root

    required property var controller
    required property var style
    property Environment environment

    environment: Environment {
    }

    property var profiles: []
    property var categories: ["materials", "fonts", "widgets", "shell"]
    property bool ready: false
    property bool directoryReady: false
    property int selectedIndex: -1
    property int deleteArmed: -1
    property string message: ""
    readonly property var selected: profiles[selectedIndex] || null
    readonly property var fonts: Qt.fontFamilies()
    readonly property var plan: selected ? Profiles.plan(selected, controller.configuration, fonts) : null

    function persist() {
        database.setText(JSON.stringify({
            "version": 1,
            "profiles": profiles
        }, null, 2));
    }

    function add(profile) {
        Profiles.validate(profile);
        if (!ready)
            throw new Error("Profile storage is unavailable");

        if (profiles.length >= 32)
            throw new Error("Maximum 32 profiles");

        if (profiles.some((item) => {
            return item.name === profile.name;
        }))
            throw new Error("A profile with this name already exists");

        const next = profiles.concat([profile]);
        if (Profiles.byteLength(JSON.stringify({
            "version": 1,
            "profiles": next
        }, null, 2)) > 131072)
            throw new Error("Profile storage exceeds 128 KiB");

        profiles = next;
        selectedIndex = profiles.length - 1;
        persist();
        message = I18n.tr("Профиль сохранён локально");
    }

    function report(error) {
        message = I18n.tr("Не удалось обработать профиль: {error}", {
            "error": String(error.message || error)
        });
    }

    Layout.fillWidth: true
    spacing: 16
    Process {
        command: ["mkdir", "-p", root.environment.controlCenterState]
        running: true
        onExited: (code, status) => {
            root.directoryReady = code === 0;
            if (root.directoryReady)
                database.reload();
            else
                root.message = I18n.tr("Хранилище профилей недоступно");
        }
    }

    FileView {
        id: database

        path: root.environment.controlCenterState + "/appearance-profiles.json"
        onLoaded: {
            try {
                const text = database.text();
                if (Profiles.byteLength(text) > 131072)
                    throw new Error("Profile storage is too large");

                const saved = JSON.parse(text);
                if (saved.version !== 1 || !Array.isArray(saved.profiles) || saved.profiles.length > 32)
                    throw new Error("Invalid profile storage");

                saved.profiles.forEach((profile) => {
                    return Profiles.validate(profile);
                });
                const names = saved.profiles.map((profile) => {
                    return profile.name;
                });
                if (new Set(names).size !== names.length)
                    throw new Error("Duplicate profile names");

                root.profiles = saved.profiles;
                root.ready = true;
            } catch (error) {
                root.ready = false;
                root.report(error);
            }
        }
        onLoadFailed: (error) => {
            if (root.directoryReady && error === FileViewError.FileNotFound)
                root.ready = true;
            else if (root.directoryReady)
                root.message = I18n.tr("Хранилище профилей недоступно");
        }
        onSaveFailed: (error) => {
            root.ready = false;
            root.message = I18n.tr("Не удалось сохранить профили");
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
                title: I18n.tr("Сохранить текущий вид")
                subtitle: I18n.tr("Только оформление: без команд, путей, сети и настроек безопасности")
            }

            MikoTextField {
                id: profileName

                style: root.style
                Layout.fillWidth: true
                maximumLength: 80
                placeholderText: I18n.tr("Имя нового профиля")
            }

            Repeater {
                model: [{
                    "id": "materials",
                    "title": I18n.tr("Цвета и материал")
                }, {
                    "id": "fonts",
                    "title": I18n.tr("Шрифты")
                }, {
                    "id": "widgets",
                    "title": I18n.tr("Виджеты")
                }, {
                    "id": "shell",
                    "title": I18n.tr("Панель, Dock и обзор")
                }]

                delegate: MikoToggleRow {
                    required property var modelData

                    style: root.style
                    title: modelData.title
                    checked: root.categories.includes(modelData.id)
                    onToggled: (checked) => {
                        return root.categories = checked ? root.categories.concat([modelData.id]) : root.categories.filter((id) => {
                            return id !== modelData.id;
                        });
                    }
                }

            }

            MikoButton {
                style: root.style
                text: I18n.tr("Сохранить профиль")
                icon: "save"
                enabled: root.ready && profileName.text.trim() !== "" && root.categories.length > 0 && !root.controller.busy
                onClicked: {
                    try {
                        root.add(Profiles.capture(root.controller.configuration, root.controller.themeSnapshot(), profileName.text, root.categories));
                    } catch (error) {
                        root.report(error);
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
                title: I18n.tr("Мои профили")
            }

            StyledText {
                visible: root.profiles.length === 0
                text: I18n.tr("Пока нет сохранённых профилей")
                color: root.style.mutedInk
            }

            Flow {
                Layout.fillWidth: true
                spacing: 8

                Repeater {
                    model: root.profiles

                    delegate: MikoButton {
                        required property var modelData
                        required property int index

                        style: root.style
                        text: modelData.name
                        selected: index === root.selectedIndex
                        onClicked: {
                            root.selectedIndex = index;
                            root.deleteArmed = -1;
                        }
                    }

                }

            }

            StyledText {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                color: root.style.mutedInk
                visible: root.plan !== null
                text: root.plan ? I18n.tr("Параметров: {count}. Будут пропущены: {skipped}", {
                    "count": Object.keys(root.plan.options).length,
                    "skipped": root.plan.skipped.length
                }) : ""
            }

            StyledText {
                Layout.fillWidth: true
                wrapMode: Text.WrapAnywhere
                color: root.style.mutedInk
                visible: root.plan !== null && root.plan.skipped.length > 0
                text: root.plan ? root.plan.skipped.join(", ") : ""
            }

            Flow {
                Layout.fillWidth: true
                spacing: 8

                MikoButton {
                    style: root.style
                    text: I18n.tr("Применить профиль")
                    icon: "check"
                    enabled: root.selected !== null && !root.controller.busy
                    onClicked: {
                        try {
                            root.controller.applyProfile(root.selected, root.fonts);
                            root.message = "";
                        } catch (error) {
                            root.report(error);
                        }
                    }
                }

                MikoButton {
                    style: root.style
                    text: I18n.tr("Экспорт JSON")
                    icon: "upload"
                    enabled: root.selected !== null
                    onClicked: {
                        exchange.text = JSON.stringify(root.selected, null, 2);
                        exchange.forceActiveFocus();
                        exchange.selectAll();
                    }
                }

                MikoButton {
                    style: root.style
                    icon: "delete"
                    text: root.deleteArmed === root.selectedIndex && root.selectedIndex >= 0 ? I18n.tr("Подтвердить удаление") : I18n.tr("Удалить профиль")
                    enabled: root.ready && root.selected !== null
                    onClicked: {
                        if (root.deleteArmed !== root.selectedIndex) {
                            root.deleteArmed = root.selectedIndex;
                            return ;
                        }
                        root.profiles = root.profiles.filter((item, index) => {
                            return index !== root.selectedIndex;
                        });
                        root.selectedIndex = -1;
                        root.deleteArmed = -1;
                        root.persist();
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
                title: I18n.tr("Обмен профилями")
                subtitle: I18n.tr("Скопируй экспорт в файл или вставь JSON для импорта. Импорт не применяет настройки")
            }

            ScrollView {
                Layout.fillWidth: true
                Layout.preferredHeight: 200

                TextArea {
                    id: exchange

                    color: root.style.ink
                    selectedTextColor: root.style.selectedInk
                    selectionColor: root.style.selectedSurface
                    font.family: Appearance.font.family.monospace
                    font.pixelSize: Appearance.font.pixelSize.small
                    selectByMouse: true
                    wrapMode: TextEdit.WrapAnywhere
                    placeholderText: "{ \"format\": \"miko-appearance\", … }"

                    background: Rectangle {
                        color: root.style.controlSurface
                        radius: root.style.radiusControl
                    }

                }

            }

            MikoButton {
                style: root.style
                text: I18n.tr("Импортировать JSON")
                icon: "download"
                enabled: root.ready && exchange.text.length > 0 && exchange.text.length <= 131072
                onClicked: {
                    try {
                        root.add(Profiles.parse(exchange.text));
                    } catch (error) {
                        root.report(error);
                    }
                }
            }

            StyledText {
                Layout.fillWidth: true
                color: root.style.mutedInk
                wrapMode: Text.WordWrap
                text: root.message || I18n.tr("Лимит: 32 профиля, 128 КиБ. Неустановленные шрифты пропускаются; текущие позиции и обои сохраняются")
            }

        }

    }

}
