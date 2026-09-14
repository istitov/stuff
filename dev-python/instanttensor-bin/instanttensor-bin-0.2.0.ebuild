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
WHL_TAIL="manylinux_2_27_x86_64.manylinux_2_28_x86_64.whl"

DESCRIPTION="Ultra-fast distributed safetensors loader for CUDA (binary wheel)"
HOMEPAGE="https://pypi.org/project/instanttensor/"
SRC_URI="
	python_single_target_python3_12? (
		${MY_BASE}/f8/02/90a64c81360d473d07f36dde68eb47d043bf442a24c9c91232643f8c0928/${MY_PN}-${PV}-cp312-cp312-${WHL_TAIL}
	)
	python_single_target_python3_13? (
		${MY_BASE}/95/33/d5ed374dd804d33657813f04ec60e9f0d6e7832bb61de196ad2ea2d517d6/${MY_PN}-${PV}-cp313-cp313-${WHL_TAIL}
	)
	python_single_target_python3_14? (
		${MY_BASE}/39/b4/32d9b4bb2525d3fbbf2e476ee7ae5516e1984b6d9378559d16a105b4783e/${MY_PN}-${PV}-cp314-cp314-${WHL_TAIL}
	)
"
S="${WORKDIR}"

# Include licenses of the statically linked libaio and liburing, plus the
# atomic_queue, pybind11, and dlpack headers vendored in the sdist.
LICENSE="Apache-2.0 BSD LGPL-2.1 MIT"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="strip"

# Use upstream wheels until the vendored native stack can be unbundled.
# The extension links no torch/CUDA/NCCL libraries and late-binds accelerator
# APIs already loaded by torch, so it is not torch-minor-locked and needs no
# toolkit dependencies. Distributed calls require a supplied process group;
# callers such as vllm provide caffe2[distributed]. Verified 2026-09-14.
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
