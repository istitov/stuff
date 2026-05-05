# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# This revision is fundamentally different from pf-sources-6.15_p6-r1.
# Instead of fetching pf-kernel/codeberg's GA-only sourcetree (Linux 6.15.0
# + pf patchset, no linux-stable updates), it builds on top of the same
# vanilla 6.15.tar.xz + Gentoo genpatches stack that gentoo-sources used
# while 6.15 was still maintained, then applies a *curated* subset of
# natalenko's pf-kernel delta on top. See pkg_postinst for what's preserved
# versus what's dropped and why. The slot's pretend version stays
# "6.15_p6" so this ebuild remains drop-in-replaceable for users on the
# existing pf-sources slot.
#
# 6.15 is a non-LTS kernel that reached end-of-life upstream (linux-stable
# stopped at 6.15.12). genpatches' last bundle for this branch (-13)
# tracks stable through 6.15.11 — one stable release short of upstream
# EOL. ::gentoo no longer ships gentoo-sources-6.15.X, but alicef's
# release tarballs remain available on dev.gentoo.org, which is what
# this ebuild fetches.

ETYPE="sources"

K_GENPATCHES_VER="13"

K_NOSETEXTRAVERSION="1"

K_SECURITY_UNSUPPORTED="1"

K_WANT_GENPATCHES="base extras"

SHPV="${PV/_p*/}"
PFPV="${PV/_p/-pf}"

inherit kernel-2 optfeature

DESCRIPTION="Linux kernel: gentoo-sources base + curated pf-kernel patchset"
HOMEPAGE="https://pfkernel.natalenko.name/
	https://dev.gentoo.org/~alicef/genpatches/"

SRC_URI="https://www.kernel.org/pub/linux/kernel/v6.x/linux-${SHPV}.tar.xz
	https://dev.gentoo.org/~alicef/dist/genpatches/genpatches-${SHPV}-${K_GENPATCHES_VER}.base.tar.xz
	https://dev.gentoo.org/~alicef/dist/genpatches/genpatches-${SHPV}-${K_GENPATCHES_VER}.extras.tar.xz
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
	eapply "${WORKDIR}"/*.patch

	# Curated pf-kernel delta on top of gentoo-sources state.
	# See pkg_postinst for the kept/dropped breakdown.
	eapply "${WORKDIR}/pf-curated-${SHPV}"/*.patch

	default
}

pkg_postinst() {
	local KV_FULL="${PFPV}"
	kernel-2_pkg_postinst

	elog ""
	elog "This revision (-r70) is the gentoo-sources-based pf-sources variant."
	elog "It tracks linux-stable through 6.15.11 via Gentoo's genpatches AND"
	elog "keeps a curated subset of natalenko's pf-kernel delta on top. 6.15"
	elog "is an EOL non-LTS branch (linux-stable ended at 6.15.12, one"
	elog "release past genpatches' last bundle); no further linux-stable"
	elog "backports will arrive."
	elog ""
	elog "Curated pf features RETAINED from natalenko's patchset:"
	elog "  * BBRv3 TCP congestion control (net/ipv4/tcp_bbr* and helpers)"
	elog "  * x86 ISA levels (pf-style: X86_64_ISA_LEVEL Kconfig + Makefile"
	elog "    cflags branches around CONFIG_GENERIC_CPU)"
	elog "  * zstd compression library updates (lib/zstd/)"
	elog "  * DDCCI / DDCCI-backlight drivers (drivers/char/ddcci.c)"
	elog "  * AMD-pstate cpufreq enhancements (drivers/cpufreq/amd-pstate.c)"
	elog "  * syscall.tbl additions across arches (futex_waitv etc.)"
	elog "  * Subset of mm/include hooks (madvise, ksm, smpboot)"
	elog ""
	elog "pf delta on this branch is small (39 partition pf-only files /"
	elog "253 KiB curated patch). Both arch/x86/Kconfig.cpu and"
	elog "arch/x86/Makefile fall into pf-only naturally — no surgical"
	elog "hand-port required."
	elog ""
	elog "Patches DROPPED from natalenko's patchset, with reasons:"
	elog "  * kernel/sched/{core,fair,rt}.c: gentoo-sources has newer"
	elog "    scheduler helpers."
	elog "  * arch/x86/Kconfig (top-level): both-touched (stable backports"
	elog "    1003_linux-6.15.4, 1005_linux-6.15.6, 1006_linux-6.15.7"
	elog "    modify it). Drop pf's Kconfig changes; the Kconfig.cpu"
	elog "    additions land separately."
	elog "  * Most 'minor fixes' pf carries are now in linux-stable's 6.15.X"
	elog "    backports already (often in newer/better form)."
	elog ""
	elog "If you specifically need pf-kernel's full patchset, install"
	elog "pf-sources-6.15_p6-r1 instead — it stays GA-frozen and ships"
	elog "natalenko's patchset verbatim, at the cost of missing all eleven"
	elog "linux-stable releases (6.15.1-6.15.11) that this revision applies."
	elog ""

	optfeature "userspace KSM helper" sys-process/uksmd
}

pkg_postrm() {
	local KV_FULL="${PFPV}"
	kernel-2_pkg_postrm
}
