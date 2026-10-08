import QtQuick

QtObject {
    id: root

    required property var operations
    required property var system
    required property var services
    required property var network
    required property var applications
    required property var kdeConnect

    function syncState(key, title, state, runningStates, successState, message) {
        if (runningStates.includes(state)) {
            root.operations.begin(key, title, message, false);
        } else if (root.operations.tasks.some(task => task.key === key
                && task.state === "running")) {
            root.operations.finish(
                key,
                state === successState,
                message || (state === successState ? I18n.tr("Готово") : I18n.tr("Операция завершилась с ошибкой")),
                ""
            );
        }
    }

    property Connections systemChanges: Connections {
        target: root.system
        function onUpdateDetailsStateChanged() {
            Qt.callLater(root.syncUpdates);
        }
        function onStorageScanStateChanged() {
            Qt.callLater(root.syncStorage);
        }
    }

    function syncUpdates() {
            root.syncState(
                "system-updates", I18n.tr("Обновления системы"),
                root.system.updateDetailsState,
                ["checking", "installing"], "ready",
                root.system.updateDetailsMessage
            );
    }
    function syncStorage() {
            root.syncState(
                "storage-scan", I18n.tr("Анализ хранилища"),
                root.system.storageScanState,
                ["checking", "cleaning"], "ready",
                root.system.storageActionMessage
            );
    }

    property Connections serviceChanges: Connections {
        target: root.services
        function onDiagnosticSummaryChanged() {
            Qt.callLater(root.syncDiagnostics);
        }
        function onActionMessageChanged() {
            if (root.services.actionMessage !== "")
                root.operations.showMessage(I18n.tr("Службы"), root.services.actionMessage, "settings_suggest", "", null);
        }
    }

    property Connections diagnosticChanges: Connections {
        target: root.services.diagnosticProcess
        function onRunningChanged() {
            Qt.callLater(root.syncDiagnostics);
        }
    }

    function syncDiagnostics() {
            if (root.services.diagnosticProcess.running) {
                root.operations.begin(
                    "desktop-diagnostic", I18n.tr("Диагностика системы"),
                    I18n.tr("Проверяем компоненты"), false
                );
            } else if (root.operations.tasks.some(task =>
                    task.key === "desktop-diagnostic"
                    && task.state === "running")) {
                root.operations.finish(
                    "desktop-diagnostic", root.services.diagnosticHealthy,
                    root.services.diagnosticSummary,
                    root.services.diagnosticDetails
                );
            }
    }

    property Connections applicationChanges: Connections {
        target: root.applications
        function onActionMessageChanged() {
            if (root.applications.actionMessage !== "")
                root.operations.showMessage(I18n.tr("Приложения"), root.applications.actionMessage, "apps", "", null);
        }
    }

    property Connections phoneChanges: Connections {
        target: root.kdeConnect
        function onTransferStateChanged() {
            if (root.kdeConnect.transferState === "sending")
                root.operations.begin("phone-transfer", I18n.tr("Передача на телефон"), I18n.tr("Отправляем по локальной сети"), false);
            else if (root.kdeConnect.transferState === "success")
                root.operations.finish("phone-transfer", true, I18n.tr("Файлы отправлены"), "");
            else if (root.kdeConnect.transferState === "error")
                root.operations.finish("phone-transfer", false, I18n.tr("Не удалось передать файлы"), "");
        }
    }
}
