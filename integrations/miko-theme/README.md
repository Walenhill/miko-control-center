# miko-theme material integration · protocol 1

## Русский

Необязательная интеграция. Центр сам проверяет `miko-theme inspect`; без API
работают настройки прозрачности оболочки, но не пресеты и нативный блюр.
Установщик центра **не патчит другой проект автоматически**.

`material-protocol-1.patch` предназначен для прежней Python-версии miko-theme
(пакет `src/miko_theme`). Сначала сохрани исходники и конфиг. Из каталога `src`
miko-theme проверь совместимость, затем примени:

```sh
patch --dry-run -p1 < /path/to/miko-control-center/integrations/miko-theme/material-protocol-1.patch
patch -p1 < /path/to/miko-control-center/integrations/miko-theme/material-protocol-1.patch
miko-theme inspect
```

Патч `switchwall-sync.patch` применяется из корня совместимой оболочки
Quickshell ii тем же способом (`--dry-run` первым). Он заменяет фоновый
`miko-theme apply` на последовательный `miko-theme sync --quiet`. Не форсируй
патчи при несовпадении версии: перенеси маленький API/хук в актуальный upstream.
Лог хука: `$XDG_STATE_HOME/quickshell/user/generated/miko-theme-sync.log`
(используется значение `STATE_DIR` конкретной оболочки).

- `inspect`: JSON protocol 1, текущие материалы, возможности, доступные пресеты
  и последний результат адаптеров; не пишет конфиг.
- `sync --quiet` / совместимый `apply`: обновляют цвета приложений, не накатывают
  параметры оболочки/compositor или поведение/оконные правила AyuGram.
- `mode <id>`: явное применение полного пресета и создание backup.
- `blur --enabled true|false --size 1..16 --passes 1..4 --expect '<JSON>'`:
  только три параметра блюра, backup и проверка свежего состояния до записи.
- `rollback`: полный последний backup, включая Hyprland overrides, затем
  обновление цветов без повторного применения пресета.

Все изменяющие операции сериализованы файловой блокировкой. Частичный отказ
внешнего приложения не выдаётся за успешное обновление всех приложений.
Регрессионные тесты центра подключают этот API, если он установлен; иначе
native-contract тесты пропускаются. Нет постоянного опроса состояния.

## English

This optional bridge is detected through `miko-theme inspect`. Shell opacity
still works without it; native blur and external presets require protocol 1.
The control-center installer does not modify another project automatically.

Back up the previous Python miko-theme package and configuration. Apply
`material-protocol-1.patch` from its `src` directory using the commands above,
always running `--dry-run` first. Apply `switchwall-sync.patch` from the matching
Quickshell ii root. Do not force mismatched patches; port the small API/hook to
the relevant upstream instead.

`inspect` is read-only, `sync` preserves shell/compositor materials, `mode` is
an explicit full preset, and `blur` modifies only enabled/size/passes after an
expected-state check. All mutations are serialized. Rollback restores the
latest complete backup and refreshes colors without replaying preset values.
Native blur is global to Hyprland, not a per-window effect. Adapter failures
remain visible rather than being reported as complete success.

The patch was dry-run checked against the installed pre-integration package;
21 native tests and the control-center contract/runtime checks passed. Other
miko-theme or shell revisions are not assumed compatible.
