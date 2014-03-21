# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION="Iterative refocus GIMP plug-in."
HOMEPAGE="http://refocus-it.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
DEPEND=">=x11-libs/gtk+-2.4.4
	>=media-gfx/gimp-2.2.0"
RDEPEND=""

src_install() {
	make install DESTDIR="${D}" || die
}
