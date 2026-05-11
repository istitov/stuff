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

Versioned sort order: packaging.version.Version is used after normalising
Portage-specific suffixes (_pN, _rcN, _alphaN, _betaN, _preN, -rN) to
their PEP 440 equivalents.  Versions that still can't be parsed fall back
to a tuple-of-int-parts key so multi-digit segments (e.g. 0.100.0 vs
0.86.0) always rank correctly.
"""

from __future__ import annotations

import json
import re
import sys
import tomllib
from pathlib import Path

try:
    from packaging.version import Version, InvalidVersion
    _HAVE_PACKAGING = True
except ImportError:
    _HAVE_PACKAGING = False


_PORTAGE_TO_PEP440 = [
    (re.compile(r'-r\d+$'),       r''),
    (re.compile(r'_p(\d+)$'),     r'.post\1'),
    (re.compile(r'_rc(\d+)$'),    r'rc\1'),
    (re.compile(r'_alpha(\d+)$'), r'a\1'),
    (re.compile(r'_beta(\d+)$'),  r'b\1'),
    (re.compile(r'_pre\d*$'),     r'.dev0'),
]


def _pv_sort_key(pv: str) -> tuple:
    """Return a sort key for a Portage PV that handles multi-digit segments.

    Normalises Portage suffixes to PEP 440 and uses packaging.version if
    available; falls back to a tuple-of-(int-or-str) parts otherwise.
    """
    normalized = pv
    for pat, repl in _PORTAGE_TO_PEP440:
        normalized = pat.sub(repl, normalized)
    if _HAVE_PACKAGING:
        try:
            return (0, Version(normalized), pv)
        except InvalidVersion:
            pass
    # Fallback: split on separators and compare numerically where possible.
    parts = re.split(r'[.\-_]', normalized)
    int_parts: list[tuple[int, int | str]] = []
    for p in parts:
        try:
            int_parts.append((0, int(p)))
        except ValueError:
            int_parts.append((1, p))
    return (1, tuple(int_parts), pv)


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
        # Newest non-live ebuild.  Live ebuilds are marked by an all-9s PV:
        # the standard 9999, revision-bumped 9999-rN, snapshot conventions
        # like 999999, or dotted variants like 9.9999.  Strip the revision
        # suffix and check whether what remains is all 9s ignoring dots.
        released = []
        for eb in pkgdir.glob(f"{pkg}-*.ebuild"):
            pv = eb.stem[len(pkg) + 1:]
            base_pv = pv.split("-r")[0]
            if set(base_pv.replace(".", "")) == {"9"}:
                continue
            released.append((pv, eb))
        if not released:
            continue
        released.sort(key=lambda pair: _pv_sort_key(pair[0]))
        newest_pv, newest_eb = released[-1]
        # For perl-module ebuilds, read DIST_VERSION directly from the ebuild
        # rather than parsing the filename's PV.  Gentoo's perl eclass munges
        # upstream CPAN versions (e.g. "v0.0.3" → "0.0.3", "2.35" → "2.350.0")
        # to fit Portage version semantics; the CPAN source returns the raw
        # upstream string, so using the munged PV produces permanent
        # false-positive drift.  DIST_VERSION holds the original CPAN value.
        if conf.get("source") == "cpan":
            try:
                ebuild_text = newest_eb.read_text(errors="replace")
                m = re.search(r'^\s*DIST_VERSION=(?:"([^"]+)"|\'([^\']+)\'|(\S+))',
                              ebuild_text, re.MULTILINE)
                if m:
                    newest_pv = next(g for g in m.groups() if g is not None)
            except OSError:
                pass
        # Strip Portage revision suffix (-rN) — nvchecker tracks upstream
        # version numbers, not our in-overlay revision bumps.
        newest_pv = re.sub(r'-r\d+$', '', newest_pv)
        # Strip date-based snapshot suffix (_pYYYYMMDD or similar long numeric
        # suffixes) — these are in-overlay snapshot markers that have no
        # counterpart in the upstream tag, so emit just the base version.
        newest_pv = re.sub(r'_p\d{5,}$', '', newest_pv)
        # Normalize Portage post-release suffix (_pN with 1-4 digits) to PEP
        # 440 form (.postN) so pypi-sourced entries compare without spurious
        # drift.  Applied after the long-suffix strip above.
        newest_pv = re.sub(r'_p(\d{1,4})$', r'.post\1', newest_pv)
        data[entry] = {"version": newest_pv}

    out = {"version": 2, "data": data}
    json.dump(out, sys.stdout, indent=2, sort_keys=True)
    sys.stdout.write("\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
