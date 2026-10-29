# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
DISTUTILS_USE_PEP517=no
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{12..14} )
inherit distutils-r1

MY_PV=${PV/_p/.post}
MY_WHEEL="tokenspeed_triton-${MY_PV}-cp312-abi3-manylinux_2_27_x86_64.manylinux_2_28_x86_64.whl"
DESCRIPTION="TokenSpeed Triton compiler and language runtime"
HOMEPAGE="https://pypi.org/project/tokenspeed-triton/"
SRC_URI="https://files.pythonhosted.org/packages/98/87/a42554a9f36a321eee01b98cb6195a1424b1dd3c01b9fca13a61590988c6/${MY_WHEEL}"
S=${WORKDIR}
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="strip"
QA_PREBUILT="usr/lib*/python*/site-packages/tokenspeed_triton/*/*.so*"

BDEPEND+="
	$(python_gen_cond_dep '
		dev-python/installer[${PYTHON_USEDEP}]
	')
"

python_install() {
	${EPYTHON} -m installer --destdir="${D}" "${DISTDIR}/${MY_WHEEL}" || die
}
