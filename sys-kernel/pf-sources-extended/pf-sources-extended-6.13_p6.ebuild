# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# 6.13 is a non-LTS kernel that reached end-of-life upstream (linux-stable
# stopped at 6.13.12). The trunk-pinned patches captured here track
# stable all the way to 6.13.12 — full coverage for this EOL branch.
#
# Per-branch judgment on 5xxx (genpatches "experimental" category):
#   * 5010_enable-cpu-optimizations-universal: NOT included (pf-flavored
#     vanilla mismatch, same pattern as 6.9-6.11).
#   * 5020_BMQ-and-PDS-io-scheduler + 5021_BMQ-and-PDS-gentoo-defaults:
#     NOT included. Out of scope.
#
# x86 ISA-level Kconfig is NOT included on this slot (same as 6.11). On
# 6.13, three trunk patches collide with pf's arch/x86 work:
#   * 1003/1005/1010/1011: stable backports modify arch/x86/Kconfig in
#     ways pf would revert (KASAN/KCSAN GCC-version compat checks,
#     conditional MMU_GATHER_RCU_TABLE_FREE/PARAVIRT, MICROCODE's
#     CRYPTO_LIB_SHA256 dep, EISA x86_32-only restriction).
#   * 1010: stable backport adds MGEODEGX1/MGEODE_LX to X86_CMPXCHG64
#     depends in arch/x86/Kconfig.cpu — pf reverts to old form.
#   * 2980_kbuild-gcc15-gnu23-to-gnu11-fix: same Makefile collision as
#     6.11; pf reverts the $(CSTD_FLAG) parameterization.
# Promoting any of arch/x86/{Kconfig,Kconfig.cpu,Makefile} would silently
# revert these stable improvements, so all three stay in both-touched and
# the curated subset drops them. User gets vanilla x86 family selection.

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
	elog "It tracks linux-stable through 6.13.12 (full upstream coverage — 6.13"
	elog "ended at .12) via alicef's genpatches trunk AND keeps a curated"
	elog "subset of natalenko's pf-kernel delta on top. 6.13 is an EOL non-LTS"
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
	elog "x86 ISA-level Kconfig is NOT included on this slot (same as 6.11)."
	elog "Three trunk patches modify arch/x86/{Kconfig,Kconfig.cpu,Makefile}"
	elog "in ways pf would revert (KASAN/KCSAN GCC-compat, MMU_GATHER, EISA"
	elog "x86_32-only, MGEODE_LX support, GCC15 build fix). Promoting pf's"
	elog "versions would regress these stable improvements; user gets vanilla"
	elog "x86 family selection on this branch."
	elog ""
	elog "Patches DROPPED from natalenko's patchset, with reasons:"
	elog "  * kernel/sched/{core,fair,rt}.c: gentoo-sources has newer"
	elog "    scheduler helpers."
	elog "  * arch/x86/Kconfig{,.cpu} + arch/x86/Makefile: see note above."
	elog "  * Most 'minor fixes' pf carries are now in linux-stable's 6.13.X"
	elog "    backports already (often in newer/better form)."
	elog ""
	elog "Patches NOT FETCHED from genpatches (per-branch judgment):"
	elog "  * 5010_enable-cpu-optimizations-universal: pf-flavored vanilla"
	elog "    mismatch."
	elog "  * 5020_BMQ-and-PDS-io-scheduler + 5021_BMQ-and-PDS-gentoo-defaults:"
	elog "    opt-in alternative scheduler. Out of scope."
	elog ""
	elog "If you specifically need pf-kernel's full patchset (including ISA"
	elog "Kconfig + scheduler), install pf-sources-6.13_p6-r1 instead — it"
	elog "stays GA-frozen and ships natalenko's patchset verbatim, missing"
	elog "the bulk of the twelve linux-stable releases (6.13.1-6.13.12) that"
	elog "this revision applies; r1 still ships surgical CVE backports for"
	elog "the most severe vulnerabilities from that range."
	elog ""

	optfeature "userspace KSM helper" sys-process/uksmd
}

pkg_postrm() {
	local KV_FULL="${PFPV}"
	kernel-2_pkg_postrm
}
