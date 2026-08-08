# Copyright 2024-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_SINGLE_IMPL=1
DISTUTILS_USE_PEP517=setuptools
DISTUTILS_EXT=1
ROCM_SKIP_GLOBALS=1
inherit cuda distutils-r1 multiprocessing rocm

DESCRIPTION="Datasets, transforms and models specific to computer vision"
HOMEPAGE="https://github.com/pytorch/vision"
SRC_URI="https://github.com/pytorch/vision/archive/refs/tags/v${PV}.tar.gz
	-> ${P}.tar.gz"

S="${WORKDIR}"/vision-${PV}

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="cuda +jpeg +png rocm +webp"

REQUIRED_USE="
	?? ( cuda rocm )
"

# torchvision 0.26.0 requires torch==2.11.0 (exact); pair with our
# sci-ml/pytorch-2.11 frontend. Restored as a frozen rollback for the
# vllm(torch==2.11) stack (0.28.0 forward otherwise).
RDEPEND="
	$(python_gen_cond_dep '
		dev-python/numpy[${PYTHON_USEDEP}]
		dev-python/pillow[${PYTHON_USEDEP}]
	')
	jpeg? ( media-libs/libjpeg-turbo:= )
	png? ( media-libs/libpng:= )
	webp? ( media-libs/libwebp )
	sci-ml/caffe2[cuda?,rocm?,${PYTHON_SINGLE_USEDEP}]
	=sci-ml/pytorch-2.11*[${PYTHON_SINGLE_USEDEP}]
"

# Test suite not re-vetted for this frozen rollback (the 0.28.0 deselect set
# is version-specific); restored purely to keep the torch-2.11 stack
# installable.
RESTRICT="test"

src_prepare() {
	use cuda && cuda_src_prepare
	distutils-r1_src_prepare
}

src_configure() {
	rocm_add_sandbox -w
	distutils-r1_src_configure
}

python_compile() {
	addpredict /dev/kfd
	# bug #968112
	addpredict /dev/random

	export FORCE_CUDA=0
	if use cuda || use rocm ; then
	  export FORCE_CUDA=1
	fi

	export TORCHVISION_USE_PNG=$(usex png 1 0)
	export TORCHVISION_USE_JPEG=$(usex jpeg 1 0)
	export TORCHVISION_USE_WEBP=$(usex webp 1 0)

	export TORCHVISION_USE_NVJPEG=$(usex cuda 1 0)

	NVCC_FLAGS="${NVCCFLAGS}" \
		MAX_JOBS="$(get_makeopts_jobs)" \
		distutils-r1_python_compile -j1
}
