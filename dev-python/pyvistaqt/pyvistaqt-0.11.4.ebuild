# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{11..14} )

inherit distutils-r1 pypi

DESCRIPTION="Qt-based plotting GUI for PyVista (background plotter, scientific viewers)"
HOMEPAGE="
	https://github.com/pyvista/pyvistaqt
	https://pypi.org/project/pyvistaqt/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="
	>=dev-python/pyvista-0.39.0[${PYTHON_USEDEP}]
	>=dev-python/qtpy-1.9.0[${PYTHON_USEDEP}]
"
BDEPEND="
	dev-python/setuptools-scm[${PYTHON_USEDEP}]
"

export SETUPTOOLS_SCM_PRETEND_VERSION=${PV}

EPYTEST_PLUGINS=()

distutils_enable_tests pytest
