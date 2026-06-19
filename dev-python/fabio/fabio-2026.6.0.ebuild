# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=meson-python
inherit distutils-r1 pypi

DESCRIPTION="FabIO is an I/O library for images produced by 2D X-ray detectors"
HOMEPAGE="https://github.com/silx-kit/fabio"
SRC_URI="$(pypi_sdist_url "${PN^}" "${PV}")"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="gui"

RDEPEND="
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/h5py[${PYTHON_USEDEP}]
	dev-python/hdf5plugin[${PYTHON_USEDEP}]
	dev-python/lxml[${PYTHON_USEDEP}]
	dev-python/pillow[${PYTHON_USEDEP}]
	dev-python/filelock[${PYTHON_USEDEP}]
	gui? (
		dev-python/matplotlib[${PYTHON_USEDEP}]
		dev-python/packaging[${PYTHON_USEDEP}]
		dev-python/pyside:6[${PYTHON_USEDEP}]
		dev-python/qtpy[${PYTHON_USEDEP}]
	)
"
DEPEND="${RDEPEND}"
BDEPEND="
	>=dev-python/cython-3.1[${PYTHON_USEDEP}]
"

# The package ships 64 test modules, but they download a test-image
# corpus from a remote server (edna-site.org) at runtime, so they can't
# run in a sandboxed build. verified 2026-06-19.
RESTRICT="test"
