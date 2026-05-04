# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# This revision is fundamentally different from pf-sources-6.10_p4-r1.
# Instead of fetching pf-kernel/codeberg's GA-only sourcetree (Linux 6.10.0
# + pf patchset, no linux-stable updates), it builds on top of vanilla
# 6.10.tar.xz + Gentoo genpatches (sourced per-patch from alicef's live
# trunk dir, since release tarballs were never cut for the 6.10 branch),
# then applies a *curated* subset of natalenko's pf-kernel delta on top.
# See pkg_postinst for what's preserved versus what's dropped and why.
# The slot's pretend version stays "6.10_p4" so this ebuild remains
# drop-in-replaceable for users on the existing pf-sources slot.
#
# 6.10 is a non-LTS kernel that reached end-of-life upstream (linux-stable
# stopped at 6.10.14). The trunk-pinned patches captured here track
# stable all the way to 6.10.14 — full coverage for this EOL branch.
#
# Per-branch judgment on 5xxx (genpatches "experimental" category):
#   * 5010_enable-cpu-optimizations-universal: NOT included. Same failure
#     mode as 6.9 — trunk's 5010 is calibrated against pf-flavored
#     vanilla rather than kernel.org pristine, hunk anchors don't match.
#     Dropping 5010 lets pf's arch/x86 fall into pf-only naturally so
#     the curated subset applies pf's full ISA Kconfig.
#   * 5020_BMQ-and-PDS-io-scheduler + 5021_BMQ-and-PDS-gentoo-defaults:
#     NOT included. Out of scope for the "minimal pf identity on
#     gentoo-sources" model.

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

# linux-stable backport chain (1000_…1013_) covers 6.10.1 through 6.10.14.
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
	1012_linux-${SHPV}.13.patch
	1013_linux-${SHPV}.14.patch
)

# Non-stable additions; all 5xxx excluded per per-branch judgment.
GENPATCHES_EXTRA=(
	1510_fs-enable-link-security-restrictions-by-default.patch
	1700_sparc-address-warray-bound-warnings.patch
	1730_parisc-Disable-prctl.patch
	2000_BT-Check-key-sizes-only-if-Secure-Simple-Pairing-enabled.patch
	2900_tmp513-Fix-build-issue-by-selecting-CONFIG_REG.patch
	2901_tools-lib-subcmd-compile-fix.patch
	2910_bfp-mark-get-entry-ip-as--maybe-unused.patch
	2911_libbpf-second-workaround-Wmaybe-uninitialized-false-pos.patch
	2920_sign-file-patch-for-libressl.patch
	2990_libbpf-v2-workaround-Wmaybe-uninitialized-false-pos.patch
	2995_dtrace-6.10_p4.patch
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
	eapply "${FILESDIR}/pf-curated-6.10"/*.patch
	default
}

pkg_postinst() {
	local KV_FULL="${PFPV}"
	kernel-2_pkg_postinst

	elog ""
	elog "This revision (-r70) is the gentoo-sources-based pf-sources variant."
	elog "It tracks linux-stable through 6.10.14 (full upstream coverage — 6.10"
	elog "ended at .14) via alicef's genpatches trunk AND keeps a curated"
	elog "subset of natalenko's pf-kernel delta on top. 6.10 is an EOL non-LTS"
	elog "branch — no further linux-stable backports will arrive."
	elog ""
	elog "Curated pf features RETAINED from natalenko's patchset:"
	elog "  * BBRv3 TCP congestion control (net/ipv4/tcp_bbr* and helpers)"
	elog "  * x86 ISA levels (pf-style: MNATIVE / X86_64_ISA_LEVEL)"
	elog "  * zstd compression library updates (lib/zstd/)"
	elog "  * DDCCI / DDCCI-backlight drivers (drivers/char/ddcci.c)"
	elog "  * AMD-pstate cpufreq enhancements (drivers/cpufreq/amd-pstate.c)"
	elog "  * syscall.tbl additions across arches (futex_waitv etc.)"
	elog "  * Subset of mm/include hooks (madvise, ksm, smpboot)"
	elog ""
	elog "Genpatches non-stable additions retained on this slot include the"
	elog "DTrace patch (2995_dtrace-6.10_p4.patch) and the libbpf"
	elog "Wmaybe-uninitialized workarounds (2911_/2990_)."
	elog ""
	elog "Patches DROPPED from natalenko's patchset, with reasons:"
	elog "  * kernel/sched/{core,fair,rt}.c: gentoo-sources has newer"
	elog "    scheduler helpers. pf's older form would regress, not improve."
	elog "  * Most 'minor fixes' pf carries are now in linux-stable's 6.10.X"
	elog "    backports already (often in newer/better form)."
	elog ""
	elog "Patches NOT FETCHED from genpatches (per-branch judgment):"
	elog "  * 5010_enable-cpu-optimizations-universal: trunk's 5010 expects"
	elog "    pf-flavored vanilla; section anchors are off in vanilla 6.10"
	elog "    from kernel.org. Dropped — pf's own ISA Kconfig naturally"
	elog "    lands in the curated subset."
	elog "  * 5020_BMQ-and-PDS-io-scheduler + 5021_BMQ-and-PDS-gentoo-defaults:"
	elog "    opt-in alternative scheduler. Out of scope for the 'minimal pf"
	elog "    identity on gentoo-sources' model. Use -r1 for pf's scheduler."
	elog ""
	elog "If you specifically need pf-kernel's full patchset, install"
	elog "pf-sources-6.10_p4-r1 instead — it stays GA-frozen and ships"
	elog "natalenko's patchset verbatim, at the cost of missing all fourteen"
	elog "linux-stable releases (6.10.1-6.10.14) that this revision applies."
	elog ""

	optfeature "userspace KSM helper" sys-process/uksmd
}

pkg_postrm() {
	local KV_FULL="${PFPV}"
	kernel-2_pkg_postrm
}
