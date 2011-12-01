# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: megabaks $

EAPI=2

inherit qt4-r2 subversion

ESVN_REPO_URI="svn://svn.rockbox.org/rockbox/trunk"

DESCRIPTION="The Rockbox Utility, all you need for installing and managing rockbox"
HOMEPAGE="http://www.rockbox.org/wiki/RockboxUtility"
LICENSE="GPL-2"

SLOT="0"
KEYWORDS=""
IUSE="ypp2"

RDEPEND="x11-libs/qt-gui:4"
DEPEND="${RDEPEND}"

S="${WORKDIR}/rbutil/rbutilqt"

src_compile() {
	use ypp2 && epatch "${FILESDIR}"/ypp2.patch
	cd "${S}"/rbutil/rbutilqt;
	qmake -recursive || die "qmake failed"
	emake -j1 || die "emake failed"
}

src_install() {
	dobin "RockboxUtility"
	insinto "/etc"
	doins "${S}/rbutil.ini"
	newicon "${S}/rockbox.ico" "${PN}.ico"
	make_desktop_entry RockboxUtility "Rockbox Utility" "/usr/share/pixmaps/${PN}.ico"
}
