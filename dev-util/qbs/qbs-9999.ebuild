# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
inherit qmake-utils git-r3

HOMEPAGE="http://labs.qt.nokia.com/2012/02/15/introducing-qbs"
EGIT_REPO_URI="https://gitorious.org/qt-labs/${PN}.git"

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
