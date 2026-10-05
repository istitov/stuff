Thanks for opening a PR! Please skim
[CONTRIBUTING.md](https://github.com/istitov/stuff/blob/master/CONTRIBUTING.md) if you haven't
already — the checklist below is a condensed view of what's there.

<!--
Delete any section that doesn't apply and fill in the rest.
Short PR descriptions are fine — the diff carries the detail.
-->

## Summary

<!-- What does this PR do, in one or two sentences? -->

## Scope

<!-- Which package(s) / eclass / profile file does this touch? -->

- Affected: `category/pkg` (or eclass / profile file)

## Checklist

- [ ] One package per commit (or a single cross-cutting infra change).
- [ ] Commit subjects follow `category/pkg: <action> [version]`.
- [ ] Dependencies and upstream's build interface were reassessed for bumps.
- [ ] Relevant test and install/merge paths were exercised, including
      minimal/maximal feature sets where USE flags materially change them.
- [ ] `pkgcheck scan --exit GentooCI,-VisibleVcsPkg,-DroppedKeywords
      --commits <base>` exits clean locally (the framing and exit set CI uses).
- [ ] `pkgcheck scan -k NonsolvableDepsInStable -p stable -a amd64 <packages>`
      reports nothing for the packages you touched, apart from lemonade's
      known kokoros findings; after an eclass or profile change, run it
      without targets. CI runs the same stable-amd64 check.
- [ ] `pkgdev manifest` was re-run if resolved distfiles or checksums changed,
      including for an ordinary version bump.
- [ ] `scripts/nvchecker/nvchecker.toml` was regenerated for package-set or
      upstream-mapping changes (in a separate infrastructure commit).
- [ ] Copyright header on any new/edited ebuild is current-year
      (`# Copyright 1999-<year> Gentoo Authors`).
- [ ] No `metadata/md5-cache/` files are staged.

## AI / LLM disclosure (optional)

<!--
Per CONTRIBUTING.md: if AI/LLM tooling helped prepare this PR,
a brief note here is appreciated — not required. Examples:
"Used Claude to draft the commit body", "Generated the patch with
Aider", etc. Helps reviewers know where to look more carefully.
-->

## Notes for the reviewer

<!--
Anything non-obvious: a deliberate KEYWORDS choice, a workaround
for upstream breakage, a pkgcheck suppression you're adding or
removing, or validation that could not be run.
-->
