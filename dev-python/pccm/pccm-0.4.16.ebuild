# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Python C++ code manager (codegen used by cumm/spconv)"
HOMEPAGE="
	https://github.com/FindDefinition/PCCM
	https://pypi.org/project/pccm/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# fire is used only by installed pccm/main.py, not the cumm/spconv import path;
# declare it so every installed module remains importable. verified 2026-07-27
RDEPEND="
	dev-python/ccimport[${PYTHON_USEDEP}]
	dev-python/fire[${PYTHON_USEDEP}]
	dev-python/lark[${PYTHON_USEDEP}]
	dev-python/portalocker[${PYTHON_USEDEP}]
	dev-python/pybind11[${PYTHON_USEDEP}]
"

src_prepare() {
	# Recreate version.txt, omitted from the sdist but required by setup.py.
	echo "${PV}" > version.txt || die
	distutils-r1_src_prepare
}
