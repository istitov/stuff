# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Define what default functions to run.
ETYPE="sources"

# -flex patch set already sets EXTRAVERSION to kernel Makefile.
K_NOSETEXTRAVERSION="1"

# flex-sources is not officially supported/covered by the Gentoo security team.
K_SECURITY_UNSUPPORTED="1"

# Major kernel version, e.g. 7.1.
SHPV="${PV/_p*/}"

# Replace "_p" with "-flex", since using "-flex" is not allowed for an ebuild
# name by PMS.
PFPV="${PV/_p/-flex}"

inherit kernel-2 optfeature
detect_version

DESCRIPTION="Linux kernel fork that includes the pf-kernel flex spine (no genpatches)"
HOMEPAGE="https://pfkernel.natalenko.name/"
SRC_URI="https://codeberg.org/pf-kernel/linux/archive/v${PFPV}.tar.gz -> linux-${PFPV}.tar.gz"

S="${WORKDIR}/linux-${PFPV}"

KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"

K_EXTRAEINFO="For more info on flex-sources and details on how to report
	problems, see: ${HOMEPAGE}."

pkg_setup() {
	ewarn ""
	ewarn "${PN} is *not* supported by the Gentoo Kernel Project in any way."
	ewarn "If you need support, please contact the pf developers directly."
	ewarn "Do *not* open bugs in Gentoo's bugzilla unless you have issues with"
	ewarn "the ebuilds. Thank you."
	ewarn ""

	# flex spine ships against an upstream rc (currently 7.1-rc3) — Makefile
	# already advertises 7.1.0 SUBLEVEL via the -flex1 EXTRAVERSION, but the
	# base is pre-release Linux.  Surface this so users don't mistake it for
	# a stable kernel.
	ewarn "${PN} ships on a pre-release Linux base; the upstream 7.1 stable"
	ewarn "kernel has not yet been released as of this ebuild's bump."
	ewarn "Use sys-kernel/pf-sources for kernel branches that track"
	ewarn "released Linux versions."
	ewarn ""

	kernel-2_pkg_setup
}

src_unpack() {
	# Since the Codeberg-hosted flex-sources include full kernel sources, we
	# need to manually override the src_unpack phase because
	# kernel-2_src_unpack() does a lot of unwanted magic here.
	unpack ${A}

	mv linux linux-${PFPV} || die "Failed to move source directory"
}

src_prepare() {
	# No genpatches to apply (genpatches-7.1 doesn't exist yet, and the flex
	# spine intentionally diverges from the pf spine's keep-set anyway).
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
