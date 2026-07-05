# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# 6.14 is a non-LTS kernel that reached end-of-life upstream (linux-stable
# stopped at 6.14.11). The trunk-pinned patches captured here track
# stable all the way to 6.14.11 — full coverage for this EOL branch.
#
# Per-branch judgment on 5xxx (genpatches "experimental" category):
#   * 5010_enable-cpu-optimizations-universal: NOT included.
#   * 5020_BMQ-and-PDS-io-scheduler + 5021_BMQ-and-PDS-gentoo-defaults:
#     NOT included.
#
# x86 ISA-level Kconfig handling on this slot is mixed:
#   * arch/x86/Makefile: naturally pf-only (no genpatch touches it on
#     this branch). pf's Makefile is clean — additions only, no reverts —
#     so the partition includes pf's full Makefile (KBUILD_CFLAGS bump
#     for -mno-avx2/-fno-tree-vectorize plus cflags-$(CONFIG_X86_64_ISA_LEVEL)
#     branches around CONFIG_GENERIC_CPU).
#   * arch/x86/Kconfig.cpu: hand-promoted into pf-only AFTER fixing up
#     pf's X86_CMPXCHG64 line to match 1001_linux-6.14.2's MGEODEGX1 +
#     MGEODE_LX additions (otherwise promoting would silently revert
#     them). Net pf addition: X86_64_ISA_LEVEL Kconfig + BROADCAST_TLB_FLUSH.
#   * arch/x86/Kconfig: NOT promoted. Stable backports 1001/1002/1006/1008
#     modify it with KASAN/KCSAN GCC-compat checks, RUST RUSTC version
#     condition, EISA x86_32-only restriction, conditional MICROCODE deps;
#     pf's version reverts all of them. Drop pf's Kconfig top-level
#     changes (HAVE_EISA + MMU_GATHER + a few others) to keep the stable
#     improvements.

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
	elog "6.14.11 (full coverage — 6.14 ended at .11) via alicef's genpatches"
	elog "trunk, plus a curated subset of natalenko's pf-kernel delta. 6.14 is"
	elog "an EOL non-LTS branch — no further linux-stable backports will arrive."
	elog ""
	elog "Curated pf features kept: BBRv3, pf-style x86 ISA levels"
	elog "(X86_64_ISA_LEVEL), BROADCAST_TLB_FLUSH, zstd bump, DDCCI, AMD-pstate,"
	elog "syscall.tbl additions, and mm/include hooks."
	elog ""
	elog "pf changes overlapping gentoo-sources' newer form (scheduler tweaks,"
	elog "top-level arch/x86/Kconfig) and the opt-in BMQ/PDS + 5010 CPU-opt"
	elog "patches are dropped in favour of stable; see the ebuild header for the"
	elog "per-branch rationale."
	elog ""
	elog "For pf-kernel's full patchset, install pf-sources-6.14_p6-r1 instead —"
	elog "it stays GA-frozen and still ships surgical CVE backports."
	elog ""

	optfeature "userspace KSM helper" sys-process/uksmd
}

pkg_postrm() {
	local KV_FULL="${PFPV}"
	kernel-2_pkg_postrm
}
