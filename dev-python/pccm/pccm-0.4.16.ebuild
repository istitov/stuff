# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{11..14} )

inherit distutils-r1 pypi

DESCRIPTION="Python C++ code manager (codegen used by cumm/spconv)"
HOMEPAGE="
	https://github.com/FindDefinition/PCCM
	https://pypi.org/project/pccm/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

# Upstream also lists 'fire' (a CLI framework), used only by pccm's command-line
# entry points -- not when cumm/spconv import generated code at runtime.
# verified 2026-06-17
RDEPEND="
	dev-python/ccimport[${PYTHON_USEDEP}]
	dev-python/lark[${PYTHON_USEDEP}]
	dev-python/portalocker[${PYTHON_USEDEP}]
	dev-python/pybind11[${PYTHON_USEDEP}]
"

src_prepare() {
	# Upstream's sdist omits version.txt (a source-tree build artifact) yet
	# setup.py reads it because the VERSION constant is left unset. Recreate it.
	echo "${PV}" > version.txt || die
	distutils-r1_src_prepare
}
