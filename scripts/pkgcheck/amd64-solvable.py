#!/usr/bin/env python3
"""Fail on dependencies that cannot be solved on Gentoo's stable amd64 profiles.

metadata/pkgcheck.conf disables NonsolvableDepsInStable for the whole
repository, because niche profiles lack keywords this ~amd64-first overlay
cannot add. That also hid real install failures on amd64 itself, found in
the 2026-10-03 audit. This script runs that one check on the stable amd64
profiles only, read from ::gentoo's profiles.desc, and fails on any finding
not listed in amd64-solvable.expected next to it.

Usage, from the overlay root:
    amd64-solvable.py                   whole repository
    amd64-solvable.py --commits [REF]   packages changed since REF (default
                                        origin/HEAD, as pkgcheck's own
                                        --commits); the whole repository
                                        when profiles/eclasses or this check
                                        changed or an ebuild was removed
    amd64-solvable.py cat/pkg ...       only these packages

Exit status: 0 when every finding is expected, 1 when one is not, 2 when
pkgcheck itself fails.
"""

import logging
import os
import re
import subprocess
import sys
import warnings

HERE = os.path.dirname(os.path.abspath(__file__))
EXPECTED = os.path.join(HERE, "amd64-solvable.expected")
KEYWORD = "NonsolvableDepsInStable"


def gentoo_location():
    logging.disable(logging.WARNING)
    warnings.simplefilter("ignore")
    from pkgcore.config import load_config

    return load_config().objects.repo["gentoo"].location


def stable_amd64_profiles(gentoo):
    profiles = []
    with open(os.path.join(gentoo, "profiles", "profiles.desc")) as f:
        for line in f:
            fields = line.split()
            if (
                len(fields) == 3
                and fields[0] == "amd64"
                and fields[1].startswith("default/linux/amd64/")
                and fields[2] == "stable"
            ):
                profiles.append(fields[1])
    if not profiles:
        sys.exit("error: no stable amd64 profile found in profiles.desc")
    return profiles


def load_expected():
    # One "<category>/<package> <atom>" per line; <atom> is the unsolvable
    # dependency pkgcheck lists under "solutions".
    entries = []
    with open(EXPECTED) as f:
        for n, line in enumerate(f, 1):
            line = line.split("#", 1)[0].strip()
            if not line:
                continue
            fields = line.split()
            if len(fields) != 2:
                sys.exit(f"error: {EXPECTED}:{n}: expected '<cat/pkg> <atom>'")
            entries.append(tuple(fields))
    return entries


def commits_scope(args):
    # pkgcheck's own --commits also opens profile and repository scopes,
    # which this single keyword cannot serve ("no matching checks"), so
    # derive the targets from git instead. Profile, eclass and layout
    # changes, removed ebuilds (whose reverse dependencies may break) and
    # edits to this check or its expected list need the whole repository;
    # otherwise scan the touched packages.
    # Same default as pkgcheck --commits: the remote's default branch, which
    # also works on a local branch that has no upstream configured.
    ref = args[1] if len(args) > 1 else "origin/HEAD"
    diff = subprocess.run(
        ["git", "diff", "--no-renames", "--name-status", ref, "HEAD"],
        capture_output=True, text=True,
    )
    if diff.returncode:
        sys.stderr.write(diff.stderr)
        sys.exit(2)
    atoms = set()
    for line in diff.stdout.splitlines():
        status, path = line.split("\t", 1)
        if (
            path.startswith(("profiles/", "eclass/", "scripts/pkgcheck/"))
            or path == "metadata/layout.conf"
            or (status == "D" and path.endswith(".ebuild"))
        ):
            return []
        parts = path.split("/")
        if len(parts) >= 3 and os.path.isdir(os.path.join(*parts[:2])):
            if any(f.endswith(".ebuild") for f in os.listdir(os.path.join(*parts[:2]))):
                atoms.add("/".join(parts[:2]))
    return sorted(atoms) or None


def atom_cp(atom):
    """category/package of a dependency atom: drop the operator, the
    version (when an operator is present), the slot and USE deps."""
    m = re.match(r"([<>=~!]*)([^\s\[:]+)", atom.strip())
    op, cpv = m.groups() if m else ("", atom.strip())
    if op.strip("!"):
        cpv = re.sub(r"-[0-9][^/]*$", "", cpv)
    return cpv


def main(args):
    if args[:1] == ["--commits"]:
        args = commits_scope(args)
        if args is None:
            print("AMD64-SOLVABLE: OK (no package changes)")
            return 0
    profiles = stable_amd64_profiles(gentoo_location())
    cmd = [
        "pkgcheck", "scan", "-k", KEYWORD, "-p", ",".join(profiles),
        "-R", "FormatReporter",
        "--format", "{category}/{package}|{version}|{desc}",
        *args,
    ]
    run = subprocess.run(cmd, capture_output=True, text=True)
    # pkgcheck exits 1 both for an exit-set finding and for its own failures
    # (an import error, say); only the first prints findings.
    if run.returncode not in (0, 1) or (run.returncode == 1 and not run.stdout.strip()):
        sys.stderr.write(run.stderr)
        print(f"AMD64-SOLVABLE: pkgcheck failed rc={run.returncode}")
        return 2

    expected = load_expected()
    used = set()
    unexpected = []
    for line in run.stdout.splitlines():
        cp, version, desc = line.split("|", 2)
        m = re.search(r"solutions: \[ (.*) \]", desc)
        solutions = m.group(1).split(", ") if m else []
        # Every unsolvable dependency needs its own accepted entry; one
        # accepted atom must not cover others on the same line.
        hits = [[e for e in expected if e[0] == cp and atom_cp(e[1]) == atom_cp(dep)]
                for dep in solutions]
        if solutions and all(hits):
            used.update(e for hit in hits for e in hit)
        else:
            unexpected.append(f"{cp}-{version}: {desc}")

    for finding in unexpected:
        print(finding)
    # Only a whole-repository scan can tell that an entry no longer matches.
    if not args:
        for cp, atom in expected:
            if (cp, atom) not in used:
                print(f"stale expected entry: {cp} {atom}")

    accepted = len(run.stdout.splitlines()) - len(unexpected)
    if unexpected:
        print(f"AMD64-SOLVABLE: FAILED ({len(unexpected)} unexpected, "
              f"{accepted} accepted, {len(profiles)} profiles)")
        return 1
    print(f"AMD64-SOLVABLE: OK ({accepted} accepted, {len(profiles)} profiles)")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
