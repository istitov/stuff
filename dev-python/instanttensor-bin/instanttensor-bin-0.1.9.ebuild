# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=no
DISTUTILS_EXT=1
DISTUTILS_SINGLE_IMPL=1
# Match the Python range supported by this overlay's torch stack.
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

MY_PN=${PN%-bin}
MY_BASE="https://files.pythonhosted.org/packages"
WHL_TAIL="manylinux_2_24_x86_64.manylinux_2_28_x86_64.whl"

DESCRIPTION="Ultra-fast distributed safetensors loader for CUDA (binary wheel)"
HOMEPAGE="https://pypi.org/project/instanttensor/"
SRC_URI="
	python_single_target_python3_12? (
		${MY_BASE}/97/01/667438b2c7b9caad3be48fe1363032574bb4a85d8d90b7a6e3ddf9979f53/${MY_PN}-${PV}-cp312-cp312-${WHL_TAIL}
	)
	python_single_target_python3_13? (
		${MY_BASE}/41/90/b50182538f64d59f4711dd902e60d84cdfb55a03e72a4619121a83260f28/${MY_PN}-${PV}-cp313-cp313-${WHL_TAIL}
	)
	python_single_target_python3_14? (
		${MY_BASE}/29/7c/b5cb0ae191bac6de43ea574b7d99a33ad9e680a44741b4f13b15e5e22e2f/${MY_PN}-${PV}-cp314-cp314-${WHL_TAIL}
	)
"
S="${WORKDIR}"

# Include licenses of the statically linked libaio, liburing, Boost headers,
# pybind11, and dlpack found in the sdist's vendored third_party tree.
LICENSE="Apache-2.0 BSD Boost-1.0 LGPL-2.1 MIT"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="strip"

# Use upstream wheels until the 94 MiB vendored native stack can be unbundled.
# The extension links no torch/CUDA/NCCL libraries and late-binds accelerator
# APIs already loaded by torch, so it is not torch-minor-locked and needs no
# toolkit dependencies. Distributed calls require a supplied process group;
# callers such as vllm provide caffe2[distributed]. Verified 2026-09-09.
RDEPEND="
	>=sci-ml/pytorch-2.8.0[${PYTHON_SINGLE_USEDEP}]
	sci-ml/caffe2
"

# Manual wheel installation needs installer despite DISTUTILS_USE_PEP517=no.
BDEPEND+="
	$(python_gen_cond_dep '
		dev-python/installer[${PYTHON_USEDEP}]
	')
"

QA_PREBUILT="usr/lib*/python*/site-packages/instanttensor/*.so"

python_install() {
	local cptag=${EPYTHON#python}
	cptag=cp${cptag//./}
	local whl="${MY_PN}-${PV}-${cptag}-${cptag}-${WHL_TAIL}"
	[[ -f ${DISTDIR}/${whl} ]] || die "expected wheel ${whl} not found"
	${EPYTHON} -m installer --destdir="${D}" "${DISTDIR}/${whl}" || die
	# installer does not byte-compile.
	python_optimize
}
