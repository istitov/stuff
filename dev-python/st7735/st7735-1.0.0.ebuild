# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..15} )

inherit distutils-r1

DESCRIPTION="Python driver for ST7735 TFT LCD displays"
HOMEPAGE="
	https://github.com/pimoroni/st7735-python
	https://pypi.org/project/st7735/
"
SRC_URI="https://github.com/pimoroni/${PN}-python/archive/refs/tags/v${PV}.tar.gz
	-> ${P}.gh.tar.gz"
S="${WORKDIR}/${PN}-python-${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64"

RDEPEND="
	dev-libs/libgpiod[python]
	>=dev-python/gpiodevice-0.1.0[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
	>=dev-python/spidev-3.4[${PYTHON_USEDEP}]
"
BDEPEND="
	dev-python/hatch-fancy-pypi-readme[${PYTHON_USEDEP}]
	test? ( dev-python/mock[${PYTHON_USEDEP}] )
"

DOCS=( CHANGELOG.md README.md )

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

src_prepare() {
	sed -i \
		-e '/    "README.md",/d' \
		-e '/    "CHANGELOG.md",/d' \
		-e '/    "LICENSE"/d' \
		pyproject.toml || die
	distutils-r1_src_prepare
}
