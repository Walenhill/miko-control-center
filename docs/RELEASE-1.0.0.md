# Cadence · v1.0.0

2026-10-08 · MIT · [English](#english) / [Русский](#русский)

## English

The first Cadence milestone brings the tabbed interface, RU/EN localization
and reliability work into the public source release. **The project remains
experimental** and depends on a compatible `illogical-impulse` runtime.
The major version marks a project milestone, not universal Linux support.

### Highlights

- Russian, English and automatic locale selection, with persistent preferences
  and live switching without restarting the application.
- Tabbed sections across all nine pages, shared interface primitives,
  wallpaper-derived accents, compact navigation and keyboard-accessible tabs.
- Launch fixes, corrected inherited click handling and source/live reconciliation.
- Shared fallback styling, stopped hidden progress animations, page-scoped
  microphone/process polling and on-demand system diagnostics.
- One control-center update query path; explicit failed/cached/successful
  results, bounded queries, paru/yay support and recycled package-list rows.
- Serialized light/dark and palette generation, queued selections and explicit
  failure feedback instead of overlapping generation jobs.
- Validated settings snapshots: archive allowlist, size limits, pre-restore
  backup, per-file atomic writes and rollback on write failure.
- Translation and placeholder checks, Qt 6 syntax checks, backend regression
  tests and a Wayland runtime smoke test for every page in both languages.

### Upgrade / install

Use the matching source release, not files copied from an older installation:

```bash
git clone --branch v1.0.0 https://github.com/Walenhill/miko-control-center.git
cd miko-control-center
./scripts/doctor.sh
./scripts/install.sh --dry-run
./scripts/install.sh
```

For an existing clean clone, fetch and check out `v1.0.0` first. Preserve local
changes before switching versions. Close and reopen only the control center
after installation; a main-shell restart is not needed.
The installer backs up replaced control-center files. Preferences are retained;
custom modifications to installed QML must be reapplied from that backup.
Python 3 is needed for snapshot operations; package result parsing requires `jq`.
See [installation](https://github.com/Walenhill/miko-control-center/blob/v1.0.0/README.md#installation)
and [troubleshooting](https://github.com/Walenhill/miko-control-center/blob/v1.0.0/docs/en/TROUBLESHOOTING.md).

### Validation and limitations

- Static checks: 100 QML files, 802 used translation keys with placeholder
  checks, shell syntax and desktop-file validation.
- Six backend failure/recovery tests passed.
- All nine pages loaded in RU and EN against the author's installed runtime.
- Primary profile: Arch-based Linux, Hyprland, PipeWire/WirePlumber and systemd.
  Optional integrations still require their own programs and configuration.
- This is source distribution, not a standalone binary or a bundled desktop.
  Other machines and runtime versions are not covered by the local smoke test.
- Snapshot writes are atomic per file, not a power-failure-safe transaction
  across both configuration files. A pre-restore backup is retained.
- ShellCheck was unavailable for this release's local validation.

See the [feature matrix](https://github.com/Walenhill/miko-control-center/blob/v1.0.0/docs/en/FEATURES.md),
[limitations](https://github.com/Walenhill/miko-control-center/blob/v1.0.0/docs/en/LIMITATIONS.md),
[architecture](https://github.com/Walenhill/miko-control-center/blob/v1.0.0/docs/en/ARCHITECTURE.md)
and [localization guide](https://github.com/Walenhill/miko-control-center/blob/v1.0.0/docs/en/LOCALIZATION.md).
Screenshots show an earlier interface revision; details may differ.

## Русский

Первый крупный релиз Cadence объединяет вкладочный интерфейс, локализацию RU/EN
и исправления надёжности в публичной версии исходников. **Проект остаётся
экспериментальным** и требует совместимый runtime `illogical-impulse`.
Мажорная версия — этап проекта, а не обещание поддержки любого Linux.

### Главное

- Русский, английский и автоматический выбор языка, сохранение предпочтений
  и переключение интерфейса без перезапуска приложения.
- Подразделы во всех девяти страницах, общие компоненты интерфейса,
  акценты из обоев, компактное меню и управление вкладками с клавиатуры.
- Исправления запуска, наследуемых обработчиков клика и сверка исходников
  с установленным интерфейсом.
- Общий резервный стиль, остановка скрытых анимаций, опрос микрофона/процессов
  только при просмотре и диагностика системы по необходимости.
- Единая проверка обновлений центра: явные ошибки и кэшированные результаты,
  ограниченное время запроса, поддержка paru/yay и переиспользование строк списка.
- Последовательная генерация светлой/тёмной темы и палитры, очередь выбора
  и понятные сообщения об ошибках вместо пересекающихся задач.
- Проверяемые снимки настроек: допустимый состав архива, лимиты размера,
  резервная копия перед восстановлением, атомарная запись отдельных файлов
  и откат при ошибке записи.
- Проверки переводов и параметров строк, синтаксиса Qt 6, регрессионные тесты
  backend и Wayland smoke-тест всех страниц на двух языках.

### Обновление / установка

Используйте исходники именно этого релиза, а не отдельные файлы старой установки:

```bash
git clone --branch v1.0.0 https://github.com/Walenhill/miko-control-center.git
cd miko-control-center
./scripts/doctor.sh
./scripts/install.sh --dry-run
./scripts/install.sh
```

В существующем чистом клоне сначала получите изменения и переключитесь на
`v1.0.0`. Перед переключением сохраните свои локальные правки. После установки
закройте и откройте только центр управления: основную оболочку перезапускать
не требуется. Установщик сохраняет резервную копию заменяемых файлов центра.
Предпочтения сохраняются; собственные изменения установленного QML нужно
перенести из резервной копии. Для снимков нужен Python 3, для разбора результатов
проверки пакетов — `jq`.
См. [установку](https://github.com/Walenhill/miko-control-center/blob/v1.0.0/README.ru.md#установка)
и [решение проблем](https://github.com/Walenhill/miko-control-center/blob/v1.0.0/docs/ru/TROUBLESHOOTING.md).

### Проверки и ограничения

- Статические проверки: 100 QML-файлов, 802 используемых ключа переводов
  с проверкой параметров, синтаксис shell и desktop-файл.
- Пройдены шесть тестов ошибок и восстановления backend.
- Все девять страниц загружены на RU и EN с установленным runtime автора.
- Основной профиль: Arch-подобный Linux, Hyprland, PipeWire/WirePlumber и systemd.
  Необязательные интеграции требуют своих программ и настройки.
- Это исходники, а не самостоятельный бинарник или комплект рабочего стола.
  Локальный smoke-тест не подтверждает работу на всех машинах и версиях runtime.
- Снимки записываются атомарно по одному файлу, но не единой транзакцией для
  двух конфигов при отключении питания. Резервная копия сохраняется.
- ShellCheck не был доступен при локальной проверке этого релиза.

См. [возможности](https://github.com/Walenhill/miko-control-center/blob/v1.0.0/docs/ru/FEATURES.md),
[ограничения](https://github.com/Walenhill/miko-control-center/blob/v1.0.0/docs/ru/LIMITATIONS.md),
[архитектуру](https://github.com/Walenhill/miko-control-center/blob/v1.0.0/docs/ru/ARCHITECTURE.md)
и [локализацию](https://github.com/Walenhill/miko-control-center/blob/v1.0.0/docs/ru/LOCALIZATION.md).
Скриншоты показывают предыдущую ревизию интерфейса; детали могут отличаться.
