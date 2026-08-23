# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=no
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{12..15} )

inherit distutils-r1

MY_WHEEL="comfy_angle-${PV}-py3-none-manylinux_2_28_x86_64.whl"

DESCRIPTION="Redistributable ANGLE libraries for ComfyUI"
HOMEPAGE="
	https://github.com/Comfy-Org/comfy-angle
	https://pypi.org/project/comfy-angle/
"
SRC_URI="https://files.pythonhosted.org/packages/af/f4/5ddd0416e9619233b20e2a34c47d2359d4ac6b17a17f8bf59e0bfe5b93c3/${MY_WHEEL}"
S=${WORKDIR}

LICENSE="BSD MIT"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="strip"

BDEPEND="dev-python/installer[${PYTHON_SINGLE_USEDEP}]"

QA_PREBUILT="usr/lib/python3.*/site-packages/comfy_angle/libs/*"

src_unpack() {
	:
}

src_install() {
	${EPYTHON} -m installer --destdir="${D}" "${DISTDIR}/${MY_WHEEL}" || die
	python_optimize
}
