# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Define what default functions to run.
ETYPE="sources"

# Use genpatches but don't include the 'experimental' use flag.
K_EXP_GENPATCHES_NOUSE="1"

# Genpatches version to use. -pf patch set already includes vanilla linux updates. Regularly "1"
# is the wanted value here, but the genpatches patch set can be bumped if it includes some
# important fixes. src_prepare() will handle deleting the updated vanilla linux patches.
# See https://archives.gentoo.org/gentoo-kernel/ (or subscribe to the list) to see all patches.
K_GENPATCHES_VER="10"

# -pf patch set already sets EXTRAVERSION to kernel Makefile.
K_NOSETEXTRAVERSION="1"

# pf-sources is not officially supported/covered by the Gentoo security team.
K_SECURITY_UNSUPPORTED="1"

# Define which parts to use from genpatches - experimental is already included in the -pf patch
# set.
K_WANT_GENPATCHES="base extras"

# Major kernel version, e.g. 5.14.
SHPV="${PV/_p*/}"

# Replace "_p" with "-pf", since using "-pf" is not allowed for an ebuild name by PMS.
PFPV="${PV/_p/-pf}"

inherit kernel-2 optfeature
detect_version

DESCRIPTION="Linux kernel fork that includes the pf-kernel patchset and Gentoo's genpatches"
HOMEPAGE="https://pfkernel.natalenko.name/
	https://dev.gentoo.org/~alicef/genpatches/"
SRC_URI="https://codeberg.org/pf-kernel/linux/archive/v${PFPV}.tar.gz -> linux-${PFPV}.tar.gz
	https://dev.gentoo.org/~alicef/dist/genpatches/genpatches-${SHPV}-${K_GENPATCHES_VER}.base.tar.xz
	https://dev.gentoo.org/~alicef/dist/genpatches/genpatches-${SHPV}-${K_GENPATCHES_VER}.extras.tar.xz"

S="${WORKDIR}/linux-${PFPV}"

KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"

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
	# Since the Codeberg-hosted pf-sources include full kernel sources, we need to manually override
	# the src_unpack phase because kernel-2_src_unpack() does a lot of unwanted magic here.
	unpack ${A}

	mv linux linux-${PFPV} || die "Failed to move source directory"
}

src_prepare() {
	# When genpatches basic version is bumped, it also includes vanilla linux updates. Those are
	# already in the -pf patch set, so need to remove the vanilla linux patches to avoid conflicts.
	if [[ ${K_GENPATCHES_VER} -ne 1 ]]; then
		find "${WORKDIR}"/ -type f -name '10*linux*patch' -delete ||
			die "Failed to delete vanilla linux patches in src_prepare."
	fi

	# kernel-2_src_prepare doesn't apply PATCHES(). Chosen genpatches are also applied here.
	eapply "${WORKDIR}"/*.patch
	eapply "${FILESDIR}/pf-sources-6.19_p4-ima_validate_range.patch"

	# CVE-2026-31431 ("Copy Fail") — local privilege escalation via
	# algif_aead in-place AAD copy. Mainline fix is upstream commit
	# a664bf3d603d (2026-03-26) reverting the 2017 in-place
	# optimization. linux-stable backported it into 6.19.12, but
	# pf-kernel branches off Linux GA only and never picks up
	# linux-stable, so 6.19-pfN ships unpatched 6.19.0 source.
	eapply "${FILESDIR}/cve-2026-31431-algif_aead-revert-out-of-place.patch"

	# CVE-2026-43037 — IPv6 tunnel ip4ip6_err() stack overflow via
	# inet6_skb_parm/inet_skb_parm cb[] reuse on cloned skb. Mainline
	# fix 2edfa31769a4 clears IPCB(skb2) and adds minimal IPv4 header
	# validation. Backported into 6.19.12; same GA-only gap as 31431.
	eapply "${FILESDIR}/cve-2026-43037-ip6_tunnel-clear-skb-cb.patch"

	# CVE-2026-43038 — IPv6 ICMP ip6_err_gen_icmpv6_unreach() OOB read
	# via the same cb[] type-confusion pattern, reachable via forged
	# ICMPv4 error with CIPSO option. Mainline fix 86ab3e55673a clears
	# IP6CB(skb2). Backported into 6.19.12; same GA-only gap.
	eapply "${FILESDIR}/cve-2026-43038-icmpv6-clear-skb-cb.patch"

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
