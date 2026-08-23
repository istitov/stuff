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
# not a drop-in replacement and upstream requires httpx<1. verified 2026-08-23.
RDEPEND="
	>=sci-ml/huggingface_hub-0.25.0[${PYTHON_SINGLE_USEDEP}]
	<sci-ml/huggingface_hub-2[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		dev-python/aiohttp[${PYTHON_USEDEP}]
		>=dev-python/dill-0.3.0[${PYTHON_USEDEP}]
		<dev-python/dill-0.4.1[${PYTHON_USEDEP}]
		dev-python/filelock[${PYTHON_USEDEP}]
		>=dev-python/fsspec-2023.1.0[${PYTHON_USEDEP}]
		<=dev-python/fsspec-2025.9.0-r0[${PYTHON_USEDEP}]
		<dev-python/httpx-1[${PYTHON_USEDEP}]
		<dev-python/multiprocess-0.70.17[${PYTHON_USEDEP}]
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
