# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit cmake-utils eutils

DESCRIPTION="Per-Face Texture Mapping for Production Rendering"
HOMEPAGE="http://ptex.us/"
SRC_URI="https://codeload.github.com/wdas/ptex/zip/v2.0.62 -> ${P}.zip"

LICENSE="PTEX SOFTWARE"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="sys-libs/zlib
	"

CMAKE_USE_DIR=${WORKDIR}/${P}/src

src_install() {
	dobin ${WORKDIR}/ptex-2.0.62_build/utils/ptxinfo
	dolib ${WORKDIR}/ptex-2.0.62_build/ptex/libPtex.so
	insinto /usr/include
	doins ${WORKDIR}/ptex-2.0.62/src/ptex/{PtexHalf.h,PtexInt.h,Ptexture.h,PtexUtils.h}
}
