# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit xdg

DESCRIPTION="Simple paint program in the spirit of MS Paint, built on GEGL"
HOMEPAGE="https://launchpad.net/dibuja"
SRC_URI="https://launchpad.net/${PN}/trunk/${PV}/+download/${P}.tar.gz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64"
IUSE="exif"

# configure asks pkg-config for plain "gexiv2", which only the 0.14 slot ships.
RDEPEND="
	dev-libs/glib:2
	media-libs/babl
	media-libs/gegl:0.4
	x11-libs/gtk+:3
	exif? ( media-libs/gexiv2:0 )
"
DEPEND="${RDEPEND}"
BDEPEND="
	sys-devel/gettext
	virtual/pkgconfig
"

src_prepare() {
	default

	# Help opens ${datadir}/doc/dibuja/dibuja.htm, which matches only
	# upstream's default htmldir; econf moves the HTML to ${PF}/html.
	local old='"doc" SEP "dibuja" SEP "dibuja.htm"'
	grep -qF "${old}" src/util.h || die "help URI anchor moved"
	sed -i -e "s|${old}|\"doc\" SEP \"${PF}\" SEP \"html\" SEP \"dibuja.htm\"|" \
		src/util.h || die
}

src_configure() {
	# GTK 2 is upstream's default; build the GTK 3 interface instead. The
	# bundled insta-curve effect installs as a plugin under gegl-0.4.
	econf \
		--with-gtk3 \
		--with-plugins \
		$(use_with exif gexiv2)
}

src_install() {
	default
	find "${ED}" -name '*.la' -delete || die
	# The top-level Makefile also copies README, COPYING and friends to a
	# hardcoded doc/dibuja; the default doc install already has them.
	rm -r "${ED}"/usr/share/doc/${PN} || die
}
