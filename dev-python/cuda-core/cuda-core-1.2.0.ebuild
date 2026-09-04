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
# uses bare v<PV>). Verified 2026-09-03 against 1.2.0.
#
# Manifest re-pinned 2026-09-04: the archive GitHub generates for this
# tag changed size (3190447 -> 3190454 bytes), so the old pin stopped
# being fetchable. Verified: the current archive's pax header carries
# 53b43746e501f1a0b627f951604991636f77cd9c, which is the commit the
# cuda-core-v1.2.0 ref resolves to, and the 1.1.1 archive still matches
# its pin byte for byte (so this is not a repo-wide gzip change). The
# superseded archive was not available on this host, so its provenance
# could not be checked directly; a 7-byte delta plus an unmoved 1.1.1
# is consistent with re-encoding rather than a moved tag, but that part
# is inference, not verification.
SRC_URI="
	https://github.com/NVIDIA/cuda-python/archive/refs/tags/${MY_TAG}.tar.gz
		-> ${P}.gh.tar.gz
"
S="${WORKDIR}/cuda-python-${MY_TAG}/cuda_core"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

# build_hooks.py reads cuda.h from /opt/cuda/include via cuda.pathfinder
# and generates Cython sources at build time. Upstream requires
# Cython >=3.2.5,<3.3.
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
	>=dev-python/cython-3.2.5[${PYTHON_USEDEP}]
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
# used verbatim and bypasses tag_regex, so it must be the LITERAL
# version, not the "v"-prefixed tag form. packaging.version normalises
# "v1.0.1" away in the dist metadata, but the raw string still leaks
# into cuda.core.__version__, which breaks consumers that parse it (the
# same class of bug fixed in cuda-bindings). verified 2026-06-10
export SETUPTOOLS_SCM_PRETEND_VERSION_FOR_CUDA_CORE="${PV}"
