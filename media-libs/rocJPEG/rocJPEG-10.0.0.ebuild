# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ROCM_SKIP_GLOBALS=1

inherit cmake rocm

DESCRIPTION="Hardware-accelerated JPEG decoding on AMD GPUs"
HOMEPAGE="https://github.com/ROCm/rocm-systems/tree/develop/projects/rocjpeg"
# rocJPEG decodes through VA-API directly into device memory; Gentoo has no package.
# ROCm 10 moved its source to rocjpeg.tar.gz on rocm-systems' therock-X.Y tag.
SRC_URI="https://github.com/ROCm/rocm-systems/releases/download/therock-$(ver_cut 1-2)/rocjpeg.tar.gz -> rocjpeg-${PV}.tar.gz"
S="${WORKDIR}/rocjpeg"

LICENSE="MIT"
# Slot by ROCm release rather than upstream's 1.7.0, matching the stack.
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"

# Mirror upstream's default and optional targets, excluding gfx1032 because no
# matching Gentoo USE flag exists. See the explicit GPU_TARGETS safeguard below.
IUSE_TARGETS=(
	gfx908 gfx90a gfx942 gfx950
	gfx1030 gfx1031
	gfx1100 gfx1101 gfx1102 gfx1150 gfx1151 gfx1152 gfx1153
	gfx1200 gfx1201 gfx1250
)
IUSE_TARGETS=( "${IUSE_TARGETS[@]/#/amdgpu_targets_}" )
ROCM_REQUIRED_USE=" || ( ${IUSE_TARGETS[*]} )"

IUSE="${IUSE_TARGETS[*]/#/+} test"
REQUIRED_USE="${ROCM_REQUIRED_USE}"
RESTRICT="!test? ( test )"

# Older libva merely clears Libva_FOUND, leading to a silent empty build.
# verified 2026-08-30
RDEPEND="
	>=media-libs/libva-1.22
	dev-libs/rocprofiler-register:${SLOT}
	dev-util/hip:${SLOT}
	x11-libs/libdrm[video_cards_amdgpu]
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-build/rocm-cmake:${SLOT}
"

src_configure() {
	rocm_use_clang

	local mycmakeargs=(
		# rocm.eclass exports AMDGPU_TARGETS even when empty, causing upstream to
		# cache an empty GPU_TARGETS and bypass its defaults. hipcc then emits only
		# gfx906 code: other GPUs return successful but zero-filled RGB output while
		# native/YUV paths work. Pass targets explicitly and verify them at install.
		# verified 2026-08-31
		-DGPU_TARGETS="$(get_amdgpu_flags)"
		# Override upstream's cache default without patching.
		-DCMAKE_INSTALL_LIBDIR="$(get_libdir)"
		-DROCJPEG_ENABLE_ROCPROFILER_REGISTER=ON
		-Wno-dev
	)

	cmake_src_configure
}

src_install() {
	# Missing HIP/libva/libdrm/Threads silently skips add_library; assert output.
	[[ -f ${BUILD_DIR}/$(get_libdir)/librocjpeg.so ]] ||
		die "librocjpeg.so was not built -- one of HIP/libva/libdrm_amdgpu was not found and rocJPEG silently built nothing"

	# A wrong architecture still links; assert every requested code object.
	local t
	for t in ${AMDGPU_TARGETS}; do
		strings "${BUILD_DIR}/$(get_libdir)/librocjpeg.so" |
			grep -q "amdgcn-amd-amdhsa--${t}" ||
			die "librocjpeg.so carries no device code for ${t}; GPU_TARGETS did not reach the compiler and the RGB output paths would silently return blank images"
	done

	cmake_src_install
}
