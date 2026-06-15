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
	python_targets_python3_12? ( ${MY_BASE}/03/60/443e559139da15ab544761ac14f4206dffb981af48cc9856cd5b5b7cf0e7/${MY_PN}-${PV}-cp312-cp312-manylinux_2_28_x86_64.whl )
	python_targets_python3_13? ( ${MY_BASE}/5c/9f/b7928ff505e577c1021c07b206ce32d285aae793763d524023c1800b6dc9/${MY_PN}-${PV}-cp313-cp313-manylinux_2_28_x86_64.whl )
	python_targets_python3_14? ( ${MY_BASE}/aa/83/d335575e1d37f6c436b1e3203ded6f352678937b9f30b900b643f9df0f9d/${MY_PN}-${PV}-cp314-cp314-manylinux_2_28_x86_64.whl )
"
S="${WORKDIR}"

LICENSE="NVIDIA-CUDA"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="bindist mirror"

# Wheel-only on PyPI — CUDA-13-specific binary kernels of NVIDIA's
# CUTLASS Python DSL. Selected by the parent nvidia-cutlass-dsl when
# the cu13 extra is enabled (the right pick with CUDA 13.2 at
# /opt/cuda). # verified 2026-05-25 against 4.5.2.
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
