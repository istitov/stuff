# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=setuptools
DISTUTILS_EXT=1

inherit distutils-r1

MYPN="prismatic"
MYP="${MYPN}-${PV}"

DESCRIPTION="Python bindings for the Prismatic STEM simulation framework"
HOMEPAGE="https://prism-em.com"
SRC_URI="https://github.com/prism-em/${MYPN}/archive/refs/tags/v${PV}.tar.gz -> ${MYP}.tar.gz"
S="${WORKDIR}/${MYP}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="gpu"

RDEPEND="
	dev-libs/boost:=
	sci-libs/fftw:3.0=[threads]
	sci-libs/hdf5:=[cxx]
	$(python_gen_cond_dep '
		dev-python/numpy[${PYTHON_USEDEP}]
		dev-python/h5py[${PYTHON_USEDEP}]
		dev-python/scipy[${PYTHON_USEDEP}]
	')
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-build/cmake
	gpu? ( dev-util/nvidia-cuda-toolkit )
"

PATCHES=(
	"${FILESDIR}/${P}-cxx17-standard.patch"
	"${FILESDIR}/${P}-boost-bessel-qualify.patch"
	"${FILESDIR}/${P}-complex-literal.patch"
)

python_configure_all() {
	use gpu && DISTUTILS_ARGS=( --enable-gpu )
}
