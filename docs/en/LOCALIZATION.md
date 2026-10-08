# Localization

Miko Control Center owns its localization layer instead of modifying the
translation files shipped by the surrounding `illogical-impulse` runtime.

## Runtime model

- Russian QML text is the stable source key and the built-in fallback.
- `src/controlcenter/I18n.qml` resolves the active language and loads a JSON
  catalog from `src/controlcenter/i18n/`.
- `auto` follows the shell language when it is available, then the Qt locale.
- A language change updates existing bindings immediately; restarting the
  control center is not required.
- The selected preference is stored by `ControlCenterState`.

The environment variable `MIKO_CONTROL_CENTER_LANGUAGE` can temporarily
override the preference with `ru_RU` or `en_US`. It is intended for previews
and automated smoke tests, not persistent configuration.

## Translating UI text

Wrap user-visible QML strings with `I18n.tr`:

```qml
StyledText {
    text: I18n.tr("Система в порядке")
}
```

Use named interpolation instead of assembling a sentence from translated
fragments:

```qml
text: I18n.tr("Проверено {time}", { time: controller.checkedAt })
```

Then add the exact source key to the target catalog:

```json
{
  "Проверено {time}": "Checked {time}"
}
```

Keep command names, protocol identifiers, product names and measurement units
untranslated when that is how users see them elsewhere in the system.

## Adding a language

1. Add the locale to `I18n.languages`.
2. Create `src/controlcenter/i18n/<locale>.json`.
3. Translate every key reported by `./scripts/check-i18n.sh`.
4. Reuse the shared `I18n.languages` model; do not create page-specific
   language buttons.
5. Smoke-test changing to and from the new language without restarting.

Run the complete validation before committing:

```bash
./scripts/check.sh
```

The check rejects malformed catalogs, empty values, missing English keys and
new unwrapped Cyrillic UI literals.
