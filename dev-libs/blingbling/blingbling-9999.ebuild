# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3

DESCRIPTION="Graphical widget library for the Awesome window manager"
HOMEPAGE="https://github.com/cedlemo/blingbling"
EGIT_REPO_URI="https://github.com/cedlemo/${PN}.git"

LICENSE="GPL-2"
SLOT="0"
IUSE="+vicious"

RDEPEND="
	dev-lang/lua:*
	dev-libs/oocairo
	x11-wm/awesome
	vicious? ( x11-plugins/vicious )
"
DEPEND="${RDEPEND}"

src_install() {
	insinto "/usr/share/awesome/lib/${PN}"
	doins *.lua
	dodoc README.md To_Do
}
