# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
EAPI=8

ETYPE="sources"
# -pf patch set already sets EXTRAVERSION to kernel Makefile.
K_NOSETEXTRAVERSION="1"
# pf-sources is not officially supported/covered by the Gentoo security team.
K_SECURITY_UNSUPPORTED="1"
SHPV="${PV/_p*/}"
PFPV="${PV/_p/-pf}"
inherit kernel-2 optfeature
detect_version
DESCRIPTION="Linux kernel fork that includes the pf-kernel patchset and Gentoo's genpatches"
HOMEPAGE="https://pfkernel.natalenko.name/
	https://dev.gentoo.org/~alicef/genpatches/"

# No release tarball exists. Share the immutable extra-stuff trunk snapshot
# with -r70, selecting only additions absent from pf's stable-inclusive base.
GENPATCHES_PATCHES=(
	1510_fs-enable-link-security-restrictions-by-default.patch
	1700_sparc-address-warray-bound-warnings.patch
	1730_parisc-Disable-prctl.patch
	2000_BT-Check-key-sizes-only-if-Secure-Simple-Pairing-enabled.patch
	2800_amdgpu-Adj-kmalloc-array-calls-for-new-Walloc-size.patch
	2900_tmp513-Fix-build-issue-by-selecting-CONFIG_REG.patch
	2910_bfp-mark-get-entry-ip-as--maybe-unused.patch
	2920_sign-file-patch-for-libressl.patch
	2930_gcc14-btrfs-fix-kvcalloc-args-order.patch
	2931_gcc14-drm-i915-Adapt-to-Walloc-size.patch
	2932_gcc14-objtool-Fix-calloc-call-for-new-Walloc-size.patch
	3000_Support-printing-firmware-info.patch
	4567_distro-Gentoo-Kconfig.patch
)

SRC_URI="https://codeberg.org/pf-kernel/linux/archive/v${PFPV}.tar.gz -> linux-${PFPV}.tar.gz
	https://raw.githubusercontent.com/istitov/extra-stuff/pf-genpatches-${SHPV}-r70-0/sys-kernel/pf-sources/pf-genpatches-${SHPV}.tar.xz -> pf-genpatches-${SHPV}-r70-0.tar.xz
	https://codeberg.org/istitov/extra-stuff/raw/tag/pf-genpatches-${SHPV}-r70-0/sys-kernel/pf-sources/pf-genpatches-${SHPV}.tar.xz -> pf-genpatches-${SHPV}-r70-0.tar.xz
	https://gitlab.com/istitov/extra-stuff/-/raw/pf-genpatches-${SHPV}-r70-0/sys-kernel/pf-sources/pf-genpatches-${SHPV}.tar.xz -> pf-genpatches-${SHPV}-r70-0.tar.xz"

S="${WORKDIR}/linux-${PFPV}"
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
	# The Codeberg archive contains full sources; bypass kernel-2 unpack logic.
	unpack linux-${PFPV}.tar.gz pf-genpatches-${SHPV}-r70-0.tar.xz
	mv linux linux-${PFPV} || die "Failed to move source directory"
	local p
	for p in "${GENPATCHES_PATCHES[@]}"; do
		cp "${WORKDIR}/pf-genpatches-${SHPV}/${p}" "${WORKDIR}/" || die "Failed to stage ${p}"
	done
}
src_prepare() {
	# kernel-2_src_prepare does not apply PATCHES.
	eapply "${WORKDIR}"/*.patch
	default
}
pkg_postinst() {
	# Override the misdetected directory name (Gentoo bug 862534).
	local KV_FULL="${PFPV}"
	kernel-2_pkg_postinst
	optfeature "userspace KSM helper" sys-process/uksmd
}
pkg_postrm() {
	# Likewise for removal (Gentoo bug 862534).
	local KV_FULL="${PFPV}"
	kernel-2_pkg_postrm
}
