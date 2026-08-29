# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Access and share datasets for Audio, Computer Vision, and NLP tasks"
HOMEPAGE="
	https://github.com/huggingface/datasets
	https://pypi.org/project/datasets/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

# The test suite requires network access and a broad set of optional storage,
# ML, and database backends.
RESTRICT="test"

# dev-python/httpx is deprecated in ::gentoo since 2026-04-01, but httpx2 is
# not a drop-in replacement and upstream requires httpx<1. verified 2026-08-23,
# re-verified 2026-08-29 against 5.0.1 (still httpx<1.0.0).
#
# aiohttp is not a base requirement upstream; it comes in via the `fsspec[http]`
# extra, which Portage cannot express (::gentoo's fsspec carries aiohttp as an
# optfeature, not a USE flag). Declaring it directly is the only way to make
# the HTTP filesystem backend actually work on a merged system.
#
# 5.0.1 relaxed three upper bounds, all of which had been holding the tree back
# to older versions than either repo ships:
#   dill         <0.4.1    -> <0.4.2   (unblocks dill-0.4.1, the only version
#                                       ::gentoo has)
#   multiprocess <0.70.17  -> <0.70.20 (unblocks multiprocess-0.70.19, likewise)
#   fsspec       <=2025.9.0 -> <=2026.6.0
# The fsspec ceiling is the interesting one: at <=2025.9.0 this package was the
# sole reason ::stuff carries a dev-python/fsspec at all, since ::gentoo has
# only 2026.6.0 and 2026.7.0. At <=2026.6.0 this version resolves against
# ::gentoo's fsspec directly. datasets-4.3.0 still needs the overlay's
# 2025.9.0, so it stays for now. verified 2026-08-29 against the 5.0.1 sdist.
#
# The fsspec ceiling carries -r9999, not the -r0 that 4.3.0 uses: upstream's
# bound is on the upstream version, and a Gentoo revbump of 2026.6.0 is still
# upstream 2026.6.0, so a packaging fix must not be excluded by our atom.
RDEPEND="
	>=sci-ml/huggingface_hub-0.25.0[${PYTHON_SINGLE_USEDEP}]
	<sci-ml/huggingface_hub-2[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		dev-python/aiohttp[${PYTHON_USEDEP}]
		>=dev-python/dill-0.3.0[${PYTHON_USEDEP}]
		<dev-python/dill-0.4.2[${PYTHON_USEDEP}]
		dev-python/filelock[${PYTHON_USEDEP}]
		>=dev-python/fsspec-2023.1.0[${PYTHON_USEDEP}]
		<=dev-python/fsspec-2026.6.0-r9999[${PYTHON_USEDEP}]
		<dev-python/httpx-1[${PYTHON_USEDEP}]
		<dev-python/multiprocess-0.70.20[${PYTHON_USEDEP}]
		>=dev-python/numpy-1.17[${PYTHON_USEDEP}]
		dev-python/packaging[${PYTHON_USEDEP}]
		dev-python/pandas[${PYTHON_USEDEP}]
		>=dev-python/pyarrow-21.0.0[${PYTHON_USEDEP}]
		>=dev-python/pyyaml-5.1[${PYTHON_USEDEP}]
		>=dev-python/requests-2.32.2[${PYTHON_USEDEP}]
		>=dev-python/tqdm-4.66.3[${PYTHON_USEDEP}]
		dev-python/xxhash[${PYTHON_USEDEP}]
	')
"
