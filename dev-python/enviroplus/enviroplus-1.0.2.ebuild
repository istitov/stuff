# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..15} )

inherit distutils-r1

DESCRIPTION="Python library for Pimoroni Enviro+ and Enviro Mini boards"
HOMEPAGE="
	https://github.com/pimoroni/enviroplus-python
	https://pypi.org/project/enviroplus/
"
SRC_URI="https://github.com/pimoroni/${PN}-python/archive/refs/tags/v${PV}.tar.gz
	-> ${P}.gh.tar.gz"
S="${WORKDIR}/${PN}-python-${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64"

RDEPEND="
	>=dev-libs/libgpiod-2.1.3[python]
	>=dev-python/ads1015-1.0.0[${PYTHON_USEDEP}]
	dev-python/astral[${PYTHON_USEDEP}]
	dev-python/font-roboto[${PYTHON_USEDEP}]
	dev-python/fonts[${PYTHON_USEDEP}]
	>=dev-python/gpiodevice-0.0.3[${PYTHON_USEDEP}]
	>=dev-python/ltr559-1.0.0[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/paho-mqtt[${PYTHON_USEDEP}]
	dev-python/pillow[${PYTHON_USEDEP}]
	>=dev-python/pimoroni-bme280-1.0.0[${PYTHON_USEDEP}]
	>=dev-python/pms5003-1.0.0[${PYTHON_USEDEP}]
	dev-python/pytz[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	dev-python/smbus2[${PYTHON_USEDEP}]
	dev-python/sounddevice[${PYTHON_USEDEP}]
	>=dev-python/st7735-1.0.0[${PYTHON_USEDEP}]
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

python_install_all() {
	distutils-r1_python_install_all
	dodoc -r examples
	docompress -x /usr/share/doc/${PF}/examples
}
