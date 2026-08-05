# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..15} )

inherit distutils-r1 pypi

DESCRIPTION="Support library of the Open Reflectometry Standards Organization (ORSO)"
HOMEPAGE="
	https://github.com/reflectivity/orsopy
	https://pypi.org/project/orsopy/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

RDEPEND="
	dev-python/h5py[${PYTHON_USEDEP}]
	dev-python/jsonschema[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/pint[${PYTHON_USEDEP}]
	>=dev-python/pyyaml-5.4.1[${PYTHON_USEDEP}]
"

EPYTEST_PLUGINS=()
EPYTEST_IGNORE=(
	orsopy/fileio/tests/test_model_language.py
)
EPYTEST_DESELECT=(
	orsopy/slddb/tests/test_webapi.py::TestWebAPI
)

distutils_enable_tests pytest
