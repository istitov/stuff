# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/meshlab/meshlab-1.3.0a.ebuild,v 0.2 2013/10/29 20:54:13 brothermechanic Exp $

EAPI=5

inherit eutils multilib qt4-r2

DESCRIPTION="A mesh processing system"
HOMEPAGE="http://meshlab.sourceforge.net/"
SRC_URI="https://launchpadlibrarian.net/145153756/meshlab_1.3.3.orig.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE=""
DEPEND="media-libs/glew
	sci-libs/levmar
	media-libs/lib3ds
	>=dev-cpp/muParser-1.30
	media-libs/qhull
	dev-qt/qtcore
	dev-qt/qtopengl"
RDEPEND="${DEPEND}"

S=${WORKDIR}/meshlab/src

src_unpack(){
	unpack ${A}
	cd "${S}"
}

src_prepare() {
	cd ${PORTAGE_BUILDDIR}
	ln -s work meshlab-1.3.3
	#patches from https://launchpad.net/~zarquon42/+archive/meshlab/+packages
	epatch "${FILESDIR}"/1.3.3/fix-external.pro.patch
	epatch "${FILESDIR}"/1.3.3/fixlocale.patch
	epatch "${FILESDIR}"/1.3.3/fix-rpath.patch
	epatch "${FILESDIR}"/1.3.3/disable-updates.patch
	epatch "${FILESDIR}"/1.3.3/pluginsdir.patch
	epatch "${FILESDIR}"/1.3.3/shadersdir.patch
	epatch "${FILESDIR}"/1.3.3/fix-plystuff.h.patch
	cd "${S}"
}

src_configure() {
	eqmake4 external/external.pro
	eqmake4 meshlab_full.pro
}

src_compile() {
	cd external && emake
	cd .. && emake
}

src_install() {
	local my_libdir=/usr/$(get_libdir)/meshlab

	exeinto ${my_libdir}
	doexe distrib/{libcommon.so.1.0.0,meshlab{,server}} || die
	dosym libcommon.so.1.0.0 ${my_libdir}/libcommon.so.1 || die
	dosym libcommon.so.1 ${my_libdir}/libcommon.so || die
	dosym ${my_libdir}/meshlab /usr/bin/meshlab || die
	dosym ${my_libdir}/meshlabserver /usr/bin/meshlabserver || die

	exeinto ${my_libdir}/plugins
	doexe distrib/plugins/*.so || die

	insinto ${my_libdir}/shaders
	doins -r distrib/shaders/* || die
	newicon ${S}/meshlab/images/eye64.png "${PN}".png
        make_desktop_entry meshlab "Meshlab"
}

