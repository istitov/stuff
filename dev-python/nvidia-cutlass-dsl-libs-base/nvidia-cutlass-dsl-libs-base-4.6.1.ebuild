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
	python_targets_python3_12? ( ${MY_BASE}/09/df/e606ae9ea51b2dc7e8942177d9487cfb718ef819769cfe641588c976641b/${MY_PN}-${PV}-cp312-cp312-manylinux_2_28_x86_64.whl )
	python_targets_python3_13? ( ${MY_BASE}/f7/1d/e19ae692f4ed485f5026834801cd044007be6a11bd30f3dad407c1422fe5/${MY_PN}-${PV}-cp313-cp313-manylinux_2_28_x86_64.whl )
	python_targets_python3_14? ( ${MY_BASE}/c8/b5/6cf58671e7d9a9163da5fab2b171e3d30446df008635a1206ea4aca3d487/${MY_PN}-${PV}-cp314-cp314-manylinux_2_28_x86_64.whl )
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
# the CUDA toolkit. # verified 2026-07-14 against 4.6.1.
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
# metapackage wheel. # verified 2026-07-14 against 4.6.1.
install_wheel() {
	local pyver=${EPYTHON#python}
	local cptag=cp${pyver//./}
	local whl="${MY_PN}-${PV}-${cptag}-${cptag}-manylinux_2_28_x86_64.whl"
	[[ -f ${S}/wheel/${whl} ]] || die "expected wheel ${whl} not found"
	${EPYTHON} -m installer --destdir="${D}" "${S}/wheel/${whl}" || die
}
