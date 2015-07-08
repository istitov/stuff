# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-extra/indicator-applet/indicator-applet-0.4.5.ebuild,v 1.2 2010/12/08 17:28:03 pacho Exp $

EAPI="5"
GCONF_DEBUG="no"

inherit autotools eutils gnome2 versionator

DESCRIPTION="A small applet to display information from various applications consistently in the panel"
HOMEPAGE="http://launchpad.net/indicator-applet/"
SRC_URI="http://launchpad.net/${PN}/$(get_version_component_range 1-2)/${PV}/+download/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="nls"

RDEPEND=">=dev-libs/glib-2.18:2
	>=x11-libs/gtk+-2.12:2
	>=dev-libs/dbus-glib-0.76
	|| ( gnome-base/gnome-panel[bonobo] <gnome-base/gnome-panel-2.32 )
	>=gnome-base/gconf-2
	>=dev-libs/libindicator-0.4"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	nls? ( >=dev-util/intltool-0.35 )"

pkg_setup() {
	G2CONF="${G2CONF}
		$(use_enable nls)
		--disable-dependency-tracking"
	DOCS="AUTHORS"
}

src_prepare() {
	gnome2_src_prepare
	sed -e 's/0.3.22/0.4.1/g' -i configure.ac configure || die
	sed -e 's:indicator >= $INDICATOR_REQUIRED_VERSION:indicator-0.4 >= $INDICATOR_REQUIRED_VERSION:g' -i configure.ac || die
	sed -e 's:--variable=indicatordir indicator:--variable=indicatordir indicator-0.4:g' -i configure.ac || die
	sed -e 's:--variable=iconsdir indicator:--variable=iconsdir indicator-0.4:g' -i configure.ac || die
	eautoreconf
}
