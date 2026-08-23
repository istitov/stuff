# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{12..14} )
PYPI_PN="cut_cross_entropy"
PYPI_NO_NORMALIZE=1

inherit distutils-r1 pypi

DESCRIPTION="Memory-efficient cross entropy loss for PyTorch"
HOMEPAGE="
	https://github.com/apple/ml-cross-entropy
	https://pypi.org/project/cut-cross-entropy/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

# The suite exercises Triton kernels and requires supported accelerator hardware.
RESTRICT="test"

RDEPEND="
	sci-ml/pytorch[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		dev-python/triton[${PYTHON_USEDEP}]
	')
"
BDEPEND="${RDEPEND}"
