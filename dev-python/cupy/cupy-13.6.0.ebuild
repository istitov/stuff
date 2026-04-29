# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1 prefix pypi cuda

DESCRIPTION="CuPy: A NumPy-compatible array library accelerated by CUDA"
HOMEPAGE="https://cupy.dev/"
SRC_URI="$(pypi_sdist_url "${PN^}" "${PV}")"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

IUSE="+cuda cudnn cusparselt"
REQUIRED_USE="
	cudnn? ( cuda )
	cusparselt? ( cuda )
"
# cupy 13.x's bundled cudnn module rejects cuDNN >=9 at build time
# ("WARNING: cuDNN <=v8970 is required" — see cupy_setup_build.py).
# Pin <dev-libs/cudnn-9 so the dep is unsatisfiable when a newer
# cuDNN is on the system, instead of silently building a no-op stub.
DEPEND="
	>=dev-python/cython-3.1.0[${PYTHON_USEDEP}]
	>=dev-python/fastrlock-0.8.1[${PYTHON_USEDEP}]
	>=dev-python/numpy-1.22[${PYTHON_USEDEP}]
	cuda? ( dev-util/nvidia-cuda-toolkit[profiler] )
	cudnn? ( <dev-libs/cudnn-9 )
	cusparselt? ( dev-libs/cusparselt )
"
RDEPEND="${DEPEND}"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

src_prepare() {
	default
	eprefixify cupy/cuda/compiler.py
	use cuda && cuda_src_prepare
}

src_compile() {
	if use cuda; then
		local target
		for target in ${NVPTX_TARGETS}; do
			CUPY_NVCC_GENERATE_CODE+="arch=${target/sm/compute},code=${target};"
		done
		export CUPY_NVCC_GENERATE_CODE
		export NVCC="nvcc ${NVCCFLAGS}"
	fi
	distutils-r1_src_compile
}
