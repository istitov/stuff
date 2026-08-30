# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ROCM_SKIP_GLOBALS=1

inherit cmake rocm

DESCRIPTION="Hardware-accelerated video decoding on AMD GPUs"
HOMEPAGE="https://github.com/ROCm/rocm-systems/tree/develop/projects/rocdecode"
# New package; ::gentoo carries no rocDecode. Companion to media-libs/rocJPEG --
# same VCN hardware block, same VA-API path, same AMD CMake template -- but for
# video streams (H.264, HEVC, AV1, VP9) rather than still images, and it leaves
# decoded frames in device memory for a downstream HIP consumer.
#
# AMD retired the rocm-* release line at rocm-7.2.4 (2026-05-28); the 10.0
# source ships as the rocdecode.tar.gz asset on the rocm-systems
# therock-<major.minor> release.
SRC_URI="https://github.com/ROCm/rocm-systems/releases/download/therock-$(ver_cut 1-2)/rocdecode.tar.gz -> rocdecode-${PV}.tar.gz"
S="${WORKDIR}/rocdecode"

LICENSE="MIT"
# Versioned by the ROCm release rather than upstream's set(VERSION "1.9.0"),
# matching the rest of the stack.
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"

IUSE="+ffmpeg"

# libva floored at 1.22 for the same reason as media-libs/rocJPEG: rocDecode
# version-checks it and, if too old, quietly clears Libva_FOUND instead of
# failing. verified 2026-08-30.
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
		# Upstream defaults this to "lib" via `set(... CACHE STRING ...)` with
		# no FORCE, so a command-line -D wins and no sed is needed.
		-DCMAKE_INSTALL_LIBDIR="$(get_libdir)"
		-DROCDECODE_ENABLE_ROCPROFILER_REGISTER=ON
		-DROCDECODE_ENABLE_HOST_DECODER=$(usex ffmpeg ON OFF)
		-Wno-dev
	)

	# NB do NOT add dev-util/hip's legacy FindHIP directory to
	# CMAKE_MODULE_PATH here. HIP has to resolve in CONFIG mode so that the
	# hip::device imported target exists; the module only sets HIP_FOUND. See
	# media-libs/rocJPEG, which shares this CMake template, for the full trap.
	cmake_src_configure
}

src_install() {
	# Same swallow-everything guard as media-libs/rocJPEG: the whole
	# add_library() sits inside
	#     if(HIP_FOUND AND Libva_FOUND AND Libdrm_amdgpu_FOUND AND Threads_FOUND)
	# with no else branch, so a missing dependency yields a successful build
	# that produces no library at all. Assert the artifact.
	[[ -f ${BUILD_DIR}/$(get_libdir)/librocdecode.so ]] ||
		die "librocdecode.so was not built -- one of HIP/libva/libdrm_amdgpu was not found and rocDecode silently built nothing"

	# The host decoder is likewise skipped with only a yellow message when
	# FFmpeg is missing, so USE=ffmpeg has to be checked the same way rather
	# than assumed from the -D above.
	if use ffmpeg; then
		[[ -f ${BUILD_DIR}/$(get_libdir)/librocdecode-host.so ]] ||
			die "librocdecode-host.so was not built -- FFmpeg was not found despite USE=ffmpeg"
	fi

	cmake_src_install

	# Upstream installs its test fixtures: ~89M of sample clips under
	# share/rocdecode/video (the same H264/HEVC/AV1/VP9 encodings of one AMD
	# demo reel) plus reference frames. That is 95% of the install tree and is
	# build/CI material, not something a user of the library needs -- the
	# sample SOURCES under share/rocdecode/samples stay, since those are what
	# the documentation refers to. Anyone who wants the clips has the tarball.
	rm -r "${ED}"/usr/share/${PN,,}/video || die
	rm -r "${ED}"/usr/share/${PN,,}/frames || die
}
