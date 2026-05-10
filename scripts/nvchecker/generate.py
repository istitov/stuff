#!/usr/bin/env python3
"""Generate nvchecker.toml by walking every package in the overlay.

For each category/package directory, read the newest ebuild, detect
the upstream source (PyPI / GitHub / SourceForge / other), and emit
a corresponding nvchecker entry. Packages with no detectable upstream
(live-only, mirror://, custom hosts) are emitted as TOML comments so
they stay visible in the generated config but are skipped by
nvchecker itself.

Usage:

    ./generate.py [--root <overlay-root>] [--out nvchecker.toml]

Default --root is two levels up from this script. Default --out is
nvchecker.toml next to this script.

The generator is deliberately conservative: when it cannot confidently
classify a source type it emits a skip comment rather than a guess, so
false positives in the drift report stay low.
"""

from __future__ import annotations

import argparse
import re
import sys
from collections import Counter, defaultdict
from pathlib import Path

# Matches the newest ebuild version string per Gentoo PMS rules (simplified).
# We rely on sort order over the full basename minus the ".ebuild" suffix.

PYPI_INHERIT_RE = re.compile(r"^\s*inherit\b.*\bpypi\b", re.MULTILINE)
PERL_INHERIT_RE = re.compile(r"^\s*inherit\b.*\bperl-module\b", re.MULTILINE)
PY2_INHERIT_RE = re.compile(r"^\s*inherit\b.*_py2\b", re.MULTILINE)
PYPI_PN_RE = re.compile(r'^\s*PYPI_PN=(?:"([^"]+)"|\'([^\']+)\'|(\S+))', re.MULTILINE)
PYPI_NORMALIZE_RE = re.compile(r'^\s*PYPI_NO_NORMALIZE=(\S+)', re.MULTILINE)
SRC_URI_RE = re.compile(r'^SRC_URI=(?:"([^"]*)"|\'([^\']*)\')', re.MULTILINE | re.DOTALL)
HOMEPAGE_RE = re.compile(r'^HOMEPAGE=(?:"([^"]*)"|\'([^\']*)\')', re.MULTILINE | re.DOTALL)
EGIT_REPO_URI_RE = re.compile(r'^EGIT_REPO_URI=(?:"([^"]*)"|\'([^\']*)\')', re.MULTILINE)

GITHUB_ARCHIVE_RE = re.compile(r'https?://(?:www\.)?github\.com/([A-Za-z0-9_.-]+)/([A-Za-z0-9_.-]+?)(?:\.git)?/(?:archive|releases/download)/')
GITHUB_HOMEPAGE_RE = re.compile(r'https?://(?:www\.)?github\.com/([A-Za-z0-9_.-]+)/([A-Za-z0-9_.-]+?)(?:\.git|/|$|\s)')
BITBUCKET_RE = re.compile(r'https?://(?:www\.)?bitbucket\.org/([A-Za-z0-9_.-]+)/([A-Za-z0-9_.-]+?)(?:\.git|/|$|\s)')
GITLAB_RE = re.compile(r'https?://(gitlab(?:\.[A-Za-z0-9-]+)+)/([A-Za-z0-9_.-]+)/([A-Za-z0-9_.-]+?)(?:\.git|/|$|\s)')
# Match both the canonical project page (sourceforge.net/project[s]/<slug>)
# and the downloads redirector used by many ebuilds
# (downloads.sourceforge.net/<slug>/).
SOURCEFORGE_RE = re.compile(
    r'https?://(?:'
    r'(?:[a-z0-9_.-]+\.)?sourceforge\.net/(?:project|projects)/([A-Za-z0-9_.-]+)'
    r'|downloads\.sourceforge\.net/([A-Za-z0-9_.-]+)/'
    r')'
)
PYPI_URL_RE = re.compile(r'https?://(?:files\.pythonhosted\.org|pypi\.(?:io|org))/')
CPAN_URL_RE = re.compile(r'mirror://cpan/authors/id/[A-Z]/[A-Z]{2}/[A-Z0-9]+/([A-Za-z0-9_-]+?)-v?[\d.]+(?:\.tar\.gz|\.tgz)?')
# Extract the URL host from a SRC_URI / HOMEPAGE string, used to enrich the
# "no recognizable upstream" skip note with a pointer to *where* the
# maintainer should look if they want to hand-add tracking.
URL_HOST_RE = re.compile(r'https?://([A-Za-z0-9._-]+)')
QT5_BUILD_RE = re.compile(r"^\s*inherit\b.*\bqt5-build\b", re.MULTILINE)


# Per-github-repo overrides emitted alongside `use_max_tag = true`.
#
# The default github classification (`use_max_tag = true` with no filter) picks
# the lexicographic-numeric max across every tag in the repo. That falls over
# when the repo carries:
#   - non-semver release tags that interleave with semver (e.g. ROCm's
#     `rocm-X.Y.Z` releases vs TheRock's `YYYYMMDD-NN` nightlies on the
#     same monorepo);
#   - a single very old tag that wins numeric-tuple compare (e.g.
#     facebookresearch/faiss `v20180223` outranking `v1.14.x`);
#   - a date-versioned nightly tag scheme that runs in parallel with
#     normal releases (e.g. mantid's `vX.Y.YYYYMMDD.HHMM` nightlies vs
#     `vX.Y.Z` releases).
#
# Each entry is `(spec_pattern, overrides)` where overrides contains
# `include_regex` (filter applied to the raw tag before max-selection) and
# optionally `prefix` (stripped after selection so drift reports show clean
# version numbers).
GITHUB_TAG_FILTERS: list[tuple[re.Pattern, dict]] = [
    # ROCm org: every project under ROCm/* uses `rocm-X.Y.Z` for stable
    # releases. Without this filter, max-tag picks up TheRock-style nightly
    # `YYYYMMDD-NN` tags or `X.Ybeta` previews from the monorepos.
    # nvchecker applies include_regex via re.fullmatch, so the pattern must
    # cover the whole tag — `^rocm-` alone matches only the 5-char prefix.
    (re.compile(r"^ROCm/.+"),
     {"include_regex": r"rocm-[0-9]+\.[0-9]+\.[0-9]+", "prefix": "rocm-"}),

    # facebookresearch/faiss has an ancient `v20180223` single-segment tag
    # that lexicographically beats `v1.14.x` semver releases.
    (re.compile(r"^facebookresearch/faiss$"),
     {"include_regex": r"^v[0-9]+\.[0-9]+\.[0-9]+$"}),

    # mantidproject/mantid runs `vX.Y.YYYYMMDD.HHMM` nightly tags alongside
    # `vX.Y.Z(.W)(_rcN)?` releases; restrict to the release form (≤3 digits
    # in the second/third segments rules out the 8-digit YYYYMMDD).
    (re.compile(r"^mantidproject/mantid$"),
     {"include_regex": r"^v[0-9]+\.[0-9]{1,3}\.[0-9]{1,4}(\.[0-9]+)?(_rc[0-9]+)?$"}),
]


# Per-package overrides keyed on cat/pkg, applied when one repo's tag scheme
# is heterogeneous and a single repo-wide filter can't cover all of its
# Python sub-packages. Wins over GITHUB_TAG_FILTERS when both match.
#
# NVIDIA/cuda-python is a monorepo housing several Python packages, each
# with its own tag scheme on the same git repo:
#   * cuda-bindings    -> v<PV>           (bare semver, the umbrella's tag)
#   * cuda-pathfinder  -> cuda-pathfinder-v<PV>
#   * cuda-python (umbrella sdist) is on PyPI -> already classified as pypi.
# Without per-package filters, both sub-packages share `NVIDIA/cuda-python`
# as github spec and max-tag picks the umbrella's `v<latest>`, false-positive
# for cuda-pathfinder (whose actual upstream version is much lower).
GITHUB_TAG_FILTERS_BY_PKG: dict[str, dict] = {
    "dev-python/cuda-bindings": {
        "include_regex": r"^v[0-9]+\.[0-9]+\.[0-9]+$",
    },
    "dev-python/cuda-pathfinder": {
        "include_regex": r"^cuda-pathfinder-v[0-9]+\.[0-9]+\.[0-9]+$",
        "prefix": "cuda-pathfinder-v",
    },
    # NVIDIA/cudnn-frontend has an ancient `v8.1.0-beta` tag (from the
    # C++ library's earlier numbering) that lexicographically beats the
    # current Python-package `v1.X.Y` line. Strict-anchored semver only.
    "dev-python/nvidia-cudnn-frontend": {
        "include_regex": r"^v[0-9]+\.[0-9]+\.[0-9]+$",
    },
}


def github_tag_filter(spec: str, entry_name: str | None = None) -> dict | None:
    """Return include_regex / prefix override for this entry, if any.

    Per-package overrides (GITHUB_TAG_FILTERS_BY_PKG) win when both match —
    a monorepo's per-sub-package tag scheme is more specific than a
    repo-wide pattern.
    """
    if entry_name and entry_name in GITHUB_TAG_FILTERS_BY_PKG:
        return GITHUB_TAG_FILTERS_BY_PKG[entry_name]
    for pat, override in GITHUB_TAG_FILTERS:
        if pat.fullmatch(spec):
            return override
    return None


def find_newest_ebuild(pkgdir: Path) -> Path | None:
    """Return the newest non-live ebuild, or the live one if that's all there is."""
    released = []
    live = []
    for eb in pkgdir.glob("*.ebuild"):
        if eb.stem.endswith("-9999"):
            live.append(eb)
        else:
            released.append(eb)
    if released:
        # Lexical sort is close enough for our purposes; we're not producing
        # a version string, just picking an ebuild to parse.
        return sorted(released)[-1]
    if live:
        return live[0]
    return None


def strip_comments(text: str) -> str:
    """Strip shell-style comments from ebuild text for simpler parsing."""
    out = []
    for line in text.splitlines():
        if line.lstrip().startswith("#"):
            continue
        # inline comment after content: leave alone (SRC_URI often has # in
        # URLs, and we're not doing deep parsing)
        out.append(line)
    return "\n".join(out)


def expand_vars(text: str | None, pkg_name: str) -> str | None:
    """Best-effort expansion of the bash variables that commonly appear in
    SRC_URI / HOMEPAGE, so the URL-matching regexes can traverse them.
    PV and P expansion isn't attempted (we don't need the version number)."""
    if text is None:
        return None
    # Both underscored (MY_PN) and un-underscored (MYPN) forms appear in
    # the overlay; similarly MY_P / MYP. Substituting them all with
    # pkg_name is close enough — we're only after the URL host.
    for v in ("${PN}", "$PN",
              "${MY_PN}", "$MY_PN", "${MYPN}", "$MYPN",
              "${MY_P}", "$MY_P", "${MYP}", "$MYP",
              "${MY_P%-*}"):
        text = text.replace(v, pkg_name)
    return text


def first_group(m: re.Match | None) -> str | None:
    if not m:
        return None
    for g in m.groups():
        if g is not None:
            return g
    return None


def classify(pkg_name: str, ebuild_text: str, homepage: str | None, src_uri: str | None, egit: str | None = None) -> dict:
    """See module docstring. Leading branches short-circuit before the
    source-type detection."""
    # Packages explicitly pinned to Python 2 (ebuild name ends in -python2
    # or inherits the *_py2 eclass family). Upstream has moved past py2, so
    # tracking upstream would produce permanent false-positive drift. The
    # overlay's job is to freeze these at the last py2-compatible version.
    if pkg_name.endswith("-python2") or PY2_INHERIT_RE.search(ebuild_text):
        return {"kind": "unknown",
                "note": "py2-pinned: upstream has moved past py2 support; "
                        "drift tracking would produce permanent false positives"}

    # Qt5 component (qt5-build eclass). These live in the overlay as snapshots
    # of ::gentoo's Qt 5 packages (eclass dropped from the main tree). Upstream
    # for our purposes is ::gentoo, not Qt's public release cadence — tracking
    # qt.io releases would not match the PV we ship.
    if QT5_BUILD_RE.search(ebuild_text):
        return {"kind": "unknown",
                "note": "qt5-build component; tracked in ::gentoo rather than "
                        "upstream Qt, so standalone drift tracking would not "
                        "match the PV ebuilds ship here"}
    """Return a dict describing how nvchecker should track this package.

    Keys:
        kind:  "pypi" | "github" | "sourceforge" | "cpan" | "live" | "unknown"
        spec:  provider-specific string (pypi name, owner/repo, project)
        note:  optional human-readable explanation
    """
    # PyPI: if inherit pypi is present
    if PYPI_INHERIT_RE.search(ebuild_text):
        pn_override = first_group(PYPI_PN_RE.search(ebuild_text))
        name = pn_override if pn_override else pkg_name
        return {"kind": "pypi", "spec": name}

    # PyPI via SRC_URI
    if src_uri and PYPI_URL_RE.search(src_uri):
        return {"kind": "pypi", "spec": pkg_name}

    # CPAN (perl packages): perl-module eclass composes SRC_URI internally
    # from DIST_AUTHOR/DIST_NAME, so the ebuild's SRC_URI= variable is often
    # empty. The Gentoo PN matches the CPAN distribution name by convention.
    if PERL_INHERIT_RE.search(ebuild_text):
        return {"kind": "cpan", "spec": pkg_name}

    # CPAN via explicit mirror://cpan URL
    if src_uri:
        m = CPAN_URL_RE.search(src_uri)
        if m:
            return {"kind": "cpan", "spec": m.group(1)}

    # GitHub via SRC_URI archive/release tarball
    for text in (src_uri, homepage):
        if not text:
            continue
        m = GITHUB_ARCHIVE_RE.search(text)
        if m:
            return {"kind": "github", "spec": f"{m.group(1)}/{m.group(2)}"}

    # GitHub via EGIT_REPO_URI (live ebuilds and some released ones that
    # fetch via git-r3). Even though we only emit this for released ebuilds,
    # the git-r3 URI still points at the upstream we want to track.
    if egit:
        m = GITHUB_HOMEPAGE_RE.search(egit)
        if m:
            return {"kind": "github", "spec": f"{m.group(1)}/{m.group(2)}", "note": "from EGIT_REPO_URI"}

    # GitHub via HOMEPAGE (no download URL — best-effort)
    if homepage:
        m = GITHUB_HOMEPAGE_RE.search(homepage)
        if m:
            owner, repo = m.group(1), m.group(2)
            # Avoid matching "https://github.com/" bare or "https://github.com/user"
            if repo and owner and repo not in ("about", "settings"):
                return {"kind": "github", "spec": f"{owner}/{repo}", "note": "from HOMEPAGE"}

    # Bitbucket (SRC_URI or HOMEPAGE)
    for text in (src_uri, homepage, egit):
        if not text:
            continue
        m = BITBUCKET_RE.search(text)
        if m:
            return {"kind": "bitbucket", "spec": f"{m.group(1)}/{m.group(2)}"}

    # GitLab (gitlab.com and self-hosted instances like gitlab.freedesktop.org,
    # gitlab.gnome.org, gitlab.kde.org). nvchecker's gitlab source takes a
    # `host` parameter so the same classifier covers all of them.
    for text in (src_uri, homepage, egit):
        if not text:
            continue
        m = GITLAB_RE.search(text)
        if m:
            return {"kind": "gitlab", "spec": f"{m.group(2)}/{m.group(3)}", "host": m.group(1)}

    # SourceForge: nvchecker 2.x has no built-in sourceforge source; an
    # nvchecker `regex` source against the project's RSS feed works but is
    # entry-by-entry. Flag as unknown-with-SF-hint so a future maintainer
    # can uncomment and hand-fill the regex.
    if src_uri:
        m = SOURCEFORGE_RE.search(src_uri)
        if m:
            slug = m.group(1) or m.group(2)
            return {"kind": "unknown",
                    "note": f"sourceforge/{slug} — no built-in source in nvchecker 2.x; "
                            "add a `regex` entry against the RSS feed if tracking is wanted"}

    # Genuinely unclassified. Include the URL host (if we can find one) so a
    # future maintainer sees at a glance where upstream lives — that's the
    # first thing they'd want before hand-adding an nvchecker `regex` or
    # `htmlparser` entry. Prefer HOMEPAGE over SRC_URI: the former is the
    # canonical project page (useful for a human setting up tracking), while
    # the latter is often a mirror / CDN / S3 bucket that's uninformative on
    # its own.
    host = None
    for text in (homepage, src_uri):
        if not text:
            continue
        m = URL_HOST_RE.search(text)
        if m:
            host = m.group(1)
            break
    if host:
        return {"kind": "unknown",
                "note": f"custom upstream at {host}; "
                        "hand-add an nvchecker `regex` or `htmlparser` entry if tracking is wanted"}
    return {"kind": "unknown", "note": "no recognizable upstream"}


def emit_entry(entry_name: str, classification: dict) -> list[str]:
    """Return TOML lines for this entry, or a skip-comment if unknown/live."""
    kind = classification["kind"]
    note = classification.get("note")

    # Quote the TOML table header: entry names contain '/' which isn't a
    # valid bare key, so we use a quoted key ([""]).
    quoted = f'["{entry_name}"]'
    if kind == "live":
        return [f"# {quoted} skipped: live-only ebuild (no release tracking)"]

    if kind == "unknown":
        return [f"# {quoted} skipped: {note or 'no recognizable upstream'}"]

    lines = [quoted]
    if kind == "pypi":
        lines.append('source = "pypi"')
        lines.append(f'pypi = "{classification["spec"]}"')
    elif kind == "github":
        lines.append('source = "github"')
        lines.append(f'github = "{classification["spec"]}"')
        # use_max_tag works for any repo with tags, including projects that
        # don't curate GitHub Releases (which use_latest_release requires).
        lines.append("use_max_tag = true")
        # Per-repo include_regex / prefix overrides for repos whose tag
        # history breaks naive max-tag selection — see GITHUB_TAG_FILTERS.
        # Per-package overrides (GITHUB_TAG_FILTERS_BY_PKG) take precedence
        # for monorepos with heterogeneous sub-package tag schemes.
        override = github_tag_filter(classification["spec"], entry_name)
        if override:
            if "include_regex" in override:
                # TOML literal string ('...'): no backslash escaping, so the
                # regex's '\.' etc. survive as-is. Patterns are kept free of
                # single quotes in GITHUB_TAG_FILTERS so the literal-string
                # form works without further quoting.
                lines.append(f"include_regex = '{override['include_regex']}'")
            if "prefix" in override:
                lines.append(f'prefix = "{override["prefix"]}"')
        if note:
            lines.append(f"# note: {note}")
    elif kind == "bitbucket":
        lines.append('source = "bitbucket"')
        lines.append(f'bitbucket = "{classification["spec"]}"')
        lines.append("use_max_tag = true")
    elif kind == "gitlab":
        lines.append('source = "gitlab"')
        lines.append(f'gitlab = "{classification["spec"]}"')
        # Only emit `host` for self-hosted GitLab instances; nvchecker's
        # default is gitlab.com, so matching that is redundant.
        host = classification.get("host")
        if host and host != "gitlab.com":
            lines.append(f'host = "{host}"')
        lines.append("use_max_tag = true")
    elif kind == "sourceforge":
        lines.append('source = "sourceforge"')
        lines.append(f'sourceforge = "{classification["spec"]}"')
    elif kind == "cpan":
        lines.append('source = "cpan"')
        lines.append(f'cpan = "{classification["spec"]}"')
    return lines


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    script_dir = Path(__file__).resolve().parent
    ap.add_argument("--root", type=Path, default=script_dir.parent.parent,
                    help="overlay root (default: two levels above this script)")
    ap.add_argument("--out", type=Path, default=script_dir / "nvchecker.toml",
                    help="output TOML path")
    args = ap.parse_args()

    root: Path = args.root.resolve()
    if not (root / "profiles" / "repo_name").is_file():
        print(f"error: {root} does not look like an overlay (no profiles/repo_name)", file=sys.stderr)
        return 1

    SKIP_TOPS = {"eclass", "licenses", "metadata", "profiles", "scripts", ".git", ".github"}
    # acct-group / acct-user packages declare UNIX accounts for system services
    # and have no upstream to track — they're entirely ebuild-local.
    SKIP_CATS = {"acct-group", "acct-user"}

    entries_by_kind: dict[str, list[tuple[str, str, dict]]] = defaultdict(list)
    counter: Counter[str] = Counter()

    for cat_dir in sorted(root.iterdir()):
        if not cat_dir.is_dir():
            continue
        if cat_dir.name in SKIP_TOPS or cat_dir.name.startswith("."):
            continue
        if cat_dir.name in SKIP_CATS:
            continue
        if "-" not in cat_dir.name and cat_dir.name not in ("virtual",):
            continue
        for pkg_dir in sorted(cat_dir.iterdir()):
            if not pkg_dir.is_dir():
                continue

            entry_name = f"{cat_dir.name}/{pkg_dir.name}"
            ebuild = find_newest_ebuild(pkg_dir)
            if ebuild is None:
                counter["no-ebuild"] += 1
                continue

            # If the only ebuild is live (-9999), mark as live
            if ebuild.stem.endswith("-9999") and not any(
                not e.stem.endswith("-9999") for e in pkg_dir.glob("*.ebuild")
            ):
                entries_by_kind["live"].append((entry_name, str(ebuild), {"kind": "live"}))
                counter["live"] += 1
                continue

            text = strip_comments(ebuild.read_text(errors="replace"))
            homepage = expand_vars(first_group(HOMEPAGE_RE.search(text)), pkg_dir.name)
            src_uri = expand_vars(first_group(SRC_URI_RE.search(text)), pkg_dir.name)
            egit = expand_vars(first_group(EGIT_REPO_URI_RE.search(text)), pkg_dir.name)

            cls = classify(pkg_dir.name, text, homepage, src_uri, egit)
            entries_by_kind[cls["kind"]].append((entry_name, str(ebuild), cls))
            counter[cls["kind"]] += 1

    # Emit TOML
    out_lines = [
        "# nvchecker config for the stuff overlay",
        "# Auto-generated by scripts/nvchecker/generate.py.",
        "# Regenerate after adding, dropping, or retargeting packages;",
        "# hand-edits in this file will be lost on the next regeneration.",
        "#",
        "# Entries are grouped by source type (pypi, github, sourceforge)",
        "# followed by commented-out skip entries (live-only ebuilds,",
        "# packages with no detectable upstream). To track a skipped",
        "# package by hand, uncomment the block and fill in the source.",
        "",
    ]

    for kind in ("pypi", "github", "gitlab", "bitbucket", "cpan"):
        if not entries_by_kind[kind]:
            continue
        out_lines.append(f"# --- {kind} ({len(entries_by_kind[kind])}) ---")
        out_lines.append("")
        for entry_name, _, cls in sorted(entries_by_kind[kind]):
            out_lines.extend(emit_entry(entry_name, cls))
            out_lines.append("")

    if entries_by_kind["live"] or entries_by_kind["unknown"]:
        out_lines.append("# --- skipped ---")
        out_lines.append("")
    for kind in ("live", "unknown"):
        for entry_name, _, cls in sorted(entries_by_kind[kind]):
            out_lines.extend(emit_entry(entry_name, cls))
        if entries_by_kind[kind]:
            out_lines.append("")

    args.out.write_text("\n".join(out_lines).rstrip() + "\n")

    # Summary to stderr so shell redirection of stdout remains clean if any
    print(f"wrote {args.out}", file=sys.stderr)
    for kind in ("pypi", "github", "gitlab", "bitbucket", "cpan", "live", "unknown", "no-ebuild"):
        if counter[kind]:
            print(f"  {kind:14s} {counter[kind]:4d}", file=sys.stderr)
    total = sum(counter.values())
    print(f"  {'total':14s} {total:4d}", file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
