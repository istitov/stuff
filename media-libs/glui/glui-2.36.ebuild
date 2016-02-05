# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils

DESCRIPTION="A GLUT-based C++ user interface library"
HOMEPAGE="http://glui.sourceforge.net/"
SRC_URI="http://downloads.sourceforge.net/glui/glui-2.36.tgz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="media-libs/freeglut"
DEPEND="${RDEPEND}"

src_compile() {
	cd "${S}"/src
	emake setup lib/libglui.a || die "make failed"
}

src_install() {
	dolib.a "${S}"/src/lib/*.a || die "Failed to install libraries"
	insinto /usr/include/GL
	doins "${S}"/src/include/GL/glui* || die "Failed to install headers"
}
