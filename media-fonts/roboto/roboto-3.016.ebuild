# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="Standard font for Android 4.0 (Ice Cream Sandwich) and later"
HOMEPAGE="https://github.com/googlefonts/roboto-3-classic"
SRC_URI="https://github.com/googlefonts/roboto-3-classic/releases/download/v${PV}/Roboto_v${PV}.zip -> ${P}.zip"
# Unhinted static instances, as ::gentoo's 2.x installs.
S="${WORKDIR}/unhinted/static"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND="app-arch/unzip"

FONT_CONF=( "${FILESDIR}"/90-roboto-regular.conf )
FONT_SUFFIX="ttf"
