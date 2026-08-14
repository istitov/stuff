# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )
inherit distutils-r1

DESCRIPTION="Python bindings for NVIDIA Tools Extension"
HOMEPAGE="https://github.com/NVIDIA/NVTX"
SRC_URI="https://files.pythonhosted.org/packages/92/dd/692765e87de30bae1522cdffaa0f2b52949658a92a0fa6d96b1a01eae9d2/nvtx-${PV}.tar.gz"
LICENSE="Apache-2.0-with-LLVM-exceptions"
SLOT="0"
KEYWORDS="~amd64"
BDEPEND=">=dev-python/cython-3.1[${PYTHON_USEDEP}]"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest
