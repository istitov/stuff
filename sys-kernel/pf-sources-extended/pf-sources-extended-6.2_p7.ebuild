# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# 6.2 is a non-LTS kernel that reached end-of-life upstream (linux-stable
# stopped at 6.2.16). genpatches' last bundle for this branch (-14) tracks
# stable through 6.2.12. ::gentoo no longer ships gentoo-sources-6.2.X,
# but alicef's release tarballs remain available on dev.gentoo.org, which
# is what this ebuild fetches.

ETYPE="sources"

# Last genpatches release for the 6.2 branch; tracks linux-stable through
# 6.2.12 (linux-stable itself ended at 6.2.16, so users on this slot are
# missing the final four stable releases — this is the upper bound of
# what's available without hand-cherry-picking from linux-stable).
K_GENPATCHES_VER="14"

# Curated pf delta sets EXTRAVERSION via the patch itself.
K_NOSETEXTRAVERSION="1"

# K_SECURITY_UNSUPPORTED is set because the curated pf delta is not
# covered by Gentoo's security
# team — bugs in the pf-specific portions (BBRv3, x86 ISA levels, zstd
# bump, DDCCI driver, syscall.tbl additions) need to be reported to
# natalenko or the overlay maintainers. Note that 6.2 itself is EOL
# upstream, so no further linux-stable backports will arrive.
K_SECURITY_UNSUPPORTED="1"

K_WANT_GENPATCHES="base extras"

# Map "6.2_p7" → "6.2" for the kernel.org tarball + genpatches.
SHPV="${PV/_p*/}"

# Pretend version visible in /lib/modules and /usr/src.
PFPV="${PV/_p/-pf}"

inherit kernel-2 optfeature

DESCRIPTION="Linux kernel: gentoo-sources base + curated pf-kernel patchset"
HOMEPAGE="https://pfkernel.natalenko.name/
	https://dev.gentoo.org/~alicef/genpatches/"

# Vanilla 6.2 from kernel.org + Gentoo's genpatches (stable + non-stable)
# + our curated pf delta. The codeberg pf-kernel tarball is intentionally
# not fetched — its content is replaced by the much smaller curated
# patch in files/.
SRC_URI="https://www.kernel.org/pub/linux/kernel/v6.x/linux-${SHPV}.tar.xz
	https://dev.gentoo.org/~alicef/dist/genpatches/genpatches-${SHPV}-${K_GENPATCHES_VER}.base.tar.xz
	https://dev.gentoo.org/~alicef/dist/genpatches/genpatches-${SHPV}-${K_GENPATCHES_VER}.extras.tar.xz
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
	# Vanilla kernel.org tarball unpacks to linux-${SHPV} directly; no
	# rename needed.
	unpack ${A}
}

src_prepare() {
	# Apply genpatches stack. Unlike pf-sources -r1, we DO NOT delete
	# `1*linux*.patch` — the linux-stable backport chain
	# (1000_linux-${SHPV}.1.patch through 1011_linux-${SHPV}.12.patch)
	# is the entire point of this revision.
	eapply "${WORKDIR}"/*.patch

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
	elog "gentoo-sources-based pf-sources-extended: tracks linux-stable up to"
	elog "6.2.12 via Gentoo's genpatches, plus a curated subset of natalenko's"
	elog "pf-kernel delta. 6.2 is an EOL non-LTS branch — no further linux-stable"
	elog "backports will arrive."
	elog ""
	elog "Curated pf features kept: BBRv3, x86 ISA levels (arch/x86/Kconfig.cpu +"
	elog "Makefile), zstd bump, DDCCI, AMD-pstate, syscall.tbl additions, and"
	elog "mm/include hooks."
	elog ""
	elog "pf changes overlapping gentoo-sources' newer form (scheduler tweaks,"
	elog "the pre-rename SMB/cifs stack) are dropped in favour of stable."
	elog ""
	elog "For pf-kernel's full patchset, install pf-sources-6.2_p7-r1 instead —"
	elog "it stays GA-frozen and still ships surgical CVE backports."
	elog ""

	optfeature "userspace KSM helper" sys-process/uksmd
}

pkg_postrm() {
	# Same here, bgo#862534.
	local KV_FULL="${PFPV}"
	kernel-2_pkg_postrm
}
