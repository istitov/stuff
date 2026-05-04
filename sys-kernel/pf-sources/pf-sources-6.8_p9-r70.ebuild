# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# This revision is fundamentally different from pf-sources-6.8_p9-r1.
# Instead of fetching pf-kernel/codeberg's GA-only sourcetree (Linux 6.8.0
# + pf patchset, no linux-stable updates), it builds on top of vanilla
# 6.8.tar.xz + Gentoo genpatches (sourced per-patch from alicef's live
# trunk dir — alicef released only one bundled tarball for 6.8 (-10),
# which stopped at stable 6.8.7; the trunk dir continued to track stable
# all the way to 6.8.12), then applies a *curated* subset of natalenko's
# pf-kernel delta on top. See pkg_postinst for what's preserved versus
# what's dropped and why. The slot's pretend version stays "6.8_p9" so
# this ebuild remains drop-in-replaceable for users on the existing
# pf-sources slot.
#
# 6.8 is a non-LTS kernel that reached end-of-life upstream (linux-stable
# stopped at 6.8.12). The trunk-pinned patches captured here track stable
# all the way to 6.8.12 — full coverage for this EOL branch.
#
# Per-branch judgment on 5xxx (genpatches "experimental" category):
#   * 5010_enable-cpu-optimizations-universal: NOT included (pf-flavored
#     vanilla mismatch pattern observed on 6.9-6.13).
#   * 5020_BMQ-and-PDS-io-scheduler + 5021_BMQ-and-PDS-gentoo-defaults:
#     NOT included.

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

# linux-stable backport chain (1000_…1011_) covers 6.8.1 through 6.8.12.
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
	2000_BT-Check-key-sizes-only-if-Secure-Simple-Pairing-enabled.patch
	2900_tmp513-Fix-build-issue-by-selecting-CONFIG_REG.patch
	2910_bfp-mark-get-entry-ip-as--maybe-unused.patch
	2920_sign-file-patch-for-libressl.patch
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
	eapply "${FILESDIR}/pf-curated-6.8"/*.patch
	default
}

pkg_postinst() {
	local KV_FULL="${PFPV}"
	kernel-2_pkg_postinst

	elog ""
	elog "This revision (-r70) is the gentoo-sources-based pf-sources variant."
	elog "It tracks linux-stable through 6.8.12 (full upstream coverage — 6.8"
	elog "ended at .12) via alicef's genpatches trunk AND keeps a curated"
	elog "subset of natalenko's pf-kernel delta on top. 6.8 is an EOL non-LTS"
	elog "branch — no further linux-stable backports will arrive."
	elog ""
	elog "Curated pf features RETAINED from natalenko's patchset:"
	elog "  * BBRv3 TCP congestion control (net/ipv4/tcp_bbr* and helpers)"
	elog "  * x86 ISA levels (pf-style on 6.8: GENERIC_CPU2/3/4 Kconfig +"
	elog "    Makefile cflags additions)"
	elog "  * zstd compression library updates (lib/zstd/)"
	elog "  * DDCCI / DDCCI-backlight drivers (drivers/char/ddcci.c)"
	elog "  * AMD-pstate cpufreq enhancements (drivers/cpufreq/amd-pstate.c)"
	elog "  * syscall.tbl additions across arches (futex_waitv etc.)"
	elog "  * Subset of mm/include hooks (madvise, ksm, smpboot)"
	elog ""
	elog "Patches DROPPED from natalenko's patchset, with reasons:"
	elog "  * kernel/sched/{core,fair,rt}.c: gentoo-sources has newer"
	elog "    scheduler helpers."
	elog "  * arch/x86/Kconfig (top-level): both-touched (six stable"
	elog "    backports modify it). Drop pf's Kconfig changes; the"
	elog "    Kconfig.cpu and Makefile additions land separately."
	elog "  * Most 'minor fixes' pf carries are now in linux-stable's 6.8.X"
	elog "    backports already (often in newer/better form)."
	elog ""
	elog "Patches NOT FETCHED from genpatches (per-branch judgment):"
	elog "  * 5010_enable-cpu-optimizations-universal: pf-flavored vanilla"
	elog "    mismatch (same pattern as 6.9-6.13)."
	elog "  * 5020_BMQ-and-PDS-io-scheduler + 5021_BMQ-and-PDS-gentoo-defaults:"
	elog "    opt-in alternative scheduler. Out of scope."
	elog ""
	elog "If you specifically need pf-kernel's full patchset, install"
	elog "pf-sources-6.8_p9-r1 instead — it stays GA-frozen and ships"
	elog "natalenko's patchset verbatim, at the cost of missing all twelve"
	elog "linux-stable releases (6.8.1-6.8.12) that this revision applies."
	elog ""

	optfeature "userspace KSM helper" sys-process/uksmd
}

pkg_postrm() {
	local KV_FULL="${PFPV}"
	kernel-2_pkg_postrm
}
