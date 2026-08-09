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
                message || (state === successState ? "Готово" : "Операция завершилась с ошибкой"),
                ""
            );
        }
    }

    property Connections systemChanges: Connections {
        target: root.system
        function onUpdateDetailsStateChanged() {
            root.syncState(
                "system-updates", "Обновления системы",
                root.system.updateDetailsState,
                ["checking", "installing"], "ready",
                root.system.updateDetailsMessage
            );
        }
        function onStorageScanStateChanged() {
            root.syncState(
                "storage-scan", "Анализ хранилища",
                root.system.storageScanState,
                ["checking", "cleaning"], "ready",
                root.system.storageActionMessage
            );
        }
    }

    property Connections serviceChanges: Connections {
        target: root.services
        function onDiagnosticSummaryChanged() {
            if (root.services.diagnosticProcess.running)
                root.operations.begin("desktop-diagnostic", "Диагностика системы", "Проверяем компоненты", false);
            else if (root.operations.tasks.some(task => task.key === "desktop-diagnostic" && task.state === "running"))
                root.operations.finish("desktop-diagnostic", root.services.diagnosticHealthy, root.services.diagnosticSummary, root.services.diagnosticDetails);
        }
        function onActionMessageChanged() {
            if (root.services.actionMessage !== "")
                root.operations.showMessage("Службы", root.services.actionMessage, "settings_suggest", "", null);
        }
    }

    property Connections diagnosticChanges: Connections {
        target: root.services.diagnosticProcess
        function onRunningChanged() {
            if (root.services.diagnosticProcess.running) {
                root.operations.begin(
                    "desktop-diagnostic", "Диагностика системы",
                    "Проверяем компоненты", false
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
    }

    property Connections applicationChanges: Connections {
        target: root.applications
        function onActionMessageChanged() {
            if (root.applications.actionMessage !== "")
                root.operations.showMessage("Приложения", root.applications.actionMessage, "apps", "", null);
        }
    }

    property Connections phoneChanges: Connections {
        target: root.kdeConnect
        function onTransferStateChanged() {
            if (root.kdeConnect.transferState === "sending")
                root.operations.begin("phone-transfer", "Передача на телефон", "Отправляем по локальной сети", false);
            else if (root.kdeConnect.transferState === "success")
                root.operations.finish("phone-transfer", true, "Файлы отправлены", "");
            else if (root.kdeConnect.transferState === "error")
                root.operations.finish("phone-transfer", false, "Не удалось передать файлы", "");
        }
    }
}
