# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# This revision is fundamentally different from pf-sources-6.18_p6{,-r1}.
# Instead of fetching pf-kernel/codeberg's GA-only sourcetree (Linux 6.18.0
# + pf patchset, no linux-stable updates), it builds on top of the same
# vanilla 6.18.tar.xz + Gentoo genpatches stack that gentoo-sources-6.18.X
# uses, then applies a *curated* subset of natalenko's pf-kernel delta
# on top. See pkg_postinst for what's preserved versus what's dropped
# and why. The slot's pretend version stays "6.18_p6" so this ebuild
# remains drop-in-replaceable for users on the existing pf-sources slot.

ETYPE="sources"

# Track the latest 6.18.X linux-stable via genpatches. Match
# gentoo-sources-6.18.26's K_GENPATCHES_VER.
K_GENPATCHES_VER="26"

# Curated pf delta sets EXTRAVERSION via the patch itself.
K_NOSETEXTRAVERSION="1"

# pf-sources has historically carried K_SECURITY_UNSUPPORTED. Even with
# linux-stable now baked in (which closes the largest gap), we keep the
# flag because the curated pf delta is not covered by Gentoo's security
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
# not fetched — its content is replaced by the much smaller curated
# patch in files/.
SRC_URI="https://www.kernel.org/pub/linux/kernel/v6.x/linux-${SHPV}.tar.xz
	https://dev.gentoo.org/~alicef/dist/genpatches/genpatches-${SHPV}-${K_GENPATCHES_VER}.base.tar.xz
	https://dev.gentoo.org/~alicef/dist/genpatches/genpatches-${SHPV}-${K_GENPATCHES_VER}.extras.tar.xz
	https://raw.githubusercontent.com/istitov/extra-stuff/pf-curated-${SHPV}-r70-0/sys-kernel/pf-sources/pf-curated-${SHPV}.tar.xz -> pf-curated-${SHPV}-r70-0.tar.xz
	https://codeberg.org/istitov/extra-stuff/raw/tag/pf-curated-${SHPV}-r70-0/sys-kernel/pf-sources/pf-curated-${SHPV}.tar.xz -> pf-curated-${SHPV}-r70-0.tar.xz
	https://gitlab.com/istitov/extra-stuff/-/raw/pf-curated-${SHPV}-r70-0/sys-kernel/pf-sources/pf-curated-${SHPV}.tar.xz -> pf-curated-${SHPV}-r70-0.tar.xz"

S="${WORKDIR}/linux-${SHPV}"

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

	# Curated pf-kernel delta on top of gentoo-sources state, as a
	# numbered series of per-feature patches re-cut from natalenko's
	# pf-kernel branches (codeberg.org/pf-kernel/linux). Filename order
	# is apply order; each patch's header explains which natalenko
	# branch + tip SHA it was derived from. See pkg_postinst for the
	# kept/dropped breakdown.
	eapply "${WORKDIR}/pf-curated-${SHPV}"/*.patch

	default
}

pkg_postinst() {
	# Fixes "wrongly" detected directory name, bgo#862534.
	local KV_FULL="${PFPV}"
	kernel-2_pkg_postinst

	elog ""
	elog "This revision (-r70) is the gentoo-sources-based pf-sources variant."
	elog "It tracks linux-stable (6.18.X) via Gentoo's genpatches AND keeps a"
	elog "curated subset of natalenko's pf-kernel delta on top. CVE backports"
	elog "now arrive automatically with each gentoo-sources stable bump."
	elog ""
	elog "Curated pf features RETAINED from natalenko's patchset:"
	elog "  * BBRv3 TCP congestion control (net/ipv4/tcp_bbr* and helpers)"
	elog "  * x86 ISA levels (arch/x86/Kconfig.cpu + arch/x86/Makefile)"
	elog "  * AES-NI/AVX10/VAES crypto improvements (arch/x86/crypto/)"
	elog "  * v4l2loopback driver"
	elog "  * Subset of mm/include hooks (pagemap, mm_init, tcp.h)"
	elog ""
	elog "Patches DROPPED from natalenko's patchset, with reasons:"
	elog "  * drivers/cpuidle/governors/{teo,menu}.c: gentoo-sources has"
	elog "    newer governor logic. Keeping pf's older form would regress."
	elog "  * Most 'minor fixes' pf carries are now in linux-stable's 6.18.X"
	elog "    backports already (often in newer/better form)."
	elog "  * Scheduler/futex tweaks (if any in this slot): same reasoning."
	elog ""
	elog "If you specifically need pf-kernel's full patchset, install"
	elog "pf-sources-6.18_p6-r1 instead — it stays GA-frozen and ships"
	elog "natalenko's patchset verbatim, at the cost of missing linux-stable"
	elog "security fixes."
	elog ""

	optfeature "userspace KSM helper" sys-process/uksmd
}

pkg_postrm() {
	# Same here, bgo#862534.
	local KV_FULL="${PFPV}"
	kernel-2_pkg_postrm
}
