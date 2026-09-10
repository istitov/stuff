# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

# GitHub and VERSION use zero-padded 26.08.00; PyPI normalizes to ${PV}.
MY_PV="26.08.00"

DESCRIPTION="Utilities for running Dask workers on CUDA-enabled systems"
HOMEPAGE="
	https://github.com/rapidsai/dask-cuda
	https://pypi.org/project/dask-cuda/
"
SRC_URI="
	https://github.com/rapidsai/dask-cuda/archive/refs/tags/v${MY_PV}.tar.gz
		-> ${P}.gh.tar.gz
"
S="${WORKDIR}/${PN}-${MY_PV}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

# RMM-based spilling is optional. cuda-core provides CUDA access, nvidia-ml-py
# provides telemetry, and rapids-dask-dependency supplies dask/distributed.
RDEPEND="
	>=dev-python/click-8.1[${PYTHON_USEDEP}]
	>=dev-python/cuda-core-0.5.1[${PYTHON_USEDEP}]
	<dev-python/cuda-core-2[${PYTHON_USEDEP}]
	>=dev-python/numpy-2.0[${PYTHON_USEDEP}]
	<dev-python/numpy-3.0[${PYTHON_USEDEP}]
	>=dev-python/nvidia-ml-py-12[${PYTHON_USEDEP}]
	>=dev-python/pandas-1.3[${PYTHON_USEDEP}]
	~dev-python/rapids-dask-dependency-26.8.0[${PYTHON_USEDEP}]
	>=dev-python/zict-2.0.0[${PYTHON_USEDEP}]
"
BDEPEND=">=dev-python/setuptools-77.0.0[${PYTHON_USEDEP}]"

python_prepare_all() {
	# Static unsuffixed deps and VERSION work without RAPIDS's CUDA-suffix wrapper.
	# verified 2026-06-10
	sed -i \
		-e 's/build-backend = "rapids_build_backend.build"/build-backend = "setuptools.build_meta"/' \
		-e '/"rapids-build-backend>=0.4.0,<0.5.0",/d' \
		pyproject.toml || die

	distutils-r1_python_prepare_all
}
