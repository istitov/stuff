# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Machine learning metrics for distributed PyTorch applications"
HOMEPAGE="
	https://github.com/Lightning-AI/torchmetrics
	https://torchmetrics.rtfd.io/
	https://pypi.org/project/torchmetrics/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

# typing_extensions is not in upstream Requires-Dist but the retrieval
# submodule imports it at top level; declare explicitly rather than rely
# on torch's transitive pull.
RDEPEND="
	sci-ml/pytorch[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		>=dev-python/numpy-1.20[${PYTHON_USEDEP}]
		>=dev-python/packaging-17.1[${PYTHON_USEDEP}]
		>=sci-ml/lightning-utilities-0.15.3[${PYTHON_USEDEP}]
		dev-python/typing-extensions[${PYTHON_USEDEP}]
	')
"

# Tests pull a long tail of extras (transformers, librosa, torchvision, ...).
RESTRICT="test"
