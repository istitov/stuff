# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
DISTUTILS_USE_PEP517=no
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{12..14} )
inherit distutils-r1

MY_WHEEL="tokenspeed_mla-${PV}-py3-none-manylinux_2_28_x86_64.whl"
DESCRIPTION="TokenSpeed multi-head latent attention CUDA kernels"
HOMEPAGE="https://pypi.org/project/tokenspeed-mla/"
SRC_URI="https://files.pythonhosted.org/packages/27/df/0037ade72b165ac97859040919e006aa3d80cb8cc3a79420fb6c03eb16a0/${MY_WHEEL}"
S=${WORKDIR}
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="strip"
RDEPEND="
	$(python_gen_cond_dep '
		>=dev-python/apache-tvm-ffi-0.1.5[${PYTHON_USEDEP}]
		<=dev-python/apache-tvm-ffi-0.1.11-r0[${PYTHON_USEDEP}]
		dev-python/nvidia-cutlass-dsl[${PYTHON_USEDEP}]
	')
	>=dev-python/tokenspeed-triton-bin-3.7.10_p20260531[${PYTHON_SINGLE_USEDEP}]
	sci-ml/caffe2
"
QA_PREBUILT="usr/lib*/python*/site-packages/tokenspeed_mla/objs/*.so*"

python_install() {
	${EPYTHON} -m installer --destdir="${D}" "${DISTDIR}/${MY_WHEEL}" || die
}
