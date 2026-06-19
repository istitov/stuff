# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

MY_PN="whisper.cpp"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Port of OpenAI's Whisper model in C/C++"
HOMEPAGE="https://github.com/ggml-org/whisper.cpp"
SRC_URI="https://github.com/ggml-org/whisper.cpp/archive/refs/tags/v${PV}.tar.gz -> ${MY_P}.tar.gz"

S="${WORKDIR}/${MY_P}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="blas cuda ffmpeg hip opencl sdl2 vulkan"

CDEPEND="blas? ( sci-libs/openblas )
	cuda? ( dev-util/nvidia-cuda-toolkit:= )
	ffmpeg? ( media-video/ffmpeg:= )
	hip? ( sci-libs/hipBLAS:= )
	opencl? ( sci-libs/clblast:= )
	sdl2? ( media-libs/libsdl2:= )"
DEPEND="${CDEPEND}
	vulkan? ( dev-util/vulkan-headers )
"
RDEPEND="${CDEPEND}
	vulkan? ( media-libs/vulkan-loader )
"
BDEPEND="vulkan? ( media-libs/shaderc )"

src_configure() {
	local mycmakeargs=(
		-DWHISPER_BUILD_EXAMPLES=ON
		-DWHISPER_BUILD_TESTS=OFF
		-DGGML_NATIVE=OFF
		-DGGML_CCACHE=OFF
		-DGGML_BLAS=$(usex blas)
		-DGGML_CLBLAST=$(usex opencl)
		-DGGML_CUDA=$(usex cuda)
		-DGGML_HIP=$(usex hip)
		-DGGML_VULKAN=$(usex vulkan)
		-DWHISPER_COMMON_FFMPEG=$(usex ffmpeg)
		-DWHISPER_SDL2=$(usex sdl2)
	)
	if use cuda; then
		# CUDA 13.x nvcc rejects gcc>15; pin host compiler when gcc-15 is present
		# (verified 2026-05-14: gcc-16 active, CUDA 13.2)
		local g15=/usr/bin/x86_64-pc-linux-gnu-g++-15
		[[ -x ${g15} ]] && mycmakeargs+=( -DCMAKE_CUDA_HOST_COMPILER="${g15}" )
	fi
	cmake_src_configure
}

src_install() {
	cmake_src_install

	newinitd "${FILESDIR}/${PN}.init" "${PN}"
	newconfd "${FILESDIR}/${PN}.confd" "${PN}"
}
