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

# PyPI is wheel-only; build from the v-prefixed tag, whose archive directory
# omits that prefix.
SRC_URI="
	https://github.com/NVIDIA/cudnn-frontend/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
"
S="${WORKDIR}/cudnn-frontend-${PV}"

LICENSE="Apache-2.0 MIT"
SLOT="0"
KEYWORDS="~amd64"

# Python CMake fetches its pinned DLPack 1.3, which Gentoo does not package.
# verified 2026-09-02
RESTRICT="network-sandbox"

# Optional framework/compiler extras are outside the dependency-free base API.
RDEPEND="
	>=dev-libs/cudnn-9
	dev-util/nvidia-cuda-toolkit:=
"
DEPEND="${RDEPEND}"
# Root CMake and the backend require the stated floors; Ninja is optional.
# The upstream pybind11 <3 cap is conservative: 3.0.4 compile-tested here.
# verified 2026-09-02
BDEPEND="
	>=dev-build/cmake-3.23
	>=dev-python/pybind11-2.13[${PYTHON_USEDEP}]
	>=dev-python/setuptools-64[${PYTHON_USEDEP}]
"
