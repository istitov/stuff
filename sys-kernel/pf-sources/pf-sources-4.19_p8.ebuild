# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
inherit readme.gentoo-r1 toolchain-funcs

COMPRESSTYPE=".xz"
K_USEPV="yes"
UNIPATCH_STRICTORDER="yes"
K_SECURITY_UNSUPPORTED="1"

CKV="$(ver_cut 1-2)"
ETYPE="sources"
inherit kernel-2
detect_version
K_NOSETEXTRAVERSION="don't_set_it"

DESCRIPTION="Linux kernel fork with new features, including the -ck patchset (BFS), BFQ"
HOMEPAGE="https://pfactum.github.io/pf-kernel/"

PF_FILE="patch-${PV/_p*/}-pf${PV/*_p/}.diff"
PF_URI="https://github.com/pfactum/pf-kernel/compare/v${PV/_p*/}...v${PV/_p*/}-pf${PV/*_p/}.diff"
SRC_URI="${KERNEL_URI} ${PF_URI} -> ${PF_FILE}"

KEYWORDS="-* ~amd64 ~ppc ~ppc64 ~x86"
IUSE=""

KV_FULL="${PVR}-pf"
S="${WORKDIR}"/linux-"${KV_FULL}"

DISABLE_AUTOFORMATTING="yes"
DOC_CONTENTS="
${P} has the following optional runtime dependencies:
- sys-apps/tuxonice-userui: provides minimal userspace progress
information related to suspending and resuming process.
- sys-power/hibernate-script or sys-power/pm-utils: runtime utilities
for hibernating and suspending your computer."

pkg_pretend() {
	# 547868
	if [[ $(gcc-version) < 4.9 ]]; then
			eerror ""
			eerror "${P} needs an active GCC 4.9+ compiler"
			eerror ""
			die "${P} needs an active sys-devel/gcc >= 4.9"
	fi
}

pkg_setup(){
	ewarn
	ewarn "${PN} is *not* supported by the Gentoo Kernel Project in any way."
	ewarn "If you need support, please contact the pf developers directly."
	ewarn "Do *not* open bugs in Gentoo's bugzilla unless you have issues with"
	ewarn "the ebuilds. Thank you."
	ewarn
	kernel-2_pkg_setup
}

src_prepare(){
	epatch "${DISTDIR}"/"${PF_FILE}"
	default
}

src_install() {
	kernel-2_src_install
	readme.gentoo_create_doc
}

pkg_postinst() {
	kernel-2_pkg_postinst
	readme.gentoo_print_elog
}

K_EXTRAEINFO="For more info on pf-sources and details on how to report problems,
see: ${HOMEPAGE}."
