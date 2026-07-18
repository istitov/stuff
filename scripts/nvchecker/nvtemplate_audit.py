#!/usr/bin/env python3
"""Audit nvchecker version-template correctness across the overlay.

Detects packages whose tracking template has gone STALE relative to upstream's
current version scheme — a silent, permanent omission (new releases stop being
seen) that a normal drift run cannot reveal, because a broken template just looks
"up to date". Complements the drift scan; does not replace it.

Read-only. Network via `git ls-remote --tags` (tokenless — not subject to the
GitHub REST API's 60 req/hr limit; see reference_nvchecker_tokenless_ls_remote),
the repo `tags.atom` feed (recent tags, to spot a scheme change), and the PyPI
JSON API. Reads the RENDERED per-package filter straight from the generated
nvchecker.toml (include_regex/exclude_regex/prefix/from_pattern/to_pattern), so it
audits exactly what nvchecker uses — no need to re-derive from generate.py.

Verdicts (per entry):
  OK              matcher resolves the newest plausible upstream release
  UNRESOLVED      matcher (or source) matches NOTHING — template almost certainly broken
  OMISSION-SUSPECT a recent version-like upstream tag is EXCLUDED by our filter while an
                  older one is matched — either a scheme change (fix) or an intended
                  prerelease exclusion (clear it); needs human eyes
  SHAPE-DRIFT     resolved value's form differs from our ebuild PV's form (part count /
                  prefix / leading component) — mapping likely drifted
  WE-SHIP-NEWER   our PV > upstream latest (usually benign: errata suffix, snapshot)
  SKIP            source type not covered by this pass (cpan/gitlab/bitbucket/regex) —
                  hand-check

Usage (from stuff/):
    python3 scripts/nvchecker/nvtemplate_audit.py [--only cat/pkg,...] [--source github|pypi]
Needs network → run with the sandbox disabled.
"""
from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
import tomllib
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

HERE = Path(__file__).resolve().parent
CONF = HERE / "nvchecker.toml"
TREE_BASELINE = HERE / "tree_baseline.py"

# ---- version key: parseable PEP440 must outrank junk so max() ignores non-version
# tags (stable/latest/ciflow/...). Tier 2 > 1 > 0. (Mirrors the tokenless checker.)
try:
    from packaging.version import Version, InvalidVersion
    _HAVE_PKG = True
except ImportError:
    _HAVE_PKG = False

_P2P = [(re.compile(r'-r\d+$'), ''), (re.compile(r'_p(\d+)$'), r'.post\1'),
        (re.compile(r'_rc(\d+)$'), r'rc\1'), (re.compile(r'_alpha(\d+)$'), r'a\1'),
        (re.compile(r'_beta(\d+)$'), r'b\1'), (re.compile(r'_pre\d*$'), r'.dev0')]


def vkey(pv: str):
    n = pv
    for pat, repl in _P2P:
        n = pat.sub(repl, n)
    if _HAVE_PKG:
        try:
            return (2, Version(n), ())
        except InvalidVersion:
            pass
    if re.match(r'\d', n):
        parts = re.split(r'[.\-_]', n)
        ip = []
        for p in parts:
            try:
                ip.append((0, int(p)))
            except ValueError:
                ip.append((1, p))
        return (1, tuple(ip), ())
    return (0, (), pv)


# A tag that plausibly denotes a release (rules out ciflow/*, branch, sha tags).
_PRERELEASE_RE = re.compile(r'(?i)(rc|alpha|beta|dev|preview|nightly|snapshot|pre|test)\d*')
# Nightly / build / calver-alpha / foreign-project channels that live alongside a
# repo's stable tags and are intentionally excluded: ROCm's therock-*/hip-version_*,
# the LLVM (llvmorg-*) and AMD driver (amdgpu-*) tags that ride in ROCm's LLVM-based
# repos, YYYYMMDD build/nightly dates (dash/underscore/dot-delimited, incl. mantid's
# vX.Y.YYYYMMDD.HHMM), and trailing-letter calver alphas like v26.10.00a.
_NIGHTLY_RE = re.compile(
    r'(?i)(therock|hip-version|llvmorg|amdgpu)|(^|[-_.])\d{8}([-_.]|$)|\d\.\d+(?:\.\d+)?[a-z]$')


def numcore(tag: str) -> str:
    """Strip a leading word/prefix so prefix-scheme tags compare on their numeric
    core (e.g. 'rocm-7.2.4'->'7.2.4', 'release-v5.6.0'->'5.6.0', 'v3.8.12'->'3.8.12')."""
    m = re.search(r'\d', tag)
    return tag[m.start():] if m else tag


def looks_versionish(tag: str) -> bool:
    if '/' in tag or ' ' in tag or len(tag) > 40:
        return False
    if not re.search(r'\d', tag):
        return False
    # optional word/prefix, a numeric core, optional letter/segment tail
    return bool(re.fullmatch(r'[A-Za-z._+-]*\d+(?:\.\d+)*[A-Za-z]*\d*(?:[._+-]\w+)?', tag))


def matches(tag: str, conf: dict) -> bool:
    """Replicate nvchecker apply_list_options filtering (include/exclude via fullmatch)."""
    inc = conf.get("include_regex")
    exc = conf.get("exclude_regex")
    if inc is not None and not re.fullmatch(inc, tag):
        return False
    if exc is not None and re.fullmatch(exc, tag):
        return False
    return True


def transform(tag: str, conf: dict) -> str:
    """Replicate nvchecker prefix-strip + from_pattern/to_pattern rewrite."""
    v = tag
    prefix = conf.get("prefix")
    if prefix and v.startswith(prefix):
        v = v[len(prefix):]
    fp = conf.get("from_pattern")
    if fp is not None:
        v = re.sub(fp, conf.get("to_pattern", ""), v)
    return v


def shape(v: str) -> tuple:
    """Coarse shape signature: (leading-alpha-prefix, numeric-part-count, has-letter-suffix)."""
    m = re.match(r'^([A-Za-z._+-]*)', v)
    prefix = m.group(1) if m else ""
    nums = re.findall(r'\d+', v)
    tail = bool(re.search(r'\d[A-Za-z]+\d*$', v))
    return (prefix, len(nums), tail)


def ls_remote_tags(repo: str) -> list[str]:
    out = subprocess.run(["git", "ls-remote", "--tags", "--refs", f"https://github.com/{repo}"],
                         capture_output=True, text=True, timeout=60)
    if out.returncode != 0:
        raise RuntimeError((out.stderr or "ls-remote failed").strip().splitlines()[-1][:100])
    return [ln.split("\trefs/tags/", 1)[1] for ln in out.stdout.splitlines() if "\trefs/tags/" in ln]


def latest_release_tag(repo: str) -> str | None:
    out = subprocess.run(["curl", "-sI", "-o", "/dev/null", "-w", "%{redirect_url}", "--max-time", "30",
                          f"https://github.com/{repo}/releases/latest"], capture_output=True, text=True, timeout=40)
    loc = out.stdout.strip()
    return loc.rsplit("/tag/", 1)[1] if "/tag/" in loc else None


def pypi_latest(name: str) -> str | None:
    out = subprocess.run(["curl", "-fsSL", "--max-time", "30", f"https://pypi.org/pypi/{name}/json"],
                         capture_output=True, text=True, timeout=40)
    if out.returncode != 0:
        return None
    try:
        return json.loads(out.stdout)["info"]["version"]
    except Exception:
        return None


def audit_github(name: str, conf: dict, pv: str | None) -> dict:
    repo = conf["github"]
    if conf.get("use_latest_release"):
        tag = latest_release_tag(repo)
        if not tag:
            return _v(name, "UNRESOLVED", pv, None, "releases/latest resolved nothing")
        val = transform(tag, conf)
        return _drift(name, pv, val, note=f"latest-release {tag}")
    # use_max_tag path
    try:
        all_tags = ls_remote_tags(repo)
    except Exception as e:
        return _v(name, "UNRESOLVED", pv, None, f"ls-remote error: {e}")
    matched = [t for t in all_tags if matches(t, conf)]
    if not matched:
        return _v(name, "UNRESOLVED", pv, None,
                  f"filter matches 0 of {len(all_tags)} tags — template broken")
    # Select the newest matched tag on its TRANSFORMED value (prefix stripped), else
    # a prefix-scheme tag falls to string compare and 'release-v3.8.9' > 'release-v3.8.14'.
    matched_latest_tag = max(matched, key=lambda t: vkey(transform(t, conf)))
    val = transform(matched_latest_tag, conf)
    # Omission check over the FULL tag list (real tag names, not atom release-titles):
    # any version-like tag the filter EXCLUDES whose numeric core exceeds our matched
    # latest — dropping intended exclusions (prereleases, nightly/calver-alpha channels).
    # Require a dotted core so ancient single-segment tags (faiss v20180223) don't flag.
    mk = vkey(numcore(matched_latest_tag))
    suspects = [t for t in all_tags
                if looks_versionish(t) and not matches(t, conf)
                and "." in numcore(t)
                and not _PRERELEASE_RE.search(t) and not _NIGHTLY_RE.search(t)
                and vkey(numcore(t)) > mk]
    if suspects:
        top = sorted(suspects, key=lambda t: vkey(numcore(t)), reverse=True)[:4]
        return _v(name, "OMISSION-SUSPECT", pv, val,
                  f"tag(s) newer than matched, excluded by filter: {', '.join(top)} "
                  f"(matched latest: {matched_latest_tag})")
    return _drift(name, pv, val, note=f"tag {matched_latest_tag}")


def audit_pypi(name: str, conf: dict, pv: str | None) -> dict:
    up = pypi_latest(conf["pypi"])
    if up is None:
        return _v(name, "UNRESOLVED", pv, None, "pypi json returned nothing")
    return _drift(name, pv, up, note="pypi", shape_check=True)


def _drift(name, pv, val, note="", shape_check=False) -> dict:
    if pv is None:
        return _v(name, "OK", pv, val, f"{note} (no PV baseline)")
    if shape_check and shape(pv) != shape(val):
        # tolerate pure major differences; flag genuine form changes
        if shape(pv)[1] != shape(val)[1] or shape(pv)[0] != shape(val)[0]:
            return _v(name, "SHAPE-DRIFT", pv, val, f"{note}: PV shape {shape(pv)} vs upstream {shape(val)}")
    try:
        if vkey(pv) > vkey(val):
            return _v(name, "WE-SHIP-NEWER", pv, val, note)
    except Exception:
        pass
    return _v(name, "OK", pv, val, note)


def _v(name, verdict, pv, val, note) -> dict:
    return {"name": name, "verdict": verdict, "pv": pv, "upstream": val, "note": note}


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--only", help="comma-separated cat/pkg to audit")
    ap.add_argument("--source", help="restrict to one source type (github/pypi)")
    ap.add_argument("--out", default="/tmp/nvtemplate_audit.report",
                    help="report path (default /tmp — a point-in-time worklist, not committed)")
    ap.add_argument("--workers", type=int, default=12)
    args = ap.parse_args()

    conf = tomllib.loads(CONF.read_text())
    # PV baseline
    tb = subprocess.run([sys.executable, str(TREE_BASELINE)], capture_output=True, text=True)
    base = json.loads(tb.stdout)["data"] if tb.returncode == 0 else {}

    only = set(args.only.split(",")) if args.only else None
    entries = []
    for name, c in conf.items():
        if name.startswith("__") or not isinstance(c, dict) or "source" not in c:
            continue
        if only and name not in only:
            continue
        if args.source and c.get("source") != args.source:
            continue
        entries.append((name, c))

    results = []
    def run_one(name, c):
        pv = base.get(name, {}).get("version")
        src = c.get("source")
        try:
            if src == "github":
                return audit_github(name, c, pv)
            if src == "pypi":
                return audit_pypi(name, c, pv)
            return _v(name, "SKIP", pv, None, f"source={src} not covered — hand-check")
        except Exception as e:
            return _v(name, "UNRESOLVED", pv, None, f"audit error: {e}")

    with ThreadPoolExecutor(max_workers=args.workers) as ex:
        futs = {ex.submit(run_one, n, c): n for n, c in entries}
        for f in as_completed(futs):
            results.append(f.result())

    order = {"UNRESOLVED": 0, "OMISSION-SUSPECT": 1, "SHAPE-DRIFT": 2, "WE-SHIP-NEWER": 3, "SKIP": 4, "OK": 5}
    results.sort(key=lambda r: (order.get(r["verdict"], 9), r["name"]))

    from collections import Counter
    tally = Counter(r["verdict"] for r in results)
    lines = [f"# nvchecker version-template audit — {len(results)} entries",
             "# " + "  ".join(f"{k}={tally.get(k,0)}" for k in order), ""]
    for r in results:
        if r["verdict"] == "OK":
            continue
        lines.append(f"[{r['verdict']}] {r['name']}  pv={r['pv']} upstream={r['upstream']}")
        lines.append(f"    {r['note']}")
    report = "\n".join(lines) + "\n"
    Path(args.out).write_text(report)
    print(report)
    print(f"(full report incl. OK written to {args.out})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
