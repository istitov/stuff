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

# NVIDIA's cuda-python is a monorepo; cuda-core tags use the
# "cuda-core-v<PV>" prefix form (matches cuda-pathfinder; cuda-bindings
# uses bare v<PV>). Verified 2026-05-30 against 1.0.1.
SRC_URI="
	https://github.com/NVIDIA/cuda-python/archive/refs/tags/${MY_TAG}.tar.gz
		-> ${P}.gh.tar.gz
"
S="${WORKDIR}/cuda-python-${MY_TAG}/cuda_core"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

# build_hooks.py reads cuda.h from /opt/cuda/include via cuda.pathfinder
# and generates Cython sources at build time. Cython is pinned to 3.2.x
# by upstream's build-system requires; ::gentoo's cython-3.2.4 matches.
# cuda-bindings is needed at build time too — cuda-core's .pyx files
# do `from cuda.bindings cimport cydriver`, which requires the
# installed package's .pxd headers. Upstream pyproject.toml declares
# cuda-bindings only under the cu12/cu13 runtime extras, but the build
# can't proceed without it.
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

# CUDA_HOME drives build_hooks.py's _get_cuda_path; without it the
# header parser raises RuntimeError. dev-util/nvidia-cuda-toolkit
# installs to /opt/cuda on this overlay's amd64 profile.
export CUDA_HOME=/opt/cuda

# setuptools_scm is configured with root=".." pointing at the
# cuda-python monorepo root; the GitHub archive has no .git so the
# dynamic version would fail. SETUPTOOLS_SCM_PRETEND_VERSION_FOR_* is
# processed as a literal version string before tag_regex applies, so
# feed plain "v${PV}" (which packaging.version accepts as v-prefixed),
# not the full "cuda-core-v${PV}" tag form. Matches cuda-bindings.
export SETUPTOOLS_SCM_PRETEND_VERSION_FOR_CUDA_CORE="v${PV}"
