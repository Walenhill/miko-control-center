# Changelog

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
