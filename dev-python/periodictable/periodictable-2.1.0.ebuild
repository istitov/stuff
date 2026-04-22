# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

DESCRIPTION="Extensible periodic table of the elements with X-ray/neutron scattering data"
HOMEPAGE="
	https://github.com/python-periodictable/periodictable
	https://pypi.org/project/periodictable/
	https://periodictable.readthedocs.io/
"
SRC_URI="https://github.com/python-periodictable/periodictable/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz"

LICENSE="public-domain BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="
	>=dev-python/pyparsing-3.0.0[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest
