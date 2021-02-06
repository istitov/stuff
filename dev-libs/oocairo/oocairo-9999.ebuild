# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
inherit git-r3

EGIT_REPO_URI="git://git.naquadah.org/oocairo.git"

DESCRIPTION="oocairo are Lua bindings to the cairo library."
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
