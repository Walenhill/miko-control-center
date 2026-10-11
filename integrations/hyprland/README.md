# Quickshell layer blur · Hyprland Lua

## Русский

Обычные окна и layer-shell панели используют разные правила compositor.
Старые правила ii задавали `ignore_alpha = 0.79`, а для popup/media — `1`.
Первое выключает блюр при прозрачности от 21% и режет сглаженные края;
второе исключает практически все пиксели из размытия.

`quickshell-materials.lua` задаёт единые правила для `quickshell:*`: нативный
блюр, `xray = false` и порог `ignore_alpha = 0.19`. Нулевой порог захватывает
полупрозрачную Qt-тень и создаёт размытую кайму вне скруглённой поверхности.
Порог 0.19 исключает внешнюю тень, но сохраняет блюр при непрозрачности
поверхности 0.20 — максимальной ручной прозрачности центра 80%. Обои,
угловые маски, полноэкранный canvas виджетов и технические слои захвата экрана
исключены. Рисунок и размытие обложек музыкальных карточек не затрагиваются.

Это **не универсальный установщик**. Файл предназначен для Lua-конфигурации
Hyprland 0.56+ с пространствами имён ii. Сохрани конфиг, затем добавь эти правила
в пользовательские layer rules, загружаемые **после** правил оболочки. Не добавляй
вторую копию, если правила с именами `miko-quickshell-*` уже установлены.

```sh
luac -p ~/.config/hypr/custom/rules.lua
hyprctl reload
hyprctl configerrors
hyprctl layers
```

Проверяй свой реальный путь и пространство имён. Перезапуск Quickshell не нужен.
Файл не меняет цвета, прозрачность, `enabled`, `size`, `passes`, округление или
тени. Сила размытия остаётся общей с центром управления. Непрозрачные кнопки
и карточки не станут стеклянными только от layer rule.

Проверено на Hyprland 0.56.2: layer с 80% прозрачностью, скруглением и той же
Qt-тенью, что у оболочки, над шахматным фоном. Внутри поверхности сохраняется
блюр, снаружи шахматный фон остаётся резким, тень остаётся обычной тенью.
Ручная проверка: `qs -p tests/layer-blur-probe.qml` из корня репозитория.
Тест не меняет настройки и завершается через 120 секунд; это только QA-overlay.

## English

Window and layer-shell blur use separate compositor rules. The old ii alpha
cutoff of `0.79` skips blur at 21% transparency or more and crops antialiased
edges; popup/media cutoffs of `1` effectively suppress blur entirely.

Load `quickshell-materials.lua` after the shell's default layer rules in a
Hyprland 0.56+ Lua configuration. Back up existing rules and do not duplicate
the named `miko-quickshell-*` rules. Validate syntax, reload Hyprland and check
`configerrors`/`layers` as shown above; no Quickshell restart is needed.

This policy uses native blur for material surfaces, includes the content behind
them rather than xray wallpaper-only blur, and excludes technical canvases.
The 0.19 alpha threshold skips the outer Qt shadow without disabling blur for
material alpha 0.20 (80% transparency). A zero threshold creates a blurred halo
outside rounded surfaces. The opt-in `tests/layer-blur-probe.qml` reproduces
the shadow and 80% translucent material over a checkerboard for visual QA.
It preserves global blur strength and all application/material preferences.
It does not make opaque controls transparent or change album-art image effects.

Reference: [Hyprland layer-rule documentation](https://wiki.hypr.land/configuring/core/rules/layer-rules/).
