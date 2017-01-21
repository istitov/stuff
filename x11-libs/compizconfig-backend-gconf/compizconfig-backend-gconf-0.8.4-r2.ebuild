# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

DESCRIPTION="Compizconfig Gconf Backend"
HOMEPAGE="http://www.compiz.org/"
SRC_URI="http://releases.compiz.org/${PV}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"
IUSE=""

DEPEND="
	>=gnome-base/gconf-2.0:2
	>=x11-libs/libcompizconfig-${PV}
	>=x11-wm/compiz-${PV}
"
RDEPEND="${DEPEND}"

src_configure() {
	econf \
		--disable-dependency-tracking \
		--enable-fast-install \
		--disable-static
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	find "${D}" -name '*.la' -delete || die
}
