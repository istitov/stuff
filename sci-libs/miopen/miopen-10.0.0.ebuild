# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ROCM_VERSION=${PV}
# Tracks the ROCm 10.0 cohort's LLVM slot; the stack is subslot-pinned as a
# single dependency closure, so all of it must use one LLVM major.
LLVM_COMPAT=( 23 )

inherit cmake flag-o-matic llvm-r2 rocm

DESCRIPTION="AMD's Machine Intelligence Library"
HOMEPAGE="https://github.com/ROCm/rocm-libraries/tree/develop/projects/miopen"
# AMD retired the rocm-* release line at rocm-7.2.4 (2026-05-28); the same
# per-component assets ship under therock-<major.minor> tags now.
SRC_URI="https://github.com/ROCm/rocm-libraries/releases/download/therock-$(ver_cut 1-2)/miopen.tar.gz -> miopen-${PV}.tar.gz"
S="${WORKDIR}/miopen"

LICENSE="MIT"
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"

IUSE="composable-kernel debug +hipblaslt +rocblas roctracer"

REQUIRED_USE="
	${ROCM_REQUIRED_USE}
	composable-kernel? (
		|| ( amdgpu_targets_gfx908 amdgpu_targets_gfx90a amdgpu_targets_gfx942 amdgpu_targets_gfx950 )
	)
"

# Upstream's tests can freeze the machine depending on the GPU and kernel.
# Do not expose dead USE=test plumbing while the test phase is restricted.
RESTRICT="test"

RDEPEND="
	dev-util/hip:${SLOT}
	dev-db/sqlite:3
	app-arch/bzip2
	sci-libs/rocRAND:${SLOT}
	dev-libs/boost:=
	dev-libs/rocm-comgr:${SLOT}

	composable-kernel? ( sci-libs/composable-kernel:${SLOT} )
	hipblaslt? ( sci-libs/hipBLASLt:${SLOT} )
	rocblas? ( sci-libs/rocBLAS:${SLOT} )
	roctracer? ( dev-util/roctracer:${SLOT} )
"

# hipblaslt? pulls hipblas-common too: CMakeLists.txt does a second
# find_package(hipblas-common REQUIRED) right after the hipblaslt one, inside
# the same if(MIOPEN_USE_HIPBLASLT) block. sci-libs/hipBLASLt carries
# hipBLAS-common in its own DEPEND, which does not propagate, so a depcleaned
# system loses the cmake config and configure fails. Build-time only - the
# package ships no library we link against. verified 2026-07-27
DEPEND="
	${RDEPEND}
	dev-cpp/nlohmann_json
	>=dev-libs/half-1.12.0-r1
	hipblaslt? ( sci-libs/hipBLAS-common:${SLOT} )
	amdgpu_targets_gfx908? ( =dev-cpp/frugally-deep-0.15* dev-cpp/eigen:3 )
	amdgpu_targets_gfx940? ( =dev-cpp/frugally-deep-0.15* dev-cpp/eigen:3 )
	amdgpu_targets_gfx941? ( =dev-cpp/frugally-deep-0.15* dev-cpp/eigen:3 )
	amdgpu_targets_gfx942? ( =dev-cpp/frugally-deep-0.15* dev-cpp/eigen:3 )
"

BDEPEND="
	dev-build/rocm-cmake:${SLOT}
"

PATCHES=(
	"${FILESDIR}"/${PN}-10.0.0-ciso646.patch
)

src_prepare() {
	cmake_src_prepare

	# `sed` exits 0 on no-match: a stale anchor here would silently restore
	# clang-tidy as a hard build error, and re-add the -s that strips the
	# libraries before portage can.
	grep -qF 'MIOPEN_TIDY_ERRORS ALL' CMakeLists.txt ||
		die 'MIOPEN_TIDY_ERRORS ALL anchor moved in CMakeLists.txt'
	grep -qF 'FLAGS_RELEASE} -s' CMakeLists.txt ||
		die 'FLAGS_RELEASE} -s anchor moved in CMakeLists.txt'
	sed -e '/MIOPEN_TIDY_ERRORS ALL/d' \
		-e 's/FLAGS_RELEASE} -s/FLAGS_RELEASE}/g' \
		-i CMakeLists.txt || die

	# The add_test --build sed is GONE at 10.0: test/CMakeLists.txt now emits
	# `--build ${CMAKE_BINARY_DIR}`, i.e. the top-level build dir, which is
	# exactly the ${BUILD_DIR} the sed used to substitute in. It previously read
	# CMAKE_CURRENT_BINARY_DIR, which in test/ resolved one level too deep.
	# Carrying the sed forward would have been a silent no-op. verified 2026-08-30.
}

src_configure() {
	rocm_use_clang

	if ! use debug; then
		append-cflags "-DNDEBUG"
		append-cxxflags "-DNDEBUG"
		CMAKE_BUILD_TYPE="Release"
	else
		CMAKE_BUILD_TYPE="Debug"
	fi

	local use_ai_tuning=OFF
	if use amdgpu_targets_gfx908 || use amdgpu_targets_gfx940 || use amdgpu_targets_gfx941 \
	|| use amdgpu_targets_gfx942; then
		use_ai_tuning=ON
	fi

	# Too many warnings
	append-cxxflags -Wno-thread-safety-analysis

	local mycmakeargs=(
		-DCMAKE_SKIP_RPATH=ON
		-DGPU_TARGETS="$(get_amdgpu_flags)"
		-DCMAKE_INSTALL_PREFIX="${EPREFIX}/usr"
		-DMIOPEN_BACKEND=HIP
		-DBoost_USE_STATIC_LIBS=OFF
		-DMIOPEN_USE_MLIR=OFF
		-DMIOPEN_USE_ROCTRACER=$(usex roctracer ON OFF)
		-DMIOPEN_USE_ROCBLAS=$(usex rocblas ON OFF)
		-DMIOPEN_USE_HIPBLASLT=$(usex hipblaslt ON OFF)
		-DMIOPEN_USE_COMPOSABLEKERNEL=$(usex composable-kernel ON OFF)
		-DBUILD_TESTING=OFF
		-DROCM_SYMLINK_LIBS=OFF
		-DMIOPEN_HIP_COMPILER="${ESYSROOT}/usr/bin/hipcc"
		# Take these from the toolchain rocm_use_clang just selected, not from
		# the system LLVM slot. Otherwise MIOpen's GPU code is COMPILED by one
		# clang and ASSEMBLED by another; with hipcc[amd-llvm] that split is
		# fatal, because vanilla clang rejects the gfx assembly AMD's toolchain
		# emits. Resolves to the same paths when hipcc points at the system
		# LLVM. verified 2026-08-30.
		-DMIOPEN_AMDGCN_ASSEMBLER="${CC}"
		-DMIOPEN_OFFLOADBUNDLER_BIN="${CC%/*}/clang-offload-bundler"
		-DHIP_OC_COMPILER="${CC}"
		-DMIOPEN_ENABLE_AI_KERNEL_TUNING=${use_ai_tuning}
		-DMIOPEN_ENABLE_AI_IMMED_MODE_FALLBACK=${use_ai_tuning}
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install
}
