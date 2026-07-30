# Miko Control Center

[Русская версия](README.ru.md) · **English**

A desktop-first control center for a customized Linux system built with
[Quickshell](https://quickshell.org/), Qt Quick and the
`illogical-impulse` (`ii`) shell runtime.

Miko Control Center brings everyday system controls, diagnostics and personal
integrations into one consistent interface without pretending that every Linux
machine is identical.

> [!WARNING]
> **Experimental project.** This is a personal system component published for
> inspection, adaptation and reuse. It is functional on the author's
> Arch/Hyprland setup, but APIs, layout and installation details may change.
> It is not a distribution-independent replacement for every settings app.

![Miko Control Center overview](docs/assets/screenshots/overview-purple.png)

## Interface

The interface follows the wallpaper-derived Material palette rather than
shipping one fixed accent color.

| Alternate palette | Appearance editor |
| --- | --- |
| ![Pink overview palette](docs/assets/screenshots/overview-pink.png) | ![Purple appearance editor](docs/assets/screenshots/appearance-purple.png) |

<details>
<summary><strong>More screenshots</strong></summary>

| Network and ports | Phone and devices |
| --- | --- |
| ![Network port inspector](docs/assets/screenshots/network-ports.png) | ![KDE Connect phone integration](docs/assets/screenshots/devices-phone.png) |

| Display workspace | System health |
| --- | --- |
| ![Display topology and modes](docs/assets/screenshots/displays.png) | ![System resources and Miko Watch](docs/assets/screenshots/system-health.png) |

| Services and integrations |
| --- |
| ![Services and integrations](docs/assets/screenshots/services.png) |

</details>

## Highlights

- Overview with CPU, memory, storage, network, devices and system attention.
- Network status, route information, connection checks and a dedicated ports
  inspector.
- Optional Throne tunnel status and live traffic data.
- PipeWire output, input and per-application audio controls.
- Display topology, modes, scaling, night light and reusable display scenes.
- KDE Connect phone actions, clipboard and drag-and-drop file transfer.
- USB and Bluetooth device overview.
- Wallpaper-derived Material colors and shell appearance controls.
- Package updates, storage cleanup, power profiles and system health checks.
- Service inspection, integrations and Miko Watch diagnostics.
- Process, autostart, notification and privacy activity views.
- Keyboard navigation, accelerated scrolling and restrained desktop motion.

The complete capability matrix is in
[docs/en/FEATURES.md](docs/en/FEATURES.md).

## Compatibility

The current supported profile is:

- Arch Linux or an Arch-based distribution;
- Hyprland;
- Quickshell with the `illogical-impulse` runtime;
- PipeWire/WirePlumber;
- systemd user services.

The interface probes optional commands and degrades some integrations to
disabled states. It is **not a standalone QML package**: it imports models,
widgets and services supplied by the surrounding `ii` runtime.

Read [docs/en/LIMITATIONS.md](docs/en/LIMITATIONS.md) before installing.
Common launch and integration problems are covered in
[docs/en/TROUBLESHOOTING.md](docs/en/TROUBLESHOOTING.md).

## Installation

Clone the repository and run the preflight check:

```bash
git clone https://github.com/Walenhill/miko-control-center.git
cd miko-control-center
./scripts/doctor.sh
```

Preview the files that would be installed:

```bash
./scripts/install.sh --dry-run
```

Install into the current XDG user directories:

```bash
./scripts/install.sh
```

The installer:

1. verifies that a compatible `ii` runtime exists;
2. backs up an existing control center into the XDG state directory;
3. installs the QML sources, launcher, desktop entry and icon;
4. never restarts the main Quickshell process.

Launch it from an application menu or run:

```bash
miko-control-center
```

To remove only the files owned by this repository:

```bash
./scripts/uninstall.sh
```

All paths respect `XDG_CONFIG_HOME`, `XDG_DATA_HOME`, `XDG_STATE_HOME` and
`XDG_BIN_HOME`.

## Repository layout

```text
src/
  control-center.qml       application composition root
  controlcenter/           pages, controllers, routing and UI primitives
packaging/
  bin/                     portable launcher
  applications/            desktop entry
  icons/                   application icon
scripts/
  install.sh               guarded XDG installer
  uninstall.sh             guarded removal
  doctor.sh                read-only capability report
  check.sh                 repository validation
docs/
  en/                      English documentation
  ru/                      Russian documentation
```

## Development

The UI is organized into four layers:

1. reusable `Miko*` visual primitives;
2. domain controllers that own processes and system state;
3. pages composed from small sections;
4. a registry, router, environment and capability probe.

Start a separate development instance:

```bash
qs -p "${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/ii/control-center.qml"
```

Do not restart the primary shell just to validate this application.

Architecture and extension rules are documented in
[docs/en/ARCHITECTURE.md](docs/en/ARCHITECTURE.md).

## Safety

The control center contains actions that can update packages, clean storage,
restart user services, change display configuration and inspect firewall
state. Destructive or disruptive actions should remain explicit and confirmed.

Do not automate those actions during a UI smoke test.

## License

Miko Control Center is available under the [MIT License](LICENSE). External
projects and runtime dependencies keep their own licenses.
