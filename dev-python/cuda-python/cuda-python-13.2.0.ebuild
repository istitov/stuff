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
	https://files.pythonhosted.org/packages/4a/da/b4dbe129f941afe1c24a09ba53521b78875626763d96414798a74763282f/${MY_WHEEL}
"
S="${WORKDIR}"

LICENSE="NVIDIA-CUDA"
SLOT="0"
KEYWORDS="~amd64"
# NVIDIA-CUDA is an EULA license — distfile must not be mirrored,
# resulting binpkgs must not be redistributed.
RESTRICT="bindist mirror"

# Trivial meta-wheel — empty package whose entire purpose is to pull
# cuda-bindings + cuda-pathfinder via runtime deps. Source is just
# pyproject.toml in the cuda-python/ subdir of NVIDIA/cuda-python with
# no Python code; packaging the wheel directly is exactly equivalent
# and avoids carrying the monorepo tarball for an empty payload.
RDEPEND="
	~dev-python/cuda-bindings-${PV}[${PYTHON_USEDEP}]
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
