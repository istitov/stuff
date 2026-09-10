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
	https://files.pythonhosted.org/packages/38/31/7ff3f7768eded7535c621abc2fecb9d181a34ea4cae3afe682feb796f242/${MY_WHEEL}
"
S="${WORKDIR}"

LICENSE="NVIDIA-CUDA"
SLOT="0"
KEYWORDS="~amd64"
# The NVIDIA EULA forbids mirroring and binary redistribution.
RESTRICT="bindist mirror"

# Install the empty metadata wheel instead of fetching the monorepo; its sole
# purpose is to pull the CUDA Python components.
RDEPEND="
	~dev-python/cuda-bindings-${PV}[${PYTHON_USEDEP}]
	dev-python/cuda-core[${PYTHON_USEDEP}]
	dev-python/cuda-pathfinder[${PYTHON_USEDEP}]
"

src_unpack() {
	mkdir -p "${S}/wheel" || die
	cp "${DISTDIR}/${MY_WHEEL}" "${S}/wheel/" || die
}

src_install() {
	python_foreach_impl install_wheel
}

install_wheel() {
	${EPYTHON} -m installer --destdir="${D}" "${S}/wheel/${MY_WHEEL}" || die
}
