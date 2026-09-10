# Copyright 1999-2026 Gentoo Authors
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

RDEPEND="
	$(python_gen_cond_dep '
		dev-python/numpy[${PYTHON_USEDEP}]
		dev-python/pillow[${PYTHON_USEDEP}]
	')
	jpeg? ( media-libs/libjpeg-turbo:= )
	png? ( media-libs/libpng:= )
	webp? ( media-libs/libwebp )
	sci-ml/caffe2[cuda?,rocm?,${PYTHON_SINGLE_USEDEP}]
	=sci-ml/pytorch-2.13*[${PYTHON_SINGLE_USEDEP}]
"

BDEPEND="
	test? (
		$(python_gen_cond_dep '
			dev-python/lmdb[${PYTHON_USEDEP}]
			dev-python/sympy[${PYTHON_USEDEP}]
		')
	)
"

EPYTEST_PLUGINS=( pytest-mock )

distutils_enable_tests pytest

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
	# The build probes /dev/random (bug #968112).
	addpredict /dev/random

	export FORCE_CUDA=0
	if use cuda || use rocm ; then
	  export FORCE_CUDA=1
	fi

	# setup.py no longer reads the legacy FFMPEG/VIDEO_CODEC knobs.
	# verified 2026-09-10
	export TORCHVISION_USE_PNG=$(usex png 1 0)
	export TORCHVISION_USE_JPEG=$(usex jpeg 1 0)
	export TORCHVISION_USE_WEBP=$(usex webp 1 0)

	export TORCHVISION_USE_NVJPEG=$(usex cuda 1 0)

	NVCC_FLAGS="${NVCCFLAGS}" \
		MAX_JOBS="$(get_makeopts_jobs)" \
		distutils-r1_python_compile -j1
}

python_test() {
	# Import the installed compiled extension, not the source tree.
	rm -rf torchvision || die
	local EPYTEST_DESELECT=(
		# Require pretrained weights or remote datasets.
		test/test_extended_models.py::TestHandleLegacyInterface::test_pretrained_pos
		test/test_extended_models.py::TestHandleLegacyInterface::test_equivalent_behavior_weights
		test/test_extended_models.py::test_get_model[lraspp_mobilenet_v3_large-LRASPP]
		test/test_internet.py::TestDatasetUtils::test_download_url_dispatch_download_from_google_drive[True]
		test/test_internet.py::TestDatasetUtils::test_download_url_dispatch_download_from_google_drive[False]
		# earth.gif is absent from the archive; deselect only its parameters.
		# verified 2026-07-22
		test/test_image.py::test_decode_gif[True-earth]
		test/test_image.py::test_decode_gif[False-earth]
	)
	# ::gentoo's deselected XYWHR cases pass here. verified 2026-07-22
	epytest
}
