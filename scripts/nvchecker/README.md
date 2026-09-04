# scripts/nvchecker

Version-drift tracking for the `stuff` overlay via
[nvchecker](https://github.com/lilydjwg/nvchecker), designed to run
from a local cron.

## What it does

A weekly (or however-you-like) cron runs `run.sh`, which queries each
tracked package's supported upstream source (including PyPI, GitHub,
GitLab, Bitbucket, CPAN and hand-defined mappings), diffs against the last
run, and prints a report to stdout. When invoked by cron, non-empty output
is delivered via local mail — so clean runs stay quiet. An entry that returns
no version for two consecutive runs is reported alongside ordinary version
drift so a stale filter does not remain silently invisible.

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
| `silent_entries.py` | Reports tracked entries missing from two consecutive local-run result sets |
| `tree_baseline.py` | Emits an nvchecker `oldver` baseline from current ebuild PVs (the CI "what does upstream have that we don't ship?" framing) |
| `nvtemplate_audit.py` | Audits per-package version-template *correctness* — detects templates that have gone stale vs upstream's current scheme (silent omission) |
| `requirements.txt` | Pins the nvchecker version installed by the CI runner |

## Setup

### GitHub token (required — the config has more than 200 GitHub entries)

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

For maintainer-only checks that should not enter the committed configuration,
set `STUFF_NVCHECKER_LOCAL_TOML` to another TOML file. `run.sh` appends that
file to its generated run configuration; CI deliberately leaves the variable
unset. This is useful for branch-tip or snapshot channels such as pf-kernel
and per-module Qt5 patch-collection watches.

## Regenerating the config

After adding, dropping, or retargeting packages in the overlay,
regenerate the tracker config:

```sh
./scripts/nvchecker/generate.py
```

The generator classifies each package's newest ebuild by source type, then
applies its package/repository-specific mappings for monorepos, unusual tag
schemes and deliberately pinned consumers:

- `inherit pypi`, or a `files.pythonhosted.org`, `pypi.io` or `pypi.org`
  SRC_URI → PyPI entry
- `github.com/.../archive/` in SRC_URI, `EGIT_REPO_URI` pointing at
  GitHub, or a plain GitHub `HOMEPAGE` → GitHub entry
  (`use_max_tag = true`, which works for both Release-curated repos
  and plain-tagged ones)
- `bitbucket.org/<owner>/<repo>` → Bitbucket entry
- `gitlab.*/<owner>/<repo>`, or a GitLab-style `/-/archive/` URL on any
  host → GitLab entry (with `host = "<instance>"` set for self-hosted
  installs such as gitlab.freedesktop.org, gitlab.gnome.org and
  gitlab.kde.org)
- `inherit perl-module` → CPAN entry (distribution name = `${PN}`)
- `sourceforge.net/project/<slug>/` or `downloads.sourceforge.net/<slug>/`
  → skip comment with a SourceForge hint (nvchecker 2.x has no built-in
  `sourceforge` source; a `regex` entry against the RSS feed works if
  tracking is wanted)
- Live-only (`-9999`) ebuilds → skip comment; no release number to track
- Python-2-pinned packages (ebuild name ends `-python2` or inherits
  a `*_py2` eclass) → skip comment; upstream has moved past py2
- `inherit qt5-build` → skip comment; these are fixed KDE Qt5 patch-collection
  snapshots whose branch-tip movement is monitored through the optional local
  config, not ordinary release-version drift
- Anything else → skip comment of the form `custom upstream at <host>;
  hand-add an nvchecker regex/htmlparser entry if tracking is wanted`,
  where `<host>` is the HOMEPAGE domain (falling back to SRC_URI)

Hand-edits to `nvchecker.toml` are overwritten on the next
`generate.py` run. To pin a non-obvious upstream, add the detection
rule to `generate.py` so the classification survives regeneration.

## Auditing template staleness

The drift report tells you when upstream *moves*. It cannot tell you when a
package's **version template silently stops matching** — if upstream changes its
tag scheme (a new major, a tag-prefix rename, a build-counter reset, an
even/odd-minor convention drop), a `github` entry's `include_regex` /
`from_pattern` can quietly match nothing or latch onto a stale tag, and the
package then reads "up to date" forever while its releases go untracked. That is
a silent, permanent omission a normal drift run cannot surface.

`nvtemplate_audit.py` catches it. For every tracked package it compares three
things — our newest ebuild PV, what the rendered template in `nvchecker.toml`
currently resolves, and upstream's true newest release — and buckets each entry:

```sh
python3 scripts/nvchecker/nvtemplate_audit.py            # all entries
python3 scripts/nvchecker/nvtemplate_audit.py --only cat/pkg,cat/pkg2
python3 scripts/nvchecker/nvtemplate_audit.py --source github
```

It reads the **rendered** filter straight from `nvchecker.toml` (so it audits
exactly what nvchecker uses) and reaches GitHub via `git ls-remote --tags` — the
git protocol, *not* the REST API — so it needs **no token** and is not subject to
the 60 req/hr limit. Needs network → run with the sandbox disabled.

Verdicts, most-actionable first:

| Verdict | Meaning |
| ------- | ------- |
| `UNRESOLVED` | the template matches **nothing** — almost certainly broken; fix now |
| `OMISSION-SUSPECT` | a version-like upstream tag newer than our matched latest is **excluded** by the filter — either a scheme change (fix) or an intended exclusion (a monorepo sibling family, a prerelease, an odd-minor dev release); needs human eyes |
| `SHAPE-DRIFT` | the resolved value's form differs from our PV's form (part count / prefix) — the mapping may have drifted |
| `WE-SHIP-NEWER` | our PV > upstream latest (usually benign: errata suffix, snapshot) |
| `SKIP` | source type not covered by this pass (cpan / gitlab / bitbucket / regex) — hand-check |

`OMISSION-SUSPECT` has a known intended-exclusion tail (deliberate one-repo-two-
package splits like `dev-ml/ocamlfuse` vs `dev-ml/fuse3`, monorepo sub-package or
sibling-artifact tag families, and the `media-gfx/darktable` even-minor policy).
The detector flags them for a glance; it never auto-edits. Nightly / build /
foreign-project tag channels (ROCm `therock-*`/`llvmorg-*`, calver `…a` alphas,
`YYYYMMDD` dates) are suppressed so they don't recur as noise.

When a fix *is* needed, correct the template in `generate.py` (the
`GITHUB_TAG_FILTERS_BY_PKG` / `GITHUB_TAG_FILTERS` / `SPECIAL_SOURCES` dict), and
if the scheme change also touched packaging, keep the ebuild PV / SRC_URI in step
so `upstream tag → nvchecker value → PV` line up. Then regenerate and re-audit the
one entry. The report is a point-in-time worklist (default `/tmp`), not committed.

## Output shape

Clean run (no drift and no persistently silent entries): silent.

Drift run: stdout looks roughly like

```
stuff overlay — nvchecker report
run: 2026-05-01T06:00:00+02:00

== version drift ==
dev-python/hyperspy 2.3.0 -> 2.4.0
dev-python/bokeh 3.4.1 -> 3.5.0
sci-physics/mantid 6.15.0.3 -> 6.16.0
```

Each line is `<category/pkg> <old> -> <new>`. Use it as a worklist
for the next round of bumps; run `emerge --ask =<atom>` locally to
test before committing. If the report also contains a
`no version for 2+ consecutive runs` section, audit those entries' source and
filter rules before treating the remaining list as complete.

## CI runner

The same `nvchecker.toml` is consumed by `.github/workflows/nvchecker.yml`.
Pull requests and relevant pushes run a cheap config-drift gate: the workflow
regenerates `nvchecker.toml` and fails if the committed result is stale. A
weekly upstream scan runs on Mondays at 06:00 UTC. It builds its baseline from
current ebuild PVs (via `tree_baseline.py`) rather than persisting last week's
upstream snapshot, so it answers a different question:

| Runner | Baseline | Question answered |
| ------ | -------- | ----------------- |
| local cron (`run.sh`) | last run's upstream snapshot | "what changed upstream since last week?" |
| CI (`nvchecker.yml`) | current ebuild PVs (`tree_baseline.py`) | "what does upstream have that we don't ship?" |

The two can coexist — the local runner's state lives in
`$XDG_STATE_HOME` outside the repo and doesn't touch CI in any way.
CI uploads the drift data and missing-version list as a 30-day workflow
artifact. It also maintains a rolling GitHub issue: a non-empty drift or
missing-version set opens or updates the issue, and a later clean run closes
it. Because CI is stateless, an entry missing from one weekly result is only a
warning there; the local runner requires the miss to persist across two runs.

## Design notes

- **No state in the repo**: `old_ver.json` / `new_ver.json` for the
  local runner live in `$XDG_STATE_HOME`; CI runs are entirely
  stateless against the worktree. The only thing version-controlled
  is the generated config and the scripts.
- **Silent on success (local)**: cron mails on non-empty stdout, so a
  clean week doesn't fill your inbox.
- **Network failures do not fail the run**: `run.sh` does not pass
  `--failures` to `nvchecker`, so a failed fetch does not make the whole run
  exit nonzero. Errors are still logged at the configured `error` level and
  may therefore produce cron mail; two-run persistence is required before a
  missing entry is added to the structured report. CI uses the same nonfatal
  convention and surfaces a one-run missing entry as a warning.
