# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=meson-python
DISTUTILS_EXT=1
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Library for X-ray matter interaction cross sections (Python bindings)"
HOMEPAGE="
	https://github.com/tschoonj/xraylib
	https://pypi.org/project/xraylib/
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	dev-python/numpy[${PYTHON_USEDEP}]
"
BDEPEND="
	dev-lang/swig
	dev-python/cython[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
"

# The PyPI sdist bakes its meson setup args into pyproject.toml
# ([tool.meson-python.args]): the C library is built static and only the
# classic + numpy Python bindings are installed (Fortran disabled).
#
# 4.3.0 dropped the need for the 4.2.x meson-install-tag-scalar patch:
# upstream now passes scalar install_tag on both extension_module targets
# and a matching 2-element array on the 2-output SWIG custom_target, all
# valid under Meson 1.11's tightened install_tag rules.
