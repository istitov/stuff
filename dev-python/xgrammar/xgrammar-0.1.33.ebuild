# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=scikit-build-core
PYTHON_COMPAT=( python3_{11..14} )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1 pypi

DESCRIPTION="Efficient, flexible structured generation engine for LLMs"
HOMEPAGE="
	https://xgrammar.mlc.ai/
	https://github.com/mlc-ai/xgrammar
	https://pypi.org/project/xgrammar/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

# vllm pins >=0.1.32, <1.0.0; we ship 0.1.33 because 0.1.34+ added a
# hard dep on apache-tvm-ffi (TVM's FFI shim) which isn't packaged.
RDEPEND="
	>=sci-ml/pytorch-1.10.0[${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/transformers-4.38.0[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		dev-python/pydantic[${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
		>=dev-python/typing-extensions-4.9.0[${PYTHON_USEDEP}]
	')
"
BDEPEND="
	>=dev-build/cmake-3.18
	$(python_gen_cond_dep '
		>=dev-python/nanobind-2.5.0[${PYTHON_USEDEP}]
	')
"
