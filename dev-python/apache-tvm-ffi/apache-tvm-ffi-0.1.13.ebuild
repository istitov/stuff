# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=scikit-build-core
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Lightweight, framework-agnostic FFI module from Apache TVM"
HOMEPAGE="
	https://github.com/apache/tvm-ffi
	https://pypi.org/project/apache-tvm-ffi/
"

LICENSE="Apache-2.0 BSD"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/typing-extensions-4.5[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
BDEPEND="
	app-alternatives/ninja
	>=dev-build/cmake-3.26
	>=dev-python/cython-3.2.8[${PYTHON_USEDEP}]
	>=dev-python/scikit-build-core-0.10[${PYTHON_USEDEP}]
	>=dev-python/setuptools-scm-8[${PYTHON_USEDEP}]
	test? (
		dev-python/ml-dtypes[${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
		dev-python/packaging[${PYTHON_USEDEP}]
	)
"

EPYTEST_PLUGINS=( pytest-xdist )
distutils_enable_tests pytest

# Upstream's pyproject.toml [tool.scikit-build] sets a cmake.args list
# that includes -DTVM_FFI_BUILD_PYTHON_MODULE=ON. The Gentoo PEP517
# helper writes its own --config-json with cmake.args, which replaces
# the pyproject.toml value, so the option falls back to its CMakeLists
# default (OFF) and the cython core extension is skipped, leaving an
# unimportable installed package. Re-pass the option via DISTUTILS_ARGS
# so it survives the override. The 0.1.13 sdist uses the same configuration.
DISTUTILS_ARGS=(
	-DTVM_FFI_BUILD_PYTHON_MODULE=ON
)
