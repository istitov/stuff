# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{11..14} )

inherit distutils-r1 pypi

DESCRIPTION="Stack AV's Triton kernel repository for GPU-accelerated ML"
HOMEPAGE="
	https://github.com/stackav-oss/conch
	https://pypi.org/project/conch-triton-kernels/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

# Hard runtime dep is just numpy. Triton + torch are pulled in via
# upstream's [cpu]/[cuda]/[rocm]/[xpu] extras and accessed lazily inside
# kernel functions — calling a kernel without triton installed raises
# ImportError, which is the same behavior we'd get from the wheel.
# triton itself is not in any tree we depend on, so we can't declare it.
RDEPEND="
	>=dev-python/numpy-1.26.4[${PYTHON_USEDEP}]
"
BDEPEND="
	dev-python/setuptools-scm[${PYTHON_USEDEP}]
"

export SETUPTOOLS_SCM_PRETEND_VERSION=${PV}
