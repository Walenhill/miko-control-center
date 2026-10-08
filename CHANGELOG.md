# Changelog

## Silverstar · 1.1.0 - Unreleased

Development update: [English / Русский](docs/UPDATE-1.1.md).

- Refine the shared form into a single window plane with quiet navigation,
  flat settings groups, soft rectangular buttons, compound steppers and a
  common keyboard-accessible switch; preserve live palette and material settings.
- Soften scrolling boundaries with a viewport-sized alpha mask shared by all
  pages; reveal first/last content fully at the ends without tinting materials.

- Remember each page's last tab, nested destination and scroll position within the session, without keeping hidden pages alive.
- Add keyboard search selection, localized categories and bilingual search aliases independent of the interface language.
- Show pending and applied appearance states; offer guarded undo for direct appearance settings and successful theme changes.
- Add navigation/search and mock-generator runtime regression checks, plus search and grouped-undo logic tests.
- Expand Appearance with a queued custom HEX/eyedropper accent, automatic/manual surface transparency, desktop clock/weather/quote controls and schematic drag placement.
- Add an installed-font picker with role-specific previews, including digital-clock typography.
- Add scoped, versioned portable appearance profiles with local storage, strict JSON import/export, missing-font reporting and grouped undo.
- Lazy-load the new appearance editors; do not add preview timers or background polling.
- Use a genuinely transparent window and compositor blur instead of a wallpaper-copy blur; apply surface alpha without hidden caps or palette RGB shifts.
- Separate off/auto/manual transparency, show effective values and add explicit, guarded native blur controls.
- Add optional miko-theme protocol 1 integration: serialized color refresh preserves shell materials, while full presets require explicit confirmation; include migration patches.
- Document and provide a native Quickshell layer-blur policy without high alpha cutoffs that disable blur on translucent panels or crop rounded edges; exclude technical canvases.
- Exclude the Qt shadow fringe from layer blur to prevent halos outside rounded surfaces, and add an opt-in shadow/translucency checkerboard probe.

## Cadence · 1.0.0 - 2026-10-08

Release notes: [English / Русский](docs/RELEASE-1.0.0.md).

- Reconciled the installed tabbed interface with the distributable source.
- Fixed overview imports, inherited click handlers and hidden progress animations.
- Added source runtime smoke checks for all nine pages in RU and EN, Qt 6 syntax checks and backend failure tests.
- Distinguish failed, cached and successful update sources; support both paru and yay queries.
- Commit operation messages with their final status and serialize light/dark and palette generation.
- Validate snapshot contents before restore, create a pre-restore backup and roll back failed writes.
- Share fallback styling, suspend hidden microphone/process polling and load system diagnostics on demand.
- Completed translations for the tabbed interface and added keyboard navigation to tabs.
- Added an application-owned localization layer with live language switching.
- Added automatic locale detection, a persistent language override and safe Russian fallback.
- Added English interface coverage and repository checks for missing or unwrapped translations.

## Silverstar · 0.2.2 - 2026-08-09

- Rebuilt the sidebar brand control so compact mode no longer crowds the title.
- Added a real live blur layer behind the operations drawer.
- Serialized palette generation and passed the selected scheme explicitly to prevent stale config races.

## Silverstar · 0.2.1 - 2026-08-02

- Fixed optical centering and square geometry for icon-only buttons.
- Removed persistent focus rings caused by ordinary pointer clicks.
- Added a responsive, manually toggleable compact sidebar (`Ctrl+B`).
- Unified window, section, control and pill radii across all pages.
- Rebuilt the phone artwork around one centered frame.
- Removed a QML property-shadowing warning in overview quick actions.

## Silverstar · 0.2.0 - 2026-08-02

- Added persistent overview customization and quick-action ordering.
- Added deep search routing to nested control-center sections.
- Added a unified operation drawer and compact action feedback.
- Added on-demand telemetry, sanitized diagnostic reports and settings snapshots.
- Expanded optional integration discovery with Throne, SMART and DDC/CI.
- Kept all new probes page-scoped or explicitly user-triggered.

## 0.1.0 - 2026-07-30

- First public source release.
- Nine control-center pages with shared visual primitives.
- Domain controllers, capability probing, routing and search.
- Portable XDG launcher and guarded installation scripts.
- Russian and English documentation.
