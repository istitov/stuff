# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..15} )

inherit distutils-r1

DESCRIPTION="Helper library for Linux gpiochip devices"
HOMEPAGE="
	https://github.com/pimoroni/gpiodevice-python
	https://pypi.org/project/gpiodevice/
"
SRC_URI="https://github.com/pimoroni/${PN}-python/archive/refs/tags/v${PV}.tar.gz
	-> ${P}.gh.tar.gz"
S="${WORKDIR}/${PN}-python-${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64"

RDEPEND="dev-libs/libgpiod[python]"
BDEPEND="dev-python/hatch-fancy-pypi-readme[${PYTHON_USEDEP}]"

DOCS=( CHANGELOG.md README.md )
PATCHES=( "${FILESDIR}/${P}-static-version.patch" )

EPYTEST_PLUGINS=()
distutils_enable_tests pytest
