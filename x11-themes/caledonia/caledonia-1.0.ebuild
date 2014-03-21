# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: bar-overlay/x11-themes/caledonia/caledonia-1.0.ebuild,v 1.1 2013/12/14 12:01:00 brothermechanic Exp $

EAPI=5

DESCRIPTION="Caledonia) icon theme for KDE4"
HOMEPAGE="https://malcer.deviantart.com/art/CLD-Icons-UNSUPPORTED-264978107"
SRC_URI="http://downloads.sourceforge.net/project/cldicons/Icon%20theme/CLD-Icons.tar.gz"

LICENSE="CC-BY-SA-3.0"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="-minimal"

RDEPEND="minimal? ( !kde-base/oxygen-icons )"
DEPEND="app-arch/unzip"

RESTRICT="binchecks strip"

S="${WORKDIR}"/CLD-Icons

src_install() {
	cd "${WORKDIR}"
	dodir /usr/share/icons
	mv ./CLD-Icons "${D}"/usr/share/icons/ || die
}
