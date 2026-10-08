import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    required property var environment
    required property var kdeConnect
    required property var easyEffects
    required property var capabilities

    property bool active: false
    property bool initialized: false
    property var serviceStates: ({})
    property string actionMessage: ""
    property var integrationStates: ({})
    property var discoveredServiceUnits: []
    property var pinnedComponentIds: [
        "quickshell", "pipewire", "portal", "clipboard-image",
        "hypridle", "kdeconnect"
    ]
    property bool editingPins: false
    property bool showAllComponents: false
    property bool showCatalog: false
    property string lastChecked: I18n.tr("ещё не проверено")
    property string diagnosticSummary:
        I18n.tr("Глубокая проверка ещё не запускалась")
    property string diagnosticDetails: ""
    property bool diagnosticHealthy: true

    readonly property var actionProcess: serviceAction
    readonly property var diagnosticProcess: desktopDiagnostic

    function capabilityAvailable(command) {
        return capabilities.ready && capabilities.has(command);
    }

    function missingCapabilities(commands) {
        if (!capabilities.ready)
            return commands;
        return commands.filter(command => !capabilities.has(command));
    }

    function rejectAction(action, commands) {
        if (!capabilities.ready) {
            actionMessage =
                I18n.tr("Определяем доступные системные инструменты…");
            serviceMessageTimer.restart();
            return true;
        }
        const missing = missingCapabilities(commands);
        if (missing.length === 0)
            return false;
        actionMessage = action + I18n.tr(" недоступно: нет ")
            + missing.join(", ");
        serviceMessageTimer.restart();
        return true;
    }

    function markServicesUnavailable() {
        const next = {};
        knownServiceComponents.forEach(component => {
            next[component.unit] = {
                active: "unavailable",
                enabled: "unavailable",
                description: I18n.tr("systemctl недоступен"),
                unavailable: true
            };
        });
        serviceStates = next;
        discoveredServiceUnits = [];
        lastChecked = I18n.tr("systemctl недоступен");
    }

    function markIntegrationsUnavailable() {
        const next = {};
        integrationCatalog.forEach(component => {
            next[component.id] = {
                installed: false,
                version: "",
                unavailable: true
            };
        });
        integrationStates = next;
    }

    readonly property var knownServiceComponents: [
        {
            id: "quickshell",
            unit: "miko-quickshell.service",
            title: I18n.tr("Интерфейс системы"),
            technicalName: "Quickshell",
            subtitle: I18n.tr("Панель, виджеты и центр управления"),
            icon: "deployed_code",
            kind: "core",
            pageId: "overview"
        },
        {
            id: "pipewire",
            unit: "pipewire.service",
            title: I18n.tr("Звук"),
            technicalName: "PipeWire",
            subtitle: I18n.tr("Воспроизведение и мультимедийные потоки"),
            icon: "audio_file",
            kind: "core",
            pageId: "sound"
        },
        {
            id: "wireplumber",
            unit: "wireplumber.service",
            title: I18n.tr("Аудиомаршрутизация"),
            technicalName: "WirePlumber",
            subtitle: I18n.tr("Выбор и связь аудиоустройств"),
            icon: "account_tree",
            kind: "core",
            pageId: "sound"
        },
        {
            id: "portal",
            unit: "xdg-desktop-portal.service",
            title: I18n.tr("Доступ приложений"),
            technicalName: "Desktop Portal",
            subtitle: I18n.tr("Экран, файлы и системные диалоги"),
            icon: "door_open",
            kind: "core",
            pageId: "services"
        },
        {
            id: "hyprland-portal",
            unit: "xdg-desktop-portal-hyprland.service",
            title: I18n.tr("Захват экрана"),
            technicalName: "Hyprland Portal",
            subtitle: I18n.tr("Демонстрация экрана в Wayland"),
            icon: "screenshot_monitor",
            kind: "system",
            pageId: "displays"
        },
        {
            id: "clipboard-image",
            unit: "miko-clipboard-image.service",
            title: I18n.tr("Изображения буфера"),
            technicalName: "miko-clipboard-image",
            subtitle: I18n.tr("История и предпросмотр картинок"),
            icon: "image",
            kind: "personal",
            pageId: "applications"
        },
        {
            id: "clipboard-text",
            unit: "miko-clipboard-text.service",
            title: I18n.tr("Текст буфера"),
            technicalName: "miko-clipboard-text",
            subtitle: I18n.tr("История скопированного текста"),
            icon: "content_paste",
            kind: "personal",
            pageId: "applications"
        },
        {
            id: "hypridle",
            unit: "miko-hypridle.service",
            title: I18n.tr("Блокировка и сон"),
            technicalName: "miko-hypridle",
            subtitle: I18n.tr("Бездействие, блокировка и питание"),
            icon: "bedtime",
            kind: "personal",
            pageId: "system"
        }
    ]

    readonly property var integrationCatalog: [
        {
            id: "throne",
            packageName: "throne",
            title: "Throne",
            subtitle: I18n.tr("TUN, маршрутизация и защищённое соединение"),
            icon: "vpn_lock",
            pageId: "network",
            source: "AUR"
        },
        {
            id: "smartmontools",
            packageName: "smartmontools",
            title: "SMART",
            subtitle: I18n.tr("Здоровье накопителей и ранние предупреждения"),
            icon: "hard_drive",
            pageId: "system",
            source: "pacman"
        },
        {
            id: "ddcutil",
            packageName: "ddcutil",
            title: "DDC/CI",
            subtitle: I18n.tr("Аппаратная яркость внешних мониторов"),
            icon: "brightness_6",
            pageId: "displays",
            source: "pacman"
        },
        {
            id: "kdeconnect",
            packageName: "kdeconnect",
            title: "KDE Connect",
            subtitle: I18n.tr("Телефон, файлы и общий буфер"),
            icon: "phonelink",
            pageId: "devices",
            source: "pacman"
        },
        {
            id: "easyeffects",
            packageName: "easyeffects",
            title: "EasyEffects",
            subtitle: I18n.tr("Обработка и профили звука"),
            icon: "graphic_eq",
            pageId: "sound",
            source: "pacman"
        },
        {
            id: "syncthing",
            packageName: "syncthing",
            title: "Syncthing",
            subtitle: I18n.tr("Прямая синхронизация папок"),
            icon: "sync",
            pageId: "",
            source: "pacman"
        },
        {
            id: "openrgb",
            packageName: "openrgb",
            title: "OpenRGB",
            subtitle: I18n.tr("Подсветка подключённых устройств"),
            icon: "lightbulb",
            pageId: "",
            source: "pacman"
        },
        {
            id: "tailscale",
            packageName: "tailscale",
            title: "Tailscale",
            subtitle: I18n.tr("Приватная сеть между устройствами"),
            icon: "vpn_lock",
            pageId: "network",
            source: "pacman"
        }
    ]

    onActiveChanged: {
        if (!active)
            return;
        if (!initialized)
            ensureLoaded();
        else
            refresh();
    }

    function ensureLoaded() {
        if (initialized)
            return;
        initialized = true;
        refresh();
    }

    function refresh() {
        if (!capabilities.ready) {
            lastChecked = I18n.tr("определяем возможности");
            return;
        }
        if (capabilityAvailable("systemctl")) {
            if (!serviceStatusRead.running)
                serviceStatusRead.running = true;
        } else {
            markServicesUnavailable();
        }
        if (capabilities.archBased && capabilityAvailable("pacman")) {
            if (!integrationDiscovery.running)
                integrationDiscovery.running = true;
        } else {
            markIntegrationsUnavailable();
        }
    }

    function toggleEditingPins() {
        editingPins = !editingPins;
    }

    function toggleAllComponents() {
        showAllComponents = !showAllComponents;
    }

    function toggleCatalog() {
        showCatalog = !showCatalog;
    }

    function restartUserService(unit) {
        if (serviceAction.running || !unit)
            return;
        if (rejectAction(
                I18n.tr("Перезапуск службы"), ["systemctl"]))
            return;
        actionMessage = I18n.tr("Перезапускаю ") + unit + "…";
        serviceAction.exec(["systemctl", "--user", "restart", unit]);
    }

    function openServiceJournal(unit) {
        if (!unit || !/^[A-Za-z0-9@_.:+-]+\.service$/.test(unit))
            return;
        if (rejectAction(
                I18n.tr("Просмотр журнала"), ["kitty", "journalctl"]))
            return;
        Quickshell.execDetached([
            "kitty", "-e", "journalctl", "--user", "-u", unit, "-f"
        ]);
    }

    function installIntegration(component) {
        const packageName = component && component.packageName
            ? component.packageName : "";
        if (!packageName || !/^[A-Za-z0-9@._+:-]+$/.test(packageName))
            return;
        if (!capabilities.archBased) {
            actionMessage =
                I18n.tr("Установка интеграций через pacman недоступна ")
                + I18n.tr("в этой системе");
            serviceMessageTimer.restart();
            return;
        }
        const aur = String(component.source).toLowerCase() === "aur";
        const helper = capabilities.has("paru") ? "paru"
            : capabilities.has("yay") ? "yay" : "";
        if (aur && helper === "") {
            actionMessage = I18n.tr("Для AUR-интеграции нужен paru или yay");
            serviceMessageTimer.restart();
            return;
        }
        if (rejectAction(I18n.tr("Установка интеграции"), aur
                ? ["kitty", helper] : ["kitty", "pacman", "pkexec"]))
            return;
        const installCommand = aur
            ? helper + " -S --needed -- " + packageName
            : "pkexec pacman -S --needed -- " + packageName;
        Quickshell.execDetached([
            "kitty", "-e", "bash", "-lc",
            installCommand + I18n.tr("; echo; read -rp 'Enter для закрытия'")
        ]);
    }

    function runDiagnostics() {
        if (desktopDiagnostic.running)
            return;
        if (!capabilities.ready
                || !capabilityAvailable("miko-check")) {
            diagnosticHealthy = false;
            diagnosticDetails = "";
            diagnosticSummary = capabilities.ready
                ? I18n.tr("Проверка недоступна: miko-check не установлен")
                : I18n.tr("Проверка недоступна: определяем возможности");
            return;
        }
        diagnosticDetails = "";
        diagnosticSummary = I18n.tr("Проверяю оболочку, службы и порталы…");
        desktopDiagnostic.running = true;
    }

    function serviceActive(unit) {
        const state = serviceStates[unit];
        return state !== undefined && state.active === "active";
    }

    function activeServiceCount() {
        return Object.values(serviceStates).filter(
            item => item.active === "active"
        ).length;
    }

    function allServiceComponents() {
        const knownUnits = knownServiceComponents.map(item => item.unit);
        const discovered = discoveredServiceUnits
            .filter(unit => !knownUnits.includes(unit))
            .map(unit => {
                const base = unit.replace(/^miko-/, "")
                    .replace(/\.service$/, "");
                const words = base.split("-").map(word =>
                    word.length > 0
                        ? word[0].toUpperCase() + word.slice(1) : word
                );
                return {
                    id: "unit-" + base,
                    unit,
                    title: words.join(" "),
                    technicalName: unit,
                    subtitle: I18n.tr("Автоматически найденный компонент Miko"),
                    icon: "extension",
                    kind: "discovered",
                    pageId: ""
                };
            });
        return knownServiceComponents.concat(discovered);
    }

    function allComponentsList() {
        const integrations = integrationCatalog.map(item => ({
            id: item.id,
            unit: "",
            title: item.title,
            technicalName: item.packageName,
            subtitle: item.subtitle,
            icon: item.icon,
            kind: "integration",
            pageId: item.pageId
        }));
        return allServiceComponents().concat(integrations);
    }

    function componentById(id) {
        const component = allComponentsList().find(item => item.id === id);
        return component === undefined ? null : component;
    }

    function componentInstalled(component) {
        if (!component)
            return false;
        if (component.kind === "integration") {
            const state = integrationStates[component.id];
            return state !== undefined && state.installed === true;
        }
        return serviceStates[component.unit] !== undefined;
    }

    function componentActive(component) {
        if (!component)
            return false;
        if (component.kind === "integration") {
            if (component.id === "kdeconnect")
                return kdeConnect.reachable;
            if (component.id === "easyeffects")
                return easyEffects.active;
            const state = integrationStates[component.id];
            return state !== undefined && state.installed === true;
        }
        return serviceActive(component.unit);
    }

    function componentStateText(component) {
        if (!component)
            return I18n.tr("Недоступно");
        if (component.kind === "integration") {
            const integrationState = integrationStates[component.id];
            if (integrationState !== undefined
                    && integrationState.unavailable === true)
                return I18n.tr("Каталог пакетов недоступен");
        } else {
            const serviceState = serviceStates[component.unit];
            if (serviceState !== undefined
                    && serviceState.unavailable === true)
                return I18n.tr("systemctl недоступен");
        }
        if (!componentInstalled(component))
            return I18n.tr("Не установлено");
        if (component.kind === "integration") {
            if (component.id === "kdeconnect")
                return kdeConnect.reachable
                    ? I18n.tr("Телефон на связи") : I18n.tr("Установлено");
            if (component.id === "easyeffects")
                return easyEffects.active
                    ? I18n.tr("Обработка активна") : I18n.tr("Установлено");
            return I18n.tr("Установлено");
        }
        return componentActive(component) ? I18n.tr("Работает") : I18n.tr("Остановлено");
    }

    function togglePin(id) {
        const next = pinnedComponentIds.includes(id)
            ? pinnedComponentIds.filter(item => item !== id)
            : pinnedComponentIds.concat([id]);
        pinnedComponentIds = next;
        servicePreferences.setText(JSON.stringify({ pinned: next }));
    }

    function installedIntegrationCount() {
        return integrationCatalog.filter(
            item => {
                const state = integrationStates[item.id];
                return state !== undefined && state.installed === true;
            }
        ).length;
    }

    property Connections capabilityMonitor: Connections {
        target: root.capabilities

        function onReadyChanged() {
            if (root.capabilities.ready && root.active)
                root.refresh();
        }
    }

    property FileView preferences: FileView {
        id: servicePreferences
        path: root.environment.servicesState

        onLoaded: {
            try {
                const saved = JSON.parse(servicePreferences.text());
                if (Array.isArray(saved.pinned))
                    root.pinnedComponentIds = saved.pinned;
            } catch (error) {
                console.warn(
                    "[Control Center] Invalid service preferences:", error
                );
            }
        }
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound) {
                servicePreferences.setText(JSON.stringify({
                    pinned: root.pinnedComponentIds
                }));
            }
        }
    }

    property Process statusProcess: Process {
        id: serviceStatusRead
        command: ["sh", "-c", `
            known_units="\
                miko-quickshell.service \
                pipewire.service \
                wireplumber.service \
                miko-clipboard-image.service \
                miko-clipboard-text.service \
                miko-hypridle.service \
                xdg-desktop-portal.service \
                xdg-desktop-portal-hyprland.service"
            discovered_units=$(systemctl --user list-unit-files \
                --type=service --no-legend --no-pager \
                'miko-*.service' 2>/dev/null | awk '{print $1}')
            printf "CHECKED|%s\\n" "$(date +%s)"
            for unit in $known_units $discovered_units
            do
                active=$(systemctl --user is-active "$unit" \
                    2>/dev/null || true)
                enabled=$(systemctl --user is-enabled "$unit" \
                    2>/dev/null || true)
                description=$(systemctl --user show "$unit" \
                    --property=Description --value 2>/dev/null || true)
                printf "UNIT|%s|%s|%s|%s\\n" \
                    "$unit" "$active" "$enabled" "$description"
            done
        `]
        stdout: StdioCollector {
            onStreamFinished: {
                const next = {};
                const discovered = [];
                for (const row of text.trim().split("\n")) {
                    const fields = row.split("|");
                    if (fields[0] === "CHECKED") {
                        const checked = new Date(Number(fields[1]) * 1000);
                        root.lastChecked = checked.toLocaleTimeString(
                            Qt.locale(), Locale.ShortFormat
                        );
                    } else if (fields[0] === "UNIT") {
                        const unit = fields[1];
                        if (!unit)
                            continue;
                        next[unit] = {
                            active: fields[2],
                            enabled: fields[3],
                            description: fields.slice(4).join("|")
                        };
                        if (unit.startsWith("miko-"))
                            discovered.push(unit);
                    }
                }
                root.serviceStates = next;
                root.discoveredServiceUnits =
                    Array.from(new Set(discovered));
            }
        }
    }

    property Process discoveryProcess: Process {
        id: integrationDiscovery
        command: ["sh", "-c", `
            printf "CHECKED|%s\\n" "$(date +%s)"
            for spec in \
                "throne|throne" \
                "smartmontools|smartmontools" \
                "ddcutil|ddcutil" \
                "kdeconnect|kdeconnect" \
                "easyeffects|easyeffects" \
                "syncthing|syncthing" \
                "openrgb|openrgb" \
                "tailscale|tailscale"
            do
                id=\${spec%%|*}
                package=\${spec#*|}
                if pacman -Q "$package" >/dev/null 2>&1; then
                    version=$(pacman -Q "$package" \
                        2>/dev/null | awk '{print $2}')
                    printf "INTEGRATION|%s|1|%s\\n" "$id" "$version"
                else
                    printf "INTEGRATION|%s|0|\\n" "$id"
                fi
            done
        `]
        stdout: StdioCollector {
            onStreamFinished: {
                const next = {};
                for (const row of text.trim().split("\n")) {
                    const fields = row.split("|");
                    if (fields[0] === "INTEGRATION" && fields[1]) {
                        next[fields[1]] = {
                            installed: fields[2] === "1",
                            version: fields[3] === undefined ? "" : fields[3]
                        };
                    }
                }
                root.integrationStates = next;
            }
        }
    }

    property Process actionRunner: Process {
        id: serviceAction
        onExited: (exitCode, exitStatus) => {
            root.actionMessage = exitCode === 0
                ? I18n.tr("Служба успешно перезапущена")
                : I18n.tr("Не удалось перезапустить службу");
            serviceMessageTimer.restart();
            root.refresh();
        }
    }

    property Process diagnosticRunner: Process {
        id: desktopDiagnostic
        command: ["miko-check", "desktop"]
        stdout: StdioCollector {
            onStreamFinished: root.diagnosticDetails = text.trim()
        }
        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim() !== "")
                    root.diagnosticDetails += "\n" + text.trim();
            }
        }
        onExited: (exitCode, exitStatus) => {
            root.diagnosticHealthy = exitCode === 0;
            root.diagnosticSummary = exitCode === 0
                ? I18n.tr("Проверка завершена — критичных проблем нет")
                : I18n.tr("Проверка нашла компоненты, требующие внимания");
        }
    }

    property Timer messageTimer: Timer {
        id: serviceMessageTimer
        interval: 3200
        onTriggered: root.actionMessage = ""
    }
}
