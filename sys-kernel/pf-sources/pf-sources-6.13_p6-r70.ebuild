# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# This revision is fundamentally different from pf-sources-6.13_p6-r1.
# Instead of fetching pf-kernel/codeberg's GA-only sourcetree (Linux 6.13.0
# + pf patchset, no linux-stable updates), it builds on top of vanilla
# 6.13.tar.xz + Gentoo genpatches (sourced per-patch from alicef's live
# trunk dir, since release tarballs were never cut for the 6.13 branch),
# then applies a *curated* subset of natalenko's pf-kernel delta on top.
# See pkg_postinst for what's preserved versus what's dropped and why.
# The slot's pretend version stays "6.13_p6" so this ebuild remains
# drop-in-replaceable for users on the existing pf-sources slot.
#
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

GENPATCHES_TRUNK="https://dev.gentoo.org/~alicef/genpatches/trunk/${SHPV}"

# linux-stable backport chain (1000_…1011_) covers 6.13.1 through 6.13.12.
GENPATCHES_STABLE=(
	1000_linux-${SHPV}.1.patch
	1001_linux-${SHPV}.2.patch
	1002_linux-${SHPV}.3.patch
	1003_linux-${SHPV}.4.patch
	1004_linux-${SHPV}.5.patch
	1005_linux-${SHPV}.6.patch
	1006_linux-${SHPV}.7.patch
	1007_linux-${SHPV}.8.patch
	1008_linux-${SHPV}.9.patch
	1009_linux-${SHPV}.10.patch
	1010_linux-${SHPV}.11.patch
	1011_linux-${SHPV}.12.patch
)

GENPATCHES_EXTRA=(
	1510_fs-enable-link-security-restrictions-by-default.patch
	1700_sparc-address-warray-bound-warnings.patch
	1730_parisc-Disable-prctl.patch
	1740_x86-insn-decoder-test-allow-longer-symbol-names.patch
	2000_BT-Check-key-sizes-only-if-Secure-Simple-Pairing-enabled.patch
	2901_permit-menuconfig-sorting.patch
	2910_bfp-mark-get-entry-ip-as--maybe-unused.patch
	2920_sign-file-patch-for-libressl.patch
	2980_kbuild-gcc15-gnu23-to-gnu11-fix.patch
	2990_libbpf-v2-workaround-Wmaybe-uninitialized-false-pos.patch
	3000_Support-printing-firmware-info.patch
	4567_distro-Gentoo-Kconfig.patch
)

GENPATCHES_PATCHES=( "${GENPATCHES_STABLE[@]}" "${GENPATCHES_EXTRA[@]}" )

SRC_URI="https://www.kernel.org/pub/linux/kernel/v6.x/linux-${SHPV}.tar.xz"
for _patch in "${GENPATCHES_PATCHES[@]}"; do
	SRC_URI+=" ${GENPATCHES_TRUNK}/${_patch}"
done
unset _patch

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
	unpack linux-${SHPV}.tar.xz

	local p
	for p in "${GENPATCHES_PATCHES[@]}"; do
		cp "${DISTDIR}/${p}" "${WORKDIR}/" || die "Failed to stage ${p}"
	done
}

src_prepare() {
	eapply "${WORKDIR}"/*.patch
	eapply "${FILESDIR}/pf-curated-6.13"/*.patch
	default
}

pkg_postinst() {
	local KV_FULL="${PFPV}"
	kernel-2_pkg_postinst

	elog ""
	elog "This revision (-r70) is the gentoo-sources-based pf-sources variant."
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
	elog "stays GA-frozen and ships natalenko's patchset verbatim, at the cost"
	elog "of missing all twelve linux-stable releases (6.13.1-6.13.12) that"
	elog "this revision applies."
	elog ""

	optfeature "userspace KSM helper" sys-process/uksmd
}

pkg_postrm() {
	local KV_FULL="${PFPV}"
	kernel-2_pkg_postrm
}
