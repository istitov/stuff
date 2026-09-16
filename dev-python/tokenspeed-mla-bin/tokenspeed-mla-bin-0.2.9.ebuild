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
SRC_URI="https://files.pythonhosted.org/packages/7a/7f/db76a861e1b79d9d74a4368f647a9bbdaec1a90597283bb53046011cbd09/${MY_WHEEL}"
S=${WORKDIR}
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
RDEPEND="
	$(python_gen_cond_dep '
		>=dev-python/apache-tvm-ffi-0.1.13_p3[${PYTHON_USEDEP}]
		<=dev-python/apache-tvm-ffi-0.1.13_p3-r0[${PYTHON_USEDEP}]
		dev-python/nvidia-cutlass-dsl[${PYTHON_USEDEP}]
	')
	>=dev-python/tokenspeed-triton-bin-3.8.10_p20260906[${PYTHON_SINGLE_USEDEP}]
	sci-ml/caffe2
"
python_install() {
	${EPYTHON} -m installer --destdir="${D}" "${DISTDIR}/${MY_WHEEL}" || die
	python_optimize
}
