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
DEPEND="
	>=dev-python/cython-3.1.0[${PYTHON_USEDEP}]
	>=dev-python/fastrlock-0.8.1[${PYTHON_USEDEP}]
	>=dev-python/numpy-1.18.0[${PYTHON_USEDEP}]
	cuda? ( dev-util/nvidia-cuda-toolkit[profiler] )
	cudnn? ( dev-libs/cudnn )
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
		local targets=() a
		if [[ -n ${NVPTX_TARGETS} ]]; then
			targets=( ${NVPTX_TARGETS} )
		elif [[ -n ${CUDAARCHS} ]]; then
			for a in ${CUDAARCHS//[;,]/ }; do
				targets+=( "sm_${a}" )
			done
		fi

		if [[ ${#targets[@]} -gt 0 ]]; then
			local supported=() codegen=()
			local s target ok

			while IFS= read -r s; do
				supported+=( "${s}" )
			done < <(nvcc --list-gpu-code) || die

			for target in "${targets[@]}"; do
				ok=
				for s in "${supported[@]}"; do
					[[ ${s} == "${target}" ]] && ok=1 && break
				done

				if [[ -n ${ok} ]]; then
					codegen+=( "arch=${target/sm_/compute_},code=${target}" )
				else
					ewarn "Skipping unsupported CUDA target ${target} for toolkit $(cuda_toolkit_version)"
				fi
			done

			[[ ${#codegen[@]} -gt 0 ]] \
				|| die "No supported CUDA targets (from NVPTX_TARGETS/CUDAARCHS)"

			local IFS=';'
			export CUPY_NVCC_GENERATE_CODE="${codegen[*]}"
		fi

		export NVCC="nvcc ${NVCCFLAGS}"
	fi
	distutils-r1_src_compile
}
