# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs

DESCRIPTION="Command line interface to manage hierarchical todos"
HOMEPAGE="https://code.meskio.net/tudu/
	https://github.com/meskio/tudu/"
SRC_URI="https://github.com/meskio/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

DEPEND="sys-libs/ncurses:=[unicode(+)]"
RDEPEND="${DEPEND}"
BDEPEND="virtual/pkgconfig"

src_configure() {
	# acr omits ncursesw from its WIDEC_CURSES link test; inject its flags.
	LDFLAGS="${LDFLAGS} $($(tc-getPKG_CONFIG) --libs ncursesw)" econf
}

src_install() {
	default
	einstalldocs
}
