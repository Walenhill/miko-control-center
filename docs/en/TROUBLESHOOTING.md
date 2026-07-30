# Troubleshooting

## The installer says that the ii runtime is missing

Miko Control Center is an extension of the `illogical-impulse` runtime. Verify
that the selected Quickshell root contains:

```text
modules/common/
modules/common/widgets/
services/
```

If your runtime uses another compatible location, set `MIKO_QS_ROOT`.
`--force` skips only the directory check; it does not provide missing QML
imports.

## The application does not appear

Run the launcher in a terminal:

```bash
miko-control-center
```

Then inspect:

```bash
${XDG_STATE_HOME:-$HOME/.local/state}/miko-control-center.log
qs list --all
```

The launcher reuses an existing instance through IPC and otherwise starts a
separate Quickshell process.

## The window is tiled too small

Some Wayland compositors ignore Qt minimum-size hints for tiled clients. Add a
compositor rule matching the exact title `Miko Control Center`, or float and
resize it manually. The repository does not edit compositor configuration.

## A card is disabled

Run:

```bash
./scripts/doctor.sh
```

Most integrations depend on an external command. Installing a command may not
be sufficient when its service, permissions or API are still disabled.

## Phone actions fail

Check that:

- `kdeconnect-cli` is installed;
- both devices are paired and reachable on the LAN;
- the relevant KDE Connect plugin is enabled on the phone;
- Android permits the requested file or clipboard operation.

Android storage browsing can remain unavailable even when file sending works.

## Throne data is incomplete

Basic status can be read without its live API. Rates, connections and process
data require the compatible API to be enabled in Throne. The control center
does not silently change Throne configuration.

## Package actions request a password or fail

The project does not install sudoers or polkit rules. Use the normal
authorization configuration of the distribution. Never solve this by granting
passwordless unrestricted root access to the control center.

## Restoring a previous installation

Installer backups are stored under:

```text
${XDG_STATE_HOME:-$HOME/.local/state}/miko-control-center/backups/
```

Uninstalled files are moved to:

```text
${XDG_STATE_HOME:-$HOME/.local/state}/miko-control-center/removed/
```

Restore only while no standalone control-center process is using those files.
