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

## Before you start

- Clone the repo (or your fork), then either enable it via
  `eselect repository enable stuff` and `emerge --sync stuff`, or
  point your own overlay config at the working tree.
- Install the tooling: `app-portage/pkgdev` and `dev-util/pkgcheck`.
- The repo declares `masters = gentoo` and `thin-manifests = true`
  — every package depends on `::gentoo` being available, and
  `Manifest` files only carry `DIST` lines.

## 📦 Per-commit checklist

One package per commit. No mixed-package commits except for
cross-cutting infrastructure (eclasses, profiles, masks).

- [ ] The change is scoped to a single `category/pkg/` directory
      (or a single eclass / profile file).
- [ ] If `SRC_URI` changed, `pkgdev manifest` has been re-run.
- [ ] `pkgcheck scan <category>/<pkg>` is clean, or any new warning
      is documented in the commit body or `metadata/pkgcheck.conf`.
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
  *what*. The diff shows what. The body should cover:
  - Why this change is needed now (upstream release, bug, policy).
  - Any non-obvious decision (e.g. "kept `~amd64` only because the
    dep is `~amd64`-only in this overlay").
  - Dated-verification notes where appropriate — see below.

Single-line commits are fine for truly trivial edits (typo fixes,
one-line metadata tweaks). Default to subject+body otherwise.

## Per-package workflow

The loop the maintainer uses:

1. `pkgcheck scan <category>/<pkg>` — see the starting baseline.
2. Edit. For ebuild changes, prefer copying the newest ebuild and
   adjusting, rather than editing in place, when bumping versions.
3. Build-check: either a local emerge against the overlay, or at
   least a successful `ebuild <pkg>.ebuild clean prepare compile`.
4. `pkgcheck scan <category>/<pkg>` again — confirm no regression.
5. `pkgdev manifest` if `SRC_URI` changed.
6. `pkgdev commit` with a body.

Do one package at a time. Do not batch unrelated packages into a
single commit — it makes reverts and bisects painful.

## Before pushing

- [ ] `pkgcheck scan --commits` is clean on your branch
      (same check CI runs on push/PR).
- [ ] No `metadata/md5-cache/` files are staged — the directory
      is gitignored and must stay that way.
- [ ] No secrets, distfile payloads, or binary blobs snuck in.

CI (`.github/workflows/pkgcheck.yml`) will re-run
`pkgcheck scan --commits` on push and PR. A separate 3-day cron
runs `pkgcheck scan` repo-wide with `--net`.

## 🧩 Conventions

### `metadata.xml`

- `https://` DTD, two-space indent.
- Proxy-maintained packages use the maintainer's own email +
  `<name>Ivan S. Titov</name>` for now, since the overlay is
  maintained by a small group; if you take over a package in a PR,
  feel free to adjust.
- Add `<upstream><remote-id>` entries where they exist
  (`pypi`, `github`, `sourceforge`, etc.).

### `*_py2` eclasses

`eclass/` carries locally-vendored `*_py2` variants of the
distutils/python eclasses (`distutils-r1_py2`, `python-r1_py2`,
`python-single-r1_py2`, `python-utils-r1_py2`). Inheriting one of
these signals that the package is **intentionally pinned to
Python 2** — typically because upstream is unmaintained and the
code has no realistic py3 port.

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
