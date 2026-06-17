# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=no
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_13 )

inherit distutils-r1

MY_PN="${PN/-/_}"
DESCRIPTION="CUDA matrix multiply codegen library (prebuilt cu126 wheel)"
HOMEPAGE="
	https://github.com/FindDefinition/cumm
	https://pypi.org/project/cumm-cu126/
"
# Prebuilt manylinux CUDA-12.6 wheel; bundles its own compiled CUDA kernels and
# loads the CUDA runtime at import. Verified to run on a CUDA-13.3 host with the
# backward-compatible driver. 0.7.x because spconv-cu126 caps cumm at <0.8.0.
SRC_URI="
	https://files.pythonhosted.org/packages/98/e3/361e39619ad4323fa0e570e83032819f0d32b64b6a8832d0adc83c8c49ba/${MY_PN}-${PV}-cp313-cp313-manylinux_2_28_x86_64.whl
"
S="${WORKDIR}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="bindist mirror strip"

QA_PREBUILT="usr/lib/python3.*/site-packages/cumm/*"

# Upstream also lists 'fire' and 'sympy'; neither is imported when spconv loads
# cumm's prebuilt GEMM kernels at runtime. verified 2026-06-17
RDEPEND="
	$(python_gen_cond_dep '
		dev-python/pccm[${PYTHON_USEDEP}]
		dev-python/pybind11[${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
	')
"

src_unpack() {
	cp "${DISTDIR}/${A}" "${WORKDIR}/" || die
}

src_compile() { :; }

src_install() {
	python_setup
	"${EPYTHON}" -m installer --destdir="${D}" "${WORKDIR}/${A}" || die
	python_optimize
}
