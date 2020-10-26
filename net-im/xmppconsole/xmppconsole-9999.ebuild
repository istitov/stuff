# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

EGIT_REPO_URI="https://github.com/pasis/xmppconsole.git"

inherit autotools git-r3

DESCRIPTION="A tool for XMPP hackers"
HOMEPAGE="https://github.com/pasis/xmppconsole"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS=""
IUSE="+gtk +ncurses"

RDEPEND="dev-libs/libstrophe
		ncurses? (
			sys-libs/ncurses
			sys-libs/readline
		)
		gtk? (
			x11-libs/gtk+:3
			|| (
				x11-libs/gtksourceview:4
				x11-libs/gtksourceview:3.0
			)
		)"
DEPEND="${RDEPEND}"

src_prepare() {
		default
		eautoreconf
}

src_configure() {
		econf \
			$(use_enable gtk) \
			$(use_enable ncurses)
}
