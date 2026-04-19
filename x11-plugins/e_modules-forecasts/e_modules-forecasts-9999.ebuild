# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

#E_PKG_IUSE="nls"
#EFL_USE_GIT="yes"
#EFL_GIT_REPO_CATEGORY="enlightenment"
EGIT_REPO_URI="https://git.enlightenment.org/enlightenment/enlightenment-module-forecasts"
inherit meson xdg git-r3

DESCRIPTION="The forecasts gadget written with EFL"
HOMEPAGE="https://git.enlightenment.org/enlightenment/enlightenment-module-forecasts"

LICENSE="BSD-2"
SLOT="0"

DEPEND="x11-wm/enlightenment"
RDEPEND="${DEPEND}"

src_compile() {
	meson build
	cd build
	ninja
}

src_install() {
	cd build
	DESTDIR=${D} ninja install
}
