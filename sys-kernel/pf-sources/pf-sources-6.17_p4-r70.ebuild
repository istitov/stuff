# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# This revision is fundamentally different from pf-sources-6.17_p4-r1.
# Instead of fetching pf-kernel/codeberg's GA-only sourcetree (Linux 6.17.0
# + pf patchset, no linux-stable updates), it builds on top of the same
# vanilla 6.17.tar.xz + Gentoo genpatches stack that gentoo-sources used
# while 6.17 was still maintained, then applies a *curated* subset of
# natalenko's pf-kernel delta on top. See pkg_postinst for what's preserved
# versus what's dropped and why. The slot's pretend version stays
# "6.17_p4" so this ebuild remains drop-in-replaceable for users on the
# existing pf-sources slot.
#
# 6.17 is a non-LTS kernel that reached end-of-life upstream (linux-stable
# stopped at 6.17.13). genpatches' last bundle for this branch (-16)
# tracks stable through 6.17.13 — full coverage. ::gentoo no longer
# ships gentoo-sources-6.17.X, but alicef's release tarballs remain
# available on dev.gentoo.org, which is what this ebuild fetches.

ETYPE="sources"

# Last genpatches release for the 6.17 branch tracks linux-stable
# through 6.17.13 (full coverage; linux-stable ended at .13).
K_GENPATCHES_VER="16"

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
	elog "It tracks linux-stable through 6.17.13 (full upstream coverage —"
	elog "6.17 ended at .13) via Gentoo's genpatches AND keeps a curated"
	elog "subset of natalenko's pf-kernel delta on top. 6.17 is an EOL"
	elog "non-LTS branch — no further linux-stable backports will arrive."
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
	elog "pf delta on this branch is small (49 partition pf-only files +"
	elog "1 hand-promoted = 50). arch/x86/Kconfig.cpu falls into pf-only"
	elog "naturally; arch/x86/Makefile is hand-promoted from both-touched"
	elog "after verifying pf's version preserves stable backport 1007's"
	elog "-mno-sse4a addition (pf's diff is additive on top of 1007)."
	elog ""
	elog "Patches DROPPED from natalenko's patchset, with reasons:"
	elog "  * kernel/sched/{core,fair,rt}.c: gentoo-sources has newer"
	elog "    scheduler helpers."
	elog "  * Most 'minor fixes' pf carries are now in linux-stable's 6.17.X"
	elog "    backports already (often in newer/better form)."
	elog ""
	elog "If you specifically need pf-kernel's full patchset, install"
	elog "pf-sources-6.17_p4-r1 instead — it stays GA-frozen and ships"
	elog "natalenko's patchset verbatim, at the cost of missing all thirteen"
	elog "linux-stable releases (6.17.1-6.17.13) that this revision applies."
	elog ""

	optfeature "userspace KSM helper" sys-process/uksmd
}

pkg_postrm() {
	local KV_FULL="${PFPV}"
	kernel-2_pkg_postrm
}
