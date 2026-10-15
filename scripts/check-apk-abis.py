#!/usr/bin/env python3
"""Reject native libraries whose ELF architecture disagrees with their APK path."""

import argparse
import struct
import sys
import zipfile

# Android ABI: ELF class, ELF machine.
EXPECTED = {"armeabi-v7a": (1, 40), "arm64-v8a": (2, 183)}


def check_apk(path):
    errors = []
    found = set()
    with zipfile.ZipFile(path) as apk:
        for name in apk.namelist():
            parts = name.split("/")
            if len(parts) != 3 or parts[0] != "lib" or not name.endswith(".so"):
                continue
            abi = parts[1]
            if abi not in EXPECTED:
                errors.append(f"{name}: unexpected ABI {abi}")
                continue
            found.add(name)
            with apk.open(name) as library:
                header = library.read(20)
            if len(header) < 20 or header[:4] != b"\x7fELF" or header[5] not in (1, 2):
                errors.append(f"{name}: invalid ELF header")
                continue
            machine = struct.unpack_from("<H" if header[5] == 1 else ">H", header, 18)[0]
            actual = (header[4], machine)
            if actual != EXPECTED[abi]:
                errors.append(f"{name}: ELF class/machine {actual}, expected {EXPECTED[abi]}")
        for abi in EXPECTED:
            for library in ("libApplicationMain.so", "liblime.so"):
                name = f"lib/{abi}/{library}"
                if name not in found:
                    errors.append(f"{name}: missing required library")
    return errors


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("apks", nargs="+")
    args = parser.parse_args()
    failed = False
    for path in args.apks:
        try:
            errors = check_apk(path)
        except (OSError, zipfile.BadZipFile) as error:
            errors = [str(error)]
        for error in errors:
            print(f"{path}: {error}", file=sys.stderr)
        if errors:
            failed = True
        else:
            print(f"{path}: ARMv7 and ARM64 native libraries verified")
    return int(failed)


if __name__ == "__main__":
    sys.exit(main())
