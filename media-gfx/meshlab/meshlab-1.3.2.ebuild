# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/meshlab/meshlab-1.3.0a.ebuild,v 0.2 2013/10/29 20:54:13 brothermechanic Exp $

EAPI=5

inherit eutils multilib qt4-r2

DESCRIPTION="A mesh processing system"
HOMEPAGE="http://meshlab.sourceforge.net/"
SRC_URI="http://kaz.dl.sourceforge.net/project/meshlab/meshlab/MeshLab%20v1.3.2/MeshLabSrc_AllInc_v132.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
DEPEND="media-libs/glew
	sys-libs/libunwind
	sci-libs/levmar
	=media-libs/lib3ds-1*
	dev-cpp/muParser
	media-libs/qhull
	media-libs/openctm
	dev-qt/qtcore
	dev-qt/qtopengl"
RDEPEND="${DEPEND}"

S=${WORKDIR}/meshlab/src

src_unpack(){
	unpack ${A}
	cd "${S}"
}

src_prepare() {
	rm "${WORKDIR}"/meshlab/src/distrib/plugins/*.xml
	rm "${WORKDIR}"/meshlab/src/meshlabplugins/filter_qhull/qhull_tools.h
	cd "${PORTAGE_BUILDDIR}"
	ln -s work a
	#pathes from debian repo
	epatch "${FILESDIR}"/1.3.2/01_crash-on-save.patch
	epatch "${FILESDIR}"/1.3.2/02_cstddef.patch
	epatch "${FILESDIR}"/1.3.2/03_disable-updates.patch
	epatch "${FILESDIR}"/1.3.2/04_eigen.patch
	epatch "${FILESDIR}"/1.3.2/05_externals.patch
	epatch "${FILESDIR}"/1.3.2/06_format-security.patch
	epatch "${FILESDIR}"/1.3.2/07_gcc47.patch
	epatch "${FILESDIR}"/1.3.2/08_lib3ds.patch
	epatch "${FILESDIR}"/1.3.2/09_libbz2.patch
	epatch "${FILESDIR}"/1.3.2/10_muparser.patch
	epatch "${FILESDIR}"/1.3.2/11_openctm.patch
	epatch "${FILESDIR}"/1.3.2/12_overflow.patch
	epatch "${FILESDIR}"/1.3.2/13_pluginsdir.patch
	epatch "${FILESDIR}"/1.3.2/14_ply_numeric.patch
	epatch "${FILESDIR}"/1.3.2/15_qhull.patch
	epatch "${FILESDIR}"/1.3.2/16_shadersdir.patch
	epatch "${FILESDIR}"/1.3.2/17_structuresynth.patch
	epatch "${FILESDIR}"/1.3.2/18_glew.c18p1.patch
	epatch "${FILESDIR}"/1.3.2/19_CONFLICTS_IN_rpath.patch
	epatch "${FILESDIR}"/1.3.2/20_rpath.c18p2.patch
	epatch "${FILESDIR}"/1.3.2/21_RESOLUTION.patch
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
	dobin distrib/{meshlab,meshlabserver}
	local my_libdir=/usr/$(get_libdir)/meshlab
	exeinto /usr/$(get_libdir)
	dolib distrib/libcommon.so.1.0.0
	dosym libcommon.so.1.0.0 /usr/$(get_libdir)/libcommon.so.1
	dosym libcommon.so.1 /usr/$(get_libdir)/libcommon.so

	exeinto "${my_libdir}"/plugins
	doexe distrib/plugins/*.so

	insinto /usr/share/meshlab/shaders
	doins -r distrib/shaders/*
	newicon "${S}"/meshlab/images/eye64.png "${PN}".png
	make_desktop_entry meshlab "Meshlab"
}
