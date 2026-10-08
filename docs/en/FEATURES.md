# Feature matrix

## Overview

- Live CPU and memory usage.
- Root and home storage summary.
- Network and device status.
- Power profile and update summary.
- Quick actions for Wi-Fi, Bluetooth, notifications, night light and displays.
- System attention from Miko Watch.
- Persisted overview sections and quick-action ordering.

## Network

- Active interface, local address, gateway and DNS.
- Internet latency, packet loss and DNS response checks.
- NetworkManager settings launcher when configured by the shell.
- Active listener list with protocol, bind scope, process and firewall context.
- Individual port inspection.
- Optional UFW visibility and guarded rule actions.
- Optional Throne status:
  - active profile, protocol, group and route;
  - TUN, strict route, DNS routing, DNS cache, system proxy, IPv6 and ad block;
  - live rates, connections and top processes when its API is enabled.

## Sound

- Default PipeWire output and input.
- Volume and microphone level.
- Mute controls.
- Output and input device selection.
- Per-application stream mixer.
- Optional EasyEffects launcher and state.
- Sound scenes and utility controls.

## Displays

- Connected monitor topology.
- Resolution, refresh rate, scale and transform controls.
- Positioning and reusable display scenes.
- Night-light controls.
- DDC/CI capability detection.
- Guarded preview/apply behavior where the surrounding runtime supports it.

## Devices

- KDE Connect phone status and battery.
- Phone ring, clipboard and file actions.
- Drag-and-drop file transfer to a reachable phone.
- USB inventory with friendly labels for a small set of known devices.
- Bluetooth adapter and device overview.
- Audio-device bridge to the Sound page.

## Appearance

- Wallpaper selection.
- Wallpaper-derived Material palette modes.
- Light/dark mode and shell transparency.
- Panel position, form, behavior and elements.
- Interface font and behavior settings.
- Notification and lock-screen settings.
- Advanced parallax and application-theme controls.
- Custom HEX accent and an optional `hyprpicker` eyedropper, using one worker for accent, palette and theme mode.
- Off/automatic/manual transparency shared with the shell, with effective percentages and no hidden caps.
- A genuinely transparent window and native Hyprland blur, explicitly applied and guarded against external changes.
- Optional miko-theme API: color refresh without material resets and confirmed full presets.
- Cookie/digital clocks: hands, date, shape and digit typography, weather and quotes.
- Schematic widget drag-placement preview with display selection.
- Installed-font search, previews and seven system roles plus the digital-clock font.
- Named category-scoped profiles, local storage and JSON exchange.
- Validated profile imports, unavailable-font reporting and single-action profile undo.
- Visible pending/applied theme and palette state.
- Session-scoped undo for reversible appearance changes. Externally changed
  values are not overwritten; wallpaper selection/download is not undone.

These settings target the `illogical-impulse` configuration schema. They are
not generic GTK, KDE Plasma or GNOME settings.

For profile details and extension guidance, see [Appearance](APPEARANCE.md).

## System

- CPU, memory and swap summary.
- Disk usage and kernel information.
- Power profile selection when `powerprofilesctl` is present.
- Repository and AUR update lists.
- Explicit package update actions.
- Package cache, trash, journal and orphan-package analysis.
- Confirmed cleanup actions.
- Miko Watch health events with read, ignore and restore flows.
- On-demand temperatures and failed-unit checks without constant polling.
- A local privacy-conscious diagnostic report.
- Confirmed snapshots of the shell and control-center configuration.

## Services

- Core shell and desktop-service status.
- systemd user-service inspection.
- Restart actions for selected services.
- Integration discovery for KDE Connect, EasyEffects, Throne, SMART and DDC/CI.
- Miko desktop diagnostics when `miko-check` is installed.
- Pinned component list.

## Applications

- Running process list and resource usage.
- User autostart entries.
- Notification settings.
- Microphone and screen-capture activity indicators where exposed by the
  surrounding runtime.

## Interaction

- `Ctrl+F` / `Ctrl+K`: focus search.
- `Ctrl+B`: collapse or expand the sidebar.
- `Up` / `Down` in search: select a result; `Enter`: open the selected result.
- `Alt+Left`: navigate back.
- `Esc`: leave search, leave a nested section, then close the window.
- `Home`, `End`, `Page Up`, `Page Down`: fast page navigation.
- Accelerated mouse-wheel scrolling.
- Short opacity/translation page transitions without scaling text.
- Deep search that routes directly to a matching subsection.
- Result categories and RU/EN aliases independent of the interface language.
- Per-page tab, nested destination and scroll memory within the session.
  Explicit search/IPC destinations take priority over remembered locations.
- One operation center and compact feedback for background actions.
