# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
DISTUTILS_SINGLE_IMPL=1
# Capped by the implementations supported by kornia-rs-bin.
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Differentiable computer vision library for PyTorch"
HOMEPAGE="
	https://github.com/kornia/kornia
	https://pypi.org/project/kornia/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	sci-ml/caffe2[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		>=dev-python/kornia-rs-bin-0.1.9[${PYTHON_USEDEP}]
		dev-python/packaging[${PYTHON_USEDEP}]
	')
"
