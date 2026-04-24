# scripts/nvchecker

Version-drift tracking for the `stuff` overlay via
[nvchecker](https://github.com/lilydjwg/nvchecker), designed to run
from a local cron.

## What it does

A weekly (or however-you-like) cron runs `run.sh`, which queries each
tracked package's upstream (PyPI, GitHub releases, SourceForge, CPAN),
diffs against the last run, and prints a drift report to stdout. When
invoked by cron, non-empty output is delivered via local mail — so
quiet runs stay quiet, and only genuine upstream movement generates
notifications.

State lives under `$XDG_STATE_HOME/stuff-nvchecker/` (default
`~/.local/state/stuff-nvchecker/`), outside this repo.

## Requirements

- `dev-util/nvchecker` (installs `nvchecker` and `nvcmp` into `$PATH`)
- A working `cron` delivery (for the notification channel)

## Files

| File | Purpose |
| ---- | ------- |
| `generate.py` | Walks the overlay, emits `nvchecker.toml` by classifying each package's upstream source |
| `nvchecker.toml` | Generated config: one entry per trackable package, skip comments for untrackable ones |
| `run.sh` | Cron-friendly runner: executes `nvchecker`, diffs against last run via `nvcmp`, prints drift |

## Setup

### GitHub token (required — the config has ~60 GitHub entries)

The GitHub API rate-limits unauthenticated requests to 60/hour per IP,
which is trivially exceeded by this config. Create a personal access
token (public-read scope is enough — a classic PAT with no scopes
works, or a fine-grained token with no extra permissions) and put it
in `~/.config/nvchecker/keyfile.toml`:

```toml
[keys]
github = "ghp_..."
```

`run.sh` looks for that file automatically and passes it via
`nvchecker -k` when present. Without it, most GitHub entries will
fail with "rate limited" after the first ~60 requests and the tool
is effectively useless for GitHub tracking.

### First run

```sh
./scripts/nvchecker/run.sh
```

The first run fetches current upstream versions for every tracked
package and exits after printing `baseline established`. No drift is
reported because there's nothing to diff against yet.

### Cron

Add an entry. Weekly is fine:

```cron
0 6 * * 0 /path/to/stuff/scripts/nvchecker/run.sh
```

## Regenerating the config

After adding, dropping, or retargeting packages in the overlay,
regenerate the tracker config:

```sh
./scripts/nvchecker/generate.py
```

The generator classifies each package's newest ebuild by source type:

- `inherit pypi` or `pypi.io` SRC_URI → PyPI entry
- `github.com/.../archive/` in SRC_URI, `EGIT_REPO_URI` pointing at
  GitHub, or a plain GitHub `HOMEPAGE` → GitHub entry
  (`use_max_tag = true`, which works for both Release-curated repos
  and plain-tagged ones)
- `bitbucket.org/<owner>/<repo>` → Bitbucket entry
- `gitlab.*/<owner>/<repo>` → GitLab entry (with `host = "<instance>"`
  set for self-hosted installs like gitlab.freedesktop.org,
  gitlab.gnome.org, gitlab.kde.org)
- `inherit perl-module` → CPAN entry (distribution name = `${PN}`)
- `sourceforge.net/project/<slug>/` or `downloads.sourceforge.net/<slug>/`
  → skip comment with a SourceForge hint (nvchecker 2.x has no built-in
  `sourceforge` source; a `regex` entry against the RSS feed works if
  tracking is wanted)
- Live-only (`-9999`) ebuilds → skip comment; no release number to track
- Python-2-pinned packages (ebuild name ends `-python2` or inherits
  a `*_py2` eclass) → skip comment; upstream has moved past py2
- `inherit qt5-build` → skip comment; tracked via ::gentoo's Qt 5
  snapshot rather than upstream Qt release cadence
- Anything else → skip comment of the form `custom upstream at <host>;
  hand-add an nvchecker regex/htmlparser entry if tracking is wanted`,
  where `<host>` is the HOMEPAGE domain (falling back to SRC_URI)

Hand-edits to `nvchecker.toml` are overwritten on the next
`generate.py` run. To pin a non-obvious upstream, add the detection
rule to `generate.py` so the classification survives regeneration.

## Output shape

Clean run (nothing changed upstream): silent.

Drift run: stdout looks roughly like

```
stuff overlay — nvchecker drift report
run: 2026-05-01T06:00:00+02:00

dev-python/hyperspy 2.3.0 -> 2.4.0
dev-python/bokeh 3.4.1 -> 3.5.0
sci-physics/mantid 6.15.0.3 -> 6.16.0
```

Each line is `<category/pkg> <old> -> <new>`. Use it as a worklist
for the next round of bumps; run `emerge --ask =<atom>` locally to
test before committing.

## Design notes

- **No GitHub Actions**: this intentionally runs on your machine, not
  in CI. Keeps Actions minutes free, avoids bot commits, and the
  solo-maintainer workflow doesn't need cross-machine visibility.
- **No state in the repo**: `old_ver.json` / `new_ver.json` live in
  `$XDG_STATE_HOME`. The only thing version-controlled is the
  generated config and the scripts.
- **Silent on success**: cron mails on non-empty stdout, so a clean
  week doesn't fill your inbox.
- **Transient network failures don't mail**: `run.sh` does not pass
  `--failures` to `nvchecker`, so a flaky PyPI response during one
  run doesn't turn into a false drift report.
