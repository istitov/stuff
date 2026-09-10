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

# cuda-core uses cuda-core-v* monorepo tags, unlike cuda-bindings' v* tags.
SRC_URI="
	https://github.com/NVIDIA/cuda-python/archive/refs/tags/${MY_TAG}.tar.gz
		-> ${P}.gh.tar.gz
"
S="${WORKDIR}/cuda-python-${MY_TAG}/cuda_core"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

# build_hooks.py reads cuda.h and generates Cython sources with upstream's
# pinned 3.2.x series. The .pyx files cimport cuda-bindings headers, making its
# nominally runtime-extra package a build dependency too.
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
	>=dev-python/cython-3.2[${PYTHON_USEDEP}]
	<dev-python/cython-3.3[${PYTHON_USEDEP}]
	>=dev-python/setuptools-scm-8[${PYTHON_USEDEP}]
	>=dev-python/setuptools-80[${PYTHON_USEDEP}]
"

# build_hooks.py needs CUDA_HOME to locate cuda.h; the toolkit uses /opt/cuda.
export CUDA_HOME=/opt/cuda

# The archive lacks .git, while setuptools-scm searches the monorepo root.
# Its override bypasses tag_regex and leaks verbatim into __version__, so use
# the literal version rather than the v-prefixed tag. # verified 2026-06-10
export SETUPTOOLS_SCM_PRETEND_VERSION_FOR_CUDA_CORE="${PV}"
