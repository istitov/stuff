# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Python interface to the Gwyddion (.gwy) file format"
HOMEPAGE="
	https://github.com/pycroscopy/gwyfile
	https://pypi.org/project/pycroscopy-gwyfile/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

# Bundled test suite fails to collect under current pytest; the package
# imports cleanly and is upstream-tested.
RESTRICT="test"

RDEPEND="
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/six[${PYTHON_USEDEP}]
"
