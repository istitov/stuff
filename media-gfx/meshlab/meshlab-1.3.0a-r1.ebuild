# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/meshlab/meshlab-1.3.0a.ebuild,v 0.1 2013/03/04 19:07:13 brothermechanic Exp $

EAPI=5

inherit eutils multilib qt4-r2

DESCRIPTION="A mesh processing system"
HOMEPAGE="http://meshlab.sourceforge.net/"
SRC_URI="mirror://sourceforge/meshlab/meshlab/MeshLab%20v1.3.0/MeshLabSrc_AllInc_v130a.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
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
	rm ${WORKDIR}/meshlab/src/fgt/filter_qhull/qhull_tools.h
	cd ${PORTAGE_BUILDDIR}
	ln -s work a
	epatch "${FILESDIR}"/01_muparser.patch
	epatch "${FILESDIR}"/02_qhull_gentoo.patch
	epatch "${FILESDIR}"/03_lib3ds.patch
	epatch "${FILESDIR}"/04_libbz2.patch
	epatch "${FILESDIR}"/05_glew.patch
	epatch "${FILESDIR}"/06_CONFLICTS_IN_eigen.patch
	epatch "${FILESDIR}"/07_eigen.patch
	epatch "${FILESDIR}"/08_disable-updates.patch
	epatch "${FILESDIR}"/09_externals.patch
	epatch "${FILESDIR}"/10_CONFLICTS_IN_rpath.patch
	epatch "${FILESDIR}"/11_rpath.patch
	epatch "${FILESDIR}"/12_shadersdir.patch
	epatch "${FILESDIR}"/13_pluginsdir.patch
	epatch "${FILESDIR}"/14_ply_numeric.patch
	epatch "${FILESDIR}"/15_cstddef.patch
	epatch "${FILESDIR}"/16_structuresynth.patch
	epatch "${FILESDIR}"/17_gcc47.patch
	epatch "${FILESDIR}"/18_RESOLUTION.patch
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
}
