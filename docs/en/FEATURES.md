# Feature matrix

## Overview

- Live CPU and memory usage.
- Root and home storage summary.
- Network and device status.
- Power profile and update summary.
- Quick actions for Wi-Fi, Bluetooth, notifications, night light and displays.
- System attention from Miko Watch.

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

These settings target the `illogical-impulse` configuration schema. They are
not generic GTK, KDE Plasma or GNOME settings.

## System

- CPU, memory and swap summary.
- Disk usage and kernel information.
- Power profile selection when `powerprofilesctl` is present.
- Repository and AUR update lists.
- Explicit package update actions.
- Package cache, trash, journal and orphan-package analysis.
- Confirmed cleanup actions.
- Miko Watch health events with read, ignore and restore flows.

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
- `Enter`: open the first search result.
- `Alt+Left`: navigate back.
- `Esc`: leave search, leave a nested section, then close the window.
- `Home`, `End`, `Page Up`, `Page Down`: fast page navigation.
- Accelerated mouse-wheel scrolling.
- Short opacity/translation page transitions without scaling text.
