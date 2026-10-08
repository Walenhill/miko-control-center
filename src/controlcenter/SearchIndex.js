.pragma library

// Search metadata is deliberately bilingual and independent of UI locale.
var aliases = {
    "network:overview": "интернет сеть маршрут шлюз днс вайфай вай фай internet network gateway dns wifi wi-fi ethernet ip",
    "network:throne": "впн прокси туннель трон vpn proxy tunnel throne tun",
    "network:ports": "порты порт фаервол файрвол брандмауэр port ports firewall ufw tcp udp sockets",
    "sound:master": "звук громкость микрофон наушники колонки sound volume microphone headphones speaker mute audio",
    "sound:mixer": "микшер громкость приложений mixer app volume streams",
    "sound:scenes": "сцены звука профиль audio scenes profiles",
    "displays:topology": "мониторы экраны расположение display monitor screen layout position",
    "displays:modes": "герцовка герцы частота обновления разрешение масштаб поворот refresh rate hz frequency resolution scaling orientation",
    "displays:comfort": "ночной свет яркость температура night light brightness temperature blue light",
    "devices:phone": "телефон файлы буфер обмена phone android files clipboard transfer",
    "devices:connections": "блютуз блютус bluetooth pairing connection",
    "devices:usb": "юсб устройства usb devices hardware",
    "appearance:wallpaper": "обои тема палитра цвета акцент светлая темная прозрачность wallpaper theme palette colors accent light dark transparency",
    "appearance:bar": "панель положение форма рабочие столы автоскрытие bar panel taskbar workspaces autohide",
    "appearance:interface": "шрифт док интерфейс анимации font dock interface animations motion",
    "appearance:notifications": "уведомления длительность расположение notifications popup timeout position",
    "appearance:lock": "блокировка экран пароль lock screen password hyprlock",
    "system:performance": "процессор память озу частота питание производительность экономия processor cpu ram memory frequency power performance battery saver",
    "system:telemetry": "температура сенсоры ошибки служб temperatures sensors failed services",
    "system:storage": "диски хранилище очистка корзина кэш мусор storage disk cleanup trash cache journal orphan",
    "system:snapshots": "снимки резервная копия восстановление откат snapshots backup restore rollback config",
    "system:updates": "обновления пакеты обновить updates packages upgrade pacman paru yay",
    "system:watch": "здоровье проблемы диагностика watch health issues diagnostics",
    "services:quickshell": "оболочка панель перезапуск shell panel restart quickshell",
    "services:pipewire": "служба звука sound service pipewire wireplumber",
    "services:kdeconnect": "связь телефон kde connect phone connection",
    "services:integrations": "интеграции добавить возможности integrations add features",
    "applications:processes": "процессы приложения ресурсы завершить processes applications resources stop kill pid",
    "applications:autostart": "автозапуск запуск startup autostart boot",
    "applications:notifications": "не беспокоить тихий режим do not disturb silent notifications",
    "applications:privacy": "приватность запись захват камера microphone screen capture privacy camera"
};

function normalize(value) {
    return String(value || "").toLowerCase().replace(/ё/g, "е")
        .replace(/[-_]/g, " ").replace(/\s+/g, " ").trim();
}

function routeKey(item) {
    return item.pageId + ":" + (item.target || item.section || item.componentId || "");
}

function search(items, query, pages) {
    var text = normalize(query);
    var terms = text.split(" ").filter(Boolean);
    var categories = {};
    pages.forEach(function(page) { categories[page.id] = page.title; });
    return items.map(function(item, index) {
        var category = categories[item.pageId] || "";
        var title = normalize(item.title);
        var haystack = normalize([item.title, item.subtitle, item.keywords,
            aliases[routeKey(item)] || "", category].join(" "));
        if (!terms.every(function(term) { return haystack.includes(term); })) return null;
        var score = title === text ? 100 : title.startsWith(text) ? 60
            : title.includes(text) ? 40 : 10;
        return Object.assign({}, item, {category: category, searchScore: score, searchOrder: index});
    }).filter(Boolean).sort(function(a, b) {
        return b.searchScore - a.searchScore || a.searchOrder - b.searchOrder;
    });
}
