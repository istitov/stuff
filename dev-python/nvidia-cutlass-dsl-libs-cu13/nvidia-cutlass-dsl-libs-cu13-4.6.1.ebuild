# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=no
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
	python_targets_python3_12? ( ${MY_BASE}/fc/b7/5fce346067727a64737666282643b048579b53df78b1f629344ff3d6a526/${MY_PN}-${PV}-cp312-cp312-manylinux_2_28_x86_64.whl )
	python_targets_python3_13? ( ${MY_BASE}/2e/59/25150c41e19e29b22df3a64e58f36d1c02a5e747e81e2313f969781412e1/${MY_PN}-${PV}-cp313-cp313-manylinux_2_28_x86_64.whl )
	python_targets_python3_14? ( ${MY_BASE}/9e/41/2cbf968ff501d4ebc0640a8eb1292fb1cef88618db3328293c091c92a5c3/${MY_PN}-${PV}-cp314-cp314-manylinux_2_28_x86_64.whl )
"
S="${WORKDIR}"

LICENSE="NVIDIA-CUDA"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="bindist mirror"

# Wheel-only on PyPI — CUDA-13-specific binary kernels of NVIDIA's
# CUTLASS Python DSL. Selected by the parent nvidia-cutlass-dsl when
# the cu13 extra is enabled (the right pick with CUDA 13.3 at
# /opt/cuda). protobuf<7 (iket profiler only) is omitted as in the base
# split; nvidia-cuda-nvdisasm is provided by the CUDA toolkit.
# # verified 2026-07-14 against 4.6.1.
RDEPEND="
	~dev-python/nvidia-cutlass-dsl-libs-base-${PV}[${PYTHON_USEDEP}]
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

install_wheel() {
	local pyver=${EPYTHON#python}
	local cptag=cp${pyver//./}
	local whl="${MY_PN}-${PV}-${cptag}-${cptag}-manylinux_2_28_x86_64.whl"
	[[ -f ${S}/wheel/${whl} ]] || die "expected wheel ${whl} not found"
	${EPYTHON} -m installer --destdir="${D}" "${S}/wheel/${whl}" || die
}
