# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# This revision is fundamentally different from pf-sources-6.4_p6-r1.
# Instead of fetching pf-kernel/codeberg's GA-only sourcetree (Linux 6.4.0
# + pf patchset, no linux-stable updates), it builds on top of vanilla
# 6.4.tar.xz + Gentoo genpatches (sourced per-patch from alicef's live
# trunk dir, since release tarballs were never cut for the 6.4 branch),
# then applies a *curated* subset of natalenko's pf-kernel delta on top.
# See pkg_postinst for what's preserved versus what's dropped and why.
# The slot's pretend version stays "6.4_p6" so this ebuild remains
# drop-in-replaceable for users on the existing pf-sources slot.
#
# 6.4 is a non-LTS kernel that reached end-of-life upstream (linux-stable
# stopped at 6.4.16). The trunk-pinned patches captured here track stable
# all the way to 6.4.16 — full coverage for this EOL branch.

ETYPE="sources"

# Curated pf delta sets EXTRAVERSION via the patch itself.
K_NOSETEXTRAVERSION="1"

# pf-sources has historically carried K_SECURITY_UNSUPPORTED. Even with
# linux-stable now baked in (which closes the largest gap), we keep the
# flag because the curated pf delta is not covered by Gentoo's security
# team — bugs in the pf-specific portions (BBRv3, x86 ISA levels, zstd
# bump, DDCCI driver, syscall.tbl additions) need to be reported to
# natalenko or the overlay maintainers. Note that 6.4 itself is EOL
# upstream, so no further linux-stable backports will arrive.
K_SECURITY_UNSUPPORTED="1"

# Map "6.4_p6" → "6.4" for the kernel.org tarball + genpatches.
SHPV="${PV/_p*/}"

# Pretend version visible in /lib/modules and /usr/src.
PFPV="${PV/_p/-pf}"

inherit kernel-2 optfeature

DESCRIPTION="Linux kernel: gentoo-sources base + curated pf-kernel patchset"
HOMEPAGE="https://pfkernel.natalenko.name/
	https://dev.gentoo.org/~alicef/genpatches/"

# alicef's trunk holds the per-branch genpatches working tree. There are
# no release tarballs for the 6.4 branch (last bundle on dev.gentoo.org
# is for 6.3); the trunk dir is the only place these patches still live.
# We pin individual patch URLs in SRC_URI so the Manifest captures their
# byte hashes — if alicef edits a patch in place, fetch will fail loudly
# rather than silently change behaviour.
# Per-slot snapshot of alicef's genpatches trunk for this branch,
# bundled into pf-genpatches-${SHPV}.tar.xz on the sister overlay
# extra-stuff (https://github.com/istitov/extra-stuff). Pinned by
# tag (-r70-0) so the URL is immutable; refreshing the snapshot
# means a new tag suffix. The original alicef trunk dir is a live
# working dir, so this bundle is the durable reference.
SRC_URI="https://www.kernel.org/pub/linux/kernel/v6.x/linux-${SHPV}.tar.xz
	https://raw.githubusercontent.com/istitov/extra-stuff/pf-genpatches-${SHPV}-r70-0/sys-kernel/pf-sources/pf-genpatches-${SHPV}.tar.xz -> pf-genpatches-${SHPV}-r70-0.tar.xz
	https://raw.githubusercontent.com/istitov/extra-stuff/pf-curated-${SHPV}-r70-0/sys-kernel/pf-sources/pf-curated-${SHPV}.tar.xz -> pf-curated-${SHPV}-r70-0.tar.xz"

S="${WORKDIR}/linux-${SHPV}"

KEYWORDS="~amd64 ~x86"

K_EXTRAEINFO="For more info on pf-sources and details on how to report problems,
	see: ${HOMEPAGE}."

pkg_setup() {
	ewarn ""
	ewarn "${PN} is *not* supported by the Gentoo Kernel Project in any way."
	ewarn "If you need support, please contact the pf developers directly."
	ewarn "Do *not* open bugs in Gentoo's bugzilla unless you have issues with"
	ewarn "the ebuilds. Thank you."
	ewarn ""

	kernel-2_pkg_setup
}

src_unpack() {
	unpack ${A}
}

src_prepare() {
	# Apply the genpatches stack (stable backports + non-stable additions).
	eapply "${WORKDIR}/pf-genpatches-${SHPV}"/*.patch

	# Curated pf-kernel delta on top of gentoo-sources state.
	# See pkg_postinst for the kept/dropped breakdown.
	eapply "${WORKDIR}/pf-curated-${SHPV}"/*.patch

	default
}

pkg_postinst() {
	# Fixes "wrongly" detected directory name, bgo#862534.
	local KV_FULL="${PFPV}"
	kernel-2_pkg_postinst

	elog ""
	elog "This revision (-r70) is the gentoo-sources-based pf-sources variant."
	elog "It tracks linux-stable through 6.4.16 (full upstream coverage — 6.4"
	elog "ended at .16) via alicef's genpatches trunk AND keeps a curated"
	elog "subset of natalenko's pf-kernel delta on top. 6.4 is an EOL non-LTS"
	elog "branch — no further linux-stable backports will arrive."
	elog ""
	elog "Curated pf features RETAINED from natalenko's patchset:"
	elog "  * BBRv3 TCP congestion control (net/ipv4/tcp_bbr* and helpers)"
	elog "  * zstd compression library updates (lib/zstd/)"
	elog "  * DDCCI / DDCCI-backlight drivers (drivers/char/ddcci.c)"
	elog "  * AMD-pstate cpufreq enhancements (drivers/cpufreq/amd-pstate.c)"
	elog "  * syscall.tbl additions across arches (futex_waitv etc.)"
	elog "  * Subset of mm/include hooks (madvise, ksm, smpboot)"
	elog ""
	elog "x86 ISA-level Kconfig comes from genpatches' 5010 patch on this slot"
	elog "(MK8SSE3, MZEN, MZEN2 etc.) rather than pf's variant (MZEN/MNATIVE/"
	elog "X86_64_ISA_LEVEL) — genpatches' arch/x86/Kconfig.cpu changes apply"
	elog "first and pf's both-touched arch/x86 work is dropped by the curated"
	elog "subset to avoid conflicts. The user-visible feature is the same."
	elog ""
	elog "Patches DROPPED from natalenko's patchset, with reasons:"
	elog "  * kernel/sched/{core,fair,rt}.c: gentoo-sources has newer"
	elog "    scheduler helpers (uclamp + thermal). Keeping pf's older form"
	elog "    would regress, not improve, scheduler behaviour."
	elog "  * fs/cifs/* and fs/ksmbd/*: stable backports already cover the"
	elog "    same fixes in newer form; pf's pre-rename patches conflict."
	elog "  * Most 'minor fixes' pf carries are now in linux-stable's 6.4.X"
	elog "    backports already (often in newer/better form)."
	elog ""
	elog "If you specifically need pf-kernel's full patchset, install"
	elog "pf-sources-6.4_p6-r1 instead — it stays GA-frozen and ships"
	elog "natalenko's patchset verbatim, at the cost of missing all sixteen"
	elog "linux-stable releases (6.4.1-6.4.16) that this revision applies."
	elog ""

	optfeature "userspace KSM helper" sys-process/uksmd
}

pkg_postrm() {
	# Same here, bgo#862534.
	local KV_FULL="${PFPV}"
	kernel-2_pkg_postrm
}
