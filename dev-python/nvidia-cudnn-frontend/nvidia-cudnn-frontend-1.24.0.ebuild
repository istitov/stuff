# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

DESCRIPTION="cuDNN Frontend Python bindings (header API + pybind11 layer)"
HOMEPAGE="
	https://github.com/NVIDIA/cudnn-frontend
	https://pypi.org/project/nvidia-cudnn-frontend/
"

# Upstream's PyPI release at this version is wheel-only; we build the
# Python binding from the source repo instead. The upstream tag does
# not carry the "v" prefix in directory names produced by the GitHub
# archive, only in the tag. # verified 2026-05-07 against 1.18.0.
SRC_URI="
	https://github.com/NVIDIA/cudnn-frontend/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
"
S="${WORKDIR}/cudnn-frontend-${PV}"

# LICENSE.txt is a permissive MIT-style notice ("Permission is hereby
# granted, free of charge...") — pyproject.toml's "NVIDIA Proprietary
# Software" string is wrong. Confirmed by reading LICENSE.txt verbatim.
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

# CMakeLists.txt FetchContent's DLPack (header-only) at configure time.
# Pinning the dlpack version into the source tree would mean carrying
# a sizeable patch series; the dependency is small and version-pinned
# in upstream's dlpack_version.txt, so accept the network-sandbox
# bypass instead — same pattern dev-python/vllm uses for its cpu?
# target. # verified 2026-05-07 against 1.18.0.
RESTRICT="network-sandbox"

# Base wheel has no Python-level deps; the cutedsl extra adds
# nvidia-cutlass-dsl + cuda-python + torch, not needed by vllm.
RDEPEND="
	>=dev-libs/cudnn-9
	dev-util/nvidia-cuda-toolkit:=
"
DEPEND="${RDEPEND}"
BDEPEND="
	>=dev-build/cmake-3.18
	>=dev-python/pybind11-2.10[${PYTHON_USEDEP}]
	dev-python/setuptools-scm[${PYTHON_USEDEP}]
"
