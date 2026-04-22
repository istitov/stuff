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
KEYWORDS="~amd64"
IUSE="doc python"

RDEPEND="
	>=dev-python/h5py-3[${PYTHON_USEDEP}]
	dev-python/fabio[${PYTHON_USEDEP}]
	dev-python/matplotlib[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/packaging[${PYTHON_USEDEP}]
	dev-python/pillow[${PYTHON_USEDEP}]
	dev-python/pint[${PYTHON_USEDEP}]
	dev-python/pooch[${PYTHON_USEDEP}]
	dev-python/pyopencl[${PYTHON_USEDEP}]
	dev-python/pyopengl[${PYTHON_USEDEP}]
	>=dev-python/pydantic-2[${PYTHON_USEDEP}]
	>=dev-python/pyside-6.5:6[${PYTHON_USEDEP}]
	dev-python/python-dateutil[${PYTHON_USEDEP}]
	dev-python/qtawesome[${PYTHON_USEDEP}]
	dev-python/qtconsole[${PYTHON_USEDEP}]
	dev-python/scipy[${PYTHON_USEDEP}]
	dev-python/hdf5plugin[${PYTHON_USEDEP}]
	dev-python/mako[${PYTHON_USEDEP}]
"

BDEPEND="
	dev-python/cython[${PYTHON_USEDEP}]
"

DEPEND="${BDEPEND}
	${RDEPEND}
	doc? ( dev-util/gtk-doc )
"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

src_unpack() {
	default
	rm -rf "${S}/${PN}/third_party/_local"
}
