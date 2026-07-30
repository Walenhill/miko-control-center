import QtQuick
import Quickshell
import Quickshell.Io
import qs.services

QtObject {
    id: root

    required property var environment
    required property var updates
    required property var capabilities
    property bool active: false
    property bool initialized: false
    property bool capabilityOverviewInitialized: false

    property string powerProfile: "unknown"
    property var repositoryUpdates: []
    property var aurUpdates: []
    property var recentPackageHistory: []
    property string updateDetailsState: "not-checked"
    property string updateDetailsMessage: ""
    property string updateLastChecked: "ещё не проверялось"
    property bool updateListExpanded: true

    property string storageScanState: "not-checked"
    property string packageCacheSize: "—"
    property string trashSize: "—"
    property string journalSize: "—"
    property var orphanPackages: []
    property string storageActionMessage: ""

    property bool cleanupConfirmVisible: false
    property string cleanupConfirmTitle: ""
    property string cleanupConfirmDescription: ""
    property var cleanupConfirmCommand: []
    property var cleanupConfirmRequirements: []

    property var watchEvents: []
    property string watchLastScan: "ещё не запускался"
    readonly property int watchUnreadCount: watchEvents.filter(
        event => !event.resolved && !event.ignored && !event.read
    ).length
    readonly property int watchActiveCount: watchEvents.filter(
        event => !event.resolved && !event.ignored
    ).length
    readonly property int watchIgnoredCount: watchEvents.filter(
        event => event.ignored
    ).length

    property real rootDiskUsed: 0
    property string rootDiskFree: "—"
    property real homeDiskUsed: 0
    property string homeDiskFree: "—"
    property real hddDiskUsed: 0
    property string hddDiskFree: "—"
    property string kernelVersion: "Linux"

    readonly property string distroName: SystemInfo.distroName
    readonly property string desktopEnvironment: SystemInfo.desktopEnvironment
    readonly property string windowingSystem: SystemInfo.windowingSystem
    readonly property real cpuUsage: ResourceUsage.cpuUsage
    readonly property real memoryUsedPercentage:
        ResourceUsage.memoryUsedPercentage
    readonly property real swapUsedPercentage:
        ResourceUsage.swapUsedPercentage
    readonly property string maxAvailableCpuString:
        ResourceUsage.maxAvailableCpuString
    readonly property string maxAvailableMemoryString:
        ResourceUsage.maxAvailableMemoryString
    readonly property int availableUpdateCount: updates.count

    readonly property var watchAction: mikoWatchAction
    readonly property var powerProfileAction: powerProfileSet
    readonly property var diskUsageAction: diskUsageRead
    readonly property var storageScanAction: storageScan
    readonly property var storageCleanupAction: storageCleanup
    readonly property var updateDetailsAction: updateDetailsRead
    readonly property var updateInstallAction: repositoryUpdateInstall

    function capabilityAvailable(command) {
        return capabilities.ready && capabilities.has(command);
    }

    function mikoWatchAvailable() {
        return capabilities.ready
            && (capabilities.has("miko-watch")
                || capabilities.mikoExtensions === true);
    }

    function missingCapabilities(commands) {
        if (!capabilities.ready)
            return commands;
        return commands.filter(command => !capabilities.has(command));
    }

    function storageCapabilityFailure(action, commands) {
        if (!capabilities.ready) {
            storageActionMessage =
                "Определяем доступные системные инструменты…";
            return true;
        }
        const missing = missingCapabilities(commands);
        if (missing.length === 0)
            return false;
        storageActionMessage = action + " недоступна: нет "
            + missing.join(", ");
        return true;
    }

    function updateCapabilityFailure(action, commands) {
        if (!capabilities.ready) {
            updateDetailsState = "checking";
            updateDetailsMessage =
                "Определяем доступные менеджеры пакетов…";
            return true;
        }
        const missing = missingCapabilities(commands);
        if (missing.length === 0)
            return false;
        updateDetailsState = "unavailable";
        updateDetailsMessage = action + " недоступно: нет "
            + missing.join(", ");
        return true;
    }

    function parsePackageUpdates(text, source) {
        return text.split("\n").map(line => line.trim()).filter(line =>
            line.length > 0 && !line.startsWith("::")
        ).map(line => {
            const parts = line.split(/\s+/);
            const arrow = parts.indexOf("->");
            return {
                name: parts[0] || line,
                currentVersion: parts[1] || "",
                nextVersion: arrow >= 0 && parts.length > arrow + 1
                    ? parts[arrow + 1] : (parts[2] || ""),
                source
            };
        });
    }

    function formatBytes(value) {
        if (value === undefined || value === null
                || String(value).trim() === "")
            return "—";
        const bytes = Number(value);
        if (!isFinite(bytes) || bytes < 0)
            return "—";
        const units = ["Б", "КБ", "МБ", "ГБ", "ТБ"];
        let amount = bytes;
        let unit = 0;
        while (amount >= 1024 && unit < units.length - 1) {
            amount /= 1024;
            unit += 1;
        }
        return (unit === 0
            ? Math.round(amount)
            : amount.toFixed(amount >= 10 ? 1 : 2)) + " " + units[unit];
    }

    function ensureOverviewLoaded() {
        if (!initialized) {
            initialized = true;
            if (!diskUsageRead.running)
                diskUsageRead.running = true;
            if (!kernelRead.running)
                kernelRead.running = true;
        }
        if (!capabilities.ready || capabilityOverviewInitialized)
            return;
        capabilityOverviewInitialized = true;
        if (capabilityAvailable("powerprofilesctl")) {
            if (!powerProfileRead.running)
                powerProfileRead.running = true;
        } else {
            powerProfile = "unavailable";
        }
        if (mikoWatchAvailable()) {
            if (!mikoWatchRead.running)
                mikoWatchRead.running = true;
        } else {
            watchEvents = [];
            watchLastScan = "miko-watch недоступен";
        }
    }

    function ensureLoaded() {
        ensureOverviewLoaded();
        if (updateDetailsState === "not-checked")
            refreshUpdates();
        if (storageScanState === "not-checked")
            refreshStorage();
    }

    onActiveChanged: {
        if (active)
            ensureLoaded();
    }

    function refreshUpdates() {
        if (!capabilities.ready) {
            updateDetailsState = "checking";
            updateDetailsMessage =
                "Определяем доступные менеджеры пакетов…";
            return;
        }
        if (!capabilities.archBased
                || updateCapabilityFailure(
                    "Проверка обновлений", ["pacman"])) {
            repositoryUpdates = [];
            aurUpdates = [];
            recentPackageHistory = [];
            if (!capabilities.archBased) {
                updateDetailsState = "unavailable";
                updateDetailsMessage =
                    "Обновления pacman недоступны в этой системе";
            }
            return;
        }
        if (!updateDetailsRead.running)
            updateDetailsRead.running = true;
        if (!packageHistoryRead.running)
            packageHistoryRead.running = true;
    }

    function refreshStorage() {
        if (!capabilities.ready) {
            storageScanState = "checking";
            storageActionMessage =
                "Определяем доступные системные инструменты…";
            return;
        }
        if (!storageScan.running) {
            storageScan.exec([
                "bash", "-c", `
                    if [ "$1" = "1" ]; then
                        printf 'CACHE=%s\\n' "$(du -sb \
                            /var/cache/pacman/pkg 2>/dev/null \
                            | awk '{print $1}')"
                    else
                        printf 'CACHE=\\n'
                    fi
                    printf 'TRASH=%s\\n' "$(du -sb \
                        "$HOME/.local/share/Trash" 2>/dev/null \
                        | awk '{print $1}')"
                    if [ "$2" = "1" ]; then
                        printf 'JOURNAL=%s\\n' "$(journalctl \
                            --disk-usage 2>/dev/null \
                            | grep -oE \
                            '[0-9]+([.,][0-9]+)?[KMGTP]?' \
                            | tail -n1)"
                    else
                        printf 'JOURNAL=\\n'
                    fi
                    printf 'PACMAN_AVAILABLE=%s\\n' "$1"
                    printf 'JOURNAL_AVAILABLE=%s\\n' "$2"
                    printf '__ORPHANS__\\n'
                    if [ "$1" = "1" ]; then
                        pacman -Qtdq 2>/dev/null || true
                    fi
                `, "miko-storage",
                capabilityAvailable("pacman") ? "1" : "0",
                capabilityAvailable("journalctl") ? "1" : "0"
            ]);
        }
    }

    function setPowerProfile(profile) {
        if (!capabilities.ready
                || !capabilityAvailable("powerprofilesctl")) {
            powerProfile = "unavailable";
            return;
        }
        if (!powerProfileSet.running)
            powerProfileSet.exec(["powerprofilesctl", "set", profile]);
    }

    function runWatch(arguments) {
        if (!capabilities.ready || !mikoWatchAvailable()) {
            watchLastScan = "miko-watch недоступен";
            return;
        }
        if (!mikoWatchAction.running) {
            mikoWatchAction.exec(
                [environment.mikoWatch].concat(arguments)
            );
        }
    }

    function scanWatch() {
        runWatch(["scan"]);
    }

    function markAllWatchRead() {
        runWatch(["read-all"]);
    }

    function restoreIgnoredWatchEvents() {
        runWatch(["restore-all"]);
    }

    function markWatchEventRead(eventId) {
        runWatch(["read", eventId]);
    }

    function ignoreWatchEvent(eventId) {
        runWatch(["ignore", eventId]);
    }

    function refreshDiskUsage() {
        if (!diskUsageRead.running)
            diskUsageRead.running = true;
    }

    function installRepositoryUpdates() {
        if (!capabilities.archBased) {
            updateDetailsState = "unavailable";
            updateDetailsMessage =
                "Обновление pacman недоступно в этой системе";
            return;
        }
        if (updateCapabilityFailure(
                "Обновление системы", ["pacman", "pkexec"]))
            return;
        if (!repositoryUpdateInstall.running)
            repositoryUpdateInstall.running = true;
    }

    function installAurUpdates() {
        if (!capabilities.archBased) {
            updateDetailsState = "unavailable";
            updateDetailsMessage =
                "Обновление AUR недоступно в этой системе";
            return;
        }
        if (updateCapabilityFailure(
                "Обновление AUR", ["paru", "kitty"]))
            return;
        Quickshell.execDetached([
            "kitty", "--hold", "-e", "paru", "-Sua"
        ]);
    }

    function toggleUpdateList() {
        updateListExpanded = !updateListExpanded;
    }

    function requestStorageCleanup(action) {
        if (action === "cache") {
            if (storageCapabilityFailure(
                    "Очистка кэша", ["pkexec", "paccache"]))
                return;
            requestCleanup(
                "Очистить кэш пакетов?",
                "paccache оставит две последние версии каждого пакета. "
                    + "Это безопаснее полной очистки и сохраняет возможность "
                    + "локального отката.",
                ["pkexec", "paccache", "-rk2"],
                ["pkexec", "paccache"]
            );
        } else if (action === "trash") {
            if (storageCapabilityFailure(
                    "Очистка корзины", ["gio"]))
                return;
            requestCleanup(
                "Очистить корзину?",
                "Файлы из корзины будут удалены окончательно. "
                    + "Остальные каталоги Home не затрагиваются.",
                ["gio", "trash", "--empty"],
                ["gio"]
            );
        } else if (action === "journal") {
            if (storageCapabilityFailure(
                    "Очистка журнала", ["pkexec", "journalctl"]))
                return;
            requestCleanup(
                "Сократить системный журнал?",
                "Будут удалены записи старше 14 дней. "
                    + "Свежие журналы для диагностики сохранятся.",
                ["pkexec", "journalctl", "--vacuum-time=14d"],
                ["pkexec", "journalctl"]
            );
        } else if (action === "orphans" && orphanPackages.length > 0) {
            if (storageCapabilityFailure(
                    "Удаление пакетов", ["pkexec", "pacman"]))
                return;
            requestCleanup(
                "Удалить осиротевшие пакеты?",
                orphanPackages.join(", ")
                    + "\n\nЭто зависимости, которые pacman больше не считает "
                    + "нужными. Проверь список перед продолжением.",
                ["pkexec", "pacman", "-Rns", "--noconfirm"].concat(
                    orphanPackages
                ),
                ["pkexec", "pacman"]
            );
        }
    }

    function requestCleanup(title, description, command, requirements) {
        cleanupConfirmTitle = title;
        cleanupConfirmDescription = description;
        cleanupConfirmCommand = command;
        cleanupConfirmRequirements = requirements;
        cleanupConfirmVisible = true;
    }

    function cancelCleanup() {
        cleanupConfirmVisible = false;
        cleanupConfirmCommand = [];
        cleanupConfirmRequirements = [];
    }

    function confirmCleanup() {
        if (storageCleanup.running || cleanupConfirmCommand.length === 0)
            return;
        if (storageCapabilityFailure(
                "Очистка", cleanupConfirmRequirements)) {
            cleanupConfirmVisible = false;
            cleanupConfirmCommand = [];
            cleanupConfirmRequirements = [];
            return;
        }
        const command = cleanupConfirmCommand;
        cleanupConfirmVisible = false;
        cleanupConfirmCommand = [];
        cleanupConfirmRequirements = [];
        storageCleanup.exec(command);
    }

    property Connections capabilityMonitor: Connections {
        target: root.capabilities

        function onReadyChanged() {
            if (!root.capabilities.ready) {
                root.capabilityOverviewInitialized = false;
                return;
            }
            if (!root.active)
                return;
            root.ensureOverviewLoaded();
            if (root.updateDetailsState === "checking"
                    || root.updateDetailsState === "not-checked")
                root.refreshUpdates();
            if (root.storageScanState === "checking"
                    || root.storageScanState === "not-checked")
                root.refreshStorage();
        }
    }

    property Process powerProfileReader: Process {
        id: powerProfileRead
        running: false
        command: ["powerprofilesctl", "get"]
        stdout: StdioCollector {
            onStreamFinished:
                root.powerProfile = text.trim() || "unknown"
        }
    }

    property Process powerProfileWriter: Process {
        id: powerProfileSet
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0
                    && root.capabilityAvailable("powerprofilesctl"))
                powerProfileRead.running = true;
            else if (exitCode !== 0)
                root.powerProfile = "unknown";
        }
    }

    property Process updateReader: Process {
        id: updateDetailsRead
        command: ["bash", "-c", `
            printf '__REPOSITORY__\\n'
            if command -v checkupdates >/dev/null 2>&1; then
                checkupdates 2>/dev/null || test $? -eq 2
            else
                pacman -Qu 2>/dev/null || true
            fi
            printf '__AUR__\\n'
            if command -v paru >/dev/null 2>&1; then
                paru -Qua 2>/dev/null || true
            fi
        `]
        onRunningChanged: {
            if (running) {
                root.updateDetailsState = "checking";
                root.updateDetailsMessage = "Проверяем репозитории и AUR…";
            }
        }
        stdout: StdioCollector {
            onStreamFinished: {
                const repositoryMarker = text.indexOf("__REPOSITORY__");
                const aurMarker = text.indexOf("__AUR__");
                if (repositoryMarker < 0 || aurMarker < 0) {
                    root.updateDetailsState = "error";
                    root.updateDetailsMessage =
                        "Не удалось разобрать ответ менеджера пакетов";
                    return;
                }
                const repositoryText = text.slice(
                    repositoryMarker + "__REPOSITORY__".length,
                    aurMarker
                );
                const aurText = text.slice(aurMarker + "__AUR__".length);
                root.repositoryUpdates = root.parsePackageUpdates(
                    repositoryText, "repository"
                );
                root.aurUpdates = root.parsePackageUpdates(aurText, "aur");
                root.updateDetailsState = "ready";
                root.updateLastChecked = Qt.formatDateTime(
                    new Date(), "dd.MM · HH:mm"
                );
                const total = root.repositoryUpdates.length
                    + root.aurUpdates.length;
                const baseMessage = total > 0
                    ? total + " обновлений найдено"
                    : "Установлены свежие версии";
                root.updateDetailsMessage =
                    root.capabilityAvailable("paru")
                    ? baseMessage
                    : baseMessage + " · AUR не проверен: paru недоступен";
            }
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0 && root.updateDetailsState === "checking") {
                root.updateDetailsState = "error";
                root.updateDetailsMessage =
                    "Проверка не завершилась. Проверь подключение к сети.";
            }
        }
    }

    property Process updateInstaller: Process {
        id: repositoryUpdateInstall
        command: [
            "bash", "-c",
            "if test -e /var/lib/pacman/db.lck; then exit 75; fi; "
                + "exec pkexec pacman -Syu --noconfirm"
        ]
        onRunningChanged: {
            if (running) {
                root.updateDetailsState = "installing";
                root.updateDetailsMessage =
                    "Устанавливаем системные пакеты…";
            }
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                root.updateDetailsMessage = "Системные пакеты обновлены";
                root.updateDetailsState = "ready";
                root.refreshUpdates();
                root.updates.refresh();
            } else {
                root.updateDetailsState = "error";
                root.updateDetailsMessage = exitCode === 75
                    ? "База пакетов занята другим процессом"
                    : exitCode === 126
                        ? "Авторизация отменена"
                        : "Обновление завершилось с ошибкой " + exitCode;
            }
        }
    }

    property Process packageHistoryProcess: Process {
        id: packageHistoryRead
        command: ["bash", "-c", `
            grep -E '\\[ALPM\\] (upgraded|installed|removed)' \
                /var/log/pacman.log 2>/dev/null | tail -n 6
        `]
        stdout: StdioCollector {
            onStreamFinished: {
                root.recentPackageHistory = text.split("\n")
                    .map(line => line.trim())
                    .filter(line => line.length > 0)
                    .reverse();
            }
        }
    }

    property Process storageReader: Process {
        id: storageScan
        onRunningChanged: {
            if (running) {
                root.storageScanState = "checking";
                root.storageActionMessage = "Анализируем хранилище…";
            }
        }
        stdout: StdioCollector {
            onStreamFinished: {
                const marker = text.indexOf("__ORPHANS__");
                if (marker < 0) {
                    root.storageScanState = "error";
                    root.storageActionMessage =
                        "Не удалось разобрать результаты анализа";
                    return;
                }
                const values = {};
                text.slice(0, marker).split("\n").forEach(line => {
                    const split = line.indexOf("=");
                    if (split > 0)
                        values[line.slice(0, split)] = line.slice(split + 1);
                });
                root.packageCacheSize = root.formatBytes(values.CACHE);
                root.trashSize = root.formatBytes(values.TRASH);
                root.journalSize = (values.JOURNAL || "—")
                    .replace(".", ",")
                    .replace(/K$/, " КБ")
                    .replace(/M$/, " МБ")
                    .replace(/G$/, " ГБ")
                    .replace(/T$/, " ТБ");
                root.orphanPackages = text.slice(
                    marker + "__ORPHANS__".length
                ).split("\n").map(line => line.trim()).filter(
                    line => line.length > 0
                );
                root.storageScanState = "ready";
                const unavailable = [];
                if (values.PACMAN_AVAILABLE !== "1")
                    unavailable.push("pacman");
                if (values.JOURNAL_AVAILABLE !== "1")
                    unavailable.push("journalctl");
                root.storageActionMessage = unavailable.length > 0
                    ? "Часть данных недоступна: "
                        + unavailable.join(", ")
                    : "Анализ завершён";
            }
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0 && root.storageScanState === "checking") {
                root.storageScanState = "error";
                root.storageActionMessage =
                    "Анализ завершился с ошибкой " + exitCode;
            }
        }
    }

    property Process storageCleaner: Process {
        id: storageCleanup
        onRunningChanged: {
            if (running)
                root.storageActionMessage = "Выполняем очистку…";
        }
        onExited: (exitCode, exitStatus) => {
            root.storageActionMessage = exitCode === 0
                ? "Очистка завершена"
                : "Очистка отменена или завершилась с ошибкой";
            root.refreshStorage();
            if (!diskUsageRead.running)
                diskUsageRead.running = true;
        }
    }

    property Process watchReader: Process {
        id: mikoWatchRead
        running: false
        command: [root.environment.mikoWatch, "json"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(text);
                    root.watchEvents = data.events || [];
                    root.watchLastScan = data.last_scan
                        ? Qt.formatDateTime(
                            new Date(data.last_scan), "dd.MM · HH:mm"
                        )
                        : "ещё не запускался";
                } catch (error) {
                    console.warn("Miko Watch state parse failed:", error);
                }
            }
        }
    }

    property Process watchWriter: Process {
        id: mikoWatchAction
        onExited: {
            if (root.mikoWatchAvailable())
                mikoWatchRead.running = true;
        }
    }

    property Timer watchRefreshTimer: Timer {
        interval: 30000
        repeat: true
        running: root.active && root.mikoWatchAvailable()
        onTriggered: {
            if (!mikoWatchRead.running)
                mikoWatchRead.running = true;
        }
    }

    property Process diskUsageProcess: Process {
        id: diskUsageRead
        running: false
        command: ["sh", "-c", `
            read_disk() {
                df -B1 --output=size,used,avail,pcent "$1" 2>/dev/null \
                    | tail -n1 \
                    | awk '{printf "%s|%s|%s|%s", $1, $2, $3, $4}'
            }
            printf "root=%s\\n" "$(read_disk /)"
            printf "home=%s\\n" "$(read_disk /home)"
            printf "hdd=%s\\n" "$(read_disk /mnt/hdd)"
        `]
        stdout: StdioCollector {
            onStreamFinished: {
                const formatFree = value => {
                    const gib = Number(value) / 1073741824;
                    return gib >= 1000
                        ? (gib / 1024).toFixed(1) + " ТБ"
                        : gib.toFixed(0) + " ГБ";
                };
                for (const row of text.trim().split("\n")) {
                    const [name, payload] = row.split("=");
                    const fields = (payload ?? "").split("|");
                    if (fields.length < 4)
                        continue;
                    const usedRatio = Number(fields[1])
                        / Math.max(1, Number(fields[0]));
                    const free = formatFree(fields[2]);
                    if (name === "root") {
                        root.rootDiskUsed = usedRatio;
                        root.rootDiskFree = free;
                    } else if (name === "home") {
                        root.homeDiskUsed = usedRatio;
                        root.homeDiskFree = free;
                    } else if (name === "hdd") {
                        root.hddDiskUsed = usedRatio;
                        root.hddDiskFree = free;
                    }
                }
            }
        }
    }

    property Process kernelReader: Process {
        id: kernelRead
        running: false
        command: ["uname", "-r"]
        stdout: StdioCollector {
            onStreamFinished:
                root.kernelVersion = text.trim() || "Linux"
        }
    }
}
