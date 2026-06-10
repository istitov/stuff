# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

# GitHub zero-pads the calendar version in the tag (26.06.00); PyPI
# normalises it to 26.6.0, which is our ${PV}. The in-tree dask_cuda/VERSION
# file already carries the clean 26.06.00 string that setuptools' dynamic
# version reads, so no version patching is needed here.
MY_PV="26.06.00"

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

# dask-cuda is pure-Python; RMM-based device-memory spilling is optional
# (sci-libs RMM is not packaged) and not a hard dependency. cuda-core is
# satisfied by our dev-python/cuda-python stack; nvidia-ml-py (pynvml) is
# the GPU telemetry binding. rapids-dask-dependency pulls the dask /
# distributed pair (see that package for the relaxed-pin rationale).
RDEPEND="
	>=dev-python/click-8.1[${PYTHON_USEDEP}]
	>=dev-python/cuda-core-0.3.2[${PYTHON_USEDEP}]
	>=dev-python/numpy-1.23[${PYTHON_USEDEP}]
	>=dev-python/nvidia-ml-py-12[${PYTHON_USEDEP}]
	>=dev-python/pandas-1.3[${PYTHON_USEDEP}]
	~dev-python/rapids-dask-dependency-26.6.0[${PYTHON_USEDEP}]
	>=dev-python/zict-2.0.0[${PYTHON_USEDEP}]
"

python_prepare_all() {
	# Upstream builds through rapids_build_backend, a RAPIDS PEP517 shim
	# whose only effects are (a) appending a CUDA suffix (-cu13) to
	# dependency names and (b) sourcing deps from dependencies.yaml. We
	# want neither — our deps are unsuffixed and already static in
	# [project.dependencies] — and its declared inner backend is plain
	# setuptools.build_meta. Swap to setuptools directly so we don't have
	# to package rapids-build-backend + rapids-dependency-file-generator
	# for byte-identical output. The dynamic version still resolves from
	# dask_cuda/VERSION via [tool.setuptools.dynamic]. verified 2026-06-10
	sed -i \
		-e 's/build-backend = "rapids_build_backend.build"/build-backend = "setuptools.build_meta"/' \
		-e '/"rapids-build-backend>=0.4.0,<0.5.0",/d' \
		pyproject.toml || die

	distutils-r1_python_prepare_all
}
