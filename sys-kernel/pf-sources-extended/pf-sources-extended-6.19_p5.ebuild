# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ETYPE="sources"

# Track the latest 6.19.X linux-stable via genpatches. K=11 carries
# 1001..1011 = stable 6.19.2 through 6.19.12. K=12 and K=13 were
# briefly published by alicef and then withdrawn — they only survive
# in our Manifest as orphan hashes; the original -r70 was authored
# against K=13 (stable 6.19.14). Pinning to K=11 is a real regression
# of two linux-stable point releases, but it's the only K still
# fetchable. Bump back up if alicef catches up. verified 2026-05-10.
K_GENPATCHES_VER="11"

# Curated pf delta sets EXTRAVERSION via the patch itself.
K_NOSETEXTRAVERSION="1"

# K_SECURITY_UNSUPPORTED is set because the curated pf delta is not
# covered by Gentoo's security
# team — bugs in the pf-specific portions (BBRv3, x86 ISA levels, TEO
# cpuidle governor, ovpn data-channel offload, zstd bump, v4l2loopback,
# DDCCI) need to be reported to natalenko or the overlay maintainers.
K_SECURITY_UNSUPPORTED="1"

K_WANT_GENPATCHES="base extras"

# Map "6.19_p5" → "6.19" for the kernel.org tarball + genpatches.
SHPV="${PV/_p*/}"

# Pretend version visible in /lib/modules and /usr/src.
PFPV="${PV/_p/-pf}"

inherit kernel-2 optfeature

DESCRIPTION="Linux kernel: gentoo-sources base + curated pf-kernel patchset"
HOMEPAGE="https://pfkernel.natalenko.name/
	https://dev.gentoo.org/~alicef/genpatches/"

# Vanilla 6.19 from kernel.org + Gentoo's genpatches (stable + non-stable)
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
	# (1000_linux-${SHPV}.1.patch through 1NNN_linux-${SHPV}.X.patch)
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
	elog "gentoo-sources-based pf-sources-extended: tracks linux-stable (6.19.X)"
	elog "via Gentoo's genpatches, plus a curated subset of natalenko's pf-kernel"
	elog "delta. CVE backports now arrive automatically with each gentoo-sources"
	elog "stable bump. 6.19 is the youngest active branch, so the curated subset"
	elog "is small (34 files / ~4k lines)."
	elog ""
	elog "Curated pf features kept: BBRv3, x86 ISA levels (arch/x86/Kconfig.cpu +"
	elog "Makefile), TEO cpuidle governor + haltpoll, zstd bump, v4l2loopback,"
	elog "ovpn (OpenVPN data-channel offload), and fs/smb/client tweaks."
	elog ""
	elog "pf changes overlapping gentoo-sources' newer form (scheduler/futex"
	elog "tweaks) are dropped in favour of stable."
	elog ""
	elog "For pf-kernel's full scheduler tuning or futex2 extensions, install"
	elog "pf-sources-6.19_p5-r1 instead — it stays GA-frozen and still ships"
	elog "surgical CVE backports."
	elog ""

	optfeature "userspace KSM helper" sys-process/uksmd
}

pkg_postrm() {
	# Same here, bgo#862534.
	local KV_FULL="${PFPV}"
	kernel-2_pkg_postrm
}
