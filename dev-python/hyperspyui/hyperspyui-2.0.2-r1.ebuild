# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )
# Pin the version without Git metadata.
export SETUPTOOLS_SCM_PRETEND_VERSION_FOR_HYPERSPYUI=${PV}

inherit distutils-r1 pypi virtualx

PATCHES=(
	"${FILESDIR}/${P}-optional-qtwebengine.patch"
)

DESCRIPTION="Qt GUI for hyperspy - multidimensional data analysis"
HOMEPAGE="
	https://hyperspy.org/hyperspyUI/
	https://github.com/hyperspy/hyperspyUI/
	https://pypi.org/project/hyperspyUI/
"
SRC_URI="$(pypi_sdist_url)"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="test"
RESTRICT="!test? ( test )"

# Avoid deprecated PyQt5 WebEngine: qtpy[gui,widgets] runs the main app, while
# the patched EELSDB plugin disables itself without WebEngine. Users may add
# pyqt6-webengine. reported 2026-05-14
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
	dev-python/qtpy[${PYTHON_USEDEP},gui,widgets]
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
