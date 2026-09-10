# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ETYPE="sources"

# Match gentoo-sources-6.1.177. # verified 2026-07-24
K_GENPATCHES_VER="193"

# The curated delta sets EXTRAVERSION.
K_NOSETEXTRAVERSION="1"

# Gentoo security does not cover the curated pf delta; report its bugs upstream
# or to overlay maintainers.
K_SECURITY_UNSUPPORTED="1"

K_WANT_GENPATCHES="base extras"

SHPV="${PV/_p*/}"

# Preserve -pf identity in module and source directory names.
PFPV="${PV/_p/-pf}"

inherit kernel-2 optfeature

DESCRIPTION="Linux kernel: gentoo-sources base + curated pf-kernel patchset"
HOMEPAGE="https://pfkernel.natalenko.name/
	https://dev.gentoo.org/~alicef/genpatches/"

# Build vanilla Linux with Gentoo genpatches and a smaller curated pf delta.
# extra-stuff hosts the immutable patch snapshot; refreshes require a new tag.
SRC_URI="https://www.kernel.org/pub/linux/kernel/v6.x/linux-${SHPV}.tar.xz
	https://distfiles.gentoo.org/pub/proj/kernel/genpatches/genpatches-${SHPV}-${K_GENPATCHES_VER}.base.tar.xz
	https://dev.gentoo.org/~alicef/dist/genpatches/genpatches-${SHPV}-${K_GENPATCHES_VER}.base.tar.xz
	https://dev.gentoo.org/~mpagano/dist/genpatches/genpatches-${SHPV}-${K_GENPATCHES_VER}.base.tar.xz
	https://distfiles.gentoo.org/pub/proj/kernel/genpatches/genpatches-${SHPV}-${K_GENPATCHES_VER}.extras.tar.xz
	https://dev.gentoo.org/~alicef/dist/genpatches/genpatches-${SHPV}-${K_GENPATCHES_VER}.extras.tar.xz
	https://dev.gentoo.org/~mpagano/dist/genpatches/genpatches-${SHPV}-${K_GENPATCHES_VER}.extras.tar.xz
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
	# Keep the 1* linux-stable chain that pf-sources drops.
	eapply "${WORKDIR}"/*.patch

	# Apply the numbered curated pf series in filename order; patch headers record
	# provenance and pkg_postinst summarizes its scope.
	eapply "${WORKDIR}/pf-curated-${SHPV}"/*.patch

	default
}

pkg_postinst() {
	# Correct kernel-2's directory detection (bug #862534).
	local KV_FULL="${PFPV}"
	kernel-2_pkg_postinst

	elog ""
	elog "gentoo-sources-based pf-sources-extended: tracks linux-stable (6.1.X)"
	elog "via Gentoo's genpatches, plus a curated subset of natalenko's pf-kernel"
	elog "delta. CVE backports now arrive automatically with each gentoo-sources"
	elog "stable bump."
	elog ""
	elog "Curated pf features kept: BBRv3, x86 ISA levels (MK8SSE3/MK10/MZEN/"
	elog "MNATIVE etc.), zstd bump, v4l2loopback, DDCCI, syscall.tbl additions,"
	elog "and vmlinux.lds.S section additions."
	elog ""
	elog "pf changes overlapping gentoo-sources' newer form (scheduler/futex"
	elog "tweaks, the pre-rewrite SMB/cifs stack) are dropped in favour of stable."
	elog ""
	elog "For pf-kernel's full patchset (scheduler heuristics, futex2, pre-rewrite"
	elog "SMB), install pf-sources-6.1_p6-r2 instead — it stays GA-frozen and"
	elog "still ships surgical CVE backports."
	elog ""

	optfeature "userspace KSM helper" sys-process/uksmd
}

pkg_postrm() {
	# Correct kernel-2's directory detection (bug #862534).
	local KV_FULL="${PFPV}"
	kernel-2_pkg_postrm
}
