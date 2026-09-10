# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# 0.16.0 replaced its removed setuptools path with scikit-build-core.
DISTUTILS_USE_PEP517=scikit-build-core
DISTUTILS_SINGLE_IMPL=1
DISTUTILS_EXT=1
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

DESCRIPTION="Decode/encode video and audio into PyTorch tensors via FFmpeg"
HOMEPAGE="
	https://github.com/meta-pytorch/torchcodec
	https://pypi.org/project/torchcodec/
"
SRC_URI="
	https://github.com/meta-pytorch/torchcodec/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="cuda"

# Upstream dlopens FFmpeg 4..8; ::gentoo supplies the live 7.x/8.x slot.
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
	# scikit-build-core maps these variables to CMake; its version provider
	# still honors BUILD_VERSION.
	export CMAKE_BUILD_TYPE=Release
	export BUILD_VERSION="${PV}"

	# Image decoders became mandatory-by-default in 0.16. Disable them to retain
	# video-only scope; their operations then fail at runtime. # verified 2026-08-14
	export TORCHCODEC_BUILD_IMAGE=0

	# Acknowledge upstream's licensing guard while linking system FFmpeg instead
	# of redistributing its S3-vendored binary.
	export I_CONFIRM_THIS_IS_NOT_A_LICENSE_VIOLATION=1

	# Torch's CMake enables CUDA whenever /opt/cuda exists, even for CPU builds;
	# CUDA 13 rejects GCC >15, so pin the host compiler unconditionally.
	export CUDAHOSTCXX="/usr/bin/g++-15"

	if use cuda; then
		export ENABLE_CUDA=1
	else
		export ENABLE_CUDA=
	fi

	distutils-r1_python_compile
}
