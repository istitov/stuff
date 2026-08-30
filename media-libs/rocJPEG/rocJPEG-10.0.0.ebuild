# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ROCM_SKIP_GLOBALS=1

inherit cmake rocm

DESCRIPTION="Hardware-accelerated JPEG decoding on AMD GPUs"
HOMEPAGE="https://github.com/ROCm/rocm-systems/tree/develop/projects/rocjpeg"
# New package; ::gentoo carries no rocJPEG. It drives the dedicated JPEG decode
# block on the GPU through VA-API and hands back the result as device memory,
# so a decode-then-infer pipeline never round-trips through the host.
#
# AMD retired the rocm-* release line at rocm-7.2.4 (2026-05-28); the 10.0
# source ships as the rocjpeg.tar.gz asset on the rocm-systems
# therock-<major.minor> release.
SRC_URI="https://github.com/ROCm/rocm-systems/releases/download/therock-$(ver_cut 1-2)/rocjpeg.tar.gz -> rocjpeg-${PV}.tar.gz"
S="${WORKDIR}/rocjpeg"

LICENSE="MIT"
# Versioned by the ROCm release rather than upstream's set(VERSION "1.7.0"),
# matching the rest of the stack.
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"

# Mirrors upstream's DEFAULT_GPU_TARGETS in CMakeLists.txt (its base list plus
# the OPTIONAL_GPU_TARGETS it probes for with rocm_check_target_ids). gfx1032 is
# in upstream's list but is dropped here: no amdgpu_targets_gfx1032 USE flag
# exists in ::gentoo or this overlay, so it cannot be expressed.
#
# Declaring these is NOT cosmetic -- see the GPU_TARGETS note in src_configure.
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

# libva is floored at 1.22 because rocJPEG checks the version itself and
# DOWNGRADES to an unbuildable configuration below it -- it sets Libva_FOUND
# back to FALSE and only prints "Libva Version Not Supported". See src_install
# for why that matters. verified 2026-08-30.
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
		# MUST be passed explicitly, and the amdgpu_targets_* IUSE above must
		# exist for it to be meaningful. Upstream computes a sensible
		# DEFAULT_GPU_TARGETS, but it only reaches the compiler if GPU_TARGETS
		# is otherwise unset -- and rocm.eclass makes AMDGPU_TARGETS a
		# USE_EXPAND, so portage always exports it. With no amdgpu_targets_*
		# in IUSE it is exported EMPTY, upstream's
		#     if((AMDGPU_TARGETS OR DEFINED ENV{AMDGPU_TARGETS}) AND NOT GPU_TARGETS)
		# fires on "defined but empty", and caches GPU_TARGETS as the empty
		# string. The later `set(GPU_TARGETS "${DEFAULT_GPU_TARGETS}" CACHE ...)`
		# is then a no-op, because a CACHE set never overwrites an existing
		# entry.
		#
		# The result is a build with NO --offload-arch at all, so hipcc falls
		# back to its built-in default and the colour-conversion kernels are
		# compiled for gfx906 alone. Nothing fails: the decode itself is VA-API
		# and works, but on any other GPU the kernel launch finds no code
		# object and ROCJPEG_OUTPUT_RGB / _RGB_PLANAR return
		# ROCJPEG_STATUS_SUCCESS with an all-zero buffer while _NATIVE,
		# _YUV_PLANAR and _Y look perfect. src_install asserts the built code
		# objects rather than trusting this. verified 2026-08-31.
		-DGPU_TARGETS="$(get_amdgpu_flags)"
		# Upstream defaults this to "lib". The assignment is a plain
		# `set(... CACHE STRING ...)` with no FORCE, so a command-line -D wins
		# and no sed is needed here -- unlike dev-libs/rocprofiler-register,
		# where the same-looking line is a bare set() and has to be patched.
		-DCMAKE_INSTALL_LIBDIR="$(get_libdir)"
		-DROCJPEG_ENABLE_ROCPROFILER_REGISTER=ON
		-Wno-dev
	)

	cmake_src_configure
}

src_install() {
	# rocJPEG wraps its ENTIRE add_library() in
	#     if(HIP_FOUND AND Libva_FOUND AND Libdrm_amdgpu_FOUND AND Threads_FOUND)
	# with no else branch and no fatal error. Miss any one of those -- an
	# unfound legacy FindHIP, a libva older than 1.22 -- and CMake configures,
	# ninja runs, the ebuild exits 0, and NOTHING WHATSOEVER is built. There is
	# no failure to catch anywhere in the build, so assert the artifact.
	[[ -f ${BUILD_DIR}/$(get_libdir)/librocjpeg.so ]] ||
		die "librocjpeg.so was not built -- one of HIP/libva/libdrm_amdgpu was not found and rocJPEG silently built nothing"

	# Assert that device code for every requested target actually landed in the
	# library. The GPU_TARGETS trap documented in src_configure produces a
	# perfectly good-looking build whose colour-conversion kernels exist only
	# for hipcc's default architecture, and the only symptom is
	# ROCJPEG_OUTPUT_RGB quietly returning zeroed pixels at runtime.
	local t
	for t in ${AMDGPU_TARGETS}; do
		strings "${BUILD_DIR}/$(get_libdir)/librocjpeg.so" |
			grep -q "amdgcn-amd-amdhsa--${t}" ||
			die "librocjpeg.so carries no device code for ${t}; GPU_TARGETS did not reach the compiler and the RGB output paths would silently return blank images"
	done

	cmake_src_install
}
