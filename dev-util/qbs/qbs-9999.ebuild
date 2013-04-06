# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/qbs/qbs-9999.ebuild,v 1.1 2011/01/13 23:44:36 dexon Exp $

EAPI="4"
inherit qt4-r2 git-2

HOMEPAGE="http://labs.qt.nokia.com/2012/02/15/introducing-qbs"
EGIT_REPO_URI="git://gitorious.org/qt-labs/${PN}.git"

DESCRIPTION="Next generation of build systems based on Qt and QML language/"
LICENSE="LGPL-2"
SLOT="0"
KEYWORDS=""
IUSE="debug"

RDEPEND="dev-qt/qtcore
	dev-qt/qtscript"
DEPEND="${RDEPEND}"

src_install() {
	QTLIBDIR=${EPREFIX}/usr/$(get_libdir)/qt4
	QTPLUGINDIR=${QTLIBDIR}/plugins
	emake INSTALL_ROOT="${D}/usr" install || die

	dobin bin/qbs*
	insinto ${QTPLUGINDIR}
	doins "${S}"/plugins/*.so

	cp -R "${S}/share" "${D}/usr" || die "Install failed!"
}
