# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"

WX_GTK_VER="2.8"

inherit eutils multilib toolchain-funcs wxwidgets

DESCRIPTION="plant modeling software package"
HOMEPAGE="http://ngplant.sourceforge.net"
SRC_URI="mirror://sourceforge/${PN}/${PN}/${PV}/${P}.tar.gz"

SLOT="0"
KEYWORDS="~amd64 ~x86"
LICENSE="GPL-3 BSD"
IUSE="doc +examples"

RDEPEND="
	media-libs/glew
	media-libs/freeglut
	x11-libs/wxGTK:2.8[X]
	dev-lang/lua"
DEPEND="${RDEPEND}
	dev-util/scons
	virtual/pkgconfig
	dev-libs/libxslt"

src_prepare() {
	epatch "${FILESDIR}"/scons.patch
	rm -rf extern

	sed \
		-e "s:CC_OPT_FLAGS=.*$:CC_OPT_FLAGS=\'${CFLAGS}\':g" \
		-i SConstruct \
		|| die "failed to correct CFLAGS"

	sed \
		-e "s:LINKFLAGS='-s':LINKFLAGS=\'${LDFLAGS}\':g" \
		-i ngpview/SConscript ${PN}/SConscript devtools/SConscript ngpshot/SConscript \
		|| die "failed to correct LDFLAGS"
}

src_compile() {
	scons \
		CC=$(tc-getCC) \
		CXX=$(tc-getCXX)\
		LINKFLAGS="${LDFLAGS}" \
		GLEW_INC="/usr/include/" \
		GLEW_LIBPATH="/usr/$(get_libdir)/" \
		GLEW_LIBS="GLEW GL GLU glut" \
		LUA_INC="/usr/include/" \
		LUA_LIBPATH="/usr/$(get_libdir)/" \
		LUA_LIBS="$(pkg-config lua --libs)" \
		|| die
}

src_install() {
	dobin ${PN}/${PN} ngpview/ngpview devtools/ngpbench ngpshot/ngpshot scripts/ngp2obj.py
	dolib.a ngpcore/libngpcore.a ngput/libngput.a
	insinto /usr/share/${PN}/
	doins -r plugins shaders
	dodoc ReleaseNotes

	if use examples; then
		doins -r samples
	fi

	if use doc; then
		dohtml -r docapi
	fi
	insinto /usr/share/pixmaps/
	doins ngplant/images/ngplant.xpm
	insinto /usr/share/applications/
	doins "${FILESDIR}"/ngplant.desktop
}
