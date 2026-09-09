# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools

COMMIT="17accd5345adeb3b81315d284dd81ac881517cc6"

DESCRIPTION="File-browser widget plugin for the DeaDBeeF audio player"
HOMEPAGE="https://gitlab.com/zykure/deadbeef-fb"
SRC_URI="https://gitlab.com/zykure/deadbeef-fb/-/archive/${COMMIT}/deadbeef-fb-${COMMIT}.tar.bz2 -> ${P}.tar.bz2"
S="${WORKDIR}/deadbeef-fb-${COMMIT}"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS=""

DEPEND="
	media-sound/deadbeef
	x11-libs/gtk+:3
"
RDEPEND="${DEPEND}"
BDEPEND="
	sys-devel/gettext
	virtual/pkgconfig
"

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	econf --disable-gtk2
}

src_install() {
	default
	find "${ED}" -type f -name '*.la' -delete || die
}
