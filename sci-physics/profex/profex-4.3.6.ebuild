# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit qmake-utils
DESCRIPTION="Open source XRD and Rietveld refiniment"
HOMEPAGE="https://www.profex-xrd.org"
SRC_URI="https://www.profex-xrd.org/wp-content/uploads/2021/12/${P}.tar.gz"
#https://www.profex-xrd.org/wp-content/uploads/2022/01/cod-220114.zip -> cod.zip
#https://www.profex-xrd.org/wp-content/uploads/2021/08/BGMN-Templates-210815.tar.gz -> bgmn_templates.tar.gz
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc test"

RDEPEND="
	sci-physics/bgmn
	sci-libs/alglib
	sys-libs/zlib
	~dev-libs/quazip-1.2
	dev-qt/qtdeclarative
	dev-qt/qtcore
	dev-qt/qtsvg
	dev-qt/qtimageformats
"

DEPEND="${RDEPEND}"

S="${WORKDIR}/${PN}-${PV}"


PATCHES=(
	"${FILESDIR}"/pro.patch
	"${FILESDIR}"/srcpro.patch
)

src_prepare() {
	rm -rf "${S}"/{quazip,zlib}
	rm -rf "${S}"/libXrdIO/3rdparty
	sed -i -e "s:../3rdparty/alglib/src:/usr/include:" "${S}"/libXrdIO/curveFitting/*.h || die
	sed -i -e "s:3rdparty/alglib/src:/usr/include:" "${S}"/libXrdIO/curveFitting/*.cpp  || die
	sed -i -e "s:3rdparty/alglib/src:/usr/include:" "${S}"/libXrdIO/scanops.h  || die
	sed -i -e "s:3rdparty/alglib/src:/usr/include:" "${S}"/libXrdIO/scanops.cpp  || die
	sed -i -e "s:3rdparty/alglib/src:/usr/include:" "${S}"/libXrdIO/parser/*.cpp  || die
	sed -i -e "s:../../quazip/:/usr/include/QuaZip-Qt5-1.2/quazip/:" "${S}"/libXrdIO/import/*.cpp  || die
	sed -i -e "s:../quazip/:/usr/include/QuaZip-Qt5-1.2/quazip/:" "${S}"/src/projectWidget/*.cpp  || die
	sed -i -e "s:../quazip/:/usr/include/QuaZip-Qt5-1.2/quazip/:" "${S}"/src/*.cpp  || die
	sed -i -e "s:../../zlib/zlib.h:/usr/include/zlib.h:" "${S}"/libXrdIO/import/*.cpp  || die
	default
}
#
src_configure() {
	default
	eqmake5 -r profex.pro
}

src_compile() {
	default
}

src_install() {
	dobin "${S}"/src/profex
	default
}
