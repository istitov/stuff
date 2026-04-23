# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )
# sdist has no git metadata; keep setuptools_scm happy.
export SETUPTOOLS_SCM_PRETEND_VERSION_FOR_HYPERSPYUI=${PV}

inherit distutils-r1 pypi virtualx

DESCRIPTION="Qt GUI for hyperspy - multidimensional data analysis"
HOMEPAGE="
	https://hyperspy.org/hyperspyUI/
	https://github.com/hyperspy/hyperspyUI/
	https://pypi.org/project/hyperspyUI/
"
SRC_URI="$(pypi_sdist_url)"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"
RESTRICT="!test? ( test )"

# Upstream 2.0.2 moved PyQt5 and PyQtWebEngine into an optional
# [pyqt] extra - qtpy detects whichever Qt Python binding is present
# (pyqt6/pyside6/pyqt5), so leave the Qt binding as a runtime-user
# choice rather than hard-forcing the deprecated pyqt5 stack.
RDEPEND="
	>=dev-python/autopep8-1.5.0[${PYTHON_USEDEP}]
	>=dev-python/exspy-0.3.1[${PYTHON_USEDEP}]
	>=dev-python/hyperspy-2.0[${PYTHON_USEDEP}]
	>=dev-python/hyperspy-gui-traitsui-2.0[${PYTHON_USEDEP}]
	>=dev-python/ipykernel-5.2.0[${PYTHON_USEDEP}]
	<dev-python/ipykernel-7[${PYTHON_USEDEP}]
	>=dev-python/matplotlib-3.6.1[${PYTHON_USEDEP}]
	dev-python/packaging[${PYTHON_USEDEP}]
	>=dev-python/pyface-6.0.0[${PYTHON_USEDEP}]
	dev-python/pyflakes[${PYTHON_USEDEP}]
	>=dev-python/pyqode-core-4.0.10[${PYTHON_USEDEP}]
	>=dev-python/pyqode-python-4.0.2[${PYTHON_USEDEP}]
	>=dev-python/qtconsole-5.2.0[${PYTHON_USEDEP}]
	dev-python/qtpy[${PYTHON_USEDEP}]
	dev-python/traits[${PYTHON_USEDEP}]
	>=dev-python/traitsui-5.2.0[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
BDEPEND="
	>=dev-python/setuptools-scm-8[${PYTHON_USEDEP}]
	test? (
		dev-python/pytest-qt[${PYTHON_USEDEP}]
		dev-python/pytest-timeout[${PYTHON_USEDEP}]
	)
"

EPYTEST_PLUGINS=( pytest-qt pytest-timeout )
distutils_enable_tests pytest

python_test() {
	virtx epytest
}
