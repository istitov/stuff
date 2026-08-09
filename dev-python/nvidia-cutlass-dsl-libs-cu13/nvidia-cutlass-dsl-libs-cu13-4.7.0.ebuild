# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=no
DISTUTILS_EXT=1
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

MY_PN=${PN//-/_}
MY_BASE="https://files.pythonhosted.org/packages"

DESCRIPTION="NVIDIA CUTLASS Python DSL — CUDA-13-specific shared libs"
HOMEPAGE="
	https://github.com/NVIDIA/cutlass
	https://pypi.org/project/nvidia-cutlass-dsl-libs-cu13/
"
SRC_URI="
	python_targets_python3_12? ( ${MY_BASE}/29/4c/1d17ab9cdc4e7494c79c60d832fabf6fcd814caaeba3ea9ea217122dd6a1/${MY_PN}-${PV}-cp312-cp312-manylinux_2_28_x86_64.whl )
	python_targets_python3_13? ( ${MY_BASE}/2f/57/6d5303dc068715863ba74f4f26480dd021a612c06a4210826448b48f8e4a/${MY_PN}-${PV}-cp313-cp313-manylinux_2_28_x86_64.whl )
	python_targets_python3_14? ( ${MY_BASE}/ef/1d/7c27b4672a3f5812efb4d7723dca604dab9dfdd4796301a0963a14edbf8f/${MY_PN}-${PV}-cp314-cp314-manylinux_2_28_x86_64.whl )
"
S="${WORKDIR}"

LICENSE="NVIDIA-CUTLASS"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="bindist mirror strip"

# Wheel-only on PyPI — CUDA-13-specific binary kernels of NVIDIA's
# CUTLASS Python DSL. Selected by the parent nvidia-cutlass-dsl when
# the cu13 extra is enabled. The wheel's dependency metadata is implemented by
# the base/core split below. # verified 2026-08-09 against 4.7.0.
RDEPEND="
	~dev-python/nvidia-cutlass-dsl-libs-base-${PV}[${PYTHON_USEDEP}]
	>=dev-python/cuda-python-12.8[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.10.0[${PYTHON_USEDEP}]
"

QA_PREBUILT="usr/lib/python3.*/site-packages/nvidia_cutlass_dsl/*"

src_unpack() {
	mkdir -p "${S}/wheel" || die
	local f
	for f in ${A}; do
		cp "${DISTDIR}/${f}" "${S}/wheel/" || die
	done
}

python_install() {
	local pyver=${EPYTHON#python}
	local cptag=cp${pyver//./}
	local whl="${MY_PN}-${PV}-${cptag}-${cptag}-manylinux_2_28_x86_64.whl"
	[[ -f ${S}/wheel/${whl} ]] || die "expected wheel ${whl} not found"
	${EPYTHON} -m installer --destdir="${D}" "${S}/wheel/${whl}" || die
	python_optimize
}
