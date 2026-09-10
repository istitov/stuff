# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1

DESCRIPTION="Ptychographic Reconstruction with Automatic Differentiation"
HOMEPAGE="
	https://github.com/chiahao3/ptyrad
	https://pypi.org/project/ptyrad/
"
# Use the GitHub archive because the PyPI sdist omits tests/.
SRC_URI="
	https://github.com/chiahao3/ptyrad/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="examples"

# Use single-implementation deps for the PyTorch stack. Declare numpy because
# ptyrad imports it directly despite omitting it upstream; jupyter is needed
# only to run bundled examples.
RDEPEND="
	>=sci-ml/pytorch-2.4[${PYTHON_SINGLE_USEDEP}]
	sci-ml/torchvision[${PYTHON_SINGLE_USEDEP}]
	sci-ml/accelerate[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		dev-python/h5py[${PYTHON_USEDEP}]
		dev-python/matplotlib[${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
		dev-python/optuna[${PYTHON_USEDEP}]
		dev-python/pydantic[${PYTHON_USEDEP}]
		dev-python/pyyaml[${PYTHON_USEDEP}]
		dev-python/scikit-learn[${PYTHON_USEDEP}]
		dev-python/scipy[${PYTHON_USEDEP}]
		dev-python/tifffile[${PYTHON_USEDEP}]
		dev-python/zarr[${PYTHON_USEDEP}]
	')
	examples? (
		$(python_gen_cond_dep '
			dev-python/jupyter[${PYTHON_USEDEP}]
		')
	)
"

# Load no third-party pytest plugins.
EPYTEST_PLUGINS=()
distutils_enable_tests pytest
