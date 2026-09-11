# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=no
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

MY_WHEEL="${PN//-/_}-${PV}-py3-none-any.whl"

DESCRIPTION="Metapackage pulling cuda-bindings and cuda-pathfinder"
HOMEPAGE="
	https://github.com/NVIDIA/cuda-python
	https://nvidia.github.io/cuda-python/
	https://pypi.org/project/cuda-python/
"
SRC_URI="
	https://files.pythonhosted.org/packages/67/83/34e195ac04461f021eb6f25e962c5d4633903a1d67f3d6f29b8bff218fe0/${MY_WHEEL}
"
S="${WORKDIR}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
# Install the empty metadata wheel instead of fetching the monorepo; its sole
# purpose is to pull the CUDA Python components.
RDEPEND="
	~dev-python/cuda-bindings-${PV}[${PYTHON_USEDEP}]
	>=dev-python/cuda-core-1.2.0[${PYTHON_USEDEP}]
	<dev-python/cuda-core-1.3[${PYTHON_USEDEP}]
	>=dev-python/cuda-pathfinder-1.1[${PYTHON_USEDEP}]
	<dev-python/cuda-pathfinder-2[${PYTHON_USEDEP}]
"

src_unpack() {
	mkdir -p "${S}/wheel" || die
	cp "${DISTDIR}/${MY_WHEEL}" "${S}/wheel/" || die
}

python_install() {
	${EPYTHON} -m installer --destdir="${D}" "${S}/wheel/${MY_WHEEL}" || die
}
