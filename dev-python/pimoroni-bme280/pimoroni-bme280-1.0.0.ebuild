# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..15} )

inherit distutils-r1

DESCRIPTION="Python driver for BME280 temperature, pressure, and humidity sensors"
HOMEPAGE="
	https://github.com/pimoroni/bme280-python
	https://pypi.org/project/pimoroni-bme280/
"
SRC_URI="https://github.com/pimoroni/bme280-python/archive/refs/tags/v${PV}.tar.gz
	-> ${P}.gh.tar.gz"
S="${WORKDIR}/bme280-python-${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64"

RDEPEND=">=dev-python/i2cdevice-1.0.0[${PYTHON_USEDEP}]"
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
