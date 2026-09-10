# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ETYPE="sources"

# Match gentoo-sources-6.18.39. # verified 2026-07-24
K_GENPATCHES_VER="46"

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

# Build vanilla Linux with Gentoo genpatches and a smaller curated pf delta
# hosted in extra-stuff.
SRC_URI="https://www.kernel.org/pub/linux/kernel/v6.x/linux-${SHPV}.tar.xz
	https://distfiles.gentoo.org/pub/proj/kernel/genpatches/genpatches-${SHPV}-${K_GENPATCHES_VER}.base.tar.xz
	https://dev.gentoo.org/~alicef/dist/genpatches/genpatches-${SHPV}-${K_GENPATCHES_VER}.base.tar.xz
	https://dev.gentoo.org/~mpagano/dist/genpatches/genpatches-${SHPV}-${K_GENPATCHES_VER}.base.tar.xz
	https://distfiles.gentoo.org/pub/proj/kernel/genpatches/genpatches-${SHPV}-${K_GENPATCHES_VER}.extras.tar.xz
	https://dev.gentoo.org/~alicef/dist/genpatches/genpatches-${SHPV}-${K_GENPATCHES_VER}.extras.tar.xz
	https://dev.gentoo.org/~mpagano/dist/genpatches/genpatches-${SHPV}-${K_GENPATCHES_VER}.extras.tar.xz
	https://raw.githubusercontent.com/istitov/extra-stuff/pf-curated-${SHPV}-r70-2/sys-kernel/pf-sources-extended/pf-curated-${SHPV}.tar.xz -> pf-curated-${SHPV}-r70-2.tar.xz
	https://codeberg.org/istitov/extra-stuff/raw/tag/pf-curated-${SHPV}-r70-2/sys-kernel/pf-sources-extended/pf-curated-${SHPV}.tar.xz -> pf-curated-${SHPV}-r70-2.tar.xz
	https://gitlab.com/istitov/extra-stuff/-/raw/pf-curated-${SHPV}-r70-2/sys-kernel/pf-sources-extended/pf-curated-${SHPV}.tar.xz -> pf-curated-${SHPV}-r70-2.tar.xz"

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

	# Apply the r70-2 curated series. BBR3 was recut against 6.18.33 after K=37
	# changed its context; pkg_postinst records limitations. # verified 2026-05-24
	eapply "${WORKDIR}/pf-curated-${SHPV}"/*.patch

	default
}

pkg_postinst() {
	# Correct kernel-2's directory detection (bug #862534).
	local KV_FULL="${PFPV}"
	kernel-2_pkg_postinst

	elog ""
	elog "gentoo-sources-based pf-sources-extended: tracks linux-stable (6.18.X)"
	elog "via Gentoo's genpatches, plus a curated subset of natalenko's pf-kernel"
	elog "delta. CVE backports now arrive automatically with each gentoo-sources"
	elog "stable bump."
	elog ""
	elog "Curated pf features kept: BBRv3, x86 ISA levels (arch/x86/Kconfig.cpu +"
	elog "Makefile), AES-NI/AVX10/VAES crypto, v4l2loopback, and mm/include hooks."
	elog ""
	elog "pf changes overlapping gentoo-sources' newer form (the teo/menu cpuidle"
	elog "governors, scheduler/futex tweaks) are dropped in favour of stable."
	elog ""
	elog "Known limitations: 0002-bbr3 reverts ~7 of K=37's WRITE_ONCE conversions"
	elog "in net/ipv4/tcp_{output,timer}.c (x86-64 impact: KCSAN-only), and 0004"
	elog "re-introduces AS_NO_DATA_INTEGRITY (no consumers). No 6.18-compatible"
	elog "BBR3 source has been rebased on a newer base upstream; verified 2026-05-24."
	elog ""
	elog "For pf-kernel's full patchset, install pf-sources-6.18_p6-r1 instead —"
	elog "it stays GA-frozen and still ships surgical CVE backports."
	elog ""

	optfeature "userspace KSM helper" sys-process/uksmd
}

pkg_postrm() {
	# Correct kernel-2's directory detection (bug #862534).
	local KV_FULL="${PFPV}"
	kernel-2_pkg_postrm
}
