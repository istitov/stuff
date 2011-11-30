# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/gimp/gimp-9999.ebuild,v 1.17 2008/05/18 02:08:03 hanno Exp $

inherit eutils
inherit subversion

ESVN_REPO_URI="https://sk1.svn.sourceforge.net/svnroot/sk1/trunk/sK1"
ESVN_PROJECT="${PN}"

MY_R="335"
DESCRIPTION="sK1 vector graphics editor"
HOMEPAGE="http://www.sk1project.org/"

LICENSE="|| ( GPL-2 LGPL-2 )"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE=""

DEPEND=">=sys-libs/glibc-2.6.1
        >=x11-libs/cairo-1.4.0
        >=media-libs/freetype-2.3.5
        x11-libs/libX11
        x11-libs/libXext
        >=dev-lang/tcl-8.5.5
        >=dev-lang/tk-8.5.5
        >=sys-libs/zlib-1.2.3-r1
        virtual/python
        dev-python/imaging
        media-libs/lcms
        gnome-extra/zenity
	media-libs/sk1libs
	media-gfx/sk1sdk"

RDEPEND="${DEPEND}"

pkg_setup() {
        if  ! built_with_use dev-lang/python tk; then
                eerror "This package requires dev-lang/python compiled with tk support."
                die "Please reemerge dev-lang/python with USE=\"tk\"."
        fi
        if  ! built_with_use media-libs/lcms python; then
                eerror "This package requires media-libs/lcms compiled with python support."
                die "Please reemerge media-libs/lcms with USE=\"python\"."
        fi
}


#src_unpack() {
#cd sK1
#}

src_compile() {
         python setup.py build || die "'python setup.py build' failed"
}

src_install() {
        python setup.py install --root="${D}" || die "'python setup.py install --root=\"${D}\"' failed"
}

