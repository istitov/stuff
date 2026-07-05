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

# Per-slot snapshot of alicef's genpatches trunk (a live working dir),
# bundled as pf-genpatches-${SHPV}.tar.xz on the sister overlay extra-stuff
# (https://github.com/istitov/extra-stuff), pinned by immutable tag -r70-1
# (refresh = new tag suffix). The bundle is the durable reference.
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
	ewarn "${PN} is *not* supported by the Gentoo Kernel Project. For support,"
	ewarn "open an issue at https://github.com/istitov/stuff/issues. Do *not* use"
	ewarn "Gentoo's bugzilla unless the problem is in the ebuild itself."
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
	elog "gentoo-sources-based pf-sources-extended: tracks linux-stable through"
	elog "6.7.12 (full coverage — 6.7 ended at .12) via alicef's genpatches"
	elog "trunk, plus a curated subset of natalenko's pf-kernel delta. 6.7 is"
	elog "an EOL non-LTS branch — no further linux-stable backports will arrive."
	elog ""
	elog "Curated pf features kept: BBRv3, pf-style x86 ISA levels (MNATIVE /"
	elog "X86_64_ISA_LEVEL, hand-promoted on this slot), AMD_MEM_ENCRYPT +"
	elog "AMD-pstate SCHED_MC_PRIO, zstd bump, DDCCI, AMD-pstate, syscall.tbl"
	elog "additions, and mm/include hooks."
	elog ""
	elog "pf changes overlapping gentoo-sources' newer form (scheduler tweaks)"
	elog "and the opt-in BMQ/PDS + 5010 CPU-opt patches are dropped in favour of"
	elog "stable; see the ebuild header for the per-branch rationale."
	elog ""
	elog "For pf-kernel's full patchset, install pf-sources-6.7_p7-r1 instead —"
	elog "it stays GA-frozen and still ships surgical CVE backports."
	elog ""

	optfeature "userspace KSM helper" sys-process/uksmd
}

pkg_postrm() {
	local KV_FULL="${PFPV}"
	kernel-2_pkg_postrm
}
