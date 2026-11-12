# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
DISTUTILS_USE_PEP517=no
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{12..14} )
inherit distutils-r1

MY_WHEEL="tokenspeed_mla-${PV}-py3-none-any.whl"
DESCRIPTION="TokenSpeed multi-head latent attention CUDA kernels"
HOMEPAGE="https://pypi.org/project/tokenspeed-mla/"
SRC_URI="https://files.pythonhosted.org/packages/21/20/d94c86610689c10e00a3fae15324ebecd69c9a5df31d98307bf83b39b927/${MY_WHEEL}"
S=${WORKDIR}
# Portions derive from CUTLASS (BSD-3-Clause) and FlashInfer (Apache-2.0),
# per the wheel's THIRDPARTYNOTICES. verified 2026-11-05
LICENSE="MIT Apache-2.0 BSD"
SLOT="0"
KEYWORDS="~amd64"
RDEPEND="
	$(python_gen_cond_dep '
		>=dev-python/apache-tvm-ffi-0.1.11[${PYTHON_USEDEP}]
		<dev-python/apache-tvm-ffi-0.2[${PYTHON_USEDEP}]
		>=dev-python/nvidia-cutlass-dsl-4.8.0[${PYTHON_USEDEP}]
	')
	>=dev-python/tokenspeed-triton-bin-3.9.10_p20261028[${PYTHON_SINGLE_USEDEP}]
	sci-ml/pytorch[${PYTHON_SINGLE_USEDEP}]
"
BDEPEND="
	$(python_gen_cond_dep '
		dev-python/installer[${PYTHON_USEDEP}]
	')
"
python_install() {
	${EPYTHON} -m installer --destdir="${D}" "${DISTDIR}/${MY_WHEEL}" || die
	python_optimize
}
