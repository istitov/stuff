# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1 pypi virtualx

DESCRIPTION="Qt-based plotting GUI for PyVista (background plotter, scientific viewers)"
HOMEPAGE="
	https://github.com/pyvista/pyvistaqt
	https://pypi.org/project/pyvistaqt/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=dev-python/pyvista-0.43.7[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		>=dev-python/qtpy-1.9.0[${PYTHON_USEDEP},opengl,widgets]
	')
"
BDEPEND="
	$(python_gen_cond_dep '
		dev-python/setuptools-scm[${PYTHON_USEDEP}]
	')
"

export SETUPTOOLS_SCM_PRETEND_VERSION=${PV}

PATCHES=( "${FILESDIR}/${P}-no-refleak.patch" )

EPYTEST_PLUGINS=( pytest-cov pytest-qt )
EPYTEST_DESELECT=(
	# VTK probes the DRM device and exits the process when no usable render
	# device is available, even with Xvfb and Mesa's software renderer.
	tests/test_plotting.py::test_depth_peeling
)

distutils_enable_tests pytest

src_test() {
	virtx distutils-r1_src_test
}

python_test() {
	# pytest-qt otherwise may import a different binding before QtPy chooses
	# one, which aborts the process when more than one binding is installed.
	local -x QT_API
	QT_API=$("${EPYTHON}" -c 'import qtpy; print(qtpy.API)') || die
	local -x PYTEST_QT_API=${QT_API}

	epytest
}
