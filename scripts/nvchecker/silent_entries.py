#!/usr/bin/env python3
"""Report tracked entries that produced no version across two runs.

nvchecker logs `include_regex matched no versions` at WARNING level. The
overlay's run.sh runs at `-l error`, so a filter that an upstream
tag-scheme pivot has emptied fails *silently*: it returns no version, which
means no drift, which looks identical to "up to date" forever.

This detector closes that gap source-agnostically. It compares the set of
active entries in the committed config against the keys actually present in
the current and previous verfiles, and prints every entry missing from
*both*. Requiring absence in two consecutive runs suppresses transient
fetch/rate-limit blips (a one-run miss self-resolves); a miss that persists
is the signal worth a human look — usually a stale include_regex.

Usage: silent_entries.py <config.toml> <new_ver.json> <old_ver.json>

A missing verfile (e.g. a crashed run that never wrote new_ver.json) is
treated as an empty key set, so a catastrophic run can't false-alarm every
entry — only those absent from the previous run too are reported.
"""

import json
import sys
import tomllib


def verfile_keys(path: str) -> set[str]:
    try:
        with open(path) as f:
            return set(json.load(f).get("data", {}))
    except FileNotFoundError:
        return set()


def main() -> int:
    config_path, new_ver, old_ver = sys.argv[1:4]
    with open(config_path, "rb") as f:
        config = tomllib.load(f)
    # Active entries are top-level tables that nvchecker treats as
    # tracked sources (have a `source` field). The committed config
    # also contains skipped packages as commented `# ["cat/pkg"]`
    # lines; tomllib ignores comments, so those never reach the
    # parsed dict. The `__config__` block (per-run state-path prepend
    # from run.sh, when present) is filtered explicitly.
    expected = {
        k for k, v in config.items()
        if not k.startswith("__") and isinstance(v, dict) and "source" in v
    }
    silent = expected - verfile_keys(new_ver) - verfile_keys(old_ver)
    for atom in sorted(silent):
        print(atom)
    return 0


if __name__ == "__main__":
    sys.exit(main())
