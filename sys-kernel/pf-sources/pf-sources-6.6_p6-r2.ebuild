# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
EAPI=8

ETYPE="sources"
# -pf already includes the experimental patches.
K_EXP_GENPATCHES_NOUSE="1"
# -pf includes vanilla updates; bump only for important fixes, then drop duplicates.
K_GENPATCHES_VER="35"
# -pf sets EXTRAVERSION itself.
K_NOSETEXTRAVERSION="1"
# pf-sources is not officially supported/covered by the Gentoo security team.
K_SECURITY_UNSUPPORTED="1"
K_WANT_GENPATCHES="base extras"
SHPV="${PV/_p*/}"
# PMS forbids -pf in ebuild versions.
PFPV="${PV/_p/-pf}"
inherit kernel-2 optfeature
detect_version
DESCRIPTION="Linux kernel fork that includes the pf-kernel patchset and Gentoo's genpatches"
HOMEPAGE="https://pfkernel.natalenko.name/
	https://dev.gentoo.org/~alicef/genpatches/"
SRC_URI="https://codeberg.org/pf-kernel/linux/archive/v${PFPV}.tar.gz -> linux-${PFPV}.tar.gz
	https://dev.gentoo.org/~alicef/genpatches/tarballs/genpatches-${SHPV}-${K_GENPATCHES_VER}.base.tar.xz
	https://dev.gentoo.org/~alicef/genpatches/tarballs/genpatches-${SHPV}-${K_GENPATCHES_VER}.extras.tar.xz
	https://raw.githubusercontent.com/istitov/extra-stuff/pf-cves-cumulative-${SHPV}-r2-0/sys-kernel/pf-sources/pf-cves-cumulative-${SHPV}.tar.xz -> pf-cves-cumulative-${SHPV}-r2-0.tar.xz
	https://codeberg.org/istitov/extra-stuff/raw/tag/pf-cves-cumulative-${SHPV}-r2-0/sys-kernel/pf-sources/pf-cves-cumulative-${SHPV}.tar.xz -> pf-cves-cumulative-${SHPV}-r2-0.tar.xz
	https://gitlab.com/istitov/extra-stuff/-/raw/pf-cves-cumulative-${SHPV}-r2-0/sys-kernel/pf-sources/pf-cves-cumulative-${SHPV}.tar.xz -> pf-cves-cumulative-${SHPV}-r2-0.tar.xz"
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
	# Avoid kernel-2 unpack handling for Codeberg's full source archive.
	unpack ${A}
	mv linux linux-${PFPV} || die "Failed to move source directory"
}
src_prepare() {
	# Drop vanilla updates already present in -pf.
	if [[ ${K_GENPATCHES_VER} -ne 1 ]]; then
		find "${WORKDIR}"/ -type f -name '1*linux*.patch' -delete ||
			die "Failed to delete vanilla linux patches in src_prepare."
	fi
	# kernel-2_src_prepare does not apply these genpatches.
	eapply "${WORKDIR}"/*.patch

	# CVE-2026-31431: algif_aead local privilege escalation. Its 6.6.137
	# stable backport does not apply to GA-based -pf; carry the affected crypto
	# files cumulatively through 6.6.137.
	eapply "${WORKDIR}/pf-cves-cumulative-6.6/cve-2026-31431-algif_aead-cumulative-6.6.patch"

	# CVE-2026-43037/43038: IPv6 cb[] confusion causing an OOB write/read.
	# The 6.6.134 fixes do not apply to GA-based -pf; carry the affected IPv6
	# files cumulatively through 6.6.137.
	eapply "${WORKDIR}/pf-cves-cumulative-6.6/cve-2026-43037-43038-cumulative-6.6.patch"

	default
}
pkg_postinst() {
	# Correct kernel-2's directory detection (bug #862534).
	local KV_FULL="${PFPV}"
	kernel-2_pkg_postinst
	optfeature "userspace KSM helper" sys-process/uksmd
}
pkg_postrm() {
	# Correct kernel-2's directory detection (bug #862534).
	local KV_FULL="${PFPV}"
	kernel-2_pkg_postrm
}
