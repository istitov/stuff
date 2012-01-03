# Copyright 1999-2012 Gentoo Linux
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"
inherit git-2

EGIT_REPO_URI="git://git.naquadah.org/oocairo.git"

DESCRIPTION="oocairo are Lua bindings to the cairo library, allowing graphic and text rendering."
HOMEPAGE="http://oocairo.naquadah.org/"

LICENSE="MIT"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND="dev-lang/lua
	x11-libs/cairo"
DEPEND="${RDEPEND}"

src_prepare() {
	./autogen.sh
}
