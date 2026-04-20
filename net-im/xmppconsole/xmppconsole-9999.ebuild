# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools git-r3

DESCRIPTION="A tool for XMPP hackers"
HOMEPAGE="https://github.com/pasis/xmppconsole"
EGIT_REPO_URI="https://github.com/pasis/${PN}.git"

LICENSE="GPL-3+"
SLOT="0"
IUSE="+gtk +ncurses"
REQUIRED_USE="|| ( gtk ncurses )"

RDEPEND="
	>=dev-libs/libstrophe-0.10.0
	gtk? (
		x11-libs/gtk+:3
		|| (
			x11-libs/gtksourceview:4
			x11-libs/gtksourceview:3.0
		)
	)
	ncurses? (
		sys-libs/ncurses:=[unicode(+)]
		sys-libs/readline:=
	)
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

src_prepare() {
	default

	# Readline's rl_command_func_t is int(*)(int, int); callbacks declared
	# with () pass under old GCC / pre-C23 but not with GCC 15's default.
	sed -i -E \
		-e 's/^(static int ui_ncurses_(pageup|pagedown|up|down)_cb)\(\)/\1(int count, int key)/' \
		src/ui_ncurses.c || die

	eautoreconf
}

src_configure() {
	econf \
		$(use_enable gtk) \
		$(use_enable ncurses)
}
