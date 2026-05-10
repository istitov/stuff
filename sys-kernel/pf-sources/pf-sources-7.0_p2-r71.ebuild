# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# This revision is fundamentally different from pf-sources-7.0_p2.
# Instead of fetching pf-kernel/codeberg's GA-only sourcetree (Linux 7.0.0
# + pf patchset, no linux-stable updates), it builds on top of the same
# vanilla 7.0.tar.xz + Gentoo genpatches stack that gentoo-sources uses,
# then applies a *curated* subset of natalenko's pf-kernel delta on top.
# See pkg_postinst for what's preserved versus what's dropped and why.
# The slot's pretend version stays "7.0_p2" so this ebuild remains
# drop-in-replaceable for users on the existing pf-sources slot.

ETYPE="sources"

# Track the latest 7.0.X linux-stable via genpatches. genpatches-7.0-4
# tracks linux-stable through 7.0.3.
K_GENPATCHES_VER="4"

# Curated pf delta sets EXTRAVERSION via the patch itself.
K_NOSETEXTRAVERSION="1"

# pf-sources has historically carried K_SECURITY_UNSUPPORTED. Even with
# linux-stable now baked in (which closes the largest gap), we keep the
# flag because the curated pf delta is not covered by Gentoo's security
# team — bugs in the pf-specific portions (BBRv3, x86 ISA levels, AESNI
# crypto, v4l2loopback, DDCCI) need to be reported to natalenko or the
# overlay maintainers.
K_SECURITY_UNSUPPORTED="1"

K_WANT_GENPATCHES="base extras"

SHPV="${PV/_p*/}"
PFPV="${PV/_p/-pf}"

inherit kernel-2 optfeature

DESCRIPTION="Linux kernel: gentoo-sources base + curated pf-kernel patchset"
HOMEPAGE="https://pfkernel.natalenko.name/
	https://dev.gentoo.org/~alicef/genpatches/"

SRC_URI="https://www.kernel.org/pub/linux/kernel/v7.x/linux-${SHPV}.tar.xz
	https://dev.gentoo.org/~alicef/dist/genpatches/genpatches-${SHPV}-${K_GENPATCHES_VER}.base.tar.xz
	https://dev.gentoo.org/~alicef/dist/genpatches/genpatches-${SHPV}-${K_GENPATCHES_VER}.extras.tar.xz
	https://raw.githubusercontent.com/istitov/extra-stuff/pf-curated-${SHPV}-r70-0/sys-kernel/pf-sources/pf-curated-${SHPV}.tar.xz -> pf-curated-${SHPV}-r70-0.tar.xz"

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
	unpack ${A}
}

src_prepare() {
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
	local KV_FULL="${PFPV}"
	kernel-2_pkg_postinst

	elog ""
	elog "This revision (-r70) is the gentoo-sources-based pf-sources variant."
	elog "It tracks linux-stable (7.0.X) via Gentoo's genpatches AND keeps a"
	elog "curated subset of natalenko's pf-kernel delta on top. CVE backports"
	elog "now arrive automatically with each gentoo-sources stable bump."
	elog ""
	elog "Curated pf features RETAINED from natalenko's patchset:"
	elog "  * BBRv3 TCP congestion control (net/ipv4/tcp_bbr* and helpers)"
	elog "  * x86 ISA levels (pf-style: X86_64_ISA_LEVEL Kconfig + Makefile)"
	elog "  * AES-NI/AVX10/VAES crypto improvements (arch/x86/crypto/)"
	elog "  * v4l2loopback driver"
	elog "  * zstd compression library updates (lib/zstd/)"
	elog "  * DDCCI / DDCCI-backlight drivers (drivers/char/ddcci.c)"
	elog "  * AMD-pstate cpufreq enhancements"
	elog "  * syscall.tbl additions across arches"
	elog "  * Subset of mm/include hooks"
	elog ""
	elog "Patches DROPPED from natalenko's patchset, with reasons:"
	elog "  * kernel/sched/* and kernel/futex/* (if any in this slot):"
	elog "    gentoo-sources has newer scheduler/futex helpers."
	elog "  * Most 'minor fixes' pf carries are now in linux-stable's 7.0.X"
	elog "    backports already (often in newer/better form)."
	elog ""
	elog "If you specifically need pf-kernel's full patchset, install the"
	elog "GA-only variant pf-sources-7.0_p2-r1 instead — it stays frozen"
	elog "and ships natalenko's patchset verbatim, at the cost of missing"
	elog "linux-stable security fixes."
	elog ""

	optfeature "userspace KSM helper" sys-process/uksmd
}

pkg_postrm() {
	local KV_FULL="${PFPV}"
	kernel-2_pkg_postrm
}
