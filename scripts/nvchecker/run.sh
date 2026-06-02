#!/usr/bin/env bash
#
# Run nvchecker against the overlay's config and report version drift.
#
# Designed for a local cron (weekly cadence is typical):
#
#     0 6 * * 0 /path/to/stuff/scripts/nvchecker/run.sh
#
# State (old_ver.json, new_ver.json) lives under
# $XDG_STATE_HOME/stuff-nvchecker/ (default: ~/.local/state/stuff-nvchecker/)
# and is not tracked by the repo. The first run establishes a baseline and
# prints nothing; subsequent runs print drift to stdout so cron delivers
# it via local mail.
#
# Requires: dev-util/nvchecker (installed as nvchecker + nvcmp in $PATH).

set -euo pipefail

HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
CONFIG="$HERE/nvchecker.toml"

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/stuff-nvchecker"
OLD="$STATE_DIR/old_ver.json"
NEW="$STATE_DIR/new_ver.json"
RUN_CFG="$STATE_DIR/nvchecker-run.toml"

command -v nvchecker >/dev/null || {
    echo "error: nvchecker not found in PATH — install dev-util/nvchecker" >&2
    exit 2
}
command -v nvcmp >/dev/null || {
    echo "error: nvcmp not found in PATH — install dev-util/nvchecker" >&2
    exit 2
}
[[ -f "$CONFIG" ]] || {
    echo "error: config not found at $CONFIG — run generate.py first" >&2
    exit 2
}

mkdir -p "$STATE_DIR"

first_run=false
[[ -f "$OLD" ]] || first_run=true

# nvchecker / nvcmp read oldver and newver paths from a [__config__] section
# in the config file. Rather than hard-coding the user's home directory into
# the committed nvchecker.toml, compose a per-run config that prepends a
# state-local [__config__] to the committed content.
#
# STUFF_NVCHECKER_LOCAL_TOML, if set and pointing at an existing file, has
# its body concatenated after the committed nvchecker.toml. This is the
# opt-in hook for maintainer-only triage entries that should never reach
# the GitHub Actions drift report (e.g. pf-kernel branch-tip watch, KDE
# Qt5 kde/5.15 per-module tip watch). Unset in CI → the file is ignored
# even if it happens to exist.
{
    printf '[__config__]\n'
    printf 'oldver = "%s"\n' "$OLD"
    printf 'newver = "%s"\n' "$NEW"
    printf '\n'
    cat "$CONFIG"
    if [[ -n "${STUFF_NVCHECKER_LOCAL_TOML:-}" && -f "$STUFF_NVCHECKER_LOCAL_TOML" ]]; then
        printf '\n'
        cat "$STUFF_NVCHECKER_LOCAL_TOML"
    fi
} > "$RUN_CFG"

# Run version checks. --logger pretty keeps output readable if the user ever
# runs this interactively; -l error silences the per-entry INFO noise in cron.
# Do not pass --failures: transient network errors should not spam mail.
#
# If a nvchecker keyfile exists at the standard XDG location, pass it — the
# GitHub source needs a token to avoid the 60-req/hour unauthenticated rate
# limit, which is trivially exceeded by this config's ~60 GitHub entries.
KEYFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nvchecker/keyfile.toml"
if [[ -f "$KEYFILE" ]]; then
    nvchecker -c "$RUN_CFG" -k "$KEYFILE" -l error --logger pretty
else
    nvchecker -c "$RUN_CFG" -l error --logger pretty
fi

if $first_run; then
    count=$(grep -cE '^\[' "$CONFIG" || true)
    echo "stuff-nvchecker: baseline established ($count entries tracked)"
    echo "future runs will report drift."
else
    drift="$(nvcmp -c "$RUN_CFG" 2>&1 || true)"

    # Surface entries that produced no version in BOTH this run and the
    # previous one. nvchecker logs the empty-filter case ('include_regex
    # matched no versions') at WARNING, below our -l error threshold, so an
    # upstream tag-scheme pivot that empties a filter would otherwise fail
    # silently (no version => no drift => looks up-to-date forever). The
    # detector is a set difference over verfile keys: source-agnostic and
    # needing no log parsing. Requiring a miss in two consecutive runs drops
    # transient fetch/rate-limit blips; $NEW/$OLD are still this run / last
    # run here (rotation happens below).
    silent="$(python3 "$HERE/silent_entries.py" "$CONFIG" "$NEW" "$OLD" 2>/dev/null || true)"

    if [[ -n "$drift" || -n "$silent" ]]; then
        echo "stuff overlay — nvchecker report"
        echo "run: $(date -Iseconds)"
        if [[ -n "$drift" ]]; then
            echo
            echo "== version drift =="
            printf '%s\n' "$drift"
        fi
        if [[ -n "$silent" ]]; then
            echo
            echo "== no version for 2+ consecutive runs =="
            echo "Likely an upstream tag-scheme pivot that silently emptied the"
            echo "entry's include_regex — re-check the filter in generate.py:"
            while IFS= read -r atom; do
                echo "  $atom"
            done <<<"$silent"
        fi
    fi
    # Silent when clean — cron only mails when stdout is non-empty.
fi

# Rotate: new becomes the next run's baseline.
mv -f "$NEW" "$OLD"
