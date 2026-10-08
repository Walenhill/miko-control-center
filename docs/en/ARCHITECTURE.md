# Architecture

## Composition root

`src/control-center.qml` creates the application window, shared services,
controllers, page components and IPC endpoints. It is dependency wiring, not a
place for page-specific layout.

## Visual primitives

Reusable components are prefixed with `Miko`:

- `MikoStyle` owns colors, radii, spacing and motion;
- `MikoSurface` and `MikoButton` define interactive surface behavior;
- `MikoListGroup` and `MikoListRow` define settings lists;
- `MikoToggleRow` and `MikoStepperRow` define common settings;
- `MikoPageFlickable` owns scrolling and keyboard navigation.

A page should extend an existing primitive before inventing a visually
incompatible copy.

Pass the window's `MikoStyle` into components. Optional styles use the shared
`DefaultStyle` singleton, not a new fallback instance per card. Endless
animations must require visibility, a running operation and enabled motion.

## Controllers

Every major domain has a controller:

- appearance;
- applications;
- audio;
- devices;
- displays;
- network;
- services;
- system.

Controllers own processes, parse output, expose state and execute commands.
They do not contain card geometry or visual composition.

Potentially disruptive operations use a two-step contract: prepare a
description/confirmation state, then execute only after explicit UI approval.

## Pages and sections

`*Page.qml` files compose smaller sections. Pages receive controllers, models
and style explicitly through `required property`. Cross-page movement is
reported with signals such as `navigateRequested`.

No page should reach into the application window through implicit QML scope.

Subtab visibility must gate probes as well as presentation: `visible: false`
does not stop timers or destroy child objects. Process polling and microphone
metering are enabled only in their visible sections. System scans are lazy.

## Validation and backend helpers

Run `scripts/check.sh` for Qt 6 syntax, translation placeholders and backend
tests. Run `scripts/smoke.sh` in a Wayland session to load every source page in
RU and EN against the installed ii imports. It uses temporary control-center
state and does not restart the main shell. Syntax-only lint is not a runtime pass.

`tools/check-updates.sh` returns separate JSON statuses for repository and AUR
queries. A failed source must never be reported as an up-to-date system.
`tools/snapshots.py` validates JSON without extracting archive paths, saves a
pre-restore snapshot and rolls back completed writes if a later write fails.
The two files cannot be replaced atomically as a pair across a power failure;
the pre-restore snapshot is retained for recovery. Requires Python 3 and jq.

## Registry and routing

`PageRegistry.qml` owns top-level page metadata and search entries.
`Router.qml` owns the active page and nested sections.

New routes use stable string IDs. Numeric routes exist only for compatibility
with old IPC callers.

## Environment and capabilities

`Environment.qml` calculates XDG-aware paths and shell integration commands.
`Capabilities.qml` performs a short command probe once at startup or on an
explicit refresh.

Missing optional tools should create an explained disabled state. They should
not produce a button that fails after being clicked.

## Cross-cutting UI services

- `ControlCenterState` persists UI preferences only;
- `I18n` resolves the active locale and exposes reactive source-based
  translations;
- `OperationCenter` owns the shared task and feedback model;
- `OperationBridge` maps domain-controller state into operations;
- `SystemTelemetryController` and `SystemSnapshotsController` stay separate
  from the large system controller and run only when their page requests work.

Search passes a stable `target` to the destination page. That page implements
`revealSection(target)` and owns its section geometry, so search routes never
hard-code scroll coordinates in the composition root.

## Adding a setting

1. Identify the owner of the value: shell configuration, controller or external
   service.
2. Use an existing `Miko*Row` component.
3. Put persistence, command execution and error parsing in the controller.
4. Gate optional operations with a capability.
5. Add confirmation and rollback for risky changes.
6. Wrap user-visible text with `I18n.tr` and update language catalogs.

## Adding a section

1. Create a focused QML section.
2. Pass `style` and data explicitly.
3. Emit signals for mutations.
4. Compose it in the matching page.
5. Extract repeated patterns into a shared primitive.

## Adding a top-level page

1. Create `ExampleController.qml` if system state or commands are required.
2. Create `ExamplePage.qml` and its sections.
3. Register metadata in `PageRegistry.pages`.
4. Add useful search entries.
5. Wire the controller and page component in `control-center.qml`.
6. Extend `Router.qml` only if nested navigation is required.
7. Verify search, back navigation, min-size layout and unavailable states.

This is intentionally explicit wiring. The project does not yet load
third-party modules from manifests.
