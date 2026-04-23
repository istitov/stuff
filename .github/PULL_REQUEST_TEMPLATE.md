Thanks for opening a PR! Please skim
[CONTRIBUTING.md](/CONTRIBUTING.md) if you haven't
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
- [ ] `pkgcheck scan --commits` is clean locally.
- [ ] `pkgdev manifest` was re-run for any `SRC_URI` change.
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
removing, etc.
-->
