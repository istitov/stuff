# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DOCS_BUILDER="doxygen"
DOCS_DEPEND="media-gfx/graphviz"
ROCM_SKIP_GLOBALS=1

# Tracks the ROCm 10.0 cohort's LLVM slot. The stack is subslot-pinned as a
# single dependency closure, so all of it must be compiled by one LLVM major;
# dev-libs/rocm-device-libs-10.0.0 requires clang 23.
LLVM_COMPAT=( 23 )

inherit cmake docs flag-o-matic llvm-r2 rocm

DESCRIPTION="C++ Heterogeneous-Compute Interface for Portability"
HOMEPAGE="https://github.com/ROCm/rocm-systems/tree/develop/projects/clr"
if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_SUBMODULES=()
	EGIT_REPO_URI="https://github.com/ROCm/rocm-systems.git"
	S="${WORKDIR}/${P}/projects/clr"
	TEST_S="${WORKDIR}/${P}/projects/hip-tests"
	HIP_S="${WORKDIR}/${P}/projects/hip"
	SLOT="0/10.0"
else
	# AMD retired the rocm-* release line at rocm-7.2.4 (2026-05-28); the same
	# per-component assets ship under therock-<major.minor> tags now. ROCm 10.0
	# is the renumbering of the 7.13 -> 7.14 line (2026-08-27), not a jump of
	# three majors. The clr.tar.gz asset is shared with
	# dev-libs/rocm-opencl-runtime.
	MY_BASE="https://github.com/ROCm/rocm-systems/releases/download/therock-$(ver_cut 1-2)"
	SRC_URI="
		${MY_BASE}/clr.tar.gz -> rocm-clr-${PV}.tar.gz
		${MY_BASE}/${PN}.tar.gz -> ${P}.tar.gz
		test? (
			${MY_BASE}/hip-tests.tar.gz -> hip-tests-${PV}.tar.gz
		)
	"
	S="${WORKDIR}/clr/"
	TEST_S="${WORKDIR}/hip-tests/catch"
	HIP_S="${WORKDIR}/hip"
	KEYWORDS="~amd64"
	SLOT="0/$(ver_cut 1-2)"
fi

LICENSE="MIT"

IUSE="debug +hip numa opencl test video_cards_amdgpu video_cards_nvidia"

# many tests are broken; also tests run against installed version, not built one
RESTRICT="test"

REQUIRED_USE="
	|| ( hip opencl )
	^^ ( video_cards_amdgpu video_cards_nvidia )
"

DEPEND="
	video_cards_amdgpu? (
		dev-util/rocminfo:${SLOT}
		dev-libs/rocm-comgr:${SLOT}
		dev-libs/rocr-runtime:${SLOT}
	)
	video_cards_nvidia? ( dev-libs/hipother:${SLOT} )
	x11-base/xorg-proto
	virtual/opengl[X]
	numa? ( sys-process/numactl )
"
BDEPEND="
	video_cards_amdgpu? (
		dev-util/hipcc:${SLOT}
	)
	test? (
		media-libs/freeglut
		$(llvm_gen_dep "
			dev-util/spirv-llvm-translator:\${LLVM_SLOT}
		")
	)
"
RDEPEND="${DEPEND}
	~dev-libs/rocm-core-${PV}
	opencl? (
		!dev-libs/opencl-icd-loader
		!dev-libs/rocm-opencl-runtime
		!dev-util/clinfo
		!dev-util/opencl-headers
	)
	video_cards_amdgpu? (
		dev-util/hipcc:${SLOT}
		dev-libs/rocm-device-libs:${SLOT}
		dev-libs/roct-thunk-interface:${SLOT}
	)
"

# Both libc++ workarounds are obsolete at 10.0 and are NOT carried:
#
#   fix-libcxx-ranges  pre-included <__ranges/join_view.h> ahead of HIP's
#                      `#define __local`, because libc++'s <ranges> uses
#                      __local as an identifier. 10.0 removed that #define
#                      from the tree entirely (device_library_decls.h is now
#                      108 lines and defines it nowhere).
#   clr-fix-libcxx     had two halves. The __local save/restore died with the
#                      same removal. The other half added
#                      <__clang_hip_math.h> because
#                      <__clang_cuda_complex_builtins.h> referred to ::max --
#                      but that header now uses __builtin_fmax/__builtin_fmaxf
#                      instead, and including the two CUDA headers in the old
#                      order compiles cleanly without it.
#
# An intermediate revision of this ebuild kept a regenerated
# ${PN}-10.0.0-clr-fix-libcxx.patch for the second half; that was based on the
# patch's stated rationale rather than on re-reading the 10.0 header, and is
# dropped. verified 2026-08-30 by compiling the include pair against clang 23.
PATCHES=(
	"${FILESDIR}/${PN}-6.3.0-no-isystem-usr-include.patch"
	# Supersedes ${PN}-7.0.2-fix-libcxx-noinline.patch: same defect, but GCC 16's
	# libstdc++ hits it too, not just libc++. The 7.2.x ebuilds keep the older,
	# libc++-only version.
	"${FILESDIR}/${PN}-10.0.0-fix-stdlib-noinline.patch"
	"${FILESDIR}/${PN}-7.1.0-no-hipother-install.patch"
	# Without this, hipStreamCreate() segfaults outright on an AVX-512 host.
	"${FILESDIR}/${PN}-10.0.0-aligned-new.patch"
)

QA_FLAGS_IGNORED="usr/lib.*/libhiprtc-builtins.*"

src_unpack() {
	# rocm 7.2.4 release-asset tarballs carry their own clr/, hip/ and
	# hip-tests/ top-level directories (7.2.3's unpacked flat, hence the
	# manual wrapper dirs previously). Unpack directly into ${WORKDIR} so
	# the tarball roots land where S=/HIP_S=/TEST_S= already expect them.
	unpack "rocm-clr-${PV}.tar.gz"
	unpack "${P}.tar.gz"
	use test && unpack "hip-tests-${PV}.tar.gz"
}

hip_test_wrapper() {
	local CMAKE_USE_DIR="${TEST_S}"
	local BUILD_DIR="${TEST_S}_build"
	cd "${TEST_S}" || die
	"${@}"
}

src_prepare() {
	pushd "${HIP_S}" >/dev/null || die

	# hipamd is itself built by cmake, and should never provide a
	# FindHIP.cmake module. But the reality is some package relies on it.
	# Set HIP and HIP Clang paths directly, don't search using heuristics
	# These two anchor on COMMENT TEXT, which upstream can reword at any time,
	# and `sed` exits 0 on no-match so `|| die` would never fire. A silent miss
	# here means FindHIP.cmake falls back to path heuristics instead of Gentoo's
	# real prefixes. Assert both. verified 2026-08-29: still present at 10.0.
	grep -q '# Search for HIP installation' cmake/FindHIP.cmake ||
		die "FindHIP.cmake 'Search for HIP installation' comment anchor moved"
	grep -q '#Set HIP_CLANG_PATH' cmake/FindHIP.cmake ||
		die "FindHIP.cmake 'Set HIP_CLANG_PATH' comment anchor moved"
	sed -e "s:# Search for HIP installation:set(HIP_ROOT_DIR \"${EPREFIX}/usr\"):" \
		-e "s:#Set HIP_CLANG_PATH:set(HIP_CLANG_PATH \"$(get_llvm_prefix -d)/bin\"):" \
		-i "cmake/FindHIP.cmake" || die
	popd >/dev/null || die

	sed -e "s/ -Werror//g" -i "hipamd/src/CMakeLists.txt" || die

	# do not install /usr/share/doc/${P}-asan
	sed -e "/asan COMPONENT asan/d" -i hipamd/packaging/CMakeLists.txt || die

	# `sed` exits 0 on no-match: leaves the placeholder unsubstituted in the installed cmake config
	grep -qF '@HIP_INSTALLS_HIPCC@' hipamd/hip-config.cmake.in ||
		die "@HIP_INSTALLS_HIPCC@ anchor moved in hipamd/hip-config.cmake.in"
	sed -e "s/@HIP_INSTALLS_HIPCC@/ON/g" -i hipamd/hip-config.cmake.in || die

	# skip installation of hipcc: installed via dev-util/hipcc.
	# Load-bearing: without it hip installs its own hipcc and collides with
	# dev-util/hipcc, so a silent no-match would be a file collision at merge.
	grep -qF 'NOT ${HIPCC_BIN_DIR}' "hipamd/CMakeLists.txt" ||
		die "HIPCC_BIN_DIR anchor moved; hip would install a colliding hipcc"
	sed -e "s/NOT \${HIPCC_BIN_DIR}/INSTALL_HIPCC AND NOT \${HIPCC_BIN_DIR}/" \
		-i "hipamd/CMakeLists.txt" || die

	# hipamd/src/hiprtc/cmake/hiprtc-config.cmake.in was in this list through
	# 7.2.4 but carries no cmake_minimum_required at all at 10.0, so listing it
	# would be a silent no-op. Only the two vendored Khronos files still need
	# it. verified 2026-08-29.
	local f
	for f in opencl/khronos/icd/CMakeLists.txt \
		opencl/khronos/headers/opencl2.2/tests/CMakeLists.txt; do
		grep -qE 'cmake_minimum_required.*3\.[35]' "${f}" ||
			die "cmake_minimum_required 3.[35] anchor moved in ${f}"
	done
	sed -e "/cmake_minimum_required/ s/3\.[35]/3.10/" \
		-i opencl/khronos/icd/CMakeLists.txt \
		-i opencl/khronos/headers/opencl2.2/tests/CMakeLists.txt || die

	cmake_src_prepare

	if use test; then
		local PATCHES=()
		# Of the four substitutions this branch used to make, only
		# "-Wall -Wextra " still matches at 10.0. Dropped as silent no-ops:
		# "-Werror " (gone from the catch CMakeLists),
		# cmake_policy(SET CMP0037 OLD) (gone), and /opt/rocm/bin (gone from
		# hipTestMain/hip_test_context.cc). Note RESTRICT="test" means this
		# branch does not normally run, which is why they went unnoticed.
		# verified 2026-08-30 against hip-tests-10.0.0.
		grep -q -- '-Wall -Wextra ' "${TEST_S}/CMakeLists.txt" ||
			die "hip-tests -Wall -Wextra anchor moved"
		sed -e "s/-Wall -Wextra //" -i "${TEST_S}/CMakeLists.txt" || die

		hip_test_wrapper cmake_src_prepare
	fi
}

src_configure() {
	# -Werror=strict-aliasing
	# https://bugs.gentoo.org/858383
	# https://github.com/ROCm/clr/issues/64
	#
	# Do not trust it for LTO either
	append-flags -fno-strict-aliasing
	filter-lto

	use debug && CMAKE_BUILD_TYPE="Debug"

	# Fix ld.lld linker error: https://github.com/ROCm/HIP/issues/3382
	# See also: https://github.com/gentoo/gentoo/pull/29097
	append-ldflags $(test-flags-CCLD -Wl,--undefined-version)

	local mycmakeargs=(
		-DCMAKE_PREFIX_PATH="$(get_llvm_prefix)"
		-DCMAKE_SKIP_RPATH=ON
		-D__HIP_ENABLE_PCH=OFF

		-DCLR_BUILD_HIP="$(usex hip)"
		-DCLR_BUILD_OCL="$(usex opencl)"

		-DHIP_COMMON_DIR="${HIP_S}"
		-DHIP_ENABLE_ROCPROFILER_REGISTER=OFF
		-DHIPCC_BIN_DIR="${EPREFIX}/usr/bin"
		-DROCM_PATH="${EPREFIX}/usr"

		-DCMAKE_DISABLE_FIND_PACKAGE_Git=ON
	)

	if use video_cards_amdgpu; then
		mycmakeargs+=(
			-DHIP_PLATFORM="amd"
			-DOpenGL_GL_PREFERENCE="GLVND"
			-DUSE_PROF_API=OFF
			# clr 7.2.3 dropped its find_package(NUMA), so cmake silently
			# ignores these; kept aligned with ::gentoo in case upstream
			# restores NUMA detection — verified inert 2026-05-08.
			-DCMAKE_DISABLE_FIND_PACKAGE_NUMA="$(usex !numa)"
			-DCMAKE_REQUIRE_FIND_PACKAGE_NUMA="$(usex numa)"
		)
	elif use video_cards_nvidia; then
		mycmakeargs+=(
			-DHIPNV_DIR="${EPREFIX}/usr"
			-DHIP_PLATFORM="nvidia"
		)
	fi

	cmake_src_configure

	if use test; then
		local mycmakeargs=(
			-DCMAKE_MODULE_PATH="${TEST_S}/external/Catch2/cmake/Catch2"
			-DROCM_PATH="${EPREFIX}/usr"
			-DCMAKE_NO_SYSTEM_FROM_IMPORTED=ON
			-Wno-dev

			# 1) Use custom build of hipamd instead of system one
			# 2) Build fails with libc++: https://github.com/llvm/llvm-project/issues/119076
			-DCMAKE_CXX_FLAGS="-I${BUILD_DIR}/hipamd/include -stdlib=libstdc++"
			-DCMAKE_EXE_LINKER_FLAGS="-L${BUILD_DIR}/hipamd/lib"
		)
		if use video_cards_amdgpu; then
			mycmakeargs+=(
				-DHIP_PLATFORM="amd"
			)
		elif use video_cards_nvidia; then
			mycmakeargs+=(
				-DHIP_PLATFORM="nvidia"
			)
		fi
		hip_test_wrapper cmake_src_configure
	fi
}

src_compile() {
	cmake_src_compile

	if use test; then
		hip_test_wrapper cmake_src_compile build_tests
	fi
}

src_install() {
	cmake_src_install

	# clang 23's HIP toolchain appends the HIP runtime to the link line as a
	# HARDCODED "<hip-path>/lib/libamdhip64.so" -- note the literal "lib",
	# which assumes a non-multilib ROCm layout. On Gentoo the library lives in
	# $(get_libdir) (lib64 here), so every HIP link fails with
	#     ld: cannot find /usr/lib/libamdhip64.so: No such file or directory
	# even though CMake itself passes the correct lib64 path via the
	# hip::amdhip64 imported target.
	#
	# Neither --rocm-path nor --hip-path changes the "lib" component (verified
	# 2026-08-29 with clang 23.1.0: both still emit /usr/lib/libamdhip64.so),
	# and clang 22 did not add the library at all, so this is new in 23 and
	# cannot be worked around per-consumer. Ship a compat symlink.
	#
	# Guarded so it is a no-op on a profile whose libdir already IS "lib",
	# where the link would otherwise point at itself.
	if [[ $(get_libdir) != lib ]]; then
		dosym -r "/usr/$(get_libdir)/libamdhip64.so" /usr/lib/libamdhip64.so
	fi
}

src_test() {
	check_amdgpu
	export LD_LIBRARY_PATH="${BUILD_DIR}/hipamd/lib"
	export ROCM_PATH="${EPREFIX}/usr"

	# TODO: research how to test Vulkan-related features.
	local CMAKE_SKIP_TESTS=(
		Unit_hipExternalMemoryGetMappedBuffer_Vulkan_Positive_Read_Write
		Unit_hipExternalMemoryGetMappedBuffer_Vulkan_Negative_Parameters
		Unit_hipImportExternalMemory_Vulkan_Negative_Parameters
		Unit_hipWaitExternalSemaphoresAsync_Vulkan_Positive_Binary_Semaphore
		Unit_hipWaitExternalSemaphoresAsync_Vulkan_Positive_Multiple_Semaphores
		Unit_hipWaitExternalSemaphoresAsync_Vulkan_Negative_Parameters
		Unit_hipSignalExternalSemaphoresAsync_Vulkan_Positive_Binary_Semaphore
		Unit_hipSignalExternalSemaphoresAsync_Vulkan_Positive_Multiple_Semaphores
		Unit_hipSignalExternalSemaphoresAsync_Vulkan_Negative_Parameters
		Unit_hipImportExternalSemaphore_Vulkan_Negative_Parameters
		Unit_hipDestroyExternalSemaphore_Vulkan_Negative_Parameters
	)

	hip_test_wrapper cmake_src_test -j1
}
