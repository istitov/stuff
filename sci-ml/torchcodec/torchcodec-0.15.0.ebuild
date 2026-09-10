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

# Upstream dlopens FFmpeg 4-8; ::gentoo supplies the live 7/8 slot.
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
	# setup.py drives CMake through environment variables.
	export CMAKE_BUILD_TYPE=Release
	export BUILD_VERSION="${PV}"

	# Link system FFmpeg instead of the S3-vendored wheel payload; acknowledge
	# upstream's redistribution guard for this local source build.
	export I_CONFIRM_THIS_IS_NOT_A_LICENSE_VIOLATION=1

	# Caffe2 enables CUDA whenever /opt/cuda exists, even for CPU builds; CUDA 13
	# rejects GCC >15, so pin the declared GCC 15 host compiler.
	export CUDAHOSTCXX="/usr/bin/g++-15"

	if use cuda; then
		export ENABLE_CUDA=1
	else
		export ENABLE_CUDA=
	fi

	distutils-r1_python_compile
}
