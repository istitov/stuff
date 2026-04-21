# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Python Materials Genomics (umbrella shim over pymatgen-core)"
HOMEPAGE="
	https://github.com/materialsproject/pymatgen/
	https://pypi.org/project/pymatgen/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/pymatgen-core-2026.3.9[${PYTHON_USEDEP}]
"
