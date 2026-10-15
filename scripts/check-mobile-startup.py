#!/usr/bin/env python3
"""Run the mobile startup path on Neko/Xvfb; this does not emulate Android."""

import os
from pathlib import Path
import signal
import subprocess
import tempfile


def main():
    root = Path(__file__).resolve().parents[1]
    build = root / "export/debug/neko"
    original = (build / "haxe/debug.hxml").read_text()
    if original.count("-main ApplicationMain") != 1:
        raise SystemExit("Expected exactly one generated ApplicationMain entry point")
    with tempfile.TemporaryDirectory(prefix="whitty-startup-") as temporary:
        hxml = Path(temporary) / "smoke.hxml"
        hxml.write_text(
            original.replace("-main ApplicationMain", "-main MobileStartupSmoke")
            + "\n-cp tests\n"
        )
        subprocess.run(["haxe", str(hxml)], cwd=root, check=True)
    environment = dict(os.environ)
    environment.update(
        SDL_AUDIODRIVER="dummy", ALSOFT_DRIVERS="null", LIBGL_ALWAYS_SOFTWARE="1"
    )
    process = subprocess.Popen(
        ["xvfb-run", "-a", "neko", "../obj/ApplicationMain.n"],
        cwd=build / "bin",
        env=environment,
        start_new_session=True,
    )
    try:
        return process.wait(timeout=30)
    except subprocess.TimeoutExpired:
        print("FAIL: startup did not complete within 30 seconds", flush=True)
        return 1
    finally:
        # Xvfb and the game can survive a TERM sent to their wrapper.
        try:
            os.killpg(process.pid, signal.SIGKILL)
        except ProcessLookupError:
            pass
        process.wait()


if __name__ == "__main__":
    raise SystemExit(main())
