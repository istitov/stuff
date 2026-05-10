#!/usr/bin/env python3
"""Emit an nvchecker-format old_ver.json baseline from current ebuild PVs.

For each package listed in scripts/nvchecker/nvchecker.toml that has a
``source`` set (i.e. is being tracked), find the newest non-live ebuild
in the package directory and record its PV as the baseline "current"
version. Output is JSON to stdout, suitable for direct use as
nvchecker's ``oldver`` path via the ``[__config__]`` section.

This differs from the local-cron model in scripts/nvchecker/run.sh: that
one persists last week's upstream snapshot as the baseline and reports
"what changed upstream since." This one reports "what we ship vs. what
upstream has now," which is the right framing for CI-driven bump
detection (drift relative to the tree, not relative to time).

Lexical sort is used to pick the newest ebuild — same heuristic as
generate.py:find_newest_ebuild. It's correct for most PVs and degrades
gracefully for edge cases (1.10.0 sorts as < 1.9.0 lexically, so a
package at 1.10.0 would falsely report drift to upstream's 1.10.0 once
the wrong baseline pointed at 1.9.0). Phase 2 will swap in a proper
PMS-aware sort if the false-positive rate matters.
"""

from __future__ import annotations

import json
import sys
import tomllib
from pathlib import Path


def main() -> int:
    here = Path(__file__).resolve().parent
    overlay_root = here.parent.parent
    config_path = here / "nvchecker.toml"

    if not config_path.is_file():
        print(f"error: {config_path} not found", file=sys.stderr)
        return 2

    config = tomllib.loads(config_path.read_text())

    data: dict[str, dict[str, str]] = {}
    for entry, conf in config.items():
        if entry.startswith("__"):
            continue
        if not isinstance(conf, dict) or "source" not in conf:
            continue
        if "/" not in entry:
            continue
        cat, pkg = entry.split("/", 1)
        pkgdir = overlay_root / cat / pkg
        if not pkgdir.is_dir():
            continue
        # Newest non-live ebuild by lexical sort. Live ebuilds are
        # marked by an all-9s PV: the standard 9999, revision-bumped
        # 9999-rN, snapshot conventions like 999999, or dotted variants
        # like 9.9999. Strip the revision and check whether what's left
        # is all 9s ignoring dots.
        released = []
        for eb in pkgdir.glob(f"{pkg}-*.ebuild"):
            pv = eb.stem[len(pkg) + 1:]
            base_pv = pv.split("-r")[0]
            if set(base_pv.replace(".", "")) == {"9"}:
                continue
            released.append((pv, eb))
        if not released:
            continue
        released.sort()
        newest_pv = released[-1][0]
        data[entry] = {"version": newest_pv}

    out = {"version": 2, "data": data}
    json.dump(out, sys.stdout, indent=2, sort_keys=True)
    sys.stdout.write("\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
