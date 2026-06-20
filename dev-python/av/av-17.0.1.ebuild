# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1 pypi

DESCRIPTION="Pythonic bindings for FFmpeg's libraries."
HOMEPAGE="https://github.com/PyAV-Org/PyAV https://pypi.org/project/av/"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

RESTRICT="test"

RDEPEND="media-video/ffmpeg:="
DEPEND="${RDEPEND}"
BDEPEND=">=dev-python/cython-3.1.0[${PYTHON_USEDEP}]"

#distutils_enable_tests setup.py
# The configuration file (or one of the modules it imports) called sys.exit()
# distutils_enable_sphinx docs
