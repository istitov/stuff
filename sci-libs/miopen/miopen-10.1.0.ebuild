# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ROCM_VERSION=${PV}
# Keep the subslot-pinned ROCm closure on one LLVM major.
LLVM_COMPAT=( 24 )

inherit cmake flag-o-matic llvm-r2 rocm

DESCRIPTION="AMD's Machine Intelligence Library"
HOMEPAGE="https://github.com/ROCm/rocm-libraries/tree/develop/projects/miopen"
# AMD retired rocm-* releases; use the matching TheRock component asset.
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

# Upstream tests can freeze some GPU/kernel combinations.
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

# hipBLASLt's non-propagating DEPEND does not satisfy MIOpen's separate required
# hipblas-common lookup; add it as build-only. # verified 2026-07-27
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

src_prepare() {
	cmake_src_prepare

	# Assert anchors before disabling fatal clang-tidy and upstream stripping.
	grep -qF 'MIOPEN_TIDY_ERRORS ALL' CMakeLists.txt ||
		die 'MIOPEN_TIDY_ERRORS ALL anchor moved in CMakeLists.txt'
	grep -qF 'FLAGS_RELEASE} -s' CMakeLists.txt ||
		die 'FLAGS_RELEASE} -s anchor moved in CMakeLists.txt'
	sed -e '/MIOPEN_TIDY_ERRORS ALL/d' \
		-e 's/FLAGS_RELEASE} -s/FLAGS_RELEASE}/g' \
		-i CMakeLists.txt || die
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

	append-cxxflags -Wno-thread-safety-analysis

	# 10.1 vendors hipconv: convolution kernels precompiled for gfx942 and
	# gfx950, serving no other GPU. Build it only when one of them is targeted.
	# verified 2026-10-09
	local use_hipconv=OFF hipconv_args=()
	if use amdgpu_targets_gfx942 || use amdgpu_targets_gfx950; then
		use_hipconv=ON
		# hipconv proves its LDS layouts in constexpr loops over std::array.
		# libstdc++'s assertions add steps to every access, and Clang stops
		# with "constexpr evaluation hit maximum step limit of 1048576". Its
		# kernels are HIP-language sources, which do not see CXXFLAGS.
		hipconv_args=( -DCMAKE_HIP_FLAGS="-fconstexpr-steps=16777216" )
	fi

	local mycmakeargs=(
		-DCMAKE_SKIP_RPATH=ON
		-DGPU_TARGETS="$(get_amdgpu_flags)"
		-DCMAKE_INSTALL_PREFIX="${EPREFIX}/usr"
		-DMIOPEN_BACKEND=HIP
		-DMIOPEN_USE_MLIR=OFF
		-DMIOPEN_USE_ROCTRACER=$(usex roctracer ON OFF)
		-DMIOPEN_USE_ROCBLAS=$(usex rocblas ON OFF)
		-DMIOPEN_USE_HIPBLASLT=$(usex hipblaslt ON OFF)
		-DMIOPEN_USE_COMPOSABLEKERNEL=$(usex composable-kernel ON OFF)
		-DMIOPEN_USE_HIPCONV=${use_hipconv}
		"${hipconv_args[@]}"
		-DBUILD_TESTING=OFF
		-DROCM_SYMLINK_LIBS=OFF
		-DMIOPEN_HIP_COMPILER="${ESYSROOT}/usr/bin/hipcc"
		# Use rocm_use_clang's toolchain for compilation and assembly. Mixing it
		# with system LLVM fails when hipcc[amd-llvm] emits AMD-only gfx assembly.
		# verified 2026-08-30
		-DMIOPEN_AMDGCN_ASSEMBLER="${CC}"
		-DMIOPEN_OFFLOADBUNDLER_BIN="${CC%/*}/clang-offload-bundler"
		-DMIOPEN_ENABLE_AI_KERNEL_TUNING=${use_ai_tuning}
		-DMIOPEN_ENABLE_AI_IMMED_MODE_FALLBACK=${use_ai_tuning}
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install
}
