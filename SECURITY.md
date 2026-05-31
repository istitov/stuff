# Security Policy

## Reporting a vulnerability

This overlay ships kernel patches (`sys-kernel/pf-sources*`), GPU
driver tooling (ROCm, CUDA), and a local-LLM stack
(`dev-python/vllm`, `sci-misc/llama-cpp`, and their dependency tail).
Vulnerabilities in the overlay's ebuilds, patches, or build recipes
warrant careful disclosure.

Please use [GitHub private vulnerability reporting](https://github.com/istitov/stuff/security/advisories/new):
the "Report a vulnerability" button under the Security tab. The
report stays private until disclosed and auto-tracks discussion.

Please include:

- The exact ebuild atom (e.g. `sys-kernel/pf-sources-7.0_p4`).
- A description of the issue and how to reproduce it.
- Any CVE identifier if upstream has already assigned one.

## Out of scope — report upstream

Vulnerabilities **upstream of this overlay** should be reported where
the code actually lives. The overlay packages and patches that code
but does not maintain it; downstream-only reports tend to languish
because the maintainer here can't fix them.

- `::gentoo` base-tree packages → [Gentoo Security Handbook](https://wiki.gentoo.org/wiki/Security_Handbook)
- Linux kernel issues (including the pf-kernel patch series) → upstream pf-kernel and/or linux-stable
- ROCm / CUDA / vllm / llama.cpp / spaCy / and similar → their respective upstream projects

Once an upstream advisory is public, we are glad to coordinate the
downstream packaging side (revbump, masking the vulnerable version,
news item if appropriate).

## Supported versions

The overlay is rolling: only the current tip of `master` is
"supported" in any meaningful sense, and there are no point-in-time
releases. When a security fix lands, downstream users should
`emerge --sync stuff` and rebuild the affected package.

For the curated `pf-sources` line specifically, see the per-version
ebuild notes in `sys-kernel/pf-sources*/` — those carry the explicit
CVE-patch curation policy that differs from the upstream pf-kernel
cadence.

## Response expectations

This is a small overlay maintained by one or two people in their
spare time. Response is best-effort:

- Acknowledgement of a credible report within one week.
- A fix, mitigation, or coordinated disclosure plan within a few
  weeks, longer if upstream coordination is involved.

If you have not heard back within two weeks, please ping the
advisory thread again — the first notification may have been missed.
