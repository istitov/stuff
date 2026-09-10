# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ROCM_SKIP_GLOBALS=1

inherit cmake rocm

DESCRIPTION="Hardware-accelerated video decoding on AMD GPUs"
HOMEPAGE="https://github.com/ROCm/rocm-systems/tree/develop/projects/rocdecode"
# AMD retired rocm-* releases; use the rocdecode asset from the matching
# TheRock release.
SRC_URI="https://github.com/ROCm/rocm-systems/releases/download/therock-$(ver_cut 1-2)/rocdecode.tar.gz -> rocdecode-${PV}.tar.gz"
S="${WORKDIR}/rocdecode"

LICENSE="MIT"
# Slot by ROCm release, not upstream's VERSION=1.9.0.
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"

IUSE="+ffmpeg"

# Older libva silently clears Libva_FOUND instead of failing configuration.
# verified 2026-08-30
RDEPEND="
	>=media-libs/libva-1.22
	dev-libs/rocprofiler-register:${SLOT}
	dev-util/hip:${SLOT}
	x11-libs/libdrm[video_cards_amdgpu]
	ffmpeg? ( media-video/ffmpeg:= )
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-build/rocm-cmake:${SLOT}
"

src_configure() {
	rocm_use_clang

	local mycmakeargs=(
		# Override upstream's non-forced "lib" cache default.
		-DCMAKE_INSTALL_LIBDIR="$(get_libdir)"
		-DROCDECODE_ENABLE_ROCPROFILER_REGISTER=ON
		-DROCDECODE_ENABLE_HOST_DECODER=$(usex ffmpeg ON OFF)
		-Wno-dev
	)

	# Keep HIP in CONFIG mode for the hip::device target; legacy FindHIP only
	# sets HIP_FOUND and breaks this template.
	cmake_src_configure
}

src_install() {
	# Missing HIP/libva/libdrm silently skips the entire library; assert it.
	[[ -f ${BUILD_DIR}/$(get_libdir)/librocdecode.so ]] ||
		die "librocdecode.so was not built -- one of HIP/libva/libdrm_amdgpu was not found and rocDecode silently built nothing"

	# Missing FFmpeg likewise only skips the requested host decoder.
	if use ffmpeg; then
		[[ -f ${BUILD_DIR}/$(get_libdir)/librocdecode-host.so ]] ||
			die "librocdecode-host.so was not built -- FFmpeg was not found despite USE=ffmpeg"
	fi

	cmake_src_install

	# Remove ~89 MiB of test clips/reference frames; keep documented sample sources.
	rm -r "${ED}"/usr/share/${PN,,}/video || die
	rm -r "${ED}"/usr/share/${PN,,}/frames || die
}
