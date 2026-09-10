# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=meson-python

inherit distutils-r1 pypi

MY_PV="${PV/_rc/rc}"

DESCRIPTION="Python packages collection for synchrotron data manipulation"
HOMEPAGE="http://www.silx.org/"
SRC_URI="$(pypi_sdist_url "${PN}" "${MY_PV}")"
S="${WORKDIR}/${PN}-${MY_PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="gui h5pyd opencl"
REQUIRED_USE="gui? ( opencl )"

# Mirror core requirements and map upstream's opencl, GUI, and h5pyd extras to
# USE flags. filelock became mandatory in 3.1. verified 2026-08-19
RDEPEND="
	dev-python/fabio[${PYTHON_USEDEP}]
	dev-python/filelock[${PYTHON_USEDEP}]
	>=dev-python/h5py-3[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/packaging[${PYTHON_USEDEP}]
	>=dev-python/pydantic-2[${PYTHON_USEDEP}]
	h5pyd? ( >=dev-python/h5pyd-0.20.0[${PYTHON_USEDEP}] )
	opencl? (
		dev-python/mako[${PYTHON_USEDEP}]
		dev-python/pyopencl[${PYTHON_USEDEP}]
	)
	gui? (
		dev-python/hdf5plugin[${PYTHON_USEDEP}]
		>=dev-python/matplotlib-3.6[${PYTHON_USEDEP}]
		dev-python/pillow[${PYTHON_USEDEP}]
		dev-python/pint[${PYTHON_USEDEP}]
		dev-python/pooch[${PYTHON_USEDEP}]
		dev-python/pyopengl[${PYTHON_USEDEP}]
		>=dev-python/pyside-6.5:6[${PYTHON_USEDEP}]
		dev-python/python-dateutil[${PYTHON_USEDEP}]
		dev-python/qtawesome[${PYTHON_USEDEP}]
		dev-python/qtconsole[${PYTHON_USEDEP}]
		dev-python/scipy[${PYTHON_USEDEP}]
	)
"

# Match the upstream Cython >=3.1,<3.3 build constraint.
BDEPEND="
	>=dev-python/cython-3.1[${PYTHON_USEDEP}]
	<dev-python/cython-3.3[${PYTHON_USEDEP}]
"

DEPEND="${BDEPEND}
	${RDEPEND}
"

src_unpack() {
	default
	rm -rf "${S}/${PN}/third_party/_local"
}
