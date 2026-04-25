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

# Genpatches sourced per-patch from alicef's live trunk dir; bundled
# tarballs for this branch were pruned from gentoo distfiles after
# gentoo-sources stopped carrying 6.13 (kernel.org-EOL). The trunk
# dir still holds the final-state patch files.
GENPATCHES_TRUNK="https://dev.gentoo.org/~alicef/genpatches/trunk/${SHPV}"
GENPATCHES_PATCHES=(
	1510_fs-enable-link-security-restrictions-by-default.patch
	1700_sparc-address-warray-bound-warnings.patch
	1730_parisc-Disable-prctl.patch
	2000_BT-Check-key-sizes-only-if-Secure-Simple-Pairing-enabled.patch
	2901_permit-menuconfig-sorting.patch
	2910_bfp-mark-get-entry-ip-as--maybe-unused.patch
	2920_sign-file-patch-for-libressl.patch
	2980_kbuild-gcc15-gnu23-to-gnu11-fix.patch
	2990_libbpf-v2-workaround-Wmaybe-uninitialized-false-pos.patch
	3000_Support-printing-firmware-info.patch
	4567_distro-Gentoo-Kconfig.patch
)

SRC_URI="https://codeberg.org/pf-kernel/linux/archive/v${PFPV}.tar.gz -> linux-${PFPV}.tar.gz"
for _patch in "${GENPATCHES_PATCHES[@]}"; do
	SRC_URI+=" ${GENPATCHES_TRUNK}/${_patch}"
done
unset _patch

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
	unpack linux-${PFPV}.tar.gz
	mv linux linux-${PFPV} || die "Failed to move source directory"
	# Stage individual genpatches into WORKDIR for src_prepare to apply.
	local p
	for p in "${GENPATCHES_PATCHES[@]}"; do
		cp "${DISTDIR}/${p}" "${WORKDIR}/" || die "Failed to stage ${p}"
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
