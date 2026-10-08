pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules.common

QtObject {
    id: root

    property string preference: "auto"
    property var catalog: ({})
    property bool loading: false
    property int revision: 0

    readonly property var languages: [
        { code: "auto", nativeName: "Auto" },
        { code: "ru_RU", nativeName: "Русский" },
        { code: "en_US", nativeName: "English" }
    ]
    readonly property string shellPreference:
        (Config.options && Config.options.language && Config.options.language.ui)
            ? Config.options.language.ui : "auto"
    readonly property string environmentPreference:
        Quickshell.env("MIKO_CONTROL_CENTER_LANGUAGE") || ""
    readonly property string detectedLanguage: normalize(
        shellPreference !== "auto" ? shellPreference : Qt.locale().name
    )
    readonly property string language: environmentPreference !== ""
        ? normalize(environmentPreference)
        : preference === "auto" ? detectedLanguage : normalize(preference)
    readonly property string catalogPath:
        Qt.resolvedUrl("i18n/" + language + ".json")

    function normalize(value) {
        const code = String(value || "").replace("-", "_").toLowerCase();
        return code.startsWith("ru") ? "ru_RU" : "en_US";
    }

    function languageName(code) {
        const item = languages.find(language => language.code === code);
        return item ? item.nativeName : code;
    }

    function interpolate(text, values) {
        if (!values)
            return text;
        let result = text;
        Object.keys(values).forEach(key => {
            result = result.split("{" + key + "}").join(String(values[key]));
        });
        return result;
    }

    function tr(source, values) {
        // Reading these properties keeps every QML binding reactive when a
        // catalog or the selected language changes.
        const currentRevision = revision;
        const key = String(source !== undefined && source !== null ? source : "");
        const translated = catalog.hasOwnProperty(key) ? catalog[key] : key;
        return interpolate(translated, values);
    }

    onCatalogPathChanged: {
        loading = true;
        translationFile.path = catalogPath;
        translationFile.reload();
    }

    property FileView translationFile: FileView {
        id: translationFile
        path: root.catalogPath
        preload: true
        blockLoading: true
        printErrors: false

        function applyContent() {
            try {
                const parsed = JSON.parse(text());
                root.catalog = parsed && typeof parsed === "object"
                    ? parsed : ({});
            } catch (error) {
                console.warn("[Miko I18n] Invalid catalog:", path, error);
                root.catalog = ({});
            }
            root.loading = false;
            root.revision += 1;
        }

        onLoaded: applyContent()
        onLoadFailed: error => {
            console.warn("[Miko I18n] Catalog unavailable:", path, error);
            root.catalog = ({});
            root.loading = false;
            root.revision += 1;
        }
    }
}
