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
MY_PN_RE = re.compile(r'^\s*MY_PN=(?:"([^"]+)"|\'([^\']+)\'|(\S+))', re.MULTILINE)
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
# Captures the project name from a canonical PyPI project URL in HOMEPAGE,
# used to redirect tracking to PyPI when an ebuild has no SRC_URI to hint at
# the upstream source (e.g. wheel-only upstreams or hand-written replacements).
PYPI_PROJECT_URL_RE = re.compile(r'https?://pypi\.org/(?:project|pypi)/([A-Za-z0-9_.-]+)')
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
    # NVIDIA monorepo sub-packages
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
    # fmaclen/hollama tags are bare (`0.35.4`), no v prefix. Default
    # v-strip would silently shadow every release.
    "www-apps/hollama": {
        "prefix": "",
    },
    # tutao/tutanota is a monorepo with multiple parallel release tag
    # families published on the same day: tutanota-release-*,
    # tutanota-desktop-release-*, tutanota-android-release-*,
    # tutanota-ios-release-*, tuta-calendar-{android,ios}-release-*.
    # PV format is MAJOR.YYMMDD.MINOR (e.g. 348.260519.0). Filter to
    # desktop-only and strip the family prefix so the value compares
    # against the ebuild PV cleanly.
    "mail-client/tutanota-desktop-bin": {
        "include_regex": r"^tutanota-desktop-release-\d+\.\d+\.\d+$",
        "prefix": "tutanota-desktop-release-",
    },
    # adplug/adplug releases are tagged as `adplug-X.Y` (with an optional
    # third segment, e.g. `adplug-2.3.3`), alongside winamp-* plugin tags.
    # Anchor with `$` so we don't accidentally include suffix-bearing tags
    # like `-beta` or `-rc1` if any ever show up.
    "media-libs/adplug": {
        "include_regex": r"^adplug-\d+\.\d+(?:\.\d+)?$",
        "prefix": "adplug-",
    },
    # adplug/libbinio: same release-tag convention (`libbinio-X.Y`); the
    # repo also has a stray "start" tag that the anchor keeps out.
    "dev-cpp/libbinio": {
        "include_regex": r"^libbinio-\d+\.\d+$",
        "prefix": "libbinio-",
    },
    # xintrea/mytetra_dev uses `v.X.Y.Z` (note the dot after v) rather than
    # the standard `vX.Y.Z`; from_pattern strips the `v.` prefix so the
    # returned version matches the plain-number Portage PV.
    "app-office/mytetra": {
        "include_regex": r"^v\.\d+\.\d+\.\d+$",
        "from_pattern": r"^v\.(.+)$",
        "to_pattern": r"\1",
    },
    # numba/llvmlite and numba/numba publish development tags (v0.48.0dev0,
    # 0.66.0dev0) that sort above the latest stable release.
    "dev-python/llvmlite": {
        "include_regex": r"^v[0-9]+\.[0-9]+\.[0-9]+$",
    },
    "dev-python/numba": {
        "include_regex": r"^[0-9]+\.[0-9]+\.[0-9]+$",
    },
    # explosion/spacy switched its release-tag format from `vX.Y.Z` to
    # `release-vX.Y.Z` somewhere around the 3.7 → 3.8 transition.  Matching
    # only `v[…]` (the older form) picks 3.7.5 as max because the 3.8.x tags
    # carry the longer prefix.  Match the current scheme and strip it.  We
    # intentionally track the stable 3.x line for the kokoro chain — there
    # are also 4.0.0.devN tags that this filter excludes.
    "dev-python/spacy": {
        "include_regex": r"^release-v[0-9]+\.[0-9]+\.[0-9]+$",
        "prefix": "release-v",
    },
    "dev-python/spacy-legacy": {
        "include_regex": r"^v[0-9]+\.[0-9]+\.[0-9]+$",
    },
    # BelledonneCommunications repos tag alpha/rc releases; restrict to
    # the plain three-part numeric form for stable-only signals.
    "net-libs/bctoolbox": {
        "include_regex": r"^[0-9]+\.[0-9]+\.[0-9]+$",
    },
    "net-libs/ortp": {
        "include_regex": r"^[0-9]+\.[0-9]+\.[0-9]+$",
    },
    # HDFGroup/hdf4 tags use the format `hdfX.Y.Z` (e.g. `hdf4.3.1`) for
    # modern releases; older `hdf-4_2_16-2`-style tags used underscores and
    # a dash separator — both are excluded by requiring `hdf[0-9]`.  Strip
    # the `hdf` prefix to get a plain dotted version comparable to the PV.
    "sci-libs/hdf": {
        "include_regex": r"^hdf[0-9]+\.[0-9]+\.[0-9]+$",
        "prefix": "hdf",
    },
    # Xilinx/XRT tags are date-prefixed: `YYYYMM.MAJOR.MINOR.PATCH`.  The
    # overlay ebuild carries only MAJOR.MINOR.PATCH (e.g. 2.21.75).  Strip
    # the 6-digit date prefix so the extracted version is comparable.
    "dev-util/xrt": {
        "include_regex": r"^[0-9]{6}\.[0-9]+\.[0-9]+\.[0-9]+$",
        "from_pattern": r"^[0-9]{6}\.(.+)$",
        "to_pattern": r"\1",
    },
    # lierdakil/pandoc-crossref publishes alpha/rc tags for next releases;
    # restrict to stable tags (3- or 4-part version, with optional trailing
    # letter like `0.3.23a`, but no hyphenated pre-release suffixes).
    "app-text/pandoc-crossref-bin": {
        "include_regex": r"^v[0-9]+\.[0-9]+\.[0-9]+[0-9a-z.]*$",
    },
    # ggml-org/llama.cpp tags its builds as `b<N>` (e.g. b9209), not semver.
    # The repo also carries old `gguf-v<X>.<Y>` and `master-<sha>` style refs.
    # Match only the 4+ digit build-number form (current N is ~9200, so 4-digit
    # is a tight fit; broaden if upstream ever resets the counter) and rewrite
    # to the `0_pre<N>` PV the overlay's ebuilds use, so drift compares cleanly
    # without falling back to tracking master's HEAD commit.
    #
    # Sort risk: nvchecker uses awesomeversion which compares `b<N>` strings
    # by extracting the numeric portion, so b9999 → b10000 should still pick
    # the latter correctly. Worth re-verifying when N actually crosses 5 digits.
    "sci-misc/llama-cpp": {
        "include_regex": r"^b[0-9]{4,}$",
        "from_pattern": r"^b([0-9]+)$",
        "to_pattern": r"0_pre\1",
    },
    # vosen/ZLUDA tags today are all `v<N>-preview.<M>` — the rolling
    # preview channel upstream recommends over the years-old stable
    # releases. The overlay's tagged ebuild uses PV form `N_preM`;
    # rewrite the preview form to it via from_pattern/to_pattern.
    # include_regex also lets through a hypothetical future `v<N>(.<M>)+`
    # stable scheme (e.g. v6.0.0, v7.0.0) so we still see drift if
    # upstream ever pivots; the prefix step strips the leading `v` so
    # those compare as bare dotted versions against our `N_preM` PV.
    "dev-util/zluda": {
        "include_regex": r"^v[0-9]+(?:-preview\.[0-9]+|(?:\.[0-9]+)+)$",
        "prefix": "v",
        "from_pattern": r"^([0-9]+)-preview\.([0-9]+)$",
        "to_pattern": r"\1_pre\2",
    },
}


# Packages whose nvchecker source needs to be hand-crafted because the
# classifier can't reach the right upstream from SRC_URI / HOMEPAGE alone.
# Each value is a dict of nvchecker keys emitted verbatim under the entry.
#
# pf-sources / pf-sources-extended: HOMEPAGE points at pfkernel.natalenko.name
# (no machine-readable release feed) and SRC_URI lists extra-stuff distfile
# mirrors (our own, not upstream).  The actual release feed is pf-kernel/linux
# on Codeberg, tagged `vX.Y-pfN`.  Both flavors share the same upstream tag
# scheme.  from_pattern/to_pattern rewrite the tag to Portage-comparable
# `X.Y_pN` form.
SPECIAL_SOURCES: dict[str, dict[str, object]] = {
    "sys-kernel/pf-sources": {
        "source": "gitea",
        "host": "codeberg.org",
        "gitea": "pf-kernel/linux",
        "use_max_tag": True,
        "include_regex": r"^v\d+\.\d+-pf\d+$",
        "prefix": "v",
        "from_pattern": r"^(\d+\.\d+)-pf(\d+)$",
        "to_pattern": r"\1_p\2",
    },
    "sys-kernel/pf-sources-extended": {
        "source": "gitea",
        "host": "codeberg.org",
        "gitea": "pf-kernel/linux",
        "use_max_tag": True,
        "include_regex": r"^v\d+\.\d+-pf\d+$",
        "prefix": "v",
        "from_pattern": r"^(\d+\.\d+)-pf(\d+)$",
        "to_pattern": r"\1_p\2",
    },
    # therock-bin tracks AMD's nightly ROCm SDK tarballs on the CDN
    # (rocm.nightlies.amd.com).  ROCm/TheRock's github tags are
    # `rocm-X.Y.Z` releases which don't map to the nightly
    # tarball naming, so we scrape the CDN's tarball/ listing for the
    # highest `therock-dist-linux-<arch>-X.Y.ZaYYYYMMDD` entry and
    # rewrite the trailing `aYYYYMMDD` to PMS-valid `_alphaYYYYMMDD`.
    #
    # The arch token is matched generically (`[a-z0-9X-]+` covers
    # gfx1150, gfx101X-dgpu, gfx950-dcgpu, …) rather than pinned to a
    # single arch: the package is multi-arch via amdgpu_targets_* USE
    # flags and every arch publishes the same nightly version, so any
    # arch is a valid version canary.  Pinning one arch would go silent
    # if AMD ever dropped that specific target from the matrix while the
    # package stayed trackable via the others.
    "dev-util/therock-bin": {
        "source": "regex",
        "url": "https://rocm.nightlies.amd.com/tarball/",
        "regex": r"therock-dist-linux-[a-z0-9X-]+-(\d+\.\d+\.\d+a\d+)\.tar\.gz",
        "from_pattern": r"^(\d+\.\d+\.\d+)a(\d+)$",
        "to_pattern": r"\1_alpha\2",
    },
    # nvidia-cuda-toolkit ships as an NVIDIA-hosted .run installer under
    # developer.download.nvidia.com (no github/pypi feed), so the classifier
    # can't reach an upstream version and would skip it — which is why a
    # 13.3.0 release went unnoticed while we shipped 13.2.1. NVIDIA's redist
    # directory is the cleanest machine-readable version list: one
    # redistrib_<X.Y.Z>.json per CUDA release. Scrape the listing and let
    # max-selection pick the newest; the capture is already PV-shaped
    # (X.Y.Z), and the older 11.x/12.x manifests sort below the current
    # 13.x so they don't interfere.
    "dev-util/nvidia-cuda-toolkit": {
        "source": "regex",
        "url": "https://developer.download.nvidia.com/compute/cuda/redist/",
        "regex": r"redistrib_(\d+\.\d+\.\d+)\.json",
    },
}


# Packages explicitly excluded from drift tracking because their GitHub
# source cannot produce version numbers comparable to the per-component
# Portage PVs.  Each maps to a human-readable skip reason emitted as a
# comment in the generated config.
#
# SuiteSparse is a monorepo tagged with the bundle version (e.g. v7.12.2),
# but each sub-library (AMD, CAMD, CHOLMOD, …) ships its own component
# version (3.3.4, 3.3.5, 5.3.4, …).  Comparing the monorepo tag against
# a component PV always produces false drift.  Use sci-libs/suitesparseconfig
# as the canary — it ships the bundle version directly.
SKIP_PKGS: dict[str, str] = {
    "sci-libs/amd":     "SuiteSparse sub-library — use sci-libs/suitesparseconfig as canary",
    "sci-libs/camd":    "SuiteSparse sub-library — use sci-libs/suitesparseconfig as canary",
    "sci-libs/ccolamd": "SuiteSparse sub-library — use sci-libs/suitesparseconfig as canary",
    "sci-libs/cholmod": "SuiteSparse sub-library — use sci-libs/suitesparseconfig as canary",
    "sci-libs/colamd":  "SuiteSparse sub-library — use sci-libs/suitesparseconfig as canary",
    "sci-libs/umfpack": "SuiteSparse sub-library — use sci-libs/suitesparseconfig as canary",
    # Repositories confirmed to have no release tags (GitHub /git/refs/tags → 404).
    "dev-python/pyprismatic":              "prism-em/pyprismatic has no GitHub release tags",
    "dev-python/dlinfo":                   "fphammerle/dlinfo has no GitHub release tags",
    "x11-apps/skb":                        "polachok/skb has no GitHub release tags",
    "media-plugins/deadbeef-waveform-seekbar": "cboxdoerfer/deadbeef-waveform-seekbar has no GitHub release tags",
    "dev-python/tccbox":                   "metab0t/tccbox has no GitHub release tags (private or untagged)",
    "sci-ml/caffe2":                       "pytorch/caffe2 repo has no tags; caffe2 was absorbed into pytorch/pytorch",
    # Upstreams that are gone or use non-public distribution channels.
    "sci-physics/demeter":                 "Demeter removed from CPAN; no public upstream tracking possible",
    "dev-python/amd-quark-bin":            "AMD internal wheel distribution; not on public PyPI",
    "dev-python/runai-model-streamer-bin": "Run:ai internal distribution; not on public PyPI",
    # Nightly / CDN-sourced package with no comparable GitHub tag scheme.
    # Intentional version pins — upstream advances but a consumer in the
    # tree hard-asserts on a specific version range.
    "dev-python/antlr4-python3-runtime":   "pinned to 4.11.x for sci-ml/lm-eval which asserts version().startswith('4.11')",
    # Snapshots ahead of upstream's only tag.
    "sci-ml/bigcode-eval":                 "we track main HEAD via 0_pre<date>; upstream's sole tag v0.1.0 (2024-04-20) is far behind",
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


def expand_pypi_pn(spec: str, pkg_name: str) -> str:
    """Expand bash ${PN/…/…} parameter substitutions captured from PYPI_PN=.

    Ebuild authors often write PYPI_PN="${PN/-/_}" or PYPI_PN="${PN/-/.}".
    Emitting the literal bash expression into the TOML produces an invalid
    URL at nvchecker runtime.  Evaluate the substitution here instead.
    """
    if not spec.startswith("${PN"):
        return spec
    if spec in ("${PN}", "$PN"):
        return pkg_name
    # ${PN/old/new} (first) or ${PN//old/new} (global)
    m = re.match(r'^\$\{PN(//?)([^/}]+)/([^}]*)\}$', spec)
    if m:
        global_replace = m.group(1) == "//"
        old, new = m.group(2), m.group(3)
        return pkg_name.replace(old, new) if global_replace else pkg_name.replace(old, new, 1)
    return spec


def expand_vars(text: str | None, pkg_name: str, my_pn: str | None = None) -> str | None:
    """Best-effort expansion of the bash variables that commonly appear in
    SRC_URI / HOMEPAGE, so the URL-matching regexes can traverse them.
    PV and P expansion isn't attempted (we don't need the version number).

    my_pn is the parsed value of MY_PN= from the ebuild, if present.  Without
    it, ${MY_PN} would expand to pkg_name, which is wrong for packages that set
    MY_PN to a different string (e.g. openai-whisper sets MY_PN="whisper",
    smart-open sets MY_PN="smart_open").
    """
    if text is None:
        return None
    my_pn_repl = my_pn if my_pn is not None else pkg_name
    for v, repl in [
        ("${PN}", pkg_name), ("$PN", pkg_name),
        ("${MY_PN}", my_pn_repl), ("$MY_PN", my_pn_repl),
        ("${MYPN}", my_pn_repl), ("$MYPN", my_pn_repl),
        ("${MY_P}", my_pn_repl), ("$MY_P", my_pn_repl),
        ("${MYP}", my_pn_repl), ("$MYP", my_pn_repl),
        ("${MY_P%-*}", my_pn_repl),
    ]:
        text = text.replace(v, repl)
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
    # A GitHub archive/release URL in SRC_URI wins over `inherit pypi`.
    # The pypi eclass auto-generates a files.pythonhosted.org SRC_URI, so an
    # explicit github .../archive/ (or releases/download) URL is a deliberate
    # fetch override — the upstream we track is the GitHub repo+tag, not the
    # eclass's PyPI package. e.g. dev-python/opentelemetry-semantic-conventions
    # inherits pypi but fetches the open-telemetry/opentelemetry-python
    # monorepo at v${PV}, while its PyPI sub-package uses an unrelated 0.Xb0
    # beta scheme that would never resolve to our PV. Only SRC_URI counts
    # here, not HOMEPAGE: a HOMEPAGE listing both github and pypi still
    # prefers pypi (see the HOMEPAGE-PyPI branch below).
    if src_uri:
        m = GITHUB_ARCHIVE_RE.search(src_uri)
        if m:
            return {"kind": "github", "spec": f"{m.group(1)}/{m.group(2)}"}

    # PyPI: if inherit pypi is present
    if PYPI_INHERIT_RE.search(ebuild_text):
        pn_override = first_group(PYPI_PN_RE.search(ebuild_text))
        if pn_override:
            name = expand_pypi_pn(pn_override, pkg_name)
        else:
            name = pkg_name
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

    # PyPI via HOMEPAGE: catches ebuilds with no SRC_URI but a canonical PyPI
    # project URL in HOMEPAGE — wheel-only upstreams or hand-written
    # replacements that should still track the upstream PyPI version.
    # Checked before HOMEPAGE-GitHub: when an ebuild lists both a GitHub repo
    # and a PyPI page in HOMEPAGE, the PyPI URL is the more reliable upstream
    # signal (the linked GitHub repo can be a fork, mirror, or carry stray
    # non-semver tags that break max-tag selection).
    if homepage:
        m = PYPI_PROJECT_URL_RE.search(homepage)
        if m:
            return {"kind": "pypi", "spec": m.group(1), "note": "from HOMEPAGE PyPI URL"}

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

    if kind == "special":
        lines = [quoted]
        for key, val in classification["spec"].items():
            if isinstance(val, bool):
                lines.append(f"{key} = {'true' if val else 'false'}")
            elif key in ("include_regex", "from_pattern", "to_pattern", "regex"):
                # TOML literal string preserves regex backslashes as-is.
                lines.append(f"{key} = '{val}'")
            else:
                lines.append(f'{key} = "{val}"')
        return lines

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
            elif "from_pattern" not in override:
                # No explicit prefix or from/to transform: apply the default
                # v-strip so upstream tags (v1.2.3) compare cleanly against
                # Portage PVs (1.2.3), which never carry a "v" prefix.
                lines.append('prefix = "v"')
            if "from_pattern" in override:
                lines.append(f"from_pattern = '{override['from_pattern']}'")
            if "to_pattern" in override:
                lines.append(f"to_pattern = '{override['to_pattern']}'")
        else:
            lines.append('prefix = "v"')
        if note:
            lines.append(f"# note: {note}")
    elif kind == "bitbucket":
        lines.append('source = "bitbucket"')
        lines.append(f'bitbucket = "{classification["spec"]}"')
        lines.append("use_max_tag = true")
        lines.append('prefix = "v"')
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

            if entry_name in SKIP_PKGS:
                cls = {"kind": "unknown", "note": SKIP_PKGS[entry_name]}
                entries_by_kind["unknown"].append((entry_name, str(pkg_dir), cls))
                counter["unknown"] += 1
                continue

            if entry_name in SPECIAL_SOURCES:
                cls = {"kind": "special", "spec": SPECIAL_SOURCES[entry_name]}
                entries_by_kind["special"].append((entry_name, str(pkg_dir), cls))
                counter["special"] += 1
                continue

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
            my_pn = first_group(MY_PN_RE.search(text))
            homepage = expand_vars(first_group(HOMEPAGE_RE.search(text)), pkg_dir.name, my_pn)
            src_uri = expand_vars(first_group(SRC_URI_RE.search(text)), pkg_dir.name, my_pn)
            egit = expand_vars(first_group(EGIT_REPO_URI_RE.search(text)), pkg_dir.name, my_pn)

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

    for kind in ("pypi", "github", "gitlab", "bitbucket", "cpan", "special"):
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
    for kind in ("pypi", "github", "gitlab", "bitbucket", "cpan", "special", "live", "unknown", "no-ebuild"):
        if counter[kind]:
            print(f"  {kind:14s} {counter[kind]:4d}", file=sys.stderr)
    total = sum(counter.values())
    print(f"  {'total':14s} {total:4d}", file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
