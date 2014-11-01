# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit versionator

COMPRESSTYPE=".gz"
K_USEPV="yes"
UNIPATCH_STRICTORDER="yes"
K_SECURITY_UNSUPPORTED="1"

CKV="$(get_version_component_range 1-2)"
ETYPE="sources"

inherit kernel-2
#detect_version
K_NOSETEXTRAVERSION="don't_set_it"

DESCRIPTION="The Liquorix Kernel Sources v3.x"
HOMEPAGE="http://liquorix.net/"
LIQUORIX_VERSION="${PV/_p[0-9]*}"
LIQUORIX_FILE="${LIQUORIX_VERSION}-1.patch${COMPRESSTYPE}"
LIQUORIX_URI="http://liquorix.net/sources/${LIQUORIX_FILE}"
SRC_URI="${KERNEL_URI} ${LIQUORIX_URI}";

KEYWORDS="-* ~amd64 ~ppc ~ppc64 ~x86"
IUSE=""

KV_FULL="${PVR/_p/-pf}"
S="${WORKDIR}"/linux-"${KV_FULL}"

pkg_setup(){
	ewarn
	ewarn "${PN} is *not* supported by the Gentoo Kernel Project in any way."
	ewarn "If you need support, please contact the Liquorix developers directly."
	ewarn "Do *not* open bugs in Gentoo's bugzilla unless you have issues with"
	ewarn "the ebuilds. Thank you."
	ewarn
	kernel-2_pkg_setup
}

src_prepare(){
	epatch "${DISTDIR}"/"${LIQUORIX_FILE}"
}

K_EXTRAEINFO="For more info on liquorix-sources and details on how to report problems, see: \
${HOMEPAGE}."
