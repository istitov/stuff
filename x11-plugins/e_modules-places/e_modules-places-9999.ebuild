# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3 meson xdg

DESCRIPTION="E17 module: manage mounting of volumes"
HOMEPAGE="https://git.enlightenment.org/enlightenment/enlightenment-module-places"
EGIT_REPO_URI="https://git.enlightenment.org/enlightenment/enlightenment-module-places"

LICENSE="BSD-2"
SLOT="0"

DEPEND=">=x11-wm/enlightenment-0.27"
RDEPEND="${DEPEND}"
