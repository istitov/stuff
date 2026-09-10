# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# EOL at 6.4.16; the bundled genpatches cover the complete stable branch.

ETYPE="sources"

# Curated pf delta sets EXTRAVERSION via the patch itself.
K_NOSETEXTRAVERSION="1"

# Gentoo security does not cover the curated pf delta; report its bugs to
# pf-kernel or the overlay. This branch is also EOL upstream.
K_SECURITY_UNSUPPORTED="1"

SHPV="${PV/_p*/}"

PFPV="${PV/_p/-pf}"

inherit kernel-2 optfeature

DESCRIPTION="Linux kernel: gentoo-sources base + curated pf-kernel patchset"
HOMEPAGE="https://pfkernel.natalenko.name/
	https://dev.gentoo.org/~alicef/genpatches/"

# No 6.4 genpatches release tarball exists. An immutable extra-stuff tag
# snapshots alicef's otherwise-live trunk; refreshes use a new tag suffix.
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
	# Override the misdetected directory name (Gentoo bug 862534).
	local KV_FULL="${PFPV}"
	kernel-2_pkg_postinst

	elog ""
	elog "gentoo-sources-based pf-sources-extended: tracks linux-stable through"
	elog "6.4.16 (full coverage — 6.4 ended at .16) via alicef's genpatches"
	elog "trunk, plus a curated subset of natalenko's pf-kernel delta. 6.4 is"
	elog "an EOL non-LTS branch — no further linux-stable backports will arrive."
	elog ""
	elog "Curated pf features kept: BBRv3, zstd bump, DDCCI, AMD-pstate,"
	elog "syscall.tbl additions, and mm/include hooks. x86 ISA levels come from"
	elog "genpatches' 5010 patch (MK8SSE3/MZEN/MZEN2) rather than pf's variant —"
	elog "same user-visible feature."
	elog ""
	elog "pf changes overlapping gentoo-sources' newer form (scheduler tweaks,"
	elog "arch/x86, the pre-rename SMB stack) are dropped in favour of stable."
	elog ""
	elog "For pf-kernel's full patchset, install pf-sources-6.4_p6-r1 instead —"
	elog "it stays GA-frozen and still ships surgical CVE backports."
	elog ""

	optfeature "userspace KSM helper" sys-process/uksmd
}

pkg_postrm() {
	# Likewise for removal (Gentoo bug 862534).
	local KV_FULL="${PFPV}"
	kernel-2_pkg_postrm
}
