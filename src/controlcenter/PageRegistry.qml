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
        { title: "Интернет и VPN", subtitle: "Ethernet, Wi-Fi, туннели", icon: "lan", pageId: "network" },
        { title: "Bluetooth", subtitle: "Адаптер и устройства", icon: "bluetooth", pageId: "network" },
        { title: "Выход звука", subtitle: "Наушники, HDMI и встроенный звук", icon: "headphones", pageId: "sound" },
        { title: "Микрофон", subtitle: "Источник и уровень записи", icon: "mic", pageId: "sound" },
        { title: "Громкость приложений", subtitle: "PipeWire streams", icon: "graphic_eq", pageId: "sound" },
        { title: "Мониторы", subtitle: "Разрешение, частота и расположение", icon: "desktop_windows", pageId: "displays" },
        { title: "Ночной свет", subtitle: "Температура и расписание", icon: "bedtime", pageId: "displays" },
        { title: "Телефон", subtitle: "KDE Connect, файлы и буфер", icon: "smartphone", pageId: "devices" },
        { title: "Обои и цвета", subtitle: "Material You и палитра", icon: "wallpaper", pageId: "appearance" },
        { title: "Панель и интерфейс", subtitle: "Форма, положение и элементы", icon: "dock_to_bottom", pageId: "appearance" },
        { title: "Производительность", subtitle: "CPU, память и профиль питания", icon: "speed", pageId: "system" },
        { title: "Хранилище", subtitle: "Диски, разделы и свободное место", icon: "hard_drive", pageId: "system" },
        { title: "Обновления", subtitle: "Пакеты системы", icon: "system_update", pageId: "system" },
        { title: "Quickshell", subtitle: "Состояние и перезапуск оболочки", icon: "deployed_code", pageId: "services" },
        { title: "PipeWire", subtitle: "Служба звука", icon: "audio_file", pageId: "services" },
        { title: "KDE Connect", subtitle: "Связь с телефоном", icon: "phonelink", pageId: "services" },
        { title: "Запущенные приложения", subtitle: "Процессы и потребление ресурсов", icon: "apps", pageId: "applications" },
        { title: "Автозапуск", subtitle: "Что запускается вместе с системой", icon: "start", pageId: "applications" },
        { title: "Не беспокоить", subtitle: "Уведомления и исключения", icon: "do_not_disturb_on", pageId: "applications" },
        { title: "Микрофон и экран", subtitle: "Активность приложений", icon: "privacy_tip", pageId: "applications" }
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
