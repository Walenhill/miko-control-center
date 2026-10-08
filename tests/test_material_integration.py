"""Optional native miko-theme contract tests. Never touch desktop settings."""
import json
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import MagicMock, patch

source = Path.home() / ".local/share/miko-theme/src"
available = (source / "miko_theme/integration.py").exists()
if available:
    sys.path.insert(0, str(source))
    from miko_theme import cli, integration, config


@unittest.skipUnless(available, "optional miko-theme integration API not installed")
class MaterialIntegrationContract(unittest.TestCase):
    def test_color_refresh_skips_material_adapters(self):
        cfg = MagicMock(active_mode="calm", notify=False)
        cfg.enabled_adapters = {"illogical": True, "hyprland": True, "vesktop": True}
        cfg.paths = {}
        cfg.raw = {}
        adapters = {name: MagicMock() for name in cfg.enabled_adapters}
        for adapter in adapters.values():
            adapter.apply.return_value = (True, "ok")
        with patch.object(cli, "load_mode", return_value={"name": "calm"}), patch.object(cli, "build_tokens", return_value=({}, False)), patch.object(cli, "get_adapters", return_value=adapters), patch.object(cli, "notify"), patch("builtins.print"):
            self.assertEqual(cli._apply_mode(cfg, create_backup_flag=False), 0)
            adapters["illogical"].apply.assert_not_called()
            adapters["hyprland"].apply.assert_not_called()
            adapters["vesktop"].apply.assert_called_once()
            self.assertEqual(cli._apply_mode(cfg, create_backup_flag=False, apply_materials=True), 0)
            adapters["illogical"].apply.assert_called_once()
            adapters["hyprland"].apply.assert_called_once()

    def test_stale_blur_snapshot_never_writes(self):
        with tempfile.TemporaryDirectory() as directory, patch.object(integration, "BASE_DIR", Path(directory)), patch.object(integration.Config, "load"), patch.object(integration, "live_blur", return_value={"enabled": False, "size": 8, "passes": 2}), patch.object(integration, "create_backup") as backup, patch.object(integration.HyprlandAdapter, "apply") as apply, patch("builtins.print"):
            self.assertEqual(integration.apply_blur(True, 6, 2, {"enabled": True, "size": 6, "passes": 2}), 1)
            backup.assert_not_called()
            apply.assert_not_called()

    def test_read_only_config_and_unknown_metadata_preservation(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "config.json"
            original = {"activeMode": "calm", "integrationMetadata": {"custom": True}}
            path.write_text(json.dumps(original))
            with patch.object(config, "BASE_DIR", Path(directory)):
                cfg = config.Config.load(path, read_only=True)
                self.assertEqual(json.loads(path.read_text()), original)
                cfg.save(path)
                self.assertEqual(json.loads(path.read_text())["integrationMetadata"], {"custom": True})

    def test_blur_range_is_bounded_before_any_command(self):
        with patch.object(integration.HyprlandAdapter, "apply") as apply:
            with self.assertRaises(ValueError):
                integration.apply_blur(True, 99, 8)
            apply.assert_not_called()

    def test_color_refresh_does_not_replay_ayugram_settings(self):
        from miko_theme.adapters.base import ApplyContext
        from miko_theme.adapters.ayugram import AyuGramAdapter
        adapter = AyuGramAdapter(MagicMock())
        with patch.object(adapter, "apply_theme_bundle", return_value=(True, "colors")) as theme, patch.object(adapter, "apply_window_rules") as rules:
            self.assertEqual(adapter.apply(ApplyContext(MagicMock(), {}, {}, colors_only=True)), (True, "colors"))
            theme.assert_called_once()
            rules.assert_not_called()


if __name__ == "__main__":
    unittest.main()
