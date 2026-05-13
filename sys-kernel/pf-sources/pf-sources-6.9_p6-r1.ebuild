# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
EAPI=8

# Define what default functions to run.
ETYPE="sources"
# -pf patch set already sets EXTRAVERSION to kernel Makefile.
K_NOSETEXTRAVERSION="1"
# pf-sources is not officially supported/covered by the Gentoo security team.
K_SECURITY_UNSUPPORTED="1"
# Major kernel version, e.g. 5.14.
SHPV="${PV/_p*/}"
# Replace "_p" with "-pf", since using "-pf" is not allowed for an ebuild name by PMS.
PFPV="${PV/_p/-pf}"
inherit kernel-2 optfeature
detect_version
DESCRIPTION="Linux kernel fork that includes the pf-kernel patchset and Gentoo's genpatches"
HOMEPAGE="https://pfkernel.natalenko.name/
	https://dev.gentoo.org/~alicef/genpatches/"

# Genpatches for this branch live only in alicef's trunk dir (no
# release tarball was ever cut). To pin immutable bytes we bundle
# the trunk patches into pf-genpatches-${SHPV}.tar.xz on extra-stuff
# and reuse the same tarball as the -r70 slot. GENPATCHES_PATCHES
# below selects the subset this -r1 ebuild needs (no stable
# backports — pf-kernel's codeberg base already includes them).
GENPATCHES_PATCHES=(
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
	# Codeberg-hosted pf-sources include full kernel sources; override
	# kernel-2_src_unpack() to avoid its tarball-naming magic.
	unpack linux-${PFPV}.tar.gz pf-genpatches-${SHPV}-r70-0.tar.xz
	mv linux linux-${PFPV} || die "Failed to move source directory"
	# Stage individual genpatches into WORKDIR for src_prepare to apply.
	local p
	for p in "${GENPATCHES_PATCHES[@]}"; do
		cp "${WORKDIR}/pf-genpatches-${SHPV}/${p}" "${WORKDIR}/" || die "Failed to stage ${p}"
	done
}
src_prepare() {
	# kernel-2_src_prepare doesn't apply PATCHES(). Chosen genpatches are also applied here.
	eapply "${WORKDIR}"/*.patch
	default
}
pkg_postinst() {
	# Fixes "wrongly" detected directory name, bgo#862534.
	local KV_FULL="${PFPV}"
	kernel-2_pkg_postinst
	optfeature "userspace KSM helper" sys-process/uksmd
}
pkg_postrm() {
	# Same here, bgo#862534.
	local KV_FULL="${PFPV}"
	kernel-2_pkg_postrm
}
