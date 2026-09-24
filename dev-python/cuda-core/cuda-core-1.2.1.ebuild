# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=standalone
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

MY_TAG="cuda-core-v${PV}"

DESCRIPTION="cuda.core: pythonic CUDA module"
HOMEPAGE="
	https://github.com/NVIDIA/cuda-python
	https://nvidia.github.io/cuda-python/cuda-core/
	https://pypi.org/project/cuda-core/
"

# cuda-core uses cuda-core-v<PV> monorepo tags, like cuda-pathfinder's
# namespaced tags; cuda-bindings uses bare v<PV>. # verified 2026-09-03
SRC_URI="
	https://github.com/NVIDIA/cuda-python/archive/refs/tags/${MY_TAG}.tar.gz
		-> ${P}.gh.tar.gz
"
S="${WORKDIR}/cuda-python-${MY_TAG}/cuda_core"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

# build_hooks.py reads cuda.h through cuda.pathfinder and generates Cython.
# cuda-bindings is also a build dependency because .pyx files cimport its .pxd
# headers, despite upstream declaring it only in runtime extras.
RDEPEND="
	>=dev-python/cuda-pathfinder-1.4.2[${PYTHON_USEDEP}]
	dev-python/cuda-bindings[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-util/nvidia-cuda-toolkit:=
"
DEPEND="${RDEPEND}"
BDEPEND="
	>=dev-python/cuda-pathfinder-1.5[${PYTHON_USEDEP}]
	dev-python/cuda-bindings[${PYTHON_USEDEP}]
	>=dev-python/cython-3.2.5[${PYTHON_USEDEP}]
	<dev-python/cython-3.3[${PYTHON_USEDEP}]
	>=dev-python/setuptools-scm-8[${PYTHON_USEDEP}]
	>=dev-python/setuptools-80[${PYTHON_USEDEP}]
"

# build_hooks.py requires CUDA_HOME to locate cuda.h.
export CUDA_HOME=/opt/cuda

# The archive lacks monorepo Git metadata, so provide the literal version.
# A v-prefixed value leaks into cuda.core.__version__ despite metadata
# normalization and breaks consumers. # verified 2026-06-10
export SETUPTOOLS_SCM_PRETEND_VERSION_FOR_CUDA_CORE="${PV}"
