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

## Adding a setting

1. Identify the owner of the value: shell configuration, controller or external
   service.
2. Use an existing `Miko*Row` component.
3. Put persistence, command execution and error parsing in the controller.
4. Gate optional operations with a capability.
5. Add confirmation and rollback for risky changes.

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
