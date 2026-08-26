# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=no
DISTUTILS_EXT=1
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

MY_PN=${PN//-/_}
MY_BASE="https://files.pythonhosted.org/packages"

DESCRIPTION="NVIDIA CUTLASS Python DSL — base shared libs"
HOMEPAGE="
	https://github.com/NVIDIA/cutlass
	https://pypi.org/project/nvidia-cutlass-dsl-libs-base/
"
SRC_URI="
	python_targets_python3_12? ( ${MY_BASE}/55/b5/af332a4dbb0dba45828994d9789d1969dfecca006a6221cd8b92e4825d3f/${MY_PN}-${PV}-cp312-cp312-manylinux_2_28_x86_64.whl )
	python_targets_python3_13? ( ${MY_BASE}/da/cd/14545cf33b22a0ddeaa7486d49fdfe278d1fd95e0c9ab3e3e5c8202044ab/${MY_PN}-${PV}-cp313-cp313-manylinux_2_28_x86_64.whl )
	python_targets_python3_14? ( ${MY_BASE}/6e/95/e1a150a9c212ed59e3b4726171cbda746b4f6bfc1a7a9e0b2ec7c1d4749f/${MY_PN}-${PV}-cp314-cp314-manylinux_2_28_x86_64.whl )
"
S="${WORKDIR}"

LICENSE="NVIDIA-CUTLASS"
SLOT="0"
KEYWORDS="-* ~amd64"
# The CUTLASS EULA prohibits redistributing the binary payload.
RESTRICT="bindist mirror strip"

# Wheel-only on PyPI (binary CUDA-shared bits with no source release).
# Sub-package of the nvidia-cutlass-dsl umbrella. 4.6.0 split the
# pure-Python core into ~libs-core (pulled below). The generated iket profiler
# module is the sole protobuf importer. It works with protobuf 7.35.1, so keep
# upstream's lower bound while relaxing its unnecessary <7 cap. Upstream's
# nvidia-cuda-nvdisasm wheel dep is satisfied by the system CUDA toolkit that
# ~libs-core pulls in.
# verified 2026-08-26 against 4.7.1.
RDEPEND="
	~dev-python/nvidia-cutlass-dsl-libs-core-${PV}[${PYTHON_USEDEP}]
	>=dev-python/cuda-python-12.8[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
	>=dev-python/protobuf-6.30.2[${PYTHON_USEDEP}]
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

# 4.6.0 restructured the split: this wheel ships only the generic
# nvidia_cutlass_dsl/dsl_packages/{cutlass,iket} bits and the sibling
# cu13 wheel ships only nvidia_cutlass_dsl/cu13/* plus its one
# CUDA-13 _cutlass_ir.cu13*.so. The two file sets are now disjoint
# (0 overlap; was ~179 shared paths through 4.5.2), so the old
# keep-only-unique dedup is gone. The `import cutlass` path is set up
# by nvidia_cutlass_dsl_packages.pth, now shipped by the parent
# metapackage wheel. # verified 2026-08-26 against 4.7.1.
python_install() {
	local pyver=${EPYTHON#python}
	local cptag=cp${pyver//./}
	local whl="${MY_PN}-${PV}-${cptag}-${cptag}-manylinux_2_28_x86_64.whl"
	[[ -f ${S}/wheel/${whl} ]] || die "expected wheel ${whl} not found"
	${EPYTHON} -m installer --destdir="${D}" "${S}/wheel/${whl}" || die
	python_optimize
}
