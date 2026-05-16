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
	python_targets_python3_12? ( ${MY_BASE}/29/b8/c70356a84a7bea64a66490097920539f76843a2bc869640ac30efededc8d/${MY_PN}-${PV}-cp312-cp312-manylinux_2_28_x86_64.whl )
	python_targets_python3_13? ( ${MY_BASE}/2b/ce/f29fcd03f57331dd49859c8777b37720af083ee9d487a62da08cf2b7c115/${MY_PN}-${PV}-cp313-cp313-manylinux_2_28_x86_64.whl )
	python_targets_python3_14? ( ${MY_BASE}/dd/e5/e3951e454c1e3cc39403cd99afd3284eed5cff3b811a7a908ce223bab152/${MY_PN}-${PV}-cp314-cp314-manylinux_2_28_x86_64.whl )
"
S="${WORKDIR}"

LICENSE="NVIDIA-CUDA"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="bindist mirror"

# Wheel-only on PyPI — CUDA-13-specific binary kernels of NVIDIA's
# CUTLASS Python DSL. Selected by the parent nvidia-cutlass-dsl when
# the cu13 extra is enabled (which we want on this host: CUDA 13.2 at
# /opt/cuda). # verified 2026-05-07 against 4.5.0.
RDEPEND="
	~dev-python/nvidia-cutlass-dsl-libs-base-${PV}[${PYTHON_USEDEP}]
	dev-python/cuda-python[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/typing-extensions[${PYTHON_USEDEP}]
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
