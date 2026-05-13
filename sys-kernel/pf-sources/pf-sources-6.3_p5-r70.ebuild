# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# This revision is fundamentally different from pf-sources-6.3_p5-r1.
# Instead of fetching pf-kernel/codeberg's GA-only sourcetree (Linux 6.3.0
# + pf patchset, no linux-stable updates), it builds on top of the same
# vanilla 6.3.tar.xz + Gentoo genpatches stack that gentoo-sources used
# while 6.3 was still maintained, then applies a *curated* subset of
# natalenko's pf-kernel delta on top. See pkg_postinst for what's preserved
# versus what's dropped and why. The slot's pretend version stays
# "6.3_p5" so this ebuild remains drop-in-replaceable for users on the
# existing pf-sources slot.
#
# 6.3 is a non-LTS kernel that reached end-of-life upstream (linux-stable
# stopped at 6.3.13). genpatches' last bundle for this branch (-12) tracks
# stable through 6.3.9. ::gentoo no longer ships gentoo-sources-6.3.X,
# but alicef's release tarballs remain available on dev.gentoo.org, which
# is what this ebuild fetches.

ETYPE="sources"

# Last genpatches release for the 6.3 branch; tracks linux-stable through
# 6.3.9 (linux-stable itself ended at 6.3.13, so users on this slot are
# missing the final four stable releases — this is the upper bound of
# what's available without hand-cherry-picking from linux-stable).
K_GENPATCHES_VER="12"

# Curated pf delta sets EXTRAVERSION via the patch itself.
K_NOSETEXTRAVERSION="1"

# pf-sources has historically carried K_SECURITY_UNSUPPORTED. Even with
# linux-stable now baked in (which closes the largest gap), we keep the
# flag because the curated pf delta is not covered by Gentoo's security
# team — bugs in the pf-specific portions (BBRv3, x86 ISA levels, zstd
# bump, DDCCI driver, syscall.tbl additions) need to be reported to
# natalenko or the overlay maintainers. Note that 6.3 itself is EOL
# upstream, so no further linux-stable backports will arrive.
K_SECURITY_UNSUPPORTED="1"

K_WANT_GENPATCHES="base extras"

# Map "6.3_p5" → "6.3" for the kernel.org tarball + genpatches.
SHPV="${PV/_p*/}"

# Pretend version visible in /lib/modules and /usr/src.
PFPV="${PV/_p/-pf}"

inherit kernel-2 optfeature

DESCRIPTION="Linux kernel: gentoo-sources base + curated pf-kernel patchset"
HOMEPAGE="https://pfkernel.natalenko.name/
	https://dev.gentoo.org/~alicef/genpatches/"

# Vanilla 6.3 from kernel.org + Gentoo's genpatches (stable + non-stable)
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
	# (1000_linux-${SHPV}.1.patch through 1008_linux-${SHPV}.9.patch)
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
	elog "This revision (-r70) is the gentoo-sources-based pf-sources variant."
	elog "It tracks linux-stable up to 6.3.9 via Gentoo's genpatches AND keeps"
	elog "a curated subset of natalenko's pf-kernel delta on top. 6.3 is an EOL"
	elog "non-LTS branch — no further linux-stable backports will arrive."
	elog ""
	elog "Curated pf features RETAINED from natalenko's patchset:"
	elog "  * BBRv3 TCP congestion control (net/ipv4/tcp_bbr* and helpers)"
	elog "  * x86 ISA levels (arch/x86/Kconfig.cpu + arch/x86/Makefile)"
	elog "  * zstd compression library updates (lib/zstd/)"
	elog "  * DDCCI / DDCCI-backlight drivers (drivers/char/ddcci.c)"
	elog "  * AMD-pstate cpufreq enhancements (drivers/cpufreq/amd-pstate.c)"
	elog "  * syscall.tbl additions across arches (futex_waitv etc.)"
	elog "  * Subset of mm/include hooks (madvise, ksm, smpboot)"
	elog ""
	elog "Patches DROPPED from natalenko's patchset, with reasons:"
	elog "  * kernel/sched/{core,fair,rt}.c: gentoo-sources has newer"
	elog "    scheduler helpers (uclamp + thermal). Keeping pf's older form"
	elog "    would regress, not improve, scheduler behaviour."
	elog "  * fs/cifs/* and fs/ksmbd/*: stable backports already cover the"
	elog "    same fixes in newer form; pf's pre-rename patches conflict."
	elog "  * Most 'minor fixes' pf carries are now in linux-stable's 6.3.X"
	elog "    backports already (often in newer/better form)."
	elog ""
	elog "If you specifically need pf-kernel's full patchset, install"
	elog "pf-sources-6.3_p5-r1 instead — it stays GA-frozen and ships"
	elog "natalenko's patchset verbatim, at the cost of missing the four"
	elog "linux-stable releases (6.3.10-6.3.13) that genpatches did pick up."
	elog ""

	optfeature "userspace KSM helper" sys-process/uksmd
}

pkg_postrm() {
	# Same here, bgo#862534.
	local KV_FULL="${PFPV}"
	kernel-2_pkg_postrm
}
