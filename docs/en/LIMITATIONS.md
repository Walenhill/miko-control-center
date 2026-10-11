# Requirements and limitations

## Not standalone

The repository contains the control center, not the complete
`illogical-impulse` desktop shell. It imports:

- `qs.services`;
- `qs.modules.common`;
- `qs.modules.common.widgets`;
- singleton models such as `Appearance`, `Config`, `Audio`, `Network`,
  `KdeConnect`, `Updates`, `HyprlandData` and others.

Copying the QML files into an unrelated Quickshell configuration will not
provide those dependencies.

## Supported operating profile

The primary profile is Arch Linux with Hyprland. Package operations use
`pacman` and optionally `paru`/`yay`. Display integration expects Hyprland.
Service inspection expects systemd.

Other distributions can reuse the UI and architecture, but their package,
display and service controllers require adapters.

## Language

Documentation and the interface support Russian and English, with live switching.
This does not translate external applications or the entire surrounding shell.

## Appearance undo and navigation

Page locations and appearance history are kept only for the current session.
History is limited to 20 actions. Undo covers settings changed through the center
and successfully generated themes/palettes, not external wallpaper selection or
downloads. Values are checked for external changes before undo. A failed external
generator cannot guarantee rollback of every file it may already have generated.

## Optional integrations

The following are optional and may disappear or become disabled:

- Throne;
- KDE Connect;
- EasyEffects;
- DDC/CI through `ddcutil`;
- SMART through `smartctl`;
- UFW;
- Miko Watch and Miko Resilience helpers.

Some device-friendly labels are based on known USB IDs. Unknown devices retain
the name reported by `lsusb`.

The phone hero can use a Nothing Phone artwork supplied by the surrounding
shell. If the asset is absent, a generic phone icon is displayed.

## Capability coverage

Capability probing is centralized, but not every historical action has been
fully migrated. Unsupported combinations should be treated as experimental
until their disabled/error state is verified.

## Window-manager behavior

Qt minimum-size hints may not constrain a tiled Wayland window. The author's
Hyprland profile uses a title-scoped rule to float, center and size the window.
This compositor rule is intentionally not installed by this repository.

## Privileged actions

Package updates, cleanup, firewall changes and some display/service operations
can require `pkexec`, sudo policy or additional group permissions.

The project does not install or weaken authorization policies.

## No plugin marketplace

The code is modular for development, but it does not automatically discover
third-party modules. Adding a top-level page still requires explicit registry
and composition-root wiring.

## Stability

### Appearance portability

Profiles use version 1 of `miko-appearance`; they are not full backups. They
exclude wallpaper files, paths, widget positions, monitor names, screen-specific
panel placement, commands, security and network settings. Fonts are not installed
automatically. Unsupported fields and unavailable fonts are listed before
application and skipped. JSON exchange currently uses a text field rather than
file dialogs. Local storage is limited to 32 profiles / 128 KiB.

Widget previews are schematic, not pixel-perfect clock replicas. The shell uses
shared widget coordinates across displays. Font variation axes depend on the
selected family's support. Constant clock rotation is opt-in and adds GPU work.

Surface transparency has no hidden caps; text, icons and selected accents do
not become transparent. Nested alpha layers compose. Native blur requires
Hyprland and protocol 1 in the optional miko-theme integration; blur settings
are global and are not included in portable profiles. Theme generation can update
external applications and is not an atomic transaction. Other profile options
are not applied when generation fails, but external side effects cannot be
guaranteed to roll back.

The project is developed against a heavily customized live desktop. Upstream
`illogical-impulse`, Quickshell or Qt API changes can require adaptation.

Back up the existing shell configuration before replacing files.
