# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{9..14} )
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1 git-r3

DESCRIPTION="Library for analysing atomic resolution images"
HOMEPAGE="https://atomap.org/"
EGIT_REPO_URI="https://github.com/atomap-dev/atomap.git"


LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE="python doc test"

RDEPEND="
	>=dev-python/numpy-1.13[${PYTHON_USEDEP}]
	>=dev-python/scipy-1.4[${PYTHON_USEDEP}]
	dev-python/h5py[${PYTHON_USEDEP}]
	>=dev-python/matplotlib-3.1.0[${PYTHON_USEDEP}]
	>=dev-python/hyperspy-1.5.2[${PYTHON_USEDEP}]
	>=dev-python/scikit-image-0.17.1[${PYTHON_USEDEP}]
	dev-python/scikit-learn[${PYTHON_USEDEP}]
	>=dev-python/ase-3.17.0[${PYTHON_USEDEP}]
	dev-python/numba[${PYTHON_USEDEP}]
"

DEPEND="${RDEPEND}
"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

PATCHES=(
	"${FILESDIR}"/4669b3370bba0a033c5903c73c26a6b45c9ffce7.patch
)

python_test() {
	epytest
}
