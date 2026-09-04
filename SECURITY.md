# Security Policy

## Reporting a vulnerability

This overlay ships kernel patches (`sys-kernel/pf-sources*`), GPU driver and
compiler tooling (ROCm, CUDA), network-facing local-AI services, and their
dependency stacks. Vulnerabilities in the overlay's ebuilds, patches, service
definitions, binary repackaging, or build recipes warrant careful disclosure.

Please use [GitHub private vulnerability reporting](https://github.com/istitov/stuff/security/advisories/new):
the "Report a vulnerability" button under the Security tab. The
report stays private until disclosed and auto-tracks discussion.

If you cannot use GitHub, mail the maintainer at
`iohann.s.titov@gmail.com` instead — the same address `metadata.xml`
carries. Ordinary email is not an encrypted reporting channel: use it for
initial contact and say up front that it is a security report, but do not send
undisclosed exploit details unless you are comfortable sending them in
plaintext. The maintainer can arrange the next step with you.

Please include:

- The exact ebuild atom (e.g. `sys-kernel/pf-sources-7.0_p4`).
- A description of the issue and how to reproduce it.
- Any CVE identifier if upstream has already assigned one.

## Out of scope — report upstream

Previously undisclosed vulnerabilities **upstream of this overlay** should be
reported to the project where the affected code lives first. The overlay
packages that code but cannot coordinate an upstream fix or disclosure on the
project's behalf.

- `::gentoo` base-tree packages → [Gentoo Security Handbook](https://wiki.gentoo.org/wiki/Security_Handbook)
- Linux kernel issues (including the pf-kernel patch series) → upstream pf-kernel and/or linux-stable
- ROCm / CUDA / vllm / llama.cpp / spaCy / and similar → their respective upstream projects

Once an upstream advisory is public — or if this overlay still ships a version
already known to be vulnerable — the downstream packaging response is in scope:
revbumping, patching, masking or dropping the affected version, and publishing
a news item where appropriate.

## Supported versions

The overlay is rolling and has no point-in-time releases. Unless a package
documents an actively maintained parallel line, only its newest unmasked
ebuild at the current tip of `master` is a security maintenance target. Older
unmasked versions and masked rollback ebuilds may remain for compatibility or
recovery, but their presence is not a promise of security fixes. When a fix
lands, downstream users should `emerge --sync stuff` and rebuild or upgrade
the affected package.

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
