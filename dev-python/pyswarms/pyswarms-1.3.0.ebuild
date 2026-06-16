# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="A research toolkit for particle swarm optimization in Python"
HOMEPAGE="
	https://github.com/ljvmiranda921/pyswarms
	https://pypi.org/project/pyswarms/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# The bundled test suite predates current matplotlib/numpy (e.g. imports
# the removed matplotlib.axes._subplots private API); upstream-tested.
RESTRICT="test"

RDEPEND="
	dev-python/attrs[${PYTHON_USEDEP}]
	dev-python/matplotlib[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/pyyaml[${PYTHON_USEDEP}]
	dev-python/scipy[${PYTHON_USEDEP}]
	dev-python/tqdm[${PYTHON_USEDEP}]
"

python_prepare_all() {
	# Drop the py2 past.builtins.xrange shim (→ range); avoids a runtime
	# dependency on the deprecated dev-python/future.
	sed -i \
		-e '/from past.builtins import xrange/d' \
		-e 's/\bxrange(/range(/g' \
		pyswarms/utils/search/random_search.py || die

	# find_packages(exclude=["docs","tests"]) lets the top-level tests
	# package leak into site-packages; broaden to glob patterns.
	sed -i -e 's/exclude=\["docs", "tests"\]/exclude=["docs", "docs.*", "tests", "tests.*"]/' setup.py || die
	distutils-r1_python_prepare_all
}
