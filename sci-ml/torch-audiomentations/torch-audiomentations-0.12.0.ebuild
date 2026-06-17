# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Fast, differentiable, GPU-friendly audio augmentations for PyTorch"
HOMEPAGE="
	https://github.com/iver56/torch-audiomentations
	https://pypi.org/project/torch-audiomentations/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# PyYAML is in upstream extras_require, imported lazily in utils/config.py;
# omit here since downstream sci-ml/pyannote-audio pulls dev-python/pyyaml
# anyway via its own dep chain.
RDEPEND="
	sci-ml/pytorch[${PYTHON_SINGLE_USEDEP}]
	sci-ml/torchaudio[${PYTHON_SINGLE_USEDEP}]
	<sci-ml/julius-0.3[${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/julius-0.2.3[${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/torch-pitch-shift-1.2.2[${PYTHON_SINGLE_USEDEP}]
"

RESTRICT="test"
