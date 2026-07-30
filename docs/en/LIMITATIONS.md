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

Project documentation is bilingual. The current application UI is Russian.
Runtime localization is not implemented yet.

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

The project is developed against a heavily customized live desktop. Upstream
`illogical-impulse`, Quickshell or Qt API changes can require adaptation.

Back up the existing shell configuration before replacing files.
