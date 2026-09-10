# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Stack AV's Triton kernel repository for GPU-accelerated ML"
HOMEPAGE="
	https://github.com/stackav-oss/conch
	https://pypi.org/project/conch-triton-kernels/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

# Map upstream's accelerator-specific extras to the unified virtual/triton
# package introduced in-tree on 2026-06-14.
RDEPEND="
	>=dev-python/numpy-1.26.4[${PYTHON_USEDEP}]
	virtual/triton[${PYTHON_USEDEP}]
"
BDEPEND="
	dev-python/setuptools-scm[${PYTHON_USEDEP}]
"

export SETUPTOOLS_SCM_PRETEND_VERSION=${PV}
