# Appearance and profiles

The center edits existing shell `Config.options` fields. There is one source of
truth: changes reach the panel, widgets and other consumers of those settings.

## Usage

1. Open custom accent/surfaces, enter HEX or use the optional eyedropper, then
   Apply. From wallpaper restores automatic color sourcing.
2. In “Transparency and blur”, choose Off, Auto or Manual. Manual mode separates
   the window/panel background from inner surfaces. “Effective” displays the
   actual values, including in automatic mode.
3. Desktop widgets exposes clock styles and details. Dragging in the schematic
   preview switches a widget to free placement.
4. Fonts and typography lets you select a role and installed family. Previewing
   does not mutate settings; Apply font does.
5. Appearance profiles saves selected categories under a unique name. Select a
   profile to review skipped options before applying. Export JSON selects text
   for copying; Import adds a profile without applying it.

Profiles live at `$XDG_STATE_HOME/miko-control-center/appearance-profiles.json`
(`~/.local/state` by default). Corrupt storage is not automatically overwritten.
Deletion requires a second click. Undo is session-scoped and guarded against
external changes.

## Transparency, blur and miko-theme

The center is a genuinely transparent window, not a blurred wallpaper copy.
Hyprland supplies native blur behind it. Transparency changes surface alpha,
not palette RGB; text, icons and selected accents retain their own opacity.
Nested window/card alpha layers compose: each percentage describes its own
surface, not the final transparency of every layer beneath it.

Transparency lives in the shared `Config.options.appearance.transparency`.
Blur is a separate compositor setting: edit the draft, then Apply blur. It also
affects other Hyprland windows. Only `enabled`, `size` and `passes` are changed;
rounding, shadows and palette are untouched. More strength/passes means more
GPU work. A fresh snapshot is checked before writing; on an external conflict,
Refresh before applying again.

Optional miko-theme protocol 1 provides actual blur values, available presets
and application-sync status. Refresh application colors preserves shell
transparency and blur. Palette changes use the same serialized path, without
background preset replay. AyuGram behavior/window rules and Steam skin repair
are reserved for explicit presets, not color refresh.

Full miko-theme presets are a separate, two-click confirmed action. They may
change transparency, blur, rounding, shadows and enabled application styles.
Restore miko-theme style restores the latest complete backup, not just blur.
Ordinary option undo cannot promise to restore external application effects.
Manual edits after a preset are indicated as such.

Older miko-theme needs the [integration patch](../../integrations/miko-theme/README.md).
Without it, shell transparency controls remain usable but external integration
is unavailable. Portable center profiles exclude compositor blur and external
application presets.
An old shell hook paired with the old backend can still replay materials on
palette changes; migrate both parts, not just the center.

If window blur works but Quickshell panels do not blur or have sharp cutouts,
check the separate [Hyprland layer rules](../../integrations/hyprland/README.md).
Old `ignore_alpha` thresholds can exclude translucent material surfaces.

## Format and extension

```json
{
  "format": "miko-appearance",
  "version": 1,
  "name": "My theme",
  "theme": {"palette": "scheme-tonal-spot", "dark": true, "accent": "#80CFA0"},
  "options": {"appearance.transparency.enable": true, "dock.height": 60}
}
```

`theme` is optional. `src/controlcenter/AppearanceProfiles.js` defines allowed
fields, categories, types and ranges. Unknown keys or invalid types reject the
entire import before any setting is written. Missing runtime fields and
uninstalled fonts are explicitly listed and skipped.

When adding a setting, verify its actual runtime field, route the control through
`AppearanceChanges`, then optionally allow a safe portable field in the schema
and add tests. Never add paths or shell commands to profiles. Route themes and
accents only through `AppearanceController`: it coalesces rapid requests,
serializes generation and records history. Load new heavy editors with an active
`Loader`, as widgets/fonts/profiles do.

Run `scripts/check.sh` and `scripts/smoke.sh`. Regression tests use a fake theme
generator and do not change the real theme. See [LIMITATIONS.md](LIMITATIONS.md)
for portability and generation caveats.
