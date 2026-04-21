# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=flit
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

MY_PN="pyqode.python"

DESCRIPTION="Python backend for pyqode - adds Python code editing support"
HOMEPAGE="
	https://github.com/pyQode/pyqode.python/
	https://pypi.org/project/pyqode.python/
"
# Upstream's 4.0.2 sdist kept the dotted filename on pypi.
SRC_URI="
	https://files.pythonhosted.org/packages/98/2e/d0dc38269c6a704c800493ed5412dba9856d6d68f2b48904e0192432c076/${MY_PN}-${PV}.tar.gz
"
S="${WORKDIR}/${MY_PN}-${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

# Upstream's metadata still names the long-renamed \`pep8\` package,
# but the actual imports (backend/workers.py, backend/pep8utils.py)
# are all against \`pycodestyle\` - the post-rename name.
RDEPEND="
	dev-python/pyqode-core[${PYTHON_USEDEP}]
	dev-python/qtawesome[${PYTHON_USEDEP}]
	dev-python/pyflakes[${PYTHON_USEDEP}]
	dev-python/autopep8[${PYTHON_USEDEP}]
	dev-python/pycodestyle[${PYTHON_USEDEP}]
	dev-python/jedi[${PYTHON_USEDEP}]
	dev-python/docutils[${PYTHON_USEDEP}]
"
