# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ETYPE="sources"

# Track the latest 6.1.X linux-stable via genpatches. Match
# gentoo-sources-6.1.174's K_GENPATCHES_VER. verified 2026-05-24.
K_GENPATCHES_VER="189"

# Curated pf delta sets EXTRAVERSION via the patch itself.
K_NOSETEXTRAVERSION="1"

# K_SECURITY_UNSUPPORTED is set because the curated pf delta is not
# covered by Gentoo's security
# team — bugs in the pf-specific portions (BBRv3, x86 ISA levels,
# zstd bump, v4l2loopback, DDCCI) need to be reported to natalenko or
# the overlay maintainers.
K_SECURITY_UNSUPPORTED="1"

K_WANT_GENPATCHES="base extras"

# Map "6.1_p6" → "6.1" for the kernel.org tarball + genpatches.
SHPV="${PV/_p*/}"

# Pretend version visible in /lib/modules and /usr/src.
PFPV="${PV/_p/-pf}"

inherit kernel-2 optfeature

DESCRIPTION="Linux kernel: gentoo-sources base + curated pf-kernel patchset"
HOMEPAGE="https://pfkernel.natalenko.name/
	https://dev.gentoo.org/~alicef/genpatches/"

# Vanilla 6.1 from kernel.org + Gentoo's genpatches (stable + non-stable)
# + our curated pf delta. The codeberg pf-kernel tarball is intentionally
# not fetched — its content is replaced by the much smaller curated
# patch series, hosted in the stuff overlay's sister "extra-stuff" repo
# (https://github.com/istitov/extra-stuff) to keep this overlay's files/
# tree small. The tag in the URL pins an immutable snapshot; bumping
# patches means a new tag suffix (-r70-1, -r70-2, ...).
SRC_URI="https://www.kernel.org/pub/linux/kernel/v6.x/linux-${SHPV}.tar.xz
	https://distfiles.gentoo.org/pub/proj/kernel/genpatches/genpatches-${SHPV}-${K_GENPATCHES_VER}.base.tar.xz
	https://dev.gentoo.org/~alicef/dist/genpatches/genpatches-${SHPV}-${K_GENPATCHES_VER}.base.tar.xz
	https://dev.gentoo.org/~mpagano/dist/genpatches/genpatches-${SHPV}-${K_GENPATCHES_VER}.base.tar.xz
	https://distfiles.gentoo.org/pub/proj/kernel/genpatches/genpatches-${SHPV}-${K_GENPATCHES_VER}.extras.tar.xz
	https://dev.gentoo.org/~alicef/dist/genpatches/genpatches-${SHPV}-${K_GENPATCHES_VER}.extras.tar.xz
	https://dev.gentoo.org/~mpagano/dist/genpatches/genpatches-${SHPV}-${K_GENPATCHES_VER}.extras.tar.xz
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
	# Apply genpatches stack. Unlike pf-sources -r1/-r2, we DO NOT
	# delete `1*linux*.patch` — the linux-stable backport chain
	# (1000_linux-${SHPV}.1.patch through 1NNN_linux-${SHPV}.X.patch)
	# is the entire point of this revision.
	eapply "${WORKDIR}"/*.patch

	# Curated pf-kernel delta on top of gentoo-sources state, as a
	# numbered series of per-feature patches re-cut from natalenko's
	# pf-kernel branches (codeberg.org/pf-kernel/linux). Filename order
	# is apply order; each patch's header explains which natalenko
	# branch + tip SHA it was derived from. The series ships in a
	# tarball from extra-stuff (see SRC_URI); unpack drops it at
	# ${WORKDIR}/pf-curated-${SHPV}/. See pkg_postinst for the
	# kept/dropped breakdown.
	eapply "${WORKDIR}/pf-curated-${SHPV}"/*.patch

	default
}

pkg_postinst() {
	# Fixes "wrongly" detected directory name, bgo#862534.
	local KV_FULL="${PFPV}"
	kernel-2_pkg_postinst

	elog ""
	elog "gentoo-sources-based pf-sources-extended: tracks linux-stable (6.1.X)"
	elog "via Gentoo's genpatches, plus a curated subset of natalenko's pf-kernel"
	elog "delta. CVE backports now arrive automatically with each gentoo-sources"
	elog "stable bump."
	elog ""
	elog "Curated pf features kept: BBRv3, x86 ISA levels (MK8SSE3/MK10/MZEN/"
	elog "MNATIVE etc.), zstd bump, v4l2loopback, DDCCI, syscall.tbl additions,"
	elog "and vmlinux.lds.S section additions."
	elog ""
	elog "pf changes overlapping gentoo-sources' newer form (scheduler/futex"
	elog "tweaks, the pre-rewrite SMB/cifs stack) are dropped in favour of stable."
	elog ""
	elog "For pf-kernel's full patchset (scheduler heuristics, futex2, pre-rewrite"
	elog "SMB), install pf-sources-6.1_p6-r2 instead — it stays GA-frozen and"
	elog "still ships surgical CVE backports."
	elog ""

	optfeature "userspace KSM helper" sys-process/uksmd
}

pkg_postrm() {
	# Same here, bgo#862534.
	local KV_FULL="${PFPV}"
	kernel-2_pkg_postrm
}
