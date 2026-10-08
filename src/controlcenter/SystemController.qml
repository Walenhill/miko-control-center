import QtQuick
import Quickshell
import Quickshell.Io
import qs.services
import qs.modules.common

QtObject {
    id: root

    required property var environment
    property bool automaticUpdates: true
    required property var capabilities
    property bool active: false
    property string activeSection: "performance"
    property bool initialized: false
    property bool capabilityOverviewInitialized: false

    property string powerProfile: "unknown"
    property var repositoryUpdates: []
    property var aurUpdates: []
    property var recentPackageHistory: []
    property string updateDetailsState: "not-checked"
    property string updateDetailsMessage: ""
    property string updateLastChecked: I18n.tr("ещё не проверялось")
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
    property string watchLastScan: I18n.tr("ещё не запускался")
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
    readonly property int availableUpdateCount: repositoryUpdates.length + aurUpdates.length

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
                I18n.tr("Определяем доступные системные инструменты…");
            return true;
        }
        const missing = missingCapabilities(commands);
        if (missing.length === 0)
            return false;
        storageActionMessage = action + I18n.tr(" недоступна: нет ")
            + missing.join(", ");
        return true;
    }

    function updateCapabilityFailure(action, commands) {
        if (!capabilities.ready) {
            updateDetailsState = "checking";
            updateDetailsMessage =
                I18n.tr("Определяем доступные менеджеры пакетов…");
            return true;
        }
        const missing = missingCapabilities(commands);
        if (missing.length === 0)
            return false;
        updateDetailsState = "unavailable";
        updateDetailsMessage = action + I18n.tr(" недоступно: нет ")
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
        const units = [I18n.tr("Б"), I18n.tr("КБ"), I18n.tr("МБ"), I18n.tr("ГБ"), I18n.tr("ТБ")];
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
            watchLastScan = I18n.tr("miko-watch недоступен");
        }
    }

    function ensureLoaded() {
        ensureOverviewLoaded();
        ensureSectionLoaded(activeSection);
    }

    function ensureSectionLoaded(section) {
        activeSection = section;
        if (!active)
            return;
        if (section === "updates" && updateDetailsState === "not-checked")
            refreshUpdates();
        if (section === "storage" && storageScanState === "not-checked")
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
                I18n.tr("Определяем доступные менеджеры пакетов…");
            return;
        }
        if (!capabilities.archBased
                || updateCapabilityFailure(
                    I18n.tr("Проверка обновлений"), ["pacman"])) {
            repositoryUpdates = [];
            aurUpdates = [];
            recentPackageHistory = [];
            if (!capabilities.archBased) {
                updateDetailsState = "unavailable";
                updateDetailsMessage =
                    I18n.tr("Обновления pacman недоступны в этой системе");
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
                I18n.tr("Определяем доступные системные инструменты…");
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
            watchLastScan = I18n.tr("miko-watch недоступен");
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
                I18n.tr("Обновление pacman недоступно в этой системе");
            return;
        }
        if (updateCapabilityFailure(
                I18n.tr("Обновление системы"), ["pacman", "pkexec"]))
            return;
        if (!repositoryUpdateInstall.running)
            repositoryUpdateInstall.running = true;
    }

    function installAurUpdates() {
        if (!capabilities.archBased) {
            updateDetailsState = "unavailable";
            updateDetailsMessage =
                I18n.tr("Обновление AUR недоступно в этой системе");
            return;
        }
        const helper = capabilityAvailable("paru") ? "paru"
            : capabilityAvailable("yay") ? "yay" : "";
        if (helper === "") {
            updateDetailsMessage = I18n.tr("Для AUR-интеграции нужен paru или yay");
            updateDetailsState = "unavailable";
            return;
        }
        if (updateCapabilityFailure(
                I18n.tr("Обновление AUR"), [helper, "kitty"]))
            return;
        Quickshell.execDetached([
            "kitty", "--hold", "-e", helper, "-Sua"
        ]);
    }

    function toggleUpdateList() {
        updateListExpanded = !updateListExpanded;
    }

    function requestStorageCleanup(action) {
        if (action === "cache") {
            if (storageCapabilityFailure(
                    I18n.tr("Очистка кэша"), ["pkexec", "paccache"]))
                return;
            requestCleanup(
                I18n.tr("Очистить кэш пакетов?"),
                I18n.tr("paccache оставит две последние версии каждого пакета. ")
                    + I18n.tr("Это безопаснее полной очистки и сохраняет возможность ")
                    + I18n.tr("локального отката."),
                ["pkexec", "paccache", "-rk2"],
                ["pkexec", "paccache"]
            );
        } else if (action === "trash") {
            if (storageCapabilityFailure(
                    I18n.tr("Очистка корзины"), ["gio"]))
                return;
            requestCleanup(
                I18n.tr("Очистить корзину?"),
                I18n.tr("Файлы из корзины будут удалены окончательно. ")
                    + I18n.tr("Остальные каталоги Home не затрагиваются."),
                ["gio", "trash", "--empty"],
                ["gio"]
            );
        } else if (action === "journal") {
            if (storageCapabilityFailure(
                    I18n.tr("Очистка журнала"), ["pkexec", "journalctl"]))
                return;
            requestCleanup(
                I18n.tr("Сократить системный журнал?"),
                I18n.tr("Будут удалены записи старше 14 дней. ")
                    + I18n.tr("Свежие журналы для диагностики сохранятся."),
                ["pkexec", "journalctl", "--vacuum-time=14d"],
                ["pkexec", "journalctl"]
            );
        } else if (action === "orphans" && orphanPackages.length > 0) {
            if (storageCapabilityFailure(
                    I18n.tr("Удаление пакетов"), ["pkexec", "pacman"]))
                return;
            requestCleanup(
                I18n.tr("Удалить осиротевшие пакеты?"),
                orphanPackages.join(", ")
                    + "\n\n" + I18n.tr("Это зависимости, которые pacman больше не считает ")
                    + I18n.tr("нужными. Проверь список перед продолжением."),
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
                I18n.tr("Очистка"), cleanupConfirmRequirements)) {
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
            if (root.activeSection === "updates" && (root.updateDetailsState === "checking"
                    || root.updateDetailsState === "not-checked"))
                root.refreshUpdates();
            if (root.activeSection === "storage" && (root.storageScanState === "checking"
                    || root.storageScanState === "not-checked"))
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

    property Timer updateRefreshTimer: Timer {
        interval: Math.max(1, Config.options.updates.checkInterval) * 60000
        running: root.automaticUpdates && root.capabilities.ready
            && root.capabilities.archBased && Config.ready && Config.options.updates.enableCheck
        triggeredOnStart: true
        repeat: true
        onTriggered: root.refreshUpdates()
    }

    property Process updateReader: Process {
        id: updateDetailsRead
        environment: ({ CHECKUPDATES_DB: root.environment.controlCenterState + "/checkupdates-db" })
        command: ["bash", decodeURIComponent(Qt.resolvedUrl("tools/check-updates.sh").toString().replace(/^file:\/\//, ""))]
        onRunningChanged: {
            if (running) {
                root.updateDetailsMessage = I18n.tr("Проверяем репозитории и AUR…");
                root.updateDetailsState = "checking";
            }
        }
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const result = JSON.parse(text);
                    const repoOk = ["ok", "cached"].includes(result.repositoryStatus);
                    const aurOk = result.aurStatus === "ok";
                    root.repositoryUpdates = repoOk ? root.parsePackageUpdates(result.repository, "repository") : [];
                    root.aurUpdates = aurOk ? root.parsePackageUpdates(result.aur, "aur") : [];
                    const errors = [];
                    if (!repoOk) errors.push(I18n.tr("Репозитории: проверка не удалась"));
                    if (result.aurStatus === "error") errors.push(I18n.tr("AUR: проверка не удалась"));
                    const total = root.repositoryUpdates.length + root.aurUpdates.length;
                    let message = errors.length ? errors.join(" · ")
                        : (total > 0 ? I18n.tr("Найдено обновлений: {count}", { count: total })
                            : I18n.tr("Обновлений в проверенных источниках нет"));
                    if (result.repositoryStatus === "cached")
                        message += " · " + I18n.tr("Локальная база; актуальность не проверена");
                    if (result.aurStatus === "unavailable")
                        message += " · " + I18n.tr("AUR не проверен: нужен paru или yay");
                    root.updateDetailsMessage = message;
                    root.updateLastChecked = Qt.formatDateTime(new Date(), "dd.MM · HH:mm");
                    root.updateDetailsState = errors.length ? "error" : "ready";
                } catch (error) {
                    root.updateDetailsMessage = I18n.tr("Не удалось разобрать ответ менеджера пакетов");
                    root.updateDetailsState = "error";
                }
            }
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                root.updateDetailsMessage = I18n.tr("Проверка не завершилась. Проверь подключение к сети.");
                root.updateDetailsState = "error";
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
                    I18n.tr("Устанавливаем системные пакеты…");
            }
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                root.updateDetailsMessage = I18n.tr("Системные пакеты обновлены");
                root.updateDetailsState = "ready";
                root.refreshUpdates();
            } else {
                root.updateDetailsState = "error";
                root.updateDetailsMessage = exitCode === 75
                    ? I18n.tr("База пакетов занята другим процессом")
                    : exitCode === 126
                        ? I18n.tr("Авторизация отменена")
                        : I18n.tr("Обновление завершилось с ошибкой ") + exitCode;
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
                root.storageActionMessage = I18n.tr("Анализируем хранилище…");
            }
        }
        stdout: StdioCollector {
            onStreamFinished: {
                const marker = text.indexOf("__ORPHANS__");
                if (marker < 0) {
                    root.storageScanState = "error";
                    root.storageActionMessage =
                        I18n.tr("Не удалось разобрать результаты анализа");
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
                    .replace(/K$/, I18n.tr(" КБ"))
                    .replace(/M$/, I18n.tr(" МБ"))
                    .replace(/G$/, I18n.tr(" ГБ"))
                    .replace(/T$/, I18n.tr(" ТБ"));
                root.orphanPackages = text.slice(
                    marker + "__ORPHANS__".length
                ).split("\n").map(line => line.trim()).filter(
                    line => line.length > 0
                );
                const unavailable = [];
                if (values.PACMAN_AVAILABLE !== "1")
                    unavailable.push("pacman");
                if (values.JOURNAL_AVAILABLE !== "1")
                    unavailable.push("journalctl");
                root.storageActionMessage = unavailable.length > 0
                    ? I18n.tr("Часть данных недоступна: ")
                        + unavailable.join(", ")
                    : I18n.tr("Анализ завершён");
                root.storageScanState = "ready";
            }
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0 && root.storageScanState === "checking") {
                root.storageScanState = "error";
                root.storageActionMessage =
                    I18n.tr("Анализ завершился с ошибкой ") + exitCode;
            }
        }
    }

    property Process storageCleaner: Process {
        id: storageCleanup
        onRunningChanged: {
            if (running)
                root.storageActionMessage = I18n.tr("Выполняем очистку…");
        }
        onExited: (exitCode, exitStatus) => {
            root.storageActionMessage = exitCode === 0
                ? I18n.tr("Очистка завершена")
                : I18n.tr("Очистка отменена или завершилась с ошибкой");
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
                        : I18n.tr("ещё не запускался");
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
                        ? (gib / 1024).toFixed(1) + I18n.tr(" ТБ")
                        : gib.toFixed(0) + I18n.tr(" ГБ");
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
