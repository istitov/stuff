# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

#E_PKG_IUSE="nls"
EFL_USE_GIT="yes"
EFL_GIT_REPO_CATEGORY="enlightenment"
EFL_GIT_REPO_NAME="enlightenment-module-places"
inherit efl

DESCRIPTION="E17 Module that manage the mounting of volumes"

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
