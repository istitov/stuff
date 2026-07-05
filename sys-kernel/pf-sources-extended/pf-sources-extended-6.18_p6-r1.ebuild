# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ETYPE="sources"

# Track the latest 6.18.X linux-stable via genpatches. Match
# gentoo-sources-6.18.33's K_GENPATCHES_VER. verified 2026-05-24.
K_GENPATCHES_VER="37"

# Curated pf delta sets EXTRAVERSION via the patch itself.
K_NOSETEXTRAVERSION="1"

# K_SECURITY_UNSUPPORTED is set because the curated pf delta is not
# covered by Gentoo's security
# team — bugs in the pf-specific portions (BBRv3, x86 ISA levels, AESNI
# crypto bump, v4l2loopback) need to be reported to natalenko or the
# overlay maintainers.
K_SECURITY_UNSUPPORTED="1"

K_WANT_GENPATCHES="base extras"

# Map "6.18_p6" → "6.18" for the kernel.org tarball + genpatches.
SHPV="${PV/_p*/}"

# Pretend version visible in /lib/modules and /usr/src.
PFPV="${PV/_p/-pf}"

inherit kernel-2 optfeature

DESCRIPTION="Linux kernel: gentoo-sources base + curated pf-kernel patchset"
HOMEPAGE="https://pfkernel.natalenko.name/
	https://dev.gentoo.org/~alicef/genpatches/"

# Vanilla 6.18 from kernel.org + Gentoo's genpatches (stable + non-stable)
# + our curated pf delta. The codeberg pf-kernel tarball is intentionally
# not fetched — its content is replaced by the much smaller curated bundle
# hosted in the stuff overlay's sister 'extra-stuff' repo.
SRC_URI="https://www.kernel.org/pub/linux/kernel/v6.x/linux-${SHPV}.tar.xz
	https://distfiles.gentoo.org/pub/proj/kernel/genpatches/genpatches-${SHPV}-${K_GENPATCHES_VER}.base.tar.xz
	https://dev.gentoo.org/~alicef/dist/genpatches/genpatches-${SHPV}-${K_GENPATCHES_VER}.base.tar.xz
	https://dev.gentoo.org/~mpagano/dist/genpatches/genpatches-${SHPV}-${K_GENPATCHES_VER}.base.tar.xz
	https://distfiles.gentoo.org/pub/proj/kernel/genpatches/genpatches-${SHPV}-${K_GENPATCHES_VER}.extras.tar.xz
	https://dev.gentoo.org/~alicef/dist/genpatches/genpatches-${SHPV}-${K_GENPATCHES_VER}.extras.tar.xz
	https://dev.gentoo.org/~mpagano/dist/genpatches/genpatches-${SHPV}-${K_GENPATCHES_VER}.extras.tar.xz
	https://raw.githubusercontent.com/istitov/extra-stuff/pf-curated-${SHPV}-r70-2/sys-kernel/pf-sources-extended/pf-curated-${SHPV}.tar.xz -> pf-curated-${SHPV}-r70-2.tar.xz
	https://codeberg.org/istitov/extra-stuff/raw/tag/pf-curated-${SHPV}-r70-2/sys-kernel/pf-sources-extended/pf-curated-${SHPV}.tar.xz -> pf-curated-${SHPV}-r70-2.tar.xz
	https://gitlab.com/istitov/extra-stuff/-/raw/pf-curated-${SHPV}-r70-2/sys-kernel/pf-sources-extended/pf-curated-${SHPV}.tar.xz -> pf-curated-${SHPV}-r70-2.tar.xz"

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
	# (1000_linux-${SHPV}.1.patch through 1NNN_linux-${SHPV}.X.patch)
	# is the entire point of this revision.
	eapply "${WORKDIR}"/*.patch

	# Curated pf-kernel delta on top of gentoo-sources state (r70-2).
	# Numbered series of per-feature patches re-cut against the 6.18.33
	# base; BBR3 (0002) re-cut 2026-05-24 because K=37's 1032 patch
	# changed tcp_bbr.c/tcp.h/tcp_output.c context. See pkg_postinst.
	eapply "${WORKDIR}/pf-curated-${SHPV}"/*.patch

	default
}

pkg_postinst() {
	# Fixes "wrongly" detected directory name, bgo#862534.
	local KV_FULL="${PFPV}"
	kernel-2_pkg_postinst

	elog ""
	elog "gentoo-sources-based pf-sources-extended: tracks linux-stable (6.18.X)"
	elog "via Gentoo's genpatches, plus a curated subset of natalenko's pf-kernel"
	elog "delta. CVE backports now arrive automatically with each gentoo-sources"
	elog "stable bump."
	elog ""
	elog "Curated pf features kept: BBRv3, x86 ISA levels (arch/x86/Kconfig.cpu +"
	elog "Makefile), AES-NI/AVX10/VAES crypto, v4l2loopback, and mm/include hooks."
	elog ""
	elog "pf changes overlapping gentoo-sources' newer form (the teo/menu cpuidle"
	elog "governors, scheduler/futex tweaks) are dropped in favour of stable."
	elog ""
	elog "Known limitations: 0002-bbr3 reverts ~7 of K=37's WRITE_ONCE conversions"
	elog "in net/ipv4/tcp_{output,timer}.c (x86-64 impact: KCSAN-only), and 0004"
	elog "re-introduces AS_NO_DATA_INTEGRITY (no consumers). No 6.18-compatible"
	elog "BBR3 source has been rebased on a newer base upstream; verified 2026-05-24."
	elog ""
	elog "For pf-kernel's full patchset, install pf-sources-6.18_p6-r1 instead —"
	elog "it stays GA-frozen and still ships surgical CVE backports."
	elog ""

	optfeature "userspace KSM helper" sys-process/uksmd
}

pkg_postrm() {
	# Same here, bgo#862534.
	local KV_FULL="${PFPV}"
	kernel-2_pkg_postrm
}
