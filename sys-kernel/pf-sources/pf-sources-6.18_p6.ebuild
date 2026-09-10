# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ETYPE="sources"

# pf already includes experimental genpatches.
K_EXP_GENPATCHES_NOUSE="1"

# pf already includes vanilla updates; non-1 bumps add only important fixes.
K_GENPATCHES_VER="10"

# -pf patch set already sets EXTRAVERSION to kernel Makefile.
K_NOSETEXTRAVERSION="1"

# pf-sources is not officially supported/covered by the Gentoo security team.
K_SECURITY_UNSUPPORTED="1"

# Use only base and extras; pf includes experimental.
K_WANT_GENPATCHES="base extras"

SHPV="${PV/_p*/}"

PFPV="${PV/_p/-pf}"

inherit kernel-2 optfeature
detect_version

DESCRIPTION="Linux kernel fork that includes the pf-kernel patchset and Gentoo's genpatches"
HOMEPAGE="https://pfkernel.natalenko.name/
	https://dev.gentoo.org/~alicef/genpatches/"
SRC_URI="https://codeberg.org/pf-kernel/linux/archive/v${PFPV}.tar.gz -> linux-${PFPV}.tar.gz
	https://dev.gentoo.org/~alicef/dist/genpatches/genpatches-${SHPV}-${K_GENPATCHES_VER}.base.tar.xz
	https://dev.gentoo.org/~alicef/dist/genpatches/genpatches-${SHPV}-${K_GENPATCHES_VER}.extras.tar.xz"

S="${WORKDIR}/linux-${PFPV}"

KEYWORDS=""

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
	unpack ${A}

	mv linux linux-${PFPV} || die "Failed to move source directory"
}

src_prepare() {
	# Drop vanilla updates already present in pf before applying remaining patches.
	if [[ ${K_GENPATCHES_VER} -ne 1 ]]; then
		find "${WORKDIR}"/ -type f -name '10*linux*patch' -delete ||
			die "Failed to delete vanilla linux patches in src_prepare."
	fi

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
