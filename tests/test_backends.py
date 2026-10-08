import importlib.util
import io
import json
import os
from pathlib import Path
import shutil
import subprocess
import tarfile
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("snapshots", ROOT / "src/controlcenter/tools/snapshots.py")
snapshots = importlib.util.module_from_spec(spec)
spec.loader.exec_module(snapshots)


class SnapshotTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.targets = (self.root / "config.json", self.root / "preferences.json")
        for target in self.targets:
            target.write_text('{"value": 1}')

    def test_roundtrip_and_pre_restore_backup(self):
        archive = snapshots.create(self.root, self.targets)
        for target in self.targets:
            target.write_text('{"value": 2}')
        backup = snapshots.restore(self.root, archive, self.targets)
        self.assertNotEqual(archive, backup)
        self.assertTrue(all(json.loads(p.read_text())["value"] == 1 for p in self.targets))
        snapshots.restore(self.root, backup, self.targets)
        self.assertTrue(all(json.loads(p.read_text())["value"] == 2 for p in self.targets))

    def archive(self, name, data, symlink=False):
        path = self.root / "invalid.tar.gz"
        with tarfile.open(path, "w:gz") as output:
            entry = tarfile.TarInfo(name)
            entry.size = len(data)
            if symlink:
                entry.type = tarfile.SYMTYPE
                entry.linkname = str(self.targets[0])
            output.addfile(entry, io.BytesIO(data))
        return path

    def test_invalid_json_and_paths_leave_configs_untouched(self):
        for name, data, link in [(snapshots.NAMES[0], b'[]', False),
                                 ('../outside', b'{}', False),
                                 (snapshots.NAMES[0], b'{}', True)]:
            with self.assertRaises(ValueError):
                snapshots.restore(self.root, self.archive(name, data, link), self.targets)
            self.assertTrue(all(p.read_text() == '{"value": 1}' for p in self.targets))

    def test_second_write_failure_rolls_back_first(self):
        archive = snapshots.create(self.root, self.targets)
        for target in self.targets:
            target.write_text('{"value": 2}')
        real_write = snapshots.atomic_write
        def fail_second(path, data):
            if path == self.targets[1]:
                raise OSError("simulated write failure")
            real_write(path, data)
        with patch.object(snapshots, "atomic_write", side_effect=fail_second):
            with self.assertRaises(OSError):
                snapshots.restore(self.root, archive, self.targets)
        self.assertTrue(all(json.loads(p.read_text())["value"] == 2 for p in self.targets))


class UpdateTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.bin = Path(self.temp.name)
        for command in ("mktemp", "rm", "jq", "timeout"):
            (self.bin / command).symlink_to(shutil.which(command))

    def command(self, name, body):
        file = self.bin / name
        file.write_text('#!/bin/bash\n' + body + '\n')
        file.chmod(0o700)

    def query(self):
        result = subprocess.run(['/bin/bash', str(ROOT / 'src/controlcenter/tools/check-updates.sh')],
                                env={**os.environ, 'PATH': str(self.bin)}, capture_output=True, text=True, check=True)
        return json.loads(result.stdout)

    def test_offline_is_not_no_updates(self):
        self.command('checkupdates', 'exit 1')
        self.command('paru', 'exit 1')
        data = self.query()
        self.assertEqual(data['repositoryStatus'], 'error')
        self.assertEqual(data['aurStatus'], 'error')

    def test_empty_success_and_yay(self):
        self.command('checkupdates', 'exit 2')
        self.command('yay', 'printf "example 1 -> 2\\n"')
        data = self.query()
        self.assertEqual(data['repositoryStatus'], 'ok')
        self.assertEqual(data['aurStatus'], 'ok')
        self.assertEqual(data['aurTool'], 'yay')

    def test_cached_database_is_explicit(self):
        self.command('pacman', 'exit 0')
        data = self.query()
        self.assertEqual(data['repositoryStatus'], 'cached')
        self.assertEqual(data['aurStatus'], 'unavailable')


if __name__ == '__main__':
    unittest.main()
