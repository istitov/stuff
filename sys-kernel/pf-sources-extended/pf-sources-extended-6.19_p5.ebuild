# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ETYPE="sources"

# K=11 reaches 6.19.12. K=12/13 (through .14) were withdrawn, so this is the
# newest fetchable bundle; bump when replacements appear. # verified 2026-05-10
K_GENPATCHES_VER="11"

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
SRC_URI="https://www.kernel.org/pub/linux/kernel/v6.x/linux-${SHPV}.tar.xz
	https://dev.gentoo.org/~alicef/dist/genpatches/genpatches-${SHPV}-${K_GENPATCHES_VER}.base.tar.xz
	https://dev.gentoo.org/~alicef/dist/genpatches/genpatches-${SHPV}-${K_GENPATCHES_VER}.extras.tar.xz
	https://raw.githubusercontent.com/istitov/extra-stuff/pf-curated-${SHPV}-r70-1/sys-kernel/pf-sources-extended/pf-curated-${SHPV}.tar.xz -> pf-curated-${SHPV}-r70-1.tar.xz
	https://codeberg.org/istitov/extra-stuff/raw/tag/pf-curated-${SHPV}-r70-1/sys-kernel/pf-sources-extended/pf-curated-${SHPV}.tar.xz -> pf-curated-${SHPV}-r70-1.tar.xz
	https://gitlab.com/istitov/extra-stuff/-/raw/pf-curated-${SHPV}-r70-1/sys-kernel/pf-sources-extended/pf-curated-${SHPV}.tar.xz -> pf-curated-${SHPV}-r70-1.tar.xz"

S="${WORKDIR}/linux-${SHPV}"

KEYWORDS="~arm64"

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

	# BBR3 requires TCP APIs absent from the fetchable 6.19.12 base.
	eapply "${WORKDIR}/pf-curated-${SHPV}"/0001-fixes-stable-backports.patch
	eapply "${FILESDIR}/${PN}-6.19-revert-partial-slab-update.patch"
	eapply "${WORKDIR}/pf-curated-${SHPV}"/0003-cpuidle.patch
	eapply "${WORKDIR}/pf-curated-${SHPV}"/0004-kbuild-tweaks.patch

	default
}

pkg_postinst() {
	# Correct kernel-2's directory detection (bug #862534).
	local KV_FULL="${PFPV}"
	kernel-2_pkg_postinst

	elog ""
	elog "gentoo-sources-based pf-sources-extended: tracks linux-stable (6.19.X)"
	elog "via Gentoo's genpatches, plus a curated subset of natalenko's pf-kernel"
	elog "delta. CVE backports now arrive automatically with each gentoo-sources"
	elog "stable bump. 6.19 is the youngest active branch, so the curated subset"
	elog "is small."
	elog ""
	elog "Curated pf features kept: x86 ISA levels (arch/x86/Kconfig.cpu +"
	elog "Makefile), TEO cpuidle governor + haltpoll, ovpn data-channel offload,"
	elog "and dma-buf/IOMMU, vmstat, and fs/smb/client tweaks."
	elog ""
	elog "BBRv3 is omitted on this slot: the curated patch assumes TCP core API"
	elog "from a newer base than the fetchable 6.19.12 genpatches stack."
	elog ""
	elog "pf changes overlapping gentoo-sources' newer form (scheduler/futex"
	elog "tweaks) are dropped in favour of stable."
	elog ""
	elog "For pf-kernel's full scheduler tuning or futex2 extensions, install"
	elog "pf-sources-6.19_p5-r1 instead — it stays GA-frozen and still ships"
	elog "surgical CVE backports."
	elog ""

	optfeature "userspace KSM helper" sys-process/uksmd
}

pkg_postrm() {
	# Correct kernel-2's directory detection (bug #862534).
	local KV_FULL="${PFPV}"
	kernel-2_pkg_postrm
}
