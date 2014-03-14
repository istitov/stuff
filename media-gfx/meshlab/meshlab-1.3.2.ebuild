# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/meshlab/meshlab-1.3.0a.ebuild,v 0.2 2013/10/29 20:54:13 brothermechanic Exp $

EAPI=5

inherit eutils versionator multilib qt4-r2

DESCRIPTION="A mesh processing system"
HOMEPAGE="http://meshlab.sourceforge.net/"
MY_PV="$(delete_all_version_separators ${PV})"
SRC_URI="mirror://sourceforge/project/${PN}/${PN}/MeshLab%20v${PV}/MeshLabSrc_AllInc_v${MY_PV}.tgz"

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
	dev-qt/qtopengl
	dev-cpp/eigen:3"
RDEPEND="${DEPEND}"

S="${WORKDIR}/meshlab/src"

src_prepare() {
	rm "${WORKDIR}"/meshlab/src/distrib/plugins/*.xml
	rm "${WORKDIR}"/meshlab/src/meshlabplugins/filter_qhull/qhull_tools.h
	cd ${PORTAGE_BUILDDIR}
	ln -s work a
	#patches from debian repo
	epatch "${FILESDIR}/${PV}"/*.patch
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
	dolib distrib/libcommon.so.1.0.0
	dosym libcommon.so.1.0.0 /usr/$(get_libdir)/libcommon.so.1
	dosym libcommon.so.1 /usr/$(get_libdir)/libcommon.so

	exeinto /usr/$(get_libdir)/meshlab/plugins
	doexe distrib/plugins/*.so

	insinto /usr/share/meshlab/shaders
	doins -r distrib/shaders/*
	newicon "${S}"/meshlab/images/eye64.png "${PN}".png
	make_desktop_entry meshlab "Meshlab"
}
