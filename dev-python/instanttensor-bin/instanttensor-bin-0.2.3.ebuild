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
		${MY_BASE}/76/64/bd16cb37abc2b35b06e7737596bf43b413fb98780bda0974425b6726d4a7/${MY_PN}-${PV}-cp312-cp312-${WHL_TAIL}
	)
	python_single_target_python3_13? (
		${MY_BASE}/d9/8f/0dfea93920a2c97f9e318c169e50b5cefd95782bd79f7896fe1b44ce2811/${MY_PN}-${PV}-cp313-cp313-${WHL_TAIL}
	)
	python_single_target_python3_14? (
		${MY_BASE}/26/d5/1b4cad78dd5ba9eadf581688c507f3ff6b9e0aaca0edf34c38c863787948/${MY_PN}-${PV}-cp314-cp314-${WHL_TAIL}
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
