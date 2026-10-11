import QtQuick

QtObject {
    readonly property var pages: [
        { id: "overview", title: I18n.tr("Обзор"), icon: "space_dashboard", subtitle: I18n.tr("Главное состояние системы") },
        { id: "network", title: I18n.tr("Сеть"), icon: "lan", subtitle: I18n.tr("Интернет, Wi-Fi, VPN и локальная сеть") },
        { id: "sound", title: I18n.tr("Звук"), icon: "volume_up", subtitle: I18n.tr("Устройства, приложения и микрофоны") },
        { id: "displays", title: I18n.tr("Экраны"), icon: "desktop_windows", subtitle: I18n.tr("Мониторы, яркость и ночной свет") },
        { id: "devices", title: I18n.tr("Устройства"), icon: "devices", subtitle: I18n.tr("Телефон и подключённая техника") },
        { id: "appearance", title: I18n.tr("Оформление"), icon: "palette", subtitle: I18n.tr("Обои, панель и интерфейс") },
        { id: "system", title: I18n.tr("Система"), icon: "memory", subtitle: I18n.tr("Ресурсы, диски, питание и обновления") },
        { id: "services", title: I18n.tr("Службы"), icon: "settings_suggest", subtitle: I18n.tr("Фоновые компоненты и диагностика") },
        { id: "applications", title: I18n.tr("Приложения"), icon: "apps", subtitle: I18n.tr("Процессы, автозапуск и уведомления") }
    ]
    readonly property string defaultPageId: pages.length > 0 ? pages[0].id : ""

    readonly property var searchable: [
        { title: I18n.tr("Интернет и VPN"), subtitle: I18n.tr("Ethernet, Wi-Fi, туннели"), icon: "lan", pageId: "network", section: "overview", keywords: I18n.tr("маршрут gateway dns ip соединение") },
        { title: "Throne", subtitle: I18n.tr("Туннель, профиль и живой трафик"), icon: "vpn_lock", pageId: "network", section: "throne", keywords: "vpn proxy tun socks hysteria xray" },
        { title: I18n.tr("Порты и firewall"), subtitle: I18n.tr("Сокеты, процессы, TCP и UDP"), icon: "security", pageId: "network", section: "ports", keywords: I18n.tr("ufw открыть закрыть listener socket") },
        { title: "Bluetooth", subtitle: I18n.tr("Адаптер и устройства"), icon: "bluetooth", pageId: "devices", target: "connections", keywords: I18n.tr("гарнитура мышь подключение") },
        { title: I18n.tr("Выход звука"), subtitle: I18n.tr("Наушники, HDMI и встроенный звук"), icon: "headphones", pageId: "sound", target: "master", keywords: I18n.tr("громкость mute sink воспроизведение") },
        { title: I18n.tr("Микрофон"), subtitle: I18n.tr("Источник и уровень записи"), icon: "mic", pageId: "sound", target: "master", keywords: I18n.tr("input source запись mute") },
        { title: I18n.tr("Громкость приложений"), subtitle: I18n.tr("Микшер потоков PipeWire"), icon: "graphic_eq", pageId: "sound", target: "mixer", keywords: I18n.tr("streams приложения routing") },
        { title: I18n.tr("Звуковые сцены"), subtitle: I18n.tr("Готовые режимы громкости"), icon: "tune", pageId: "sound", target: "scenes", keywords: I18n.tr("тихо ночь игра") },
        { title: I18n.tr("Мониторы"), subtitle: I18n.tr("Расположение и рабочее пространство"), icon: "desktop_windows", pageId: "displays", target: "topology", keywords: I18n.tr("экран дисплей позиция") },
        { title: I18n.tr("Разрешение и герцовка"), subtitle: I18n.tr("Режим, частота и масштаб"), icon: "aspect_ratio", pageId: "displays", target: "modes", keywords: "144 hz scale orientation" },
        { title: I18n.tr("Ночной свет"), subtitle: I18n.tr("Температура и расписание"), icon: "bedtime", pageId: "displays", target: "comfort", keywords: I18n.tr("яркость blue light ddc") },
        { title: I18n.tr("Телефон"), subtitle: I18n.tr("KDE Connect, файлы и буфер"), icon: "smartphone", pageId: "devices", target: "phone", keywords: I18n.tr("android clipboard ping ring отправить") },
        { title: I18n.tr("USB-устройства"), subtitle: I18n.tr("Подключённое оборудование"), icon: "usb", pageId: "devices", target: "usb", keywords: I18n.tr("гарнитура ресивер lsusb") },
        { title: I18n.tr("Обои и цвета"), subtitle: I18n.tr("Material You и палитра"), icon: "wallpaper", pageId: "appearance", section: "wallpaper", keywords: I18n.tr("matugen тема светлая темная прозрачность") },
        { title: I18n.tr("Прозрачность и блюр"), subtitle: "Hyprland · miko-theme", icon: "blur_on", pageId: "appearance", section: "materials", keywords: "opacity alpha blur glass calm neon" },
        { title: I18n.tr("Виджеты рабочего стола"), subtitle: I18n.tr("Часы, погода и расположение"), icon: "schedule", pageId: "appearance", section: "widgets", keywords: "clock weather cookie digital quote widgets" },
        { title: I18n.tr("Шрифты и типографика"), subtitle: I18n.tr("Роли шрифтов и предпросмотр"), icon: "text_fields", pageId: "appearance", section: "fonts", keywords: "font typography preview" },
        { title: I18n.tr("Профили оформления"), subtitle: I18n.tr("Сохранение и перенос внешнего вида"), icon: "palette", pageId: "appearance", section: "profiles", keywords: "appearance profiles json import export" },
        { title: I18n.tr("Панель и экран"), subtitle: I18n.tr("Положение, форма и элементы"), icon: "dock_to_bottom", pageId: "appearance", section: "bar", keywords: I18n.tr("dock panel workspaces автоскрытие") },
        { title: I18n.tr("Интерфейс"), subtitle: I18n.tr("Шрифт, overview и поведение"), icon: "widgets", pageId: "appearance", section: "interface", keywords: I18n.tr("font osd масштаб") },
        { title: I18n.tr("Уведомления"), subtitle: I18n.tr("Время и расположение карточек"), icon: "notifications", pageId: "appearance", section: "notifications", keywords: "popup timeout monitor" },
        { title: I18n.tr("Экран блокировки"), subtitle: I18n.tr("Безопасность и фон"), icon: "lock", pageId: "appearance", section: "lock", keywords: I18n.tr("hyprlock пароль blur") },
        { title: I18n.tr("Производительность"), subtitle: I18n.tr("CPU, память и профиль питания"), icon: "speed", pageId: "system", target: "performance", keywords: I18n.tr("ram swap частота power profile") },
        { title: I18n.tr("Температуры и службы"), subtitle: I18n.tr("Сенсоры и failed units"), icon: "device_thermostat", pageId: "system", target: "telemetry", keywords: I18n.tr("cpu gpu sensors systemd ошибка") },
        { title: I18n.tr("Хранилище"), subtitle: I18n.tr("Диски, разделы и свободное место"), icon: "hard_drive", pageId: "system", target: "storage", keywords: "smart cache trash journal orphan" },
        { title: "Snapshots", subtitle: I18n.tr("Точки состояния настроек"), icon: "restore", pageId: "system", target: "snapshots", keywords: I18n.tr("backup restore конфиг откат") },
        { title: I18n.tr("Обновления"), subtitle: I18n.tr("Пакеты системы и AUR"), icon: "system_update", pageId: "system", target: "updates", keywords: "pacman paru yay upgrade" },
        { title: "Miko Watch", subtitle: I18n.tr("События здоровья системы"), icon: "visibility", pageId: "system", target: "watch", keywords: I18n.tr("проблемы диагностика ignore") },
        { title: "Quickshell", subtitle: I18n.tr("Состояние и перезапуск оболочки"), icon: "deployed_code", pageId: "services", componentId: "quickshell", keywords: I18n.tr("панель shell") },
        { title: "PipeWire", subtitle: I18n.tr("Служба звука"), icon: "audio_file", pageId: "services", componentId: "pipewire", keywords: "wireplumber systemctl" },
        { title: "KDE Connect", subtitle: I18n.tr("Связь с телефоном"), icon: "phonelink", pageId: "services", componentId: "kdeconnect", keywords: "android lan" },
        { title: I18n.tr("Интеграции"), subtitle: I18n.tr("Необязательные возможности системы"), icon: "extension", pageId: "services", target: "integrations", keywords: "install easyeffects throne smart ddc" },
        { title: I18n.tr("Запущенные приложения"), subtitle: I18n.tr("Процессы и потребление ресурсов"), icon: "apps", pageId: "applications", target: "processes", keywords: "cpu ram pid stop" },
        { title: I18n.tr("Автозапуск"), subtitle: I18n.tr("Что запускается вместе с системой"), icon: "start", pageId: "applications", target: "autostart", keywords: "desktop startup" },
        { title: I18n.tr("Не беспокоить"), subtitle: I18n.tr("Уведомления и исключения"), icon: "do_not_disturb_on", pageId: "applications", target: "notifications", keywords: "timeout popup silent" },
        { title: I18n.tr("Микрофон и экран"), subtitle: I18n.tr("Активность приложений"), icon: "privacy_tip", pageId: "applications", target: "privacy", keywords: "capture portal privacy" }
    ]

    function tabForTarget(pageId, target) {
        const tabs = {
            sound: {master: "devices", mixer: "mixer", scenes: "mixer", tools: "effects", effects: "effects", balance: "effects"},
            displays: {topology: "topology", modes: "modes", comfort: "comfort"},
            devices: {phone: "phone", connections: "connections", bluetooth: "connections", usb: "usb"},
            system: {performance: "performance", watch: "performance", storage: "storage", snapshots: "storage", updates: "updates", telemetry: "updates"},
            services: {diagnostics: "diagnostics", all: "all", integrations: "components"},
            applications: {processes: "processes", autostart: "autostart", notifications: "notifications", privacy: "notifications"}
        };
        return tabs[pageId] ? tabs[pageId][target] || "" : "";
    }

    function indexOf(pageId) {
        return pages.findIndex(item => item.id === pageId);
    }

    function pageById(pageId) {
        const index = indexOf(String(pageId));
        return index >= 0 ? pages[index] : null;
    }

    function pageAt(index) {
        if (pages.length === 0)
            return null;
        const requested = Number(index);
        const safeIndex = Number.isFinite(requested)
            ? Math.max(0, Math.min(pages.length - 1, Math.floor(requested)))
            : 0;
        return pages[safeIndex];
    }

    function idAt(index) {
        const item = pageAt(index);
        return item ? item.id : defaultPageId;
    }

}
