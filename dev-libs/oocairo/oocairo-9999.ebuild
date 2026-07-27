# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"

inherit autotools
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

RDEPEND="dev-lang/lua
	x11-libs/cairo"
DEPEND="${RDEPEND}"
# No configure script is shipped, so the autotools have to run here. perl
# supplies pod2man, which configure.ac hard-errors without (AC_ERROR "Could
# not find pod2man") because man_MANS is unconditional; pkgconfig supplies
# both pkg.m4 for autoreconf and the PKG_CHECK_MODULES lookup of lua and
# cairo. autoconf, automake and libtool come from autotools.eclass.
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
