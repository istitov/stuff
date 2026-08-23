# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

DESCRIPTION="PyTorch architecture optimization library"
HOMEPAGE="https://github.com/pytorch/ao"
SRC_URI="https://github.com/pytorch/ao/archive/refs/tags/v${PV}.tar.gz
	-> ${P}.gh.tar.gz"
S="${WORKDIR}/ao-${PV}"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"

# Hardware-specific tests require supported accelerator devices.
RESTRICT="test"

RDEPEND="sci-ml/pytorch[${PYTHON_SINGLE_USEDEP}]"
BDEPEND="${RDEPEND}"

# The pure-Python kernels are usable without building CUDA/ROCm extensions.
export USE_CPP=0
# Release archives lack Git metadata; keep the wheel version equal to ${PV}.
export VERSION_SUFFIX=""

python_prepare_all() {
	# Upstream's package discovery otherwise installs this as top-level "test".
	rm -r test || die
	distutils-r1_python_prepare_all
}
