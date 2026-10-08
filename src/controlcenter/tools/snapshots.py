#!/usr/bin/env python3
"""Validated configuration snapshots. No archive paths are ever extracted."""
import fcntl
import io
import json
import os
from pathlib import Path
import sys
import tarfile
import tempfile
from datetime import datetime, timezone

NAMES = ("config/illogical-impulse.json", "config/control-center.json")
LIMIT = 2 * 1024 * 1024


def validate(data):
    if len(data) > LIMIT or not isinstance(json.loads(data), dict):
        raise ValueError("Configuration must be a JSON object smaller than 2 MiB")
    return data


def atomic_write(path, data):
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    descriptor, staging = tempfile.mkstemp(prefix=".miko-", dir=path.parent)
    try:
        with os.fdopen(descriptor, "wb") as stream:
            stream.write(data)
            stream.flush()
            os.fsync(stream.fileno())
        os.replace(staging, path)
    finally:
        if os.path.exists(staging):
            os.unlink(staging)


def create(root, targets):
    contents = {}
    for name, target in zip(NAMES, targets):
        if target.exists():
            contents[name] = validate(target.read_bytes())
    stamp = datetime.now(timezone.utc).strftime("%Y%m%d-%H%M%S-%f")
    archive = root / (stamp + ".tar.gz")
    buffer = io.BytesIO()
    with tarfile.open(fileobj=buffer, mode="w:gz") as output:
        contents["metadata"] = ("created=" + stamp + "\n").encode()
        for name, data in contents.items():
            info = tarfile.TarInfo(name)
            info.size = len(data)
            info.mode = 0o600
            output.addfile(info, io.BytesIO(data))
    atomic_write(archive, buffer.getvalue())
    return str(archive)


def restore(root, archive, targets):
    archive = Path(archive).resolve(strict=True)
    if archive.parent != root.resolve() or not archive.name.endswith(".tar.gz"):
        raise ValueError("Snapshot must be in the snapshot directory")
    contents = {}
    with tarfile.open(archive, "r:gz") as source:
        for member in source:
            name = member.name.removeprefix("./")
            if member.isdir() and name.rstrip("/") in (".", "config", ""):
                continue
            if name not in (*NAMES, "metadata") or not member.isfile() or member.size > LIMIT:
                raise ValueError("Unsupported snapshot entry: " + member.name)
            if name in contents:
                raise ValueError("Duplicate snapshot entry: " + name)
            data = source.extractfile(member).read(LIMIT + 1)
            contents[name] = validate(data) if name in NAMES else data
    if not any(name in contents for name in NAMES):
        raise ValueError("Snapshot contains no configuration")

    # Validate the whole archive before touching either configuration.
    backup = create(root, targets)
    previous = {target: target.read_bytes() if target.exists() else None for target in targets}
    written = []
    try:
        for name, target in zip(NAMES, targets):
            if name in contents:
                atomic_write(target, contents[name])
                written.append(target)
    except BaseException:
        for target in reversed(written):
            if previous[target] is None:
                target.unlink(missing_ok=True)
            else:
                atomic_write(target, previous[target])
        raise
    return backup


def main():
    action, root_arg, config, preferences, *args = sys.argv[1:]
    root = Path(root_arg)
    root.mkdir(parents=True, exist_ok=True, mode=0o700)
    targets = (Path(config), Path(preferences))
    with (root / ".lock").open("a") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        if action == "create":
            result = create(root, targets)
        elif action == "restore" and len(args) == 1:
            result = restore(root, args[0], targets)
        else:
            raise ValueError("Unknown snapshot action")
    print(result)


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, tarfile.TarError) as error:
        print(str(error), file=sys.stderr)
        sys.exit(1)
