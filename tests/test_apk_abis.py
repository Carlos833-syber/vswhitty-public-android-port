import importlib.util
from pathlib import Path
import struct
import tempfile
import unittest
import zipfile


spec = importlib.util.spec_from_file_location(
    "apk_abis", Path(__file__).resolve().parents[1] / "scripts/check-apk-abis.py"
)
apk_abis = importlib.util.module_from_spec(spec)
spec.loader.exec_module(apk_abis)


def elf(elf_class, machine):
    header = bytearray(64)
    header[:6] = b"\x7fELF" + bytes([elf_class, 1])
    struct.pack_into("<H", header, 18, machine)
    return header


class ApkAbiTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.path = Path(self.temp.name) / "test.apk"
        self.libraries = {
            "lib/armeabi-v7a/libApplicationMain.so": elf(1, 40),
            "lib/armeabi-v7a/liblime.so": elf(1, 40),
            "lib/arm64-v8a/libApplicationMain.so": elf(2, 183),
            "lib/arm64-v8a/liblime.so": elf(2, 183),
        }

    def check(self):
        with zipfile.ZipFile(self.path, "w") as apk:
            for name, data in self.libraries.items():
                apk.writestr(name, data)
        return apk_abis.check_apk(self.path)

    def test_correct_universal_apk(self):
        self.assertEqual(self.check(), [])

    def test_rejects_reported_arm64_library_in_armv7_directory(self):
        self.libraries["lib/armeabi-v7a/libApplicationMain.so"] = elf(2, 183)
        errors = self.check()
        self.assertEqual(len(errors), 1)
        self.assertIn("lib/armeabi-v7a/libApplicationMain.so", errors[0])
        self.assertIn("expected (1, 40)", errors[0])

    def test_checks_engine_libraries_too(self):
        self.libraries["lib/arm64-v8a/liblime.so"] = elf(1, 40)
        self.assertEqual(len(self.check()), 1)

    def test_missing_library(self):
        del self.libraries["lib/arm64-v8a/liblime.so"]
        self.assertIn("missing required library", self.check()[0])

    def test_invalid_elf(self):
        self.libraries["lib/armeabi-v7a/libApplicationMain.so"] = b"invalid"
        self.assertIn("invalid ELF header", self.check()[0])

    def test_apk_without_native_libraries(self):
        self.libraries.clear()
        self.assertEqual(len(self.check()), 4)


if __name__ == "__main__":
    unittest.main()
