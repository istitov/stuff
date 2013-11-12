# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# TODO: unbundle tinyxml, glew, etc...

EAPI=5

inherit eutils multilib qt4-r2 versionator

MY_PF=OpenCTM-1.0.3

DESCRIPTION="OpenCTM - the Open Compressed Triangle Mesh file format - is a file format, a software library and a tool set for compression of 3D triangle meshes."
HOMEPAGE="http://openctm.sourceforge.net"
SRC_URI="mirror://debian/pool/main/o/openctm/openctm_1.0.3+dfsg1.orig.tar.bz2"


LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
DEPEND="media-libs/glew
	dev-libs/tinyxml 
	media-libs/pnglite 
        media-libs/freeglut"
RDEPEND="${DEPEND}"

S=${WORKDIR}/${MY_PF}

src_configure() {
	epatch "${FILESDIR}"/makefiles
	mv Makefile.linux Makefile
}

src_compile() {
	emake DESTDIR="${D}"
}


