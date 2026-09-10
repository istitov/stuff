# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ETYPE="sources"

# -pf already includes the experimental patches.
K_EXP_GENPATCHES_NOUSE="1"

# -pf includes vanilla updates; bump only for important fixes, then drop duplicates.
K_GENPATCHES_VER="10"

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
	https://dev.gentoo.org/~alicef/dist/genpatches/genpatches-${SHPV}-${K_GENPATCHES_VER}.base.tar.xz
	https://dev.gentoo.org/~alicef/dist/genpatches/genpatches-${SHPV}-${K_GENPATCHES_VER}.extras.tar.xz
	https://raw.githubusercontent.com/istitov/extra-stuff/pf-cves-surgical-r1-0/sys-kernel/pf-sources/pf-cves-surgical.tar.xz -> pf-cves-surgical-r1-0.tar.xz
	https://codeberg.org/istitov/extra-stuff/raw/tag/pf-cves-surgical-r1-0/sys-kernel/pf-sources/pf-cves-surgical.tar.xz -> pf-cves-surgical-r1-0.tar.xz
	https://gitlab.com/istitov/extra-stuff/-/raw/pf-cves-surgical-r1-0/sys-kernel/pf-sources/pf-cves-surgical.tar.xz -> pf-cves-surgical-r1-0.tar.xz"

S="${WORKDIR}/linux-${PFPV}"

KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"

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
		find "${WORKDIR}"/ -type f -name '10*linux*patch' -delete ||
			die "Failed to delete vanilla linux patches in src_prepare."
	fi

	# kernel-2_src_prepare does not apply these genpatches.
	eapply "${WORKDIR}"/*.patch
	eapply "${FILESDIR}/pf-sources-6.19_p4-ima_validate_range.patch"

	# CVE-2026-31431: algif_aead local privilege escalation. GA-based -pf never
	# receives the 6.19.12 stable fix, so carry upstream revert a664bf3d603d.
	eapply "${WORKDIR}/pf-cves-surgical/cve-2026-31431-algif_aead-revert-out-of-place.patch"

	# CVE-2026-43037: IPv6 tunnel cb[] confusion causing stack overflow. Carry
	# upstream fix 2edfa31769a4 across the same GA-only stable gap.
	eapply "${WORKDIR}/pf-cves-surgical/cve-2026-43037-ip6_tunnel-clear-skb-cb.patch"

	# CVE-2026-43038: related IPv6 ICMP cb[] confusion causing an OOB read.
	# Carry upstream fix 86ab3e55673a across the same gap.
	eapply "${WORKDIR}/pf-cves-surgical/cve-2026-43038-icmpv6-clear-skb-cb.patch"

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
