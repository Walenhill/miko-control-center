import QtQuick

QtObject {
    readonly property var pages: [
        { id: "overview", title: "Обзор", icon: "space_dashboard", subtitle: "Главное состояние системы" },
        { id: "network", title: "Сеть", icon: "lan", subtitle: "Интернет, Wi-Fi, VPN и локальная сеть" },
        { id: "sound", title: "Звук", icon: "volume_up", subtitle: "Устройства, приложения и микрофоны" },
        { id: "displays", title: "Экраны", icon: "desktop_windows", subtitle: "Мониторы, яркость и ночной свет" },
        { id: "devices", title: "Устройства", icon: "devices", subtitle: "Телефон и подключённая техника" },
        { id: "appearance", title: "Оформление", icon: "palette", subtitle: "Обои, панель и интерфейс" },
        { id: "system", title: "Система", icon: "memory", subtitle: "Ресурсы, диски, питание и обновления" },
        { id: "services", title: "Службы", icon: "settings_suggest", subtitle: "Фоновые компоненты и диагностика" },
        { id: "applications", title: "Приложения", icon: "apps", subtitle: "Процессы, автозапуск и уведомления" }
    ]
    readonly property string defaultPageId: pages.length > 0 ? pages[0].id : ""

    readonly property var searchable: [
        { title: "Интернет и VPN", subtitle: "Ethernet, Wi-Fi, туннели", icon: "lan", pageId: "network", section: "overview", keywords: "маршрут gateway dns ip соединение" },
        { title: "Throne", subtitle: "Туннель, профиль и живой трафик", icon: "vpn_lock", pageId: "network", section: "throne", keywords: "vpn proxy tun socks hysteria xray" },
        { title: "Порты и firewall", subtitle: "Сокеты, процессы, TCP и UDP", icon: "security", pageId: "network", section: "ports", keywords: "ufw открыть закрыть listener socket" },
        { title: "Bluetooth", subtitle: "Адаптер и устройства", icon: "bluetooth", pageId: "devices", target: "connections", keywords: "гарнитура мышь подключение" },
        { title: "Выход звука", subtitle: "Наушники, HDMI и встроенный звук", icon: "headphones", pageId: "sound", target: "master", keywords: "громкость mute sink воспроизведение" },
        { title: "Микрофон", subtitle: "Источник и уровень записи", icon: "mic", pageId: "sound", target: "master", keywords: "input source запись mute" },
        { title: "Громкость приложений", subtitle: "Микшер потоков PipeWire", icon: "graphic_eq", pageId: "sound", target: "mixer", keywords: "streams приложения routing" },
        { title: "Звуковые сцены", subtitle: "Готовые режимы громкости", icon: "tune", pageId: "sound", target: "scenes", keywords: "тихо ночь игра" },
        { title: "Мониторы", subtitle: "Расположение и рабочее пространство", icon: "desktop_windows", pageId: "displays", target: "topology", keywords: "экран дисплей позиция" },
        { title: "Разрешение и герцовка", subtitle: "Режим, частота и масштаб", icon: "aspect_ratio", pageId: "displays", target: "modes", keywords: "144 hz scale orientation" },
        { title: "Ночной свет", subtitle: "Температура и расписание", icon: "bedtime", pageId: "displays", target: "comfort", keywords: "яркость blue light ddc" },
        { title: "Телефон", subtitle: "KDE Connect, файлы и буфер", icon: "smartphone", pageId: "devices", target: "phone", keywords: "android clipboard ping ring отправить" },
        { title: "USB-устройства", subtitle: "Подключённое оборудование", icon: "usb", pageId: "devices", target: "usb", keywords: "гарнитура ресивер lsusb" },
        { title: "Обои и цвета", subtitle: "Material You и палитра", icon: "wallpaper", pageId: "appearance", section: "wallpaper", keywords: "matugen тема светлая темная прозрачность" },
        { title: "Панель и экран", subtitle: "Положение, форма и элементы", icon: "dock_to_bottom", pageId: "appearance", section: "bar", keywords: "dock panel workspaces автоскрытие" },
        { title: "Интерфейс", subtitle: "Шрифт, overview и поведение", icon: "widgets", pageId: "appearance", section: "interface", keywords: "font osd масштаб" },
        { title: "Уведомления", subtitle: "Время и расположение карточек", icon: "notifications", pageId: "appearance", section: "notifications", keywords: "popup timeout monitor" },
        { title: "Экран блокировки", subtitle: "Безопасность и фон", icon: "lock", pageId: "appearance", section: "lock", keywords: "hyprlock пароль blur" },
        { title: "Производительность", subtitle: "CPU, память и профиль питания", icon: "speed", pageId: "system", target: "performance", keywords: "ram swap частота power profile" },
        { title: "Температуры и службы", subtitle: "Сенсоры и failed units", icon: "device_thermostat", pageId: "system", target: "telemetry", keywords: "cpu gpu sensors systemd ошибка" },
        { title: "Хранилище", subtitle: "Диски, разделы и свободное место", icon: "hard_drive", pageId: "system", target: "storage", keywords: "smart cache trash journal orphan" },
        { title: "Snapshots", subtitle: "Точки состояния настроек", icon: "restore", pageId: "system", target: "snapshots", keywords: "backup restore конфиг откат" },
        { title: "Обновления", subtitle: "Пакеты системы и AUR", icon: "system_update", pageId: "system", target: "updates", keywords: "pacman paru yay upgrade" },
        { title: "Miko Watch", subtitle: "События здоровья системы", icon: "visibility", pageId: "system", target: "watch", keywords: "проблемы диагностика ignore" },
        { title: "Quickshell", subtitle: "Состояние и перезапуск оболочки", icon: "deployed_code", pageId: "services", componentId: "quickshell", keywords: "панель shell" },
        { title: "PipeWire", subtitle: "Служба звука", icon: "audio_file", pageId: "services", componentId: "pipewire", keywords: "wireplumber systemctl" },
        { title: "KDE Connect", subtitle: "Связь с телефоном", icon: "phonelink", pageId: "services", componentId: "kdeconnect", keywords: "android lan" },
        { title: "Интеграции", subtitle: "Необязательные возможности системы", icon: "extension", pageId: "services", target: "integrations", keywords: "install easyeffects throne smart ddc" },
        { title: "Запущенные приложения", subtitle: "Процессы и потребление ресурсов", icon: "apps", pageId: "applications", target: "processes", keywords: "cpu ram pid stop" },
        { title: "Автозапуск", subtitle: "Что запускается вместе с системой", icon: "start", pageId: "applications", target: "autostart", keywords: "desktop startup" },
        { title: "Не беспокоить", subtitle: "Уведомления и исключения", icon: "do_not_disturb_on", pageId: "applications", target: "notifications", keywords: "timeout popup silent" },
        { title: "Микрофон и экран", subtitle: "Активность приложений", icon: "privacy_tip", pageId: "applications", target: "privacy", keywords: "capture portal privacy" }
    ]

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
