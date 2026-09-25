# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"

# luaL_typerror/luaL_checkint pin the C API to 5.1 (5.2 via its own shims).
LUA_COMPAT=( lua5-1 luajit )

inherit autotools lua-single
[[ ${PV} == 9999 ]] && inherit git-r3

DESCRIPTION="oocairo are Lua bindings to the cairo library"
HOMEPAGE="https://github.com/awesomeWM/oocairo"

if [[ ${PV} == 9999 ]]; then
	EGIT_REPO_URI="https://github.com/awesomeWM/${PN}.git"
else
	SRC_URI="https://github.com/awesomeWM/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="MIT"
SLOT="0"
REQUIRED_USE="${LUA_REQUIRED_USE}"

RDEPEND="${LUA_DEPS}
	x11-libs/cairo"
DEPEND="${RDEPEND}"
# Configure requires pod2man and pkg.m4; autotools.eclass supplies the remaining
# generators.
# verified 2026-07-27
BDEPEND="
	dev-lang/perl
	virtual/pkgconfig
"

src_prepare() {
	default
	eautoreconf
}

src_install() {
	default
	find "${ED}" -type f -name "*.la" -delete || die
}
