# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/arc3d_client/arc3d_client-2.1.1.ebuild,v 0.1 2013/11/04 13:38:00 brothermechanic Exp $

EAPI=5

inherit eutils multilib qt4-r2

DESCRIPTION="The web Tools for 3D reconstruction"
HOMEPAGE="http://homes.esat.kuleuven.be/~visit3d/webservice/v2/index.php"
SRC_URI="http://homes.esat.kuleuven.be/~visit3d/webservice/v2/arc3d_client_v2.1.1.tar.gz"

LICENSE="ARC3D"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
DEPEND="media-gfx/exiv2
	dev-qt/qtcore
	sys-libs/zlib
	virtual/jpeg"
RDEPEND="${DEPEND}"

S="${WORKDIR}/arc3d_client"

src_prepare() {
	#path from oh-la-la http://www.linux.org.ru/forum/development/9776470?lastmod=1383557443423#comment-9776560
	epatch "${FILESDIR}"/oh-la-la.patch
}

src_configure() {
	eqmake4 -recursive
}

src_install() {
	dobin bin/*
	dolib lib/*
	newicon gui/resources/gui/arc_logo32x32.png "${PN}".png
	make_desktop_entry arc3d_gui "ARC 3D" Graphics
}
