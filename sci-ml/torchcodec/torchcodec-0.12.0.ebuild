# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_SINGLE_IMPL=1
DISTUTILS_EXT=1
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

DESCRIPTION="Decode/encode video and audio into PyTorch tensors via FFmpeg"
HOMEPAGE="
	https://github.com/pytorch/torchcodec
	https://pypi.org/project/torchcodec/
"
SRC_URI="
	https://github.com/pytorch/torchcodec/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="cuda"

# Upstream supports FFmpeg majors 4..8 (compiled separately and dlopen'd
# at runtime); ::gentoo's media-video/ffmpeg covers the live 7.x/8.x slot.
RDEPEND="
	sci-ml/pytorch[${PYTHON_SINGLE_USEDEP}]
	media-video/ffmpeg:=
	cuda? (
		dev-util/nvidia-cuda-toolkit:=
	)
"
DEPEND="${RDEPEND}"
BDEPEND="
	$(python_gen_cond_dep '
		dev-python/pybind11[${PYTHON_USEDEP}]
	')
	dev-build/cmake
"

# Tests pull a video corpus from S3.
RESTRICT="test"

python_compile() {
	# torchcodec's setup.py invokes cmake itself; use env vars to drive it.
	export CMAKE_BUILD_TYPE=Release
	export BUILD_VERSION="${PV}"

	# Upstream defaults to vendoring FFmpeg from S3 to skirt the wheel-
	# distribution licensing question; we link against media-video/ffmpeg
	# instead and have to ack the opt-out env var. Self-built local
	# install is not redistributing a binary, so no GPL concerns.
	export I_CONFIRM_THIS_IS_NOT_A_LICENSE_VIOLATION=1

	# CUDA 13.x nvcc rejects gcc>15. Caffe2's cmake config is included
	# unconditionally by find_package(Torch) and tries to enable_language(CUDA)
	# whenever it finds /opt/cuda — even for our CPU-only build path. Pin
	# the host compiler always; gcc-15 is installed alongside the active
	# gcc-16 system slot. See feedback_cuda_13_host_compiler_gcc_15.
	export CUDAHOSTCXX="/usr/bin/g++-15"

	if use cuda; then
		export ENABLE_CUDA=1
	else
		export ENABLE_CUDA=
	fi

	distutils-r1_python_compile
}
