# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..14} )
DISTUTILS_SINGLE_IMPL=1
DISTUTILS_USE_PEP517=setuptools
DISTUTILS_EXT=1
inherit distutils-r1 multiprocessing

DESCRIPTION="Audio data, transforms and models for PyTorch"
HOMEPAGE="https://github.com/pytorch/audio"
SRC_URI="
	https://github.com/pytorch/audio/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
"
S="${WORKDIR}/audio-${PV}"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"

# Sister of sci-ml/torchvision; built CPU-only here. CUDA/ROCm modes
# need the same setup_helpers env-var dance torchvision does — defer
# until a USE-flag-driven cycle.
RDEPEND="
	=sci-ml/pytorch-2.11*[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		dev-python/numpy[${PYTHON_USEDEP}]
	')
"

# Tests pull soundfile + a network corpus; not wired up.
RESTRICT="test"

python_compile() {
	export USE_CUDA=0
	export USE_ROCM=0
	export BUILD_CUDA_CTC_DECODER=0

	MAX_JOBS="$(get_makeopts_jobs)" \
		distutils-r1_python_compile -j1
}
