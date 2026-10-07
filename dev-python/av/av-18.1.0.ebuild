# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1 pypi

DESCRIPTION="Pythonic bindings for FFmpeg's libraries"
HOMEPAGE="https://github.com/PyAV-Org/PyAV https://pypi.org/project/av/"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"

# Test configuration exits during collection.
RESTRICT="test"

RDEPEND="media-video/ffmpeg:="
DEPEND="${RDEPEND}"
# av 19 needs Cython >=3.3 to build, while cupy, cuda-bindings and cuda-core
# cap it below 3.3 upstream, and Cython is unslotted. This is the newest av
# that can be built on a system with those. verified 2026-10-07
BDEPEND="
	>=dev-python/cython-3.1.0[${PYTHON_USEDEP}]
	>=dev-python/setuptools-77[${PYTHON_USEDEP}]
"
