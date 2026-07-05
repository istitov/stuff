# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# 6.5 is a non-LTS kernel that reached end-of-life upstream (linux-stable
# stopped at 6.5.13). The trunk-pinned patches captured here track stable
# all the way to 6.5.13 — full coverage for this EOL branch.
#
# Per-branch judgment on 5xxx (genpatches "experimental" category):
#   * 5010_enable-cpu-optimizations-universal: included (small, x86 ISA
#     Kconfig — the partition drops pf's both-touched arch/x86 changes
#     anyway, so genpatches' Kconfig wins either way; user gets ISA-level
#     options under MK8SSE3/MZEN/MZEN2 names).
#   * 5020_BMQ-and-PDS-io-scheduler: NOT included. Adding BMQ would mean
#     11k lines + 40 files of opt-in alternative scheduler on a slot
#     whose curated subset already drops pf's scheduler tweaks — out of
#     scope for the "minimal pf identity on gentoo-sources" model.

ETYPE="sources"

# Curated pf delta sets EXTRAVERSION via the patch itself.
K_NOSETEXTRAVERSION="1"

# K_SECURITY_UNSUPPORTED is set because the curated pf delta is not
# covered by Gentoo's security
# team — bugs in the pf-specific portions (BBRv3, zstd bump, DDCCI,
# AMD-pstate, syscall.tbl additions) need to be reported to natalenko or
# the overlay maintainers. Note that 6.5 itself is EOL upstream, so no
# further linux-stable backports will arrive.
K_SECURITY_UNSUPPORTED="1"

# Map "6.5_p6" → "6.5" for the kernel.org tarball + genpatches.
SHPV="${PV/_p*/}"

# Pretend version visible in /lib/modules and /usr/src.
PFPV="${PV/_p/-pf}"

inherit kernel-2 optfeature

DESCRIPTION="Linux kernel: gentoo-sources base + curated pf-kernel patchset"
HOMEPAGE="https://pfkernel.natalenko.name/
	https://dev.gentoo.org/~alicef/genpatches/"

# No genpatches release tarball exists for the 6.5 branch (dev.gentoo.org
# has 6.3 then 6.6), so this uses a per-slot snapshot of alicef's genpatches
# trunk (a live working dir), bundled as pf-genpatches-${SHPV}.tar.xz on the
# sister overlay extra-stuff (https://github.com/istitov/extra-stuff), pinned
# by immutable tag -r70-1 (refresh = new tag suffix). The bundle is the
# durable reference.
SRC_URI="https://www.kernel.org/pub/linux/kernel/v6.x/linux-${SHPV}.tar.xz
	https://raw.githubusercontent.com/istitov/extra-stuff/pf-genpatches-${SHPV}-r70-1/sys-kernel/pf-sources-extended/pf-genpatches-${SHPV}.tar.xz -> pf-genpatches-${SHPV}-r70-1.tar.xz
	https://codeberg.org/istitov/extra-stuff/raw/tag/pf-genpatches-${SHPV}-r70-1/sys-kernel/pf-sources-extended/pf-genpatches-${SHPV}.tar.xz -> pf-genpatches-${SHPV}-r70-1.tar.xz
	https://gitlab.com/istitov/extra-stuff/-/raw/pf-genpatches-${SHPV}-r70-1/sys-kernel/pf-sources-extended/pf-genpatches-${SHPV}.tar.xz -> pf-genpatches-${SHPV}-r70-1.tar.xz
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
	# Apply the genpatches stack (stable backports + non-stable additions).
	eapply "${WORKDIR}/pf-genpatches-${SHPV}"/*.patch

	# Curated pf-kernel delta on top of gentoo-sources state.
	# See pkg_postinst for the kept/dropped breakdown.
	eapply "${WORKDIR}/pf-curated-${SHPV}"/*.patch

	default
}

pkg_postinst() {
	# Fixes "wrongly" detected directory name, bgo#862534.
	local KV_FULL="${PFPV}"
	kernel-2_pkg_postinst

	elog ""
	elog "gentoo-sources-based pf-sources-extended: tracks linux-stable through"
	elog "6.5.13 (full coverage — 6.5 ended at .13) via alicef's genpatches"
	elog "trunk, plus a curated subset of natalenko's pf-kernel delta. 6.5 is"
	elog "an EOL non-LTS branch — no further linux-stable backports will arrive."
	elog ""
	elog "Curated pf features kept: BBRv3, zstd bump, DDCCI, AMD-pstate,"
	elog "syscall.tbl additions, and mm/include hooks. x86 ISA levels come from"
	elog "genpatches' 5010 patch (MK8SSE3/MZEN/MZEN2) rather than pf's variant."
	elog ""
	elog "pf changes overlapping gentoo-sources' newer form (scheduler tweaks,"
	elog "arch/x86, the pre-rename SMB stack) and the opt-in BMQ/PDS scheduler"
	elog "are dropped in favour of stable; see the ebuild header for details."
	elog ""
	elog "For pf-kernel's full patchset, install pf-sources-6.5_p6-r1 instead —"
	elog "it stays GA-frozen and still ships surgical CVE backports."
	elog ""

	optfeature "userspace KSM helper" sys-process/uksmd
}

pkg_postrm() {
	# Same here, bgo#862534.
	local KV_FULL="${PFPV}"
	kernel-2_pkg_postrm
}
