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
KEYWORDS="~amd64"

# fire is reached only through pccm/main.py: __init__.py imports builder,
# core, middlewares and targets, and upstream ships an empty console_scripts
# list, so nothing cumm/spconv import at runtime touches it. Declared anyway,
# because main.py is installed and does a module-level `import fire` - leaving
# it out ships a module that cannot be imported. dev-python/fire carries the
# same PYTHON_COMPAT, so this costs no targets. verified 2026-07-27
RDEPEND="
	dev-python/ccimport[${PYTHON_USEDEP}]
	dev-python/fire[${PYTHON_USEDEP}]
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
