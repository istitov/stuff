# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# This revision is fundamentally different from pf-sources-6.12_p4{,-r1,-r2}.
# Instead of fetching pf-kernel/codeberg's GA-only sourcetree (Linux 6.12.0
# + pf patchset, no linux-stable updates), it builds on top of the same
# vanilla 6.12.tar.xz + Gentoo genpatches stack that gentoo-sources-6.12.X
# uses, then applies a *curated* subset of natalenko's pf-kernel delta
# on top. See pkg_postinst for what's preserved versus what's dropped
# and why. The slot's pretend version stays "6.12_p4" so this ebuild
# remains drop-in-replaceable for users on the existing pf-sources slot.

ETYPE="sources"

# Track the latest 6.12.X linux-stable via genpatches. Match
# gentoo-sources-6.12.85's K_GENPATCHES_VER.
K_GENPATCHES_VER="90"

# Curated pf delta sets EXTRAVERSION via the patch itself.
K_NOSETEXTRAVERSION="1"

# pf-sources has historically carried K_SECURITY_UNSUPPORTED. Even with
# linux-stable now baked in (which closes the largest gap), we keep the
# flag because the curated pf delta is not covered by Gentoo's security
# team — bugs in the pf-specific portions (BBRv3, x86 ISA generic-v2/v3/v4
# levels, zstd bump, v4l2loopback, DDCCI) need to be reported to natalenko
# or the overlay maintainers.
K_SECURITY_UNSUPPORTED="1"

K_WANT_GENPATCHES="base extras"

# Map "6.12_p4" → "6.12" for the kernel.org tarball + genpatches.
SHPV="${PV/_p*/}"

# Pretend version visible in /lib/modules and /usr/src.
PFPV="${PV/_p/-pf}"

inherit kernel-2 optfeature

DESCRIPTION="Linux kernel: gentoo-sources base + curated pf-kernel patchset"
HOMEPAGE="https://pfkernel.natalenko.name/
	https://dev.gentoo.org/~alicef/genpatches/"

# Vanilla 6.12 from kernel.org + Gentoo's genpatches (stable + non-stable)
# + our curated pf delta. The codeberg pf-kernel tarball is intentionally
# not fetched — its content is replaced by the much smaller curated
# patch in files/.
SRC_URI="https://www.kernel.org/pub/linux/kernel/v6.x/linux-${SHPV}.tar.xz
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
	elog "It tracks linux-stable (6.12.X) via Gentoo's genpatches AND keeps a"
	elog "curated subset of natalenko's pf-kernel delta on top. CVE backports"
	elog "now arrive automatically with each gentoo-sources stable bump; the"
	elog "earlier per-CVE patches in files/ no longer apply against this base."
	elog ""
	elog "Curated pf features RETAINED from natalenko's patchset:"
	elog "  * BBRv3 TCP congestion control + Kconfig"
	elog "  * x86 ISA levels (X86_64_ISA_LEVEL=1..4 → -march=x86-64-vN) for"
	elog "    arch-specific tuning"
	elog "  * zstd compression library bump"
	elog "  * v4l2loopback driver"
	elog "  * DDCCI / DDCCI-backlight drivers"
	elog "  * syscall.tbl additions across architectures"
	elog "  * vmlinux.lds.S section additions"
	elog ""
	elog "Patches DROPPED from natalenko's patchset, with reasons:"
	elog "  * fs/cifs/* + fs/ksmbd/* if any: linux-stable backported the"
	elog "    fs/cifs → fs/smb/{client,server} rename together with substantial"
	elog "    code rework. pf's pre-rewrite patches are obsolete; stable's"
	elog "    rework supersedes them."
	elog "  * kernel/futex/{core,syscalls}.c: most differences were comment"
	elog "    wording; functional additions weren't worth the per-bump merge"
	elog "    cost."
	elog "  * kernel/sched/* tweaks: gentoo-sources has newer scheduler"
	elog "    helpers (uclamp/thermal handling). Keeping pf's older form"
	elog "    would regress, not improve, scheduler behaviour."
	elog ""
	elog "If you specifically need pf-kernel's full scheduler heuristics,"
	elog "futex2 extensions, or the pre-rewrite SMB stack, install"
	elog "pf-sources-6.12_p4-r2 instead — it stays GA-frozen and ships"
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
