# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ROCM_SKIP_GLOBALS=1

inherit cmake rocm

DESCRIPTION="High-performance tensor contraction, reduction and permutation library"
HOMEPAGE="https://github.com/ROCm/rocm-libraries/tree/develop/projects/hiptensor"
# AMD's cuTENSOR-like API uses composable-kernel instances; Gentoo has no package.
# ROCm 10 moved its source to hiptensor.tar.gz on the rocm-libraries therock-X.Y tag.
SRC_URI="https://github.com/ROCm/rocm-libraries/releases/download/therock-$(ver_cut 1-2)/hiptensor.tar.gz -> hiptensor-${PV}.tar.gz"
S="${WORKDIR}/hiptensor"

LICENSE="MIT"
# Slot by ROCm release rather than upstream's 2.4.0, matching the stack.
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"

# From SUPPORTED_ARCHITECTURES, excluding generic compiler pseudo-targets.
# verified 2026-08-30
IUSE_TARGETS=(
	gfx908 gfx90a gfx942 gfx950
	gfx1100 gfx1101 gfx1102 gfx1103 gfx1150 gfx1151 gfx1152 gfx1153
	gfx1200 gfx1201 gfx1250
)
IUSE_TARGETS=( "${IUSE_TARGETS[@]/#/amdgpu_targets_}" )
ROCM_USEDEP_OPTFLAGS=${IUSE_TARGETS[*]/%/(-)?}
ROCM_USEDEP=${ROCM_USEDEP_OPTFLAGS// /,}
ROCM_REQUIRED_USE=" || ( ${IUSE_TARGETS[*]} )"

IUSE="${IUSE_TARGETS[*]/#/+} test"
REQUIRED_USE="${ROCM_REQUIRED_USE}"

RESTRICT="!test? ( test )"

# The default composable-kernel build omits hipTensor's required contraction,
# reduction, and other-operation components. Its hiptensor and MIOpen filters
# form a union, so enabling both preserves MIOpen's instances.
# CK is build-only: hipTensor compiles its header templates into the library;
# objdump and installed CMake metadata depend only on HIP. verified 2026-08-31
RDEPEND="
	dev-util/hip:${SLOT}
"
DEPEND="
	${RDEPEND}
	sci-libs/composable-kernel:${SLOT}[hiptensor]
"
BDEPEND="
	dev-build/rocm-cmake:${SLOT}
	test? ( dev-cpp/gtest )
"

# RDNA builds but is unusable in 10.0: gfx1150 contraction returns ARCH_MISMATCH;
# all contraction instances are CDNA XDL kernels, with no WMMA/DL alternatives.
# Keep RDNA flags to mirror SUPPORTED_ARCHITECTURES; retest when WMMA appears.
# verified 2026-08-31

src_configure() {
	rocm_use_clang

	local mycmakeargs=(
		-DGPU_TARGETS="$(get_amdgpu_flags)"
		-DHIPTENSOR_BUILD_TESTS=$(usex test ON OFF)
		-DHIPTENSOR_BUILD_SAMPLES=OFF
		-Wno-dev
	)

	# Defined only by the test subdirectory; when enabled, avoid its FetchContent.
	use test && mycmakeargs+=( -DHIPTENSOR_USE_SYSTEM_GOOGLETEST=ON )

	cmake_src_configure
}

src_install() {
	# An empty target set silently builds an API-compatible stub returning
	# NOT_SUPPORTED. Assert the configured outcome because its filename is normal.
	grep -q 'HIPTENSOR_DISABLE_DEVICE:.*=OFF' "${BUILD_DIR}"/CMakeCache.txt ||
		die "hipTensor fell back to its stub library -- no device backend was built"

	cmake_src_install
}
