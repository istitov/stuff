# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=meson-python
inherit distutils-r1 pypi

DESCRIPTION="FabIO is an I/O library for images produced by 2D X-ray detectors"
HOMEPAGE="https://github.com/silx-kit/fabio"
#SRC_URI="mirror://pypi/${P:0:1}/${PN}/${P}.tar.gz"
SRC_URI="$(pypi_sdist_url "${PN^}" "${PV}")"

LICENSE="MIT"
SLOT="0"
# x86 retained here as the fallback: 2025.10.0 added a hard
# dev-python/hdf5plugin dep, which is not keyworded ~x86 in
# ::gentoo, so the newer version cannot solve on x86. pkgcheck
# DroppedKeywords on the bump is therefore informational and
# expected; do not "fix" by chasing parity.
KEYWORDS="~amd64 ~arm64 ~x86"

RDEPEND="
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/h5py[${PYTHON_USEDEP}]
	dev-python/hdf5plugin[${PYTHON_USEDEP}]
	dev-python/lxml[${PYTHON_USEDEP}]
	dev-python/pillow[${PYTHON_USEDEP}]
	gui? (
		dev-python/matplotlib[${PYTHON_USEDEP}]
		dev-python/pyqt5[${PYTHON_USEDEP}]
	)
"
DEPEND="${RDEPEND}"
BDEPEND="
	>=dev-python/cython-0.29[${PYTHON_USEDEP}]
"
IUSE="gui"
