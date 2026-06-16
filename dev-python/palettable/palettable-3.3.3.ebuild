# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Color palettes for Python"
HOMEPAGE="
	https://jiffyclub.github.io/palettable/
	https://github.com/jiffyclub/palettable/
	https://pypi.org/project/palettable/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

src_prepare() {
	# Upstream's [tool.setuptools.packages.find] doesn't exclude
	# top-level scripts/, test/, docs/ (none are real Python packages
	# but find_packages() picks them up alongside palettable/).
	rm -r scripts test docs || die
	distutils-r1_src_prepare
}
