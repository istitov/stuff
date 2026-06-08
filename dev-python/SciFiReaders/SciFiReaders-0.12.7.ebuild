# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Tools for extracting data and metadata from scientific data files"
HOMEPAGE="
	https://github.com/pycroscopy/SciFiReaders
	https://pycroscopy.github.io/SciFiReaders/
	https://pypi.org/project/SciFiReaders/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="hyperspy mcp nsid tiff"

RDEPEND="
	>=dev-python/numpy-1.24[${PYTHON_USEDEP}]
	dev-python/toolz[${PYTHON_USEDEP}]
	dev-python/cytoolz[${PYTHON_USEDEP}]
	>=dev-python/dask-2.20.0[${PYTHON_USEDEP}]
	>=dev-python/sidpy-0.11.2[${PYTHON_USEDEP}]
	dev-python/numba[${PYTHON_USEDEP}]
	>=dev-python/ipython-7.1.0[${PYTHON_USEDEP}]
	dev-python/pyUSID[${PYTHON_USEDEP}]
	dev-python/gdown[${PYTHON_USEDEP}]
	dev-python/mrcfile[${PYTHON_USEDEP}]
	dev-python/pycroscopy-gwyfile[${PYTHON_USEDEP}]
	>=dev-python/scipy-1.11[${PYTHON_USEDEP}]
	dev-python/pillow[${PYTHON_USEDEP}]
	hyperspy? ( dev-python/hyperspy[${PYTHON_USEDEP}] )
	mcp? ( dev-python/mcp[${PYTHON_USEDEP}] )
	nsid? ( dev-python/pyNSID[${PYTHON_USEDEP}] )
	tiff? ( dev-python/tifffile[${PYTHON_USEDEP}] )
"

# pillow is declared upstream under the optional [image] extra, but the
# image reader does an unconditional `import PIL` that runs on every
# `import SciFiReaders`, so it is effectively a core dependency.
#
# The igor2 extra is omitted: igor2 is not packaged, and the Igor reader
# guards its import and only fails when an Igor file is actually opened.
#
# Test suite downloads remote fixtures via gdown and needs igor2/aicspylibczi.
RESTRICT="test"

python_prepare_all() {
	# setuptools auto-discovery installs the top-level examples/ dir as a
	# stray namespace package; widen the packages.find exclude to drop it.
	sed -i \
		-e 's/"tests"\]/"tests", "examples", "examples.*", "docs", "docs.*"]/' \
		pyproject.toml || die
	distutils-r1_python_prepare_all
}
