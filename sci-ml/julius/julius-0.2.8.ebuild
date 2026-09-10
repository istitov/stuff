# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Differentiable digital signal processing for PyTorch"
HOMEPAGE="
	https://github.com/adefossez/julius
	https://pypi.org/project/julius/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=sci-ml/pytorch-1.13.0[${PYTHON_SINGLE_USEDEP}]
"

# Tests require resampy, onnxruntime, and audio fixtures.
RESTRICT="test"
