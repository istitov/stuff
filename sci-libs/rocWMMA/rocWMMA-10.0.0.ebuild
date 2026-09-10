# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ROCM_SKIP_GLOBALS=1

inherit cmake rocm

DESCRIPTION="library for accelerating mixed precision matrix multiply-accumulate operations"
HOMEPAGE="https://github.com/ROCm/rocm-libraries/tree/develop/projects/rocwmma"
# ::gentoo's slot-pinned 7.2.0 cannot coexist with ROCm 10. Since AMD retired
# rocm-* releases, use the rocwmma asset from the matching TheRock release.
SRC_URI="https://github.com/ROCm/rocm-libraries/releases/download/therock-$(ver_cut 1-2)/rocwmma.tar.gz -> rocwmma-${PV}.tar.gz"
S="${WORKDIR}/rocwmma"

LICENSE="MIT"
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"

# Mirror rocWMMA's own CMake target list, not rocm.eclass. 10.0 adds gfx1250;
# gfx1103 is only a source predicate, not a build target. # verified 2026-08-30
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

# amdsmi replaces rocm-smi and is test-only; the header library needs neither.
# verified 2026-08-30
DEPEND="
	dev-util/hip:${SLOT}
"
# Header-library interface dependency.
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
	# Remove unsupported hipcc flags; assert the anchors to catch upstream changes.
	# verified 2026-08-30
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
	# Prevent the test build from fetching googletest under network sandbox.
	use test && mycmakeargs+=(-DROCWMMA_USE_SYSTEM_GOOGLETEST=ON)
	cmake_src_configure
}

src_test() {
	check_amdgpu

	# gfx1100 takes about 936s at -j32; hide the APU by selecting the first GPU.
	HIP_VISIBLE_DEVICES=0 cmake_src_test
}
