# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ROCM_SKIP_GLOBALS=1

inherit cmake rocm

DESCRIPTION="library for accelerating mixed precision matrix multiply-accumulate operations"
HOMEPAGE="https://github.com/ROCm/rocm-libraries/tree/develop/projects/rocwmma"
# Forked into ::stuff for ROCm 10.0: ::gentoo stops at 7.2.0, and rocWMMA pins
# dev-util/hip:${SLOT}, so a 7.2.0 rocWMMA cannot coexist with the 10.0 stack.
# It was the last ROCm component ::gentoo carried that this overlay did not.
#
# AMD retired the rocm-* release line at rocm-7.2.4 (2026-05-28); the 10.0
# source ships as the rocwmma.tar.gz asset on the rocm-libraries
# therock-<major.minor> release, the same shape sci-libs/rocPRIM uses.
SRC_URI="https://github.com/ROCm/rocm-libraries/releases/download/therock-$(ver_cut 1-2)/rocwmma.tar.gz -> rocwmma-${PV}.tar.gz"
S="${WORKDIR}/rocwmma"

LICENSE="MIT"
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"

# Mirrors upstream's DEFAULT_GPU_TARGETS rocm_check_target_ids() list in
# CMakeLists.txt, which rocWMMA maintains separately from the rest of the stack
# -- so this is hand-written rather than taken from rocm.eclass.
#
# Re-read from the therock-10.0 asset 2026-08-30: 10.0 ADDS gfx1250 over
# ::gentoo's 7.2.0 list. gfx1103 is deliberately NOT here: it has a
# ROCWMMA_ARCH_GFX1103 macro in library/include/rocwmma/internal/config.hpp but
# is absent from the CMake target list, so it is a source-level arch predicate
# rather than a shipped build target.
IUSE_TARGETS=(
	gfx908 gfx90a gfx942 gfx950
	gfx1100 gfx1101 gfx1102 gfx1150 gfx1151 gfx1152 gfx1153
	gfx1200 gfx1201 gfx1250
)
IUSE_TARGETS=( "${IUSE_TARGETS[@]/#/amdgpu_targets_}" )
ROCM_REQUIRED_USE=" || ( ${IUSE_TARGETS[*]} )"

IUSE="${IUSE_TARGETS[*]/#/+} test"
REQUIRED_USE="test? ( ${ROCM_REQUIRED_USE} )"

RESTRICT="!test? ( test )"

# ::gentoo's 7.2.0 ebuild also carries dev-util/rocm-smi:${SLOT} here. Dropped:
# at 10.0 upstream migrated to amdsmi (find_package(amd_smi) in CMakeLists.txt,
# <amd_smi/amdsmi.h> in test/hip_device.cpp) and no rocm_smi reference is left
# anywhere in the tree. The library itself needs neither -- the find_package is
# guarded by ROCWMMA_BUILD_BENCHMARK_TESTS, and with it off AMD_SMI_LIBRARY
# stays empty, so the INTERFACE target links nothing extra. Only the test
# executables need it, via hip_device.cpp, which is in
# ROCWMMA_COMMON_TEST_SOURCES and therefore linked into every test binary.
# verified 2026-08-30.
DEPEND="
	dev-util/hip:${SLOT}
"
# interface dependencies of header library
RDEPEND="${DEPEND}"

BDEPEND="
	test? (
		>=dev-cpp/gtest-1.16.0
		dev-util/amdsmi:${SLOT}
		sci-libs/rocBLAS:${SLOT}
	)
	dev-build/rocm-cmake:${SLOT}
"

PATCHES=(
	"${FILESDIR}"/${PN}-7.2.0-no-test-install.patch
)

src_prepare() {
	# unknown arguments for hipcc.
	#
	# The anchors are asserted first: `sed` exits 0 on no-match, so an upstream
	# flag removal would otherwise leave the substitution silently inert and the
	# build would fail later with an unrelated-looking hipcc error. Both are
	# still present in CMAKE_CXX_FLAGS at 10.0; verified 2026-08-30.
	grep -q -- '-parallel-jobs=4' CMakeLists.txt ||
		die "-parallel-jobs=4 gone from CMakeLists.txt; upstream likely dropped it, so drop that expression"
	grep -q -- '-Xclang -fallow-half-arguments-and-returns' CMakeLists.txt ||
		die "-fallow-half-arguments-and-returns gone from CMakeLists.txt; upstream likely dropped it, so drop that expression"
	sed -e "s/ -parallel-jobs=4//" \
		-e "s/ -Xclang -fallow-half-arguments-and-returns//" \
		-i CMakeLists.txt || die

	cmake_src_prepare
}

src_configure() {
	rocm_use_clang

	local mycmakeargs=(
		-DGPU_TARGETS="$(get_amdgpu_flags)"
		-DROCWMMA_BUILD_SAMPLES=OFF
		-DROCWMMA_BUILD_TESTS="$(usex test)"
	)
	# Without this the test build FetchContent-clones googletest, which cannot
	# work under network-sandbox.
	use test && mycmakeargs+=(-DROCWMMA_USE_SYSTEM_GOOGLETEST=ON)
	cmake_src_configure
}

src_test() {
	check_amdgpu

	# Expected time on gfx1100 is 1260s (-j1) or 936s (-j32)
	# Visible devices are limited to the first one to exclude APU (if not disabled in the BIOS)
	HIP_VISIBLE_DEVICES=0 cmake_src_test
}
