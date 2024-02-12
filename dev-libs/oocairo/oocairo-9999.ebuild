# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
inherit git-r3

EGIT_REPO_URI="https://github.com/awesomeWM/oocairo.git"

DESCRIPTION="oocairo are Lua bindings to the cairo library."
HOMEPAGE="https://github.com/awesomeWM/oocairo"
#"http://oocairo.naquadah.org/"

LICENSE="MIT"
SLOT="0"

RDEPEND="dev-lang/lua
	x11-libs/cairo"
DEPEND="${RDEPEND}"

src_prepare() {
	default
	./autogen.sh
}
