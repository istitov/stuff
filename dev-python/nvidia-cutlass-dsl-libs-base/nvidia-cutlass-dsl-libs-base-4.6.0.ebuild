# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=no
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
	python_targets_python3_12? ( ${MY_BASE}/ce/38/e91f66739d2f8711d1a2457e68cd86d6fbae307ce66ce270a405d4dc6dc7/${MY_PN}-${PV}-cp312-cp312-manylinux_2_28_x86_64.whl )
	python_targets_python3_13? ( ${MY_BASE}/7f/67/6c21b2d140bbd1ad94a2e22a0e2881457f9e363bdff1b35898a2d7d25aa2/${MY_PN}-${PV}-cp313-cp313-manylinux_2_28_x86_64.whl )
	python_targets_python3_14? ( ${MY_BASE}/81/f3/72b53467741043e45a2d776485753b37bca6a3466d9964a75aaccccd82db/${MY_PN}-${PV}-cp314-cp314-manylinux_2_28_x86_64.whl )
"
S="${WORKDIR}"

LICENSE="NVIDIA-CUDA"
SLOT="0"
KEYWORDS="-* ~amd64"
# NVIDIA-CUDA is an EULA license; distfiles must not be mirrored,
# binpkgs must not be redistributed.
RESTRICT="bindist mirror"

# Wheel-only on PyPI (binary CUDA-shared bits with no source release).
# Sub-package of the nvidia-cutlass-dsl umbrella. 4.6.0 split the
# pure-Python core into ~libs-core (pulled below). protobuf<7 is declared
# upstream but only used by the iket perfetto profiler (perfetto_trace_pb2.py
# ships here), which this overlay does not use; omitted to avoid a
# system-wide protobuf 7->6 downgrade. nvidia-cuda-nvdisasm is provided by
# the CUDA toolkit. # verified 2026-07-04 against 4.6.0.
RDEPEND="
	~dev-python/nvidia-cutlass-dsl-libs-core-${PV}[${PYTHON_USEDEP}]
	dev-python/cuda-python[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/typing-extensions[${PYTHON_USEDEP}]
	>=dev-util/nvidia-cuda-toolkit-13.3
"

QA_PREBUILT="usr/lib/python3.*/site-packages/nvidia_cutlass_dsl/*"

src_unpack() {
	mkdir -p "${S}/wheel" || die
	local f
	for f in ${A}; do
		cp "${DISTDIR}/${f}" "${S}/wheel/" || die
	done
}

src_install() {
	python_foreach_impl install_wheel
}

# 4.6.0 restructured the split: this wheel ships only the generic
# nvidia_cutlass_dsl/dsl_packages/{cutlass,iket} bits and the sibling
# cu13 wheel ships only nvidia_cutlass_dsl/cu13/* plus its one
# CUDA-13 _cutlass_ir.cu13*.so. The two file sets are now disjoint
# (0 overlap; was ~179 shared paths through 4.5.2), so the old
# keep-only-unique dedup is gone. The `import cutlass` path is set up
# by nvidia_cutlass_dsl_packages.pth, now shipped by the parent
# metapackage wheel. # verified 2026-07-04 against 4.6.0.
install_wheel() {
	local pyver=${EPYTHON#python}
	local cptag=cp${pyver//./}
	local whl="${MY_PN}-${PV}-${cptag}-${cptag}-manylinux_2_28_x86_64.whl"
	[[ -f ${S}/wheel/${whl} ]] || die "expected wheel ${whl} not found"
	${EPYTHON} -m installer --destdir="${D}" "${S}/wheel/${whl}" || die
}
