# Contributing to `stuff`

Thanks for taking a look. 🖤 This overlay is maintained by a small
number of contributors, but PRs, bug reports, and patches are welcome
— especially for packages you actually use on your own system.

This document is the house-style checklist. It is not a replacement
for the broader Gentoo guides:

- [Contributing to Gentoo](https://wiki.gentoo.org/wiki/Contributing_to_Gentoo)
  — big-picture entry point.
- [GURU / Information for Contributors](https://wiki.gentoo.org/wiki/Project:GURU/Information_for_Contributors)
  — the contributor guide for Gentoo's user-run overlay; most of the
  tooling and workflow there applies here too.

If something here disagrees with those pages for a reason that is
not obvious, that is a bug in this file — please open an issue.

## Scope

The overlay grew around a few specific maintenance interests, and
that's where its packages mostly cluster. Contributions are welcome
regardless — though for packages outside those areas, the conversation
may end with "this might fit better in [some other overlay]" rather
than a merge. That's a discussion, not an automatic no; the overlay
already carries a handful of packages that landed for historical
reasons unrelated to the current focus.

What we mostly cover:

- **Niche scientific physics** — SAXS / SANS / XAFS / EM /
  micromagnetism / Rietveld (mantid, mumax, oommf, xraylarch,
  demeter, vampire, bornagain, …)
- **DeaDBeeF plugin ecosystem** — the [DeaDBeeF](https://deadbeef.sf.net/)
  audio player's third-party plugins
- **Local AI / ML** — ComfyUI, Unsloth, local LLM runtimes, evaluation and
  RAG tooling, plus the split PyTorch/Caffe2 and ONNX ecosystems
- **GPU and accelerator stacks** — AMD Ryzen-AI / XDNA, source and binary
  ROCm distributions, and CUDA-facing packages, typically ahead of
  `::gentoo`
- **TeX Live and legacy GUI support** — current TeX Live collections and
  the Qt5 revival retained for consumers that have not completed Qt6 ports
- **The `pf-sources` line** — two deliberately co-installable tiers,
  both maintained separately from the upstream pf-kernel cadence:
  `pf-sources` (the full pf patchset, GA-frozen, with surgical CVE
  backports) and `pf-sources-extended` (a vanilla + genpatches base
  that does track linux-stable, carrying a curated subset of the pf
  delta)
- **Python-2 preservation** — `*_py2` forks of py3-only `::gentoo`
  packages, kept alive for legacy scientific Python consumers

If you're unsure whether something fits here, opening an issue
first is cheap and usually clearer than guessing.

## Before you start

- Clone the repo (or your fork), then either enable it via
  `eselect repository enable stuff` and `emerge --sync stuff`, or
  point your own overlay config at the working tree.
- Install the tooling: `dev-util/pkgdev` and `dev-util/pkgcheck`.
- Keep `dev-python/tree-sitter` below 0.26.0 (today that means
  0.25.2-r1). 0.26.0 crashes the bash parser `pkgcheck` uses, and it
  does so *silently*: the affected results are dropped and the scan
  still exits 0, so a broken toolchain looks like a clean tree. If a
  scan suddenly reports nothing, check that version before believing
  it. (verified 2026-07-28)
- The repo declares `masters = gentoo` and `thin-manifests = true`
  — every package depends on `::gentoo` being available, and
  `Manifest` files only carry `DIST` lines.

## 📦 Per-commit checklist

One package per commit. No mixed-package commits except for
cross-cutting infrastructure (eclasses, profiles, masks).

- [ ] The change is scoped to a single `category/pkg/` directory
      (or a single eclass / profile file).
- [ ] If the resolved distfile set or checksums changed — including for an
      ordinary version bump whose `SRC_URI` still uses the same `${PV}`
      expression — `pkgdev manifest` has been re-run.
- [ ] If a package was added, dropped, or retargeted, `generate.py` has
      regenerated `scripts/nvchecker/nvchecker.toml` — in its own
      `scripts/nvchecker:` commit, not this one (see step 7 below).
- [ ] `pkgcheck scan <category>/<pkg>` is clean, or any new warning
      is documented in the commit body or `metadata/pkgcheck.conf`.
- [ ] The relevant build, test and install phases have been exercised; any
      validation that could not be run is identified in the commit body.
- [ ] The copyright header on any new/edited ebuild reads
      `# Copyright 1999-<current year> Gentoo Authors`.
- [ ] Commit message follows the shape below.

## Commit message form

Use `pkgdev commit` — it composes the subject automatically from
the staged diff. The body is on you.

- **Subject** — `category/pkg: <action> [version]`.
  Examples in recent history:
  - `sci-libs/cholmod: bump to 5.3.4`
  - `dev-python/pycuda: drop rocm USE`
  - `media-plugins/deadbeef-jack: patch for current deadbeef API`
- **Blank line.**
- **Body** — two or three short paragraphs explaining *why*, not
  *what*, hard-wrapped at 72 columns. The diff shows what. The body
  should cover:
  - Why this change is needed now (upstream release, bug, policy).
  - Any non-obvious decision (e.g. "kept `~amd64` only because the
    dep is `~amd64`-only in this overlay").
  - Dated-verification notes where appropriate — see below.

Single-line commits are fine for truly trivial edits (typo fixes,
one-line metadata tweaks). Default to subject+body otherwise.

Review fixups made before publication belong in the commit that introduced
the change. Squash them rather than retaining follow-up `fix`, `drop`,
`restore`, or similar repair commits. A package addition and a later version
drop remain separate commits as described below.

## Per-package workflow

The loop the maintainer uses:

1. `pkgcheck scan <category>/<pkg>` — record the starting baseline. Scan
   without `--exit`: the point here is to read every finding, not to get a
   pass/fail.
2. For a bump, copy the newest ebuild as a starting point, then reassess it
   against the new release. Inspect upstream's build metadata and source tree
   for changed build, runtime and test dependencies; renamed options;
   automagic feature detection; bundled libraries; and compiler or language
   requirements. A clean textual copy is not evidence that the build
   interface stayed unchanged.
3. Check each meaningful USE combination. At minimum cover the smallest
   supported feature set and the largest relevant set when optional modules
   alter dependencies or installed files. Verify that disabled features do
   not build through host autodetection.
4. Exercise the full build and staged install, not only compilation. A local
   `emerge -1 =category/pkg-version` is preferred; otherwise run at least
   `ebuild <pkg>.ebuild clean install`, and where practical merge into a
   throwaway `ROOT=` on real disk — under `/var/tmp/`, not `/tmp`, which is
   a RAM-backed tmpfs on many systems and will not survive staging a large
   package. Then read the result: the image should hold the files you
   expect, and a staged merge's VDB the dependencies you declared. A green
   build is not that evidence — an automagic probe can fail silently and
   drop a whole feature without changing the exit status. Run the upstream
   test phase when it is usable.
5. `pkgcheck scan <category>/<pkg>` again — confirm no regression against
   that baseline.
6. Run `pkgdev manifest` if the resolved distfiles or checksums changed,
   including for ordinary version bumps.
7. If the package set or upstream mapping changed, run
   `./scripts/nvchecker/generate.py` and verify the resulting entry. Keep the
   generated-config update in a separate `scripts/nvchecker:` infrastructure
   commit so the package commit remains single-package.
8. `pkgdev commit` with a body that records non-obvious decisions and any
   validation limitation.

Do one package at a time. Do not batch unrelated packages into a
single commit — it makes reverts and bisects painful.

## Before pushing

- [ ] `pkgcheck scan --exit GentooCI,-VisibleVcsPkg,-DroppedKeywords
      --commits <base>` exits clean on your branch, using the same explicit
      base-ref framing and exit set as CI. `--exit` selects what fails the
      run, not what gets reported: findings outside that set still print, and
      still deserve a look.
- [ ] No `metadata/md5-cache/` files are staged — the directory
      is gitignored and must stay that way.
- [ ] No secrets, distfile payloads, or binary blobs snuck in.

What CI actually runs — the canonical list; README links here rather than
repeating it:

- `.github/workflows/pkgcheck.yml` re-runs the commit-diff scan on pull
  requests and relevant pushes to `master`; a 3-day cron runs a repo-wide
  scan; and a change to `metadata/layout.conf` or `metadata/pkgcheck.conf`
  triggers an immediate full validation.
- `.github/workflows/nvchecker.yml` checks on pull requests and relevant
  pushes that the generated `nvchecker.toml` is current, and runs a weekly
  upstream drift scan.
- `.github/workflows/dusty.yml` runs quarterly and reports packages
  untouched for more than 60 days.

URL-liveness checks (`pkgcheck scan --net`) are not part of CI — run them
locally if you change an upstream URL.

## 🧩 Conventions

### `metadata.xml`

- `https://` DTD, two-space indent.
- Packages maintained here carry `iohann.s.titov@gmail.com` with
  `<name>Ivan S. Titov</name>`.
- Ebuilds imported from another overlay keep their original
  maintainer entry verbatim — the upstream author's own email and
  name, and any `proxied="yes"`. Don't overwrite it with this
  overlay's identity; add a second `<maintainer>` if you need to be
  reachable too. Some inherited entries carry an email with no
  `<name>`; that is how they arrived, and is left alone rather than
  guessed at.
- Add `<upstream><remote-id>` entries where they exist
  (`pypi`, `github`, `sourceforge`, etc.).

### `*_py2` eclasses

`eclass/` carries locally-vendored `*_py2` variants of the
distutils/python eclasses (`distutils-r1_py2`, `python-r1_py2`,
`python-utils-r1_py2`). Inheriting one of these signals that the
package is **intentionally pinned to Python 2** — typically because
upstream is unmaintained and the code has no realistic py3 port.

There is no `python-single-r1_py2`: nothing ever set
`DISTUTILS_SINGLE_IMPL` in a py2 package, so the fork was dropped.
`distutils-r1_py2` dies with a clear message if that variable is set;
recover the eclass from git history if a py2 package ever needs it.

Do not inherit these for packages that still have a living py3
upstream. Use the normal `::gentoo` eclasses instead.

### `profiles/package.mask`

Overlay-wide masks live here. Do not add per-profile masks
unless the mask is truly profile-specific (rare for this overlay,
which mostly targets `default/linux/amd64/23.0`).

### `licenses/`

Overlay-local only for licenses that `::gentoo` does not carry.
Do not duplicate files that already exist upstream — `masters =
gentoo` makes them reachable automatically.

### `metadata/pkgcheck.conf` suppressions

Suppressions are allowed but must be justified in the config
itself, in the comment block immediately above the
`keywords = -Foo,-Bar,...` line. Each suppression should carry a
dated rationale noting:

- What was checked.
- When (ISO date, e.g. `2026-04-23`).
- Why the finding is expected or policy, not a bug.

If the rationale goes stale, someone (probably future-you) needs
to be able to re-run the same check. Undated "this is fine"
comments rot fast.

### Version drops

Drop superseded versions in a **separate** commit titled
`category/pkg: drop <old versions>`. Do not bundle a drop into
the same commit as a new version bump — keeping them separate
makes reverting or bisecting either operation independently
clean.

### Live (`-9999`) ebuilds

Live ebuilds have no DIST entries. `pkgdev manifest` is a no-op
for them. If a live ebuild is the **only** access path for a
package (no released-version sibling), please say so in the
commit body the first time you add it — it is a brittle shape
and the next maintainer should know.

### News items (GLEP 42)

User-facing news items live under `metadata/news/` and are
picked up by `eselect news` after `emerge --sync`. A reference
template that walks through the headers and directory naming
lives at `metadata/news/TEMPLATE/` — copy that directory and
rename to `YYYY-MM-DD-short-slug/` when you need to ship an
item (e.g. a breaking package drop, a migration, or a
security-sensitive notice).

## 🤖 AI / LLM assistance

AI/LLM assistance may be used on changes to this overlay —
the maintainer routinely uses it for mechanical work
(pkgcheck cleanups, metadata normalization, commit-body drafting,
repetitive bumps). Every commit is reviewed by a human before it
lands, and the maintainer bears responsibility for correctness.

If you are opening a PR and AI/LLM tooling helped you prepare it,
a brief note in the PR description is appreciated — it helps
reviewers know where to look more carefully (e.g. generated tests,
non-trivial `PATCHES=` application, license claims). There is no
formal form for this and no per-commit trailer is required.

## 🐛 Bug reports

- Use the GitHub issue tracker on the primary mirror
  (`github.com/istitov/stuff`).
- Include: exact `category/pkg-version`, the full `emerge --info`
  output, and the failing build log (or the last few dozen lines
  if the log is enormous).
- If the bug is upstream's (not the ebuild's), also file it with
  upstream and link the report.

## License

Ebuild code in this repository is distributed under GPL-2 (same
as the main `::gentoo` tree) unless an individual file states
otherwise. By submitting a PR you agree that your contribution
may be distributed under those terms.
