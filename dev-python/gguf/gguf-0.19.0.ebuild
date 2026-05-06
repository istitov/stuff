# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=poetry
PYTHON_COMPAT=( python3_{11..14} )

inherit distutils-r1 pypi

DESCRIPTION="Read and write ML models in GGUF for GGML"
HOMEPAGE="
	https://ggml.ai
	https://github.com/ggml-org/llama.cpp
	https://pypi.org/project/gguf/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="gui"

RDEPEND="
	>=dev-python/numpy-1.17[${PYTHON_USEDEP}]
	>=dev-python/pyyaml-5.1[${PYTHON_USEDEP}]
	>=dev-python/requests-2.25[${PYTHON_USEDEP}]
	>=dev-python/tqdm-4.27[${PYTHON_USEDEP}]
	gui? (
		>=dev-python/pyside-6.9[${PYTHON_USEDEP}]
	)
"
