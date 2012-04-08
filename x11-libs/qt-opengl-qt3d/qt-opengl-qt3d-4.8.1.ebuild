# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/qt-opengl/qt-opengl-4.8.0-r2.ebuild,v 1.1 2012/02/05 13:02:29 wired Exp $

EAPI="3"
inherit qt4-build

DESCRIPTION="The headers needed for Qt3D"
SLOT="4"
KEYWORDS="~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 -sparc ~x86 ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND="~x11-libs/qt-core-${PV}
	~x11-libs/qt-gui-${PV}
	~x11-libs/qt-opengl-${PV}
	virtual/opengl"
RDEPEND="${DEPEND}"

pkg_setup() {
	QT4_EXTRACT_DIRECTORIES="
	include/QtOpenGL/private
	src/opengl"
}

src_configure(){
	sed -e 's|../||' -i include/QtOpenGL/private/qglextensions_p.h
}

src_install() {
	insinto "${QTHEADERDIR#${EPREFIX}}"/QtOpenGL/private || die
	doins include/QtOpenGL/private/qglextensions_p.h || die

	insinto "${QTHEADERDIR#${EPREFIX}}"/src/opengl || die
	doins src/opengl/qglextensions_p.h || die
}
