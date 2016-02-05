# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=4

inherit eutils subversion

ESVN_REPO_URI="https://sk1.svn.sourceforge.net/svnroot/sk1/trunk/sK1"
ESVN_PROJECT="${PN}"

MY_R="335"
DESCRIPTION="sK1 vector graphics editor"
HOMEPAGE="http://www.sk1project.org/"

LICENSE="|| ( GPL-2 LGPL-2 )"
SLOT="0"
KEYWORDS=""

IUSE=""

DEPEND=">=sys-libs/glibc-2.6.1
	>=x11-libs/cairo-1.4.0
	media-libs/freetype:2
	x11-libs/libX11
	x11-libs/libXext
	>=dev-lang/tcl-8.5.5
	>=dev-lang/tk-8.5.5
	>=sys-libs/zlib-1.2.3-r1
	dev-lang/python[tk]
	dev-python/imaging
	media-libs/lcms:0[python]
	gnome-extra/zenity
	media-libs/sk1libs
	media-gfx/sk1sdk"

RDEPEND="${DEPEND}"

src_compile() {
	python setup.py build || die "'python setup.py build' failed"
}

src_install() {
	python setup.py install --root="${D}" || die "'python setup.py install --root=\"${D}\"' failed"
}
