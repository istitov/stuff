# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-video/AwesomeBump/AwesomeBump-9999.ebuild,v 1.1 2015-03-27 13:19:13 brothermechanic Exp $

#TODO create menu launcher

EAPI=5

inherit git-2 eutils

DESCRIPTION="A free, open source, cross-platform video editor"
HOMEPAGE="http://awesomebump.besaba.com/"
EGIT_REPO_URI="https://github.com/kmkolasinski/AwesomeBump.git"
#EGIT_COMMIT="a15b411"

LICENSE="GPL-3"

SLOT="0"

KEYWORDS="~x86 ~amd64"

IUSE=""

DEPEND="
	dev-qt/qtcore:5
	dev-qt/qtopengl:5
	virtual/opengl
	"

RDEPEND="${DEPEND}"

#S="${WORKDIR}/Sources"

src_prepare() {
	/usr/lib64/qt5/bin/qmake Sources/AwesomeBump.pro || die
}

src_compile() {
	emake || die
}

src_install() {
	INST_DIR="/opt/AwesomeBump"
	insinto $INST_DIR
	doins -r Bin/*
	exeinto $INST_DIR
	doexe Build/Bin/AwesomeBump
	dobin ${FILESDIR}/AwesomeBump.sh
	newicon Sources/resources/logo.png "${PN}".png || die
	make_desktop_entry AwesomeBump.sh
}
