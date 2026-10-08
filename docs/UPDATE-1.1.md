# Silverstar 1.1 · development update

2026-10-08 · [English](#english) / [Русский](#русский)

## English

This update is published on `codex/silverstar-convenience-1.1`, based on
Cadence v1.0.0. It is **not a tagged release**: `VERSION` still identifies the
last release. The project remains experimental and requires a compatible
Quickshell / `illogical-impulse` runtime.

### What changed

- Navigation remembers each page's tab, nested editor and scroll position for
  the session. Explicit search destinations take priority over saved locations.
- Search adds keyboard selection, localized categories and aliases in both
  languages, regardless of the current interface language.
- Appearance shows requested versus applied theme state, coalesces rapid
  palette/accent changes and offers guarded, session-scoped undo.
- Appearance editors add HEX/optional eyedropper accents, installed-font
  selection, desktop widget controls and a schematic placement preview.
- Versioned appearance profiles support selected categories, local storage and
  JSON exchange. Validation rejects unsafe fields; unsupported options and
  missing fonts are reported before application.
- Transparency has separate Off, Auto and Manual modes with effective values.
  Background and inner-surface alpha are independent of palette RGB and text.
  The window uses compositor blur instead of a wallpaper-copy effect.
- Optional miko-theme protocol 1 separates application color refresh from full
  material presets. Native blur drafts require explicit application and check
  for external state changes; full presets require a second confirmation.
- Shared visual primitives use one window plane, quieter navigation, flat
  settings groups, soft rectangular controls, compound steppers and accessible
  switches. Scroll edges fade over 36 px without painting an extra color band;
  the first/last content remains fully visible at the respective ends.
- Heavy appearance editors remain lazy-loaded. Navigation does not keep hidden
  pages alive; this update adds no continuous preview polling.

### Integrations and limits

The installer does not patch miko-theme or Hyprland automatically. Optional
[miko-theme migration patches](../integrations/miko-theme/README.md) and
[Hyprland layer rules](../integrations/hyprland/README.md) are included with
compatibility and backup instructions. Do not force patches against another
runtime revision.

Native blur settings are global to Hyprland, not per-window. Portable profiles
are not full backups and exclude external presets, blur, personal paths and
screen-specific placement. JSON exchange currently uses text fields. Undo
cannot guarantee restoration of side effects in external applications.
Scroll fading uses an extra viewport-sized rendering layer only on overflowing,
visible pages; it is alpha fading, not another full-page blur.

See [appearance usage](en/APPEARANCE.md), [features](en/FEATURES.md),
[architecture](en/ARCHITECTURE.md) and [limitations](en/LIMITATIONS.md).
README screenshots show an older interface revision.

### Checks and trying this branch

Local validation covers 113 QML files, 947 translation keys, 11 Python tests
and 11 JavaScript tests. Wayland smoke checks load all nine pages in RU/EN,
exercise five appearance editors, navigation/search and mock theme-generation
failure/queue/undo scenarios. Native Qt captures check scrolling boundaries.
This is local validation, not a guarantee for every machine. ShellCheck was
unavailable.

For a new clone:

```bash
git clone --branch codex/silverstar-convenience-1.1 https://github.com/Walenhill/miko-control-center.git
cd miko-control-center
./scripts/doctor.sh
./scripts/install.sh --dry-run
./scripts/install.sh
```

Preserve local modifications before switching an existing checkout. The
installer backs up replaced center files, but custom installed QML changes must
be reapplied from that backup. Reopen only the center; do not restart the main
shell just for this update. Run `bash scripts/check.sh` and, inside a Wayland
session with compatible installed imports, `bash scripts/smoke.sh`.

## Русский

Обновление опубликовано в ветке `codex/silverstar-convenience-1.1` на базе
Cadence v1.0.0. Это **ещё не релиз с тегом**: `VERSION` сохраняет номер последнего
релиза. Проект экспериментальный, нужен совместимый runtime Quickshell /
`illogical-impulse`.

### Что изменилось

- Навигация помнит вкладку, вложенный редактор и прокрутку каждой страницы
  в текущем сеансе. Явный переход из поиска важнее сохранённого положения.
- Поиск получил выбор с клавиатуры, переведённые категории и псевдонимы на
  двух языках независимо от языка интерфейса.
- Оформление разделяет выбранное и применённое состояние, объединяет быстрые
  изменения палитры/акцента в очередь и предлагает безопасный возврат в сеансе.
- Добавлены HEX-акцент и необязательная пипетка, выбор установленных шрифтов,
  настройки виджетов рабочего стола и схематичный предпросмотр расположения.
- Версионные профили оформления сохраняют выбранные категории локально и
  поддерживают обмен JSON. Небезопасные поля отклоняются; недоступные настройки
  и отсутствующие шрифты показываются перед применением.
- Прозрачность разделена на «Выключено», «Авто» и «Вручную», показаны реальные
  значения. Альфа фона и внутренних поверхностей не меняет RGB палитры и текст.
  Окно использует блюр compositor, а не размывание копии обоев.
- Необязательный miko-theme protocol 1 отделяет обновление цветов приложений
  от полных пресетов. Блюр применяется явно с проверкой внешних изменений;
  полный пресет требует второго подтверждения.
- Общий дизайн: единая плоскость окна, спокойная навигация, плоские группы
  настроек, мягкие прямоугольные кнопки, составные степперы и доступные
  переключатели. Прокрутка мягко затухает на 36 px без дополнительной цветной
  полосы; в начале/конце крайние элементы видны полностью.
- Тяжёлые редакторы загружаются по необходимости. Скрытые страницы не остаются
  в памяти ради навигации; постоянного опроса предпросмотров не добавлено.

### Интеграции и ограничения

Установщик не патчит miko-theme и Hyprland автоматически. В комплекте есть
[патчи миграции miko-theme](../integrations/miko-theme/README.md) и
[layer rules Hyprland](../integrations/hyprland/README.md) с указанием
совместимости и резервного копирования. Не применяйте патчи принудительно
к другой версии runtime.

Нативный блюр глобален для Hyprland. Переносимые профили — не полные backup:
в них нет внешних пресетов, блюра, личных путей и расположения по конкретным
экранам. Обмен JSON пока через текстовые поля. Возврат не гарантирует откат
побочных эффектов во внешних приложениях. Затухание использует дополнительный
слой размером с видимую область только на видимых страницах с прокруткой;
это альфа-затухание, а не ещё один блюр всей страницы.

Подробнее: [оформление](ru/APPEARANCE.md), [возможности](ru/FEATURES.md),
[архитектура](ru/ARCHITECTURE.md), [ограничения](ru/LIMITATIONS.md).
Скриншоты README показывают более ранний интерфейс.

### Проверки и установка ветки

Локально проверены 113 QML-файлов, 947 ключей переводов, 11 Python-тестов
и 11 JavaScript-тестов. Wayland smoke проверяет девять страниц на RU/EN,
пять редакторов оформления, навигацию/поиск и сценарии очереди, ошибок и
возврата с подставным генератором темы. Края прокрутки проверены нативными
Qt-снимками. Это локальная проверка, не гарантия для любой машины.
ShellCheck недоступен.

Команды для нового клона приведены в английском разделе выше. Перед сменой
ветки существующего клона сохраните локальные правки. Установщик делает backup
заменяемых файлов центра; собственные изменения установленного QML нужно
перенести из него. Достаточно переоткрыть центр, основную оболочку перезапускать
не нужно. Проверки: `bash scripts/check.sh` и `bash scripts/smoke.sh` внутри
Wayland-сеанса с установленными совместимыми импортами.
