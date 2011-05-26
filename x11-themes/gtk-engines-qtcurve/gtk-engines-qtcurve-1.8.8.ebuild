# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-themes/gtk-engines-qtcurve/gtk-engines-qtcurve-1.8.7.ebuild,v 1.1 2011/03/26 23:03:42 wired Exp $

EAPI=4
inherit cmake-utils

MY_P=${P/gtk-engines-qtcurve/QtCurve-Gtk2}

DESCRIPTION="A set of widget styles for GTK2 based apps, also available for KDE3 and Qt4"
HOMEPAGE="http://www.kde-look.org/content/show.php?content=40492"
SRC_URI="http://craigd.wikispaces.com/file/view/${MY_P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~hppa ~ppc ~ppc64 ~sparc ~x86"
IUSE="mozilla"

RDEPEND="x11-libs/gtk+:2
	x11-libs/cairo
	mozilla? (
		|| (
			>=www-client/firefox-3.0
			>=www-client/firefox-bin-3.0
		)
	)"
DEPEND="x11-libs/gtk+:2
	x11-libs/cairo
	dev-util/pkgconfig"

S=${WORKDIR}/${MY_P}
DOCS="ChangeLog README TODO"

src_configure() {
	local mycmakeargs=(
		"-DQTC_OLD_MOZILLA=OFF"
		"-QTC_USE_CAIRO_FOR_ARROWS=ON"
		$(cmake-utils_use mozilla QTC_MODIFY_MOZILLA)
	)
	cmake-utils_src_configure
}
