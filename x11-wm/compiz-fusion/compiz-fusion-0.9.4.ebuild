# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="Compiz Fusion (meta)"
HOMEPAGE="http://www.compiz.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="gnome kde unsupported"

RDEPEND="
	>=x11-wm/compiz-${PV}
	>=x11-plugins/compiz-plugins-main-${PV}
	>=x11-plugins/compiz-plugins-extra-${PV}
	>=x11-apps/ccsm-${PV}
	gnome? ( >=x11-libs/compizconfig-backend-gconf-${PV} )
	kde? ( >=x11-libs/compizconfig-backend-kconfig4-${PV} )
	unsupported? ( >=x11-plugins/compiz-plugins-unsupported-${PV} )
"
