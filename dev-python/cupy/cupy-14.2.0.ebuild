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

IUSE="+cuda"
# CuPy 14 moved cuDNN, cuSPARSELt, and cuTENSOR integrations to separate
# distributions; this core package follows its NumPy and CUDA-pathfinder bounds.
DEPEND="
	>=dev-python/numpy-2.0[${PYTHON_USEDEP}]
	<dev-python/numpy-2.6[${PYTHON_USEDEP}]
	cuda? (
		dev-util/nvidia-cuda-toolkit[profiler]
		>=dev-python/cuda-pathfinder-1.3.4[${PYTHON_USEDEP}]
		<dev-python/cuda-pathfinder-2[${PYTHON_USEDEP}]
	)
"
RDEPEND="${DEPEND}"
BDEPEND="
	>=dev-python/setuptools-77[${PYTHON_USEDEP}]
	dev-python/wheel[${PYTHON_USEDEP}]
	>=dev-python/cython-3.2[${PYTHON_USEDEP}]
	<dev-python/cython-3.3[${PYTHON_USEDEP}]
"

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
