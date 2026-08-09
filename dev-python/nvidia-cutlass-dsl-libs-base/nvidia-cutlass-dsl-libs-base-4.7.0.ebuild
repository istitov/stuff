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
	python_targets_python3_12? ( ${MY_BASE}/08/97/896495b02ec87fd19372f3e5245be12e301651f610b6ec7408bc7e562426/${MY_PN}-${PV}-cp312-cp312-manylinux_2_28_x86_64.whl )
	python_targets_python3_13? ( ${MY_BASE}/c1/eb/39d8840899487ea897201e4706575254a8b485f3b1e2f899edbb0b89ee9b/${MY_PN}-${PV}-cp313-cp313-manylinux_2_28_x86_64.whl )
	python_targets_python3_14? ( ${MY_BASE}/2c/0f/ea0e737d970d5eae072e3da5d89f7307f8f9bbe45305c4d7c4a9226c9276/${MY_PN}-${PV}-cp314-cp314-manylinux_2_28_x86_64.whl )
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
# verified 2026-08-09 against 4.7.0.
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
# metapackage wheel. # verified 2026-08-09 against 4.7.0.
python_install() {
	local pyver=${EPYTHON#python}
	local cptag=cp${pyver//./}
	local whl="${MY_PN}-${PV}-${cptag}-${cptag}-manylinux_2_28_x86_64.whl"
	[[ -f ${S}/wheel/${whl} ]] || die "expected wheel ${whl} not found"
	${EPYTHON} -m installer --destdir="${D}" "${S}/wheel/${whl}" || die
	python_optimize
}
