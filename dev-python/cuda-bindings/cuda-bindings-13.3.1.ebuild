# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=standalone
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

DESCRIPTION="Python bindings for CUDA driver and runtime APIs"
HOMEPAGE="
	https://github.com/NVIDIA/cuda-python
	https://nvidia.github.io/cuda-python/cuda-bindings/
	https://pypi.org/project/cuda-bindings/
"

# NVIDIA's cuda-python is a monorepo; cuda-bindings tags use a bare
# v<PV> form (vs cuda-pathfinder's "cuda-pathfinder-v<PV>" prefix).
# Verified 2026-05-30 against 13.3.1.
SRC_URI="
	https://github.com/NVIDIA/cuda-python/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
"
S="${WORKDIR}/cuda-python-${PV}/cuda_bindings"

LICENSE="NVIDIA-CUDA"
SLOT="0"
KEYWORDS="~amd64"
# NVIDIA-CUDA is an EULA license — distfile must not be mirrored,
# resulting binpkgs must not be redistributed.
RESTRICT="bindist mirror"

# build_hooks.py reads /opt/cuda headers via pyclibrary and generates
# Cython sources; cython is pinned to 3.2.x by upstream's build-system
# requires, and ::gentoo's cython-3.2.4 matches that band exactly.
# 13.3.0 added cudaProfiler.h + cuda_profiler_api.h to the required-
# headers list (build_hooks.py _REQUIRED_HEADERS), so the toolkit's
# profiler components (cuda-cupti + cuda-profiler-api) are now needed.
RDEPEND="
	>=dev-python/cuda-pathfinder-1.5[${PYTHON_USEDEP}]
	dev-util/nvidia-cuda-toolkit:=[profiler]
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-python/pyclibrary[${PYTHON_USEDEP}]
	>=dev-python/cython-3.2[${PYTHON_USEDEP}]
	<dev-python/cython-3.3[${PYTHON_USEDEP}]
	>=dev-python/setuptools-scm-8[${PYTHON_USEDEP}]
"

# CUDA_HOME drives _get_cuda_paths in build_hooks.py — without it the
# header parser raises RuntimeError. dev-util/nvidia-cuda-toolkit
# installs to /opt/cuda on this overlay's amd64 profile.
export CUDA_HOME=/opt/cuda

# setuptools_scm is configured with root=".." pointing at the cuda-python
# monorepo root; the GitHub archive has no .git so the dynamic version
# would fail. Feed PV explicitly via SETUPTOOLS_SCM_PRETEND_VERSION;
# the tag_regex strips the "v" prefix from upstream tags.
export SETUPTOOLS_SCM_PRETEND_VERSION_FOR_CUDA_BINDINGS="v${PV}"
