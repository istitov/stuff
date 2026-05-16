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
	elog "It tracks linux-stable through 6.14.11 (full upstream coverage — 6.14"
	elog "ended at .11) via alicef's genpatches trunk AND keeps a curated"
	elog "subset of natalenko's pf-kernel delta on top. 6.14 is an EOL non-LTS"
	elog "branch — no further linux-stable backports will arrive."
	elog ""
	elog "Curated pf features RETAINED from natalenko's patchset:"
	elog "  * BBRv3 TCP congestion control (net/ipv4/tcp_bbr* and helpers)"
	elog "  * x86 ISA levels (pf-style: X86_64_ISA_LEVEL, surgically merged"
	elog "    with stable's X86_CMPXCHG64 + MGEODE additions)"
	elog "  * BROADCAST_TLB_FLUSH AMD-pstate-related Kconfig"
	elog "  * zstd compression library updates (lib/zstd/)"
	elog "  * DDCCI / DDCCI-backlight drivers (drivers/char/ddcci.c)"
	elog "  * AMD-pstate cpufreq enhancements (drivers/cpufreq/amd-pstate.c)"
	elog "  * syscall.tbl additions across arches (futex_waitv etc.)"
	elog "  * Subset of mm/include hooks (madvise, ksm, smpboot)"
	elog ""
	elog "Patches DROPPED from natalenko's patchset, with reasons:"
	elog "  * kernel/sched/{core,fair,rt}.c: gentoo-sources has newer"
	elog "    scheduler helpers."
	elog "  * arch/x86/Kconfig (top-level): pf reverts stable's KASAN/KCSAN"
	elog "    GCC-compat checks, EISA x86_32-only restriction, RUST RUSTC"
	elog "    version condition, conditional MICROCODE deps. Drop pf's"
	elog "    top-level Kconfig changes to keep stable improvements."
	elog "  * Most 'minor fixes' pf carries are now in linux-stable's 6.14.X"
	elog "    backports already (often in newer/better form)."
	elog ""
	elog "Patches NOT FETCHED from genpatches (per-branch judgment):"
	elog "  * 5010_enable-cpu-optimizations-universal: pf-flavored vanilla"
	elog "    mismatch (same as 6.9-6.13)."
	elog "  * 5020_BMQ-and-PDS-io-scheduler + 5021_BMQ-and-PDS-gentoo-defaults:"
	elog "    opt-in alternative scheduler. Out of scope."
	elog ""
	elog "If you specifically need pf-kernel's full patchset, install"
	elog "pf-sources-6.14_p6-r1 instead — it stays GA-frozen and ships"
	elog "natalenko's patchset verbatim, missing the bulk of the eleven"
	elog "linux-stable releases (6.14.1-6.14.11) that this revision applies;"
	elog "r1 still ships surgical CVE backports for the most severe"
	elog "vulnerabilities from that range."
	elog ""

	optfeature "userspace KSM helper" sys-process/uksmd
}

pkg_postrm() {
	local KV_FULL="${PFPV}"
	kernel-2_pkg_postrm
}
