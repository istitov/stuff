# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{11..14} )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1 pypi

DESCRIPTION="QuACK attention kernels for vLLM/FlashInfer (cute-DSL based)"
HOMEPAGE="
	https://github.com/Dao-AILab/quack
	https://pypi.org/project/quack-kernels/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

# Pure-Python; the kernels themselves are JIT-compiled at first use
# via apache-tvm-ffi + nvidia-cutlass-dsl. Upstream's cu13 extra
# selects the matching cutlass-dsl[cu13] sub-libs which we already
# pull via dev-python/nvidia-cutlass-dsl on this overlay; no USE
# flag needed. # verified 2026-05-07 against 0.3.3.
RDEPEND="
	dev-python/torch-c-dlpack-ext[${PYTHON_SINGLE_USEDEP}]
	sci-ml/pytorch[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		>=dev-python/nvidia-cutlass-dsl-4.4.2[${PYTHON_USEDEP}]
		>=dev-python/apache-tvm-ffi-0.1.6[${PYTHON_USEDEP}]
		<dev-python/apache-tvm-ffi-0.2[${PYTHON_USEDEP}]
		dev-python/einops[${PYTHON_USEDEP}]
	')
"
DEPEND="${RDEPEND}"
