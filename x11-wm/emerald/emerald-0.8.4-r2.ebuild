# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-wm/emerald/emerald-0.8.4-r2.ebuild,v 1.4 2011/09/14 20:47:24 ssuominen Exp $

EAPI="2"

inherit eutils

THEMES_RELEASE=0.5.2

DESCRIPTION="Emerald Window Decorator"
HOMEPAGE="http://www.compiz.org/"
SRC_URI="http://releases.compiz.org/${PV}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"
IUSE=""

PDEPEND="~x11-themes/emerald-themes-${THEMES_RELEASE}"

RDEPEND="
	>=x11-libs/gtk+-2.8.0:2
	>=x11-libs/libwnck-2.14.2:1
	>=x11-wm/compiz-${PV}
"

DEPEND="${RDEPEND}
	>=dev-util/intltool-0.35
	>=dev-util/pkgconfig-0.19
	>=sys-devel/gettext-0.15
"

src_prepare() {
	# Fix pkg-config file pollution wrt #380197
	epatch "${FILESDIR}"/${P}-pkgconfig-pollution.patch
	# Fixing GTK symbol - bug 308791.
	epatch "${FILESDIR}/${P}-gtk+-2.20-build.patch"
	# fix build with gtk+-2.22 - bug 341143
	sed -i -e '/#define G[DT]K_DISABLE_DEPRECATED/s:^://:' \
		include/emerald.h || die
}

src_configure() {
	econf \
		--disable-dependency-tracking \
		--disable-static \
		--enable-fast-install \
		--disable-mime-update || die "econf failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	find "${D}" -name '*.la' -delete || die
}
