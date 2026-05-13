# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# 6.7 is a non-LTS kernel that reached end-of-life upstream (linux-stable
# stopped at 6.7.12). The trunk-pinned patches captured here track stable
# all the way to 6.7.12 — full coverage for this EOL branch.
#
# Per-branch judgment on 5xxx (genpatches "experimental" category):
#   * 5010_enable-cpu-optimizations-universal: NOT included on this slot.
#     Stable backport 1005_linux-6.7.6 modifies arch/x86/Kconfig.cpu (one
#     small `MCRUSOE` removal), shifting line numbers enough that 5010's
#     hunk #10 cannot relocate within fuzz tolerance. Rather than drop
#     1005 (loses all 6.7.6 stable fixes) we drop 5010 and hand-promote
#     pf's own arch/x86/Kconfig{,.cpu} into the curated subset — partition
#     normally classifies them as both-touched (1005 also touches), but
#     here we override that and let the curated diff turn gentoo's
#     post-1005 state into pf's state. User sees pf-style ISA levels
#     (MNATIVE/X86_64_ISA_LEVEL) plus pf's AMD_MEM_ENCRYPT_ACTIVE_BY_DEFAULT
#     and AMD-pstate-friendly SCHED_MC_PRIO depend tweak.
#   * 5020_BMQ-and-PDS-io-scheduler: NOT included. Out of scope for the
#     "minimal pf identity on gentoo-sources" model.

ETYPE="sources"

K_NOSETEXTRAVERSION="1"

K_SECURITY_UNSUPPORTED="1"

SHPV="${PV/_p*/}"
PFPV="${PV/_p/-pf}"

inherit kernel-2 optfeature

DESCRIPTION="Linux kernel: gentoo-sources base + curated pf-kernel patchset"
HOMEPAGE="https://pfkernel.natalenko.name/
	https://dev.gentoo.org/~alicef/genpatches/"

# Per-slot snapshot of alicef's genpatches trunk for this branch,
# bundled into pf-genpatches-${SHPV}.tar.xz on the sister overlay
# extra-stuff (https://github.com/istitov/extra-stuff). Pinned by
# tag (-r70-1) so the URL is immutable; refreshing the snapshot
# means a new tag suffix. The original alicef trunk dir is a live
# working dir, so this bundle is the durable reference.
SRC_URI="https://www.kernel.org/pub/linux/kernel/v6.x/linux-${SHPV}.tar.xz
	https://raw.githubusercontent.com/istitov/extra-stuff/pf-genpatches-${SHPV}-r70-1/sys-kernel/pf-sources-extended/pf-genpatches-${SHPV}.tar.xz -> pf-genpatches-${SHPV}-r70-1.tar.xz
	https://codeberg.org/istitov/extra-stuff/raw/tag/pf-genpatches-${SHPV}-r70-1/sys-kernel/pf-sources-extended/pf-genpatches-${SHPV}.tar.xz -> pf-genpatches-${SHPV}-r70-1.tar.xz
	https://gitlab.com/istitov/extra-stuff/-/raw/pf-genpatches-${SHPV}-r70-1/sys-kernel/pf-sources-extended/pf-genpatches-${SHPV}.tar.xz -> pf-genpatches-${SHPV}-r70-1.tar.xz
	https://raw.githubusercontent.com/istitov/extra-stuff/pf-curated-${SHPV}-r70-1/sys-kernel/pf-sources-extended/pf-curated-${SHPV}.tar.xz -> pf-curated-${SHPV}-r70-1.tar.xz
	https://codeberg.org/istitov/extra-stuff/raw/tag/pf-curated-${SHPV}-r70-1/sys-kernel/pf-sources-extended/pf-curated-${SHPV}.tar.xz -> pf-curated-${SHPV}-r70-1.tar.xz
	https://gitlab.com/istitov/extra-stuff/-/raw/pf-curated-${SHPV}-r70-1/sys-kernel/pf-sources-extended/pf-curated-${SHPV}.tar.xz -> pf-curated-${SHPV}-r70-1.tar.xz"

S="${WORKDIR}/linux-${SHPV}"

KEYWORDS=""

K_EXTRAEINFO="For more info on pf-kernel and details on how to report problems,
	see: ${HOMEPAGE}."

pkg_setup() {
	ewarn ""
	ewarn "${PN} is *not* supported by the Gentoo Kernel Project in any way."
	ewarn "If you need support, please create an issue at"
	ewarn "https://github.com/istitov/stuff/issues"
	ewarn "Do *not* open bugs in Gentoo's bugzilla unless you have issues with"
	ewarn "the ebuilds. Thank you."
	ewarn ""

	kernel-2_pkg_setup
}

src_unpack() {
	unpack ${A}
}

src_prepare() {
	eapply "${WORKDIR}/pf-genpatches-${SHPV}"/*.patch
	eapply "${WORKDIR}/pf-curated-${SHPV}"/*.patch
	default
}

pkg_postinst() {
	local KV_FULL="${PFPV}"
	kernel-2_pkg_postinst

	elog ""
	elog "This is the gentoo-sources-based pf-sources-extended kernel."
	elog "It tracks linux-stable through 6.7.12 (full upstream coverage — 6.7"
	elog "ended at .12) via alicef's genpatches trunk AND keeps a curated"
	elog "subset of natalenko's pf-kernel delta on top. 6.7 is an EOL non-LTS"
	elog "branch — no further linux-stable backports will arrive."
	elog ""
	elog "Curated pf features RETAINED from natalenko's patchset:"
	elog "  * BBRv3 TCP congestion control (net/ipv4/tcp_bbr* and helpers)"
	elog "  * x86 ISA levels (pf-style: MNATIVE / X86_64_ISA_LEVEL)"
	elog "  * AMD_MEM_ENCRYPT_ACTIVE_BY_DEFAULT + AMD-pstate SCHED_MC_PRIO"
	elog "  * zstd compression library updates (lib/zstd/)"
	elog "  * DDCCI / DDCCI-backlight drivers (drivers/char/ddcci.c)"
	elog "  * AMD-pstate cpufreq enhancements (drivers/cpufreq/amd-pstate.c)"
	elog "  * syscall.tbl additions across arches (futex_waitv etc.)"
	elog "  * Subset of mm/include hooks (madvise, ksm, smpboot)"
	elog ""
	elog "Note: arch/x86/Kconfig and arch/x86/Kconfig.cpu are normally classified"
	elog "as both-touched by the partition (because 1005_linux-6.7.6 modifies"
	elog "Kconfig.cpu), so the curated subset would drop them. They're"
	elog "hand-promoted on this slot to keep pf's identity ISA-level Kconfig."
	elog ""
	elog "Patches DROPPED from natalenko's patchset, with reasons:"
	elog "  * kernel/sched/{core,fair,rt}.c: gentoo-sources has newer"
	elog "    scheduler helpers (uclamp + thermal). Keeping pf's older form"
	elog "    would regress, not improve, scheduler behaviour."
	elog "  * Most 'minor fixes' pf carries are now in linux-stable's 6.7.X"
	elog "    backports already (often in newer/better form). pf's overall"
	elog "    delta is much smaller on this branch (151 paths) than on older"
	elog "    LTS slots, so the curated/dropped split is more lopsided here."
	elog ""
	elog "Patches NOT FETCHED from genpatches (per-branch judgment):"
	elog "  * 5010_enable-cpu-optimizations-universal: collides with 1005's"
	elog "    arch/x86/Kconfig.cpu touch. Dropped — pf's own ISA Kconfig is"
	elog "    promoted into the curated subset instead."
	elog "  * 5020_BMQ-and-PDS-io-scheduler: opt-in alternative scheduler."
	elog "    Out of scope for the 'minimal pf identity on gentoo-sources'"
	elog "    model. Use -r1 if you want pf's scheduler tweaks."
	elog ""
	elog "If you specifically need pf-kernel's full patchset, install"
	elog "pf-sources-6.7_p7-r1 instead — it stays GA-frozen and ships"
	elog "natalenko's patchset verbatim, at the cost of missing all twelve"
	elog "linux-stable releases (6.7.1-6.7.12) that this revision applies."
	elog ""

	optfeature "userspace KSM helper" sys-process/uksmd
}

pkg_postrm() {
	local KV_FULL="${PFPV}"
	kernel-2_pkg_postrm
}
