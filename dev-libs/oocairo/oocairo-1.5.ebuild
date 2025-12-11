# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"

[[ ${PV} == 9999 ]] && inherit git-r3

DESCRIPTION="oocairo are Lua bindings to the cairo library."
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

src_prepare() {
	default
	./autogen.sh
}
