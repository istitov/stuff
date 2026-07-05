# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# 6.16 is a non-LTS kernel that reached end-of-life upstream (linux-stable
# stopped at 6.16.12). genpatches' last bundle for this branch (-15)
# tracks stable through 6.16.12 — full coverage. ::gentoo no longer
# ships gentoo-sources-6.16.X, but alicef's release tarballs remain
# available on dev.gentoo.org, which is what this ebuild fetches.

ETYPE="sources"

# Last genpatches release for the 6.16 branch tracks linux-stable
# through 6.16.12 (which is also where linux-stable ended for 6.16,
# so coverage is complete).
K_GENPATCHES_VER="15"

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
	elog "gentoo-sources-based pf-sources-extended: tracks linux-stable through"
	elog "6.16.12 (full coverage — 6.16 ended at .12) via Gentoo's genpatches,"
	elog "plus a curated subset of natalenko's pf-kernel delta. 6.16 is an EOL"
	elog "non-LTS branch — no further linux-stable backports will arrive."
	elog ""
	elog "Curated pf features kept: BBRv3, pf-style x86 ISA levels"
	elog "(X86_64_ISA_LEVEL), zstd bump, DDCCI, AMD-pstate, syscall.tbl"
	elog "additions, and mm/include hooks."
	elog ""
	elog "pf changes overlapping gentoo-sources' newer form (scheduler tweaks,"
	elog "top-level arch/x86/Kconfig) are dropped in favour of stable."
	elog ""
	elog "For pf-kernel's full patchset, install pf-sources-6.16_p5-r1 instead —"
	elog "it stays GA-frozen and still ships surgical CVE backports."
	elog ""

	optfeature "userspace KSM helper" sys-process/uksmd
}

pkg_postrm() {
	local KV_FULL="${PFPV}"
	kernel-2_pkg_postrm
}
