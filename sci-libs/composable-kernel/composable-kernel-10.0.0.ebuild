# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ROCM_VERSION=${PV}
PYTHON_COMPAT=( python3_{12..14} )

inherit check-reqs cmake flag-o-matic multiprocessing python-r1 rocm

GTEST_COMMIT="b85864c64758dec007208e56af933fc3f52044ee"
GTEST_FILE="gtest-1.14.0_p20220421.tar.gz"

DESCRIPTION="High Performance Composable Kernel for AMD GPUs"
HOMEPAGE="https://github.com/ROCm/composable_kernel"
# AMD retired the rocm-* release line at rocm-7.2.4 (2026-05-28); the same
# per-component assets ship under therock-<major.minor> tags now. Note the
# asset name has no separator: composablekernel.tar.gz.
MY_BASE="https://github.com/ROCm/rocm-libraries/releases/download/therock-$(ver_cut 1-2)"
SRC_URI="${MY_BASE}/composablekernel.tar.gz -> ${P}.tar.gz
	test? ( https://github.com/google/googletest/archive/${GTEST_COMMIT}.tar.gz -> ${GTEST_FILE} )"
S="${WORKDIR}/composablekernel"

LICENSE="MIT"
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"

IUSE="debug profiler test"
REQUIRED_USE="${ROCM_REQUIRED_USE} ${PYTHON_REQUIRED_USE}"
RESTRICT="!test? ( test )"

RDEPEND="
	dev-util/hip:${SLOT}
	${PYTHON_DEPS}
"

DEPEND="${RDEPEND}"

# dev-util/hipcc[amd-llvm] is a build requirement, not documentation.
# rocm_use_clang() resolves the compiler via `hipconfig --hipclangpath`, and
# hipcc points that at llvm-core/rocm-llvm only when the flag is set. This
# package cannot be compiled by a vanilla LLVM: amd_wmma.hpp passes bhalf16_t
# (a __bf16 vector) to __builtin_amdgcn_wmma_f32_16x16x16_bf16_w32, which
# vanilla clang 23 declares as taking short __attribute__((ext_vector_type(16))).
# Until now that requirement lived only in a profiles/package.mask comment, so
# building against a hipcc without the flag died deep in compilation with no
# resolver-level signal. hipconfig belongs to hipcc and was reached only
# transitively through dev-util/hip, which cannot carry the USE-dep.
#
# Unconditional deliberately. Every failure on record is a gfx11xx/gfx12xx one,
# so a narrower amdgpu_targets_*? form may well be correct -- but nobody has
# built this against a vanilla LLVM for a CDNA-only target, and claiming
# support that was never verified is the worse error. Narrow it once someone
# has that build. # verified 2026-08-30
BDEPEND="
	dev-build/rocm-cmake:${SLOT}
	dev-util/hipcc:${SLOT}[amd-llvm]
"

PATCHES=(
	# no-git-no-hash and conditional-ckprofiler are both obsolete at 10.0:
	#   no-git-no-hash        - it downgraded find_package(Git REQUIRED) so
	#                           release tarballs without .git would configure.
	#                           Upstream rewrote the block to do exactly that:
	#                           plain find_package(Git), a COMMIT_ID default of
	#                           "unknown", an if(GIT_FOUND) guard and
	#                           RESULT_VARIABLE/ERROR_QUIET to "degrade
	#                           gracefully when building from a release tarball
	#                           without a .git directory".
	#   conditional-ckprofiler - it added a CK_USE_PROFILER escape hatch so the
	#                           multi-GB ckprofiler could be skipped. Upstream
	#                           now gates it on its own BUILD_CK_PROFILER
	#                           option, which src_configure uses instead.
	# libcxx-includes and expand-isa are regenerated; see their headers for
	# what 10.0 absorbed. All verified 2026-08-29.
	"${FILESDIR}"/${PN}-6.3.0-conditional-kernels.patch
	"${FILESDIR}"/${PN}-10.0.0-libcxx-includes.patch
	"${FILESDIR}"/${PN}-10.0.0-expand-isa.patch
	"${FILESDIR}"/${PN}-10.0.0-clang23-buffer-load-types.patch
)

ck_check-reqs() {
	[[ ${MERGE_TYPE} == binary ]] && return

	targets=($AMDGPU_TARGETS)
	if [[ ${#targets[@]} -gt 1 ]]; then
		ewarn "composable-kernel will be compiled for multiple GPU architectures,"
		ewarn "which will take a significant amount of time."
		ewarn "Please consider setting AMDGPU_TARGETS USE_EXPAND variable to a single architecture."
	fi

	# It takes ~3GB of RAM per build thread
	local user_jobs=$(makeopts_jobs)
	local available_memory_mb=$(free -m | awk '/Mem:/ {print $7}')
	local max_jobs=$(( available_memory_mb / 2048 ))
	max_jobs=$(( max_jobs < 1 ? 1 : max_jobs ))
	local limited_jobs=$(( user_jobs < max_jobs ? user_jobs : max_jobs ))
	if [[ "${max_jobs}" -lt "${user_jobs}" ]]; then
		ewarn "${available_memory_mb} MB of free RAM is not enough for ${user_jobs} parallel build jobs (~2Gb per job)."
		ewarn "Please consider setting MAKEOPTS=\"-j${limited_jobs}\" for this package."
	fi

	local CHECKREQS_MEMORY=$((user_jobs*3072))M
	check-reqs_${EBUILD_PHASE_FUNC}
}

pkg_pretend() {
	ck_check-reqs
}

pkg_setup() {
	ck_check-reqs
}

src_prepare() {
	# `sed` exits 0 on no-match, so a silent miss here leaves -Werror in place
	# and turns any warning a newer compiler emits into a hard build failure.
	# verified 2026-08-30 against the therock-10.0 source.
	grep -q -- '-Werror' cmake/EnableCompilerWarnings.cmake ||
		die "-Werror anchor moved in EnableCompilerWarnings.cmake"
	sed -e '/-Werror/d' -i cmake/EnableCompilerWarnings.cmake || die

	# don't build examples -- a silent miss builds and installs the whole
	# example tree, a large and slow addition that would look like a normal
	# (just much longer) build. verified 2026-08-30.
	grep -q 'add_subdirectory(example)' CMakeLists.txt ||
		die "add_subdirectory(example) anchor moved; the example tree would be built"
	sed -e "/add_subdirectory(example)/d" -i CMakeLists.txt || die

	# Flag -amdgpu-early-inline-all explodes memory consumption
	# https://github.com/llvm/llvm-project/issues/86332
	# Load-bearing: these two -mllvm flags make the compiler inline every
	# device function, which OOMs the build (llvm-project#86332). `sed` exits 0
	# on no-match, so a silent miss here would quietly reintroduce a build that
	# exhausts RAM rather than failing fast. verified 2026-08-29: both still
	# present (twice each) at therock-10.0.
	local f
	for f in amdgpu-early-inline-all amdgpu-function-calls; do
		grep -q -- "${f}" CMakeLists.txt ||
			die "-${f} anchor moved; build would OOM"
	done
	sed -e "/-amdgpu-early-inline-all/d" -e "/-amdgpu-function-calls/d" -i CMakeLists.txt || die

	cmake_src_prepare
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

	local mycmakeargs=(
		-DCMAKE_SKIP_RPATH=ON
		-DBUILD_DEV=OFF
		-DGPU_TARGETS="$(get_amdgpu_flags)"
		-DCMAKE_INSTALL_PREFIX="${EPREFIX}/usr"
		-DBUILD_TESTING=$(usex test ON OFF)
		# Was -DCK_USE_PROFILER, a flag introduced by our own
		# conditional-ckprofiler patch. ROCm 10.0 provides BUILD_CK_PROFILER
		# upstream, so the patch is dropped and we drive the real option.
		-DBUILD_CK_PROFILER=$(usex profiler ON OFF)

		# Builds 2x less files, but faster.
		# See https://github.com/ROCm/TheRock/blob/5cb6abaa43ad664c85a99ac37bd4d3abf9b6260e/ml-libs/CMakeLists.txt#L37
		-DMIOPEN_REQ_LIBS_ONLY=ON
		-Wno-dev
	)

	# Since 6.4.1 "fallback" DL kernels should be enabled manually...
	if use amdgpu_targets_gfx1010 || use amdgpu_targets_gfx1011 || use amdgpu_targets_gfx1012 \
	|| use amdgpu_targets_gfx1030 || use amdgpu_targets_gfx1031 ; then
		mycmakeargs+=(-DDL_KERNELS=ON)
	fi

	if use test; then
		mycmakeargs+=(
			-DFETCHCONTENT_SOURCE_DIR_GTEST="${WORKDIR}/googletest-${GTEST_COMMIT}"
		)
	fi

	# rocminfo call during configuration; should not happen
	# Bug: https://github.com/ROCm/composable_kernel/issues/2994
	rocm_add_sandbox -w
	addpredict /dev/random

	cmake_src_configure
}

src_install() {
	cmake_src_install

	# shellcheck disable=SC2329
	installation() {
		python_domodule python/ck4inductor

		# install package-data manually, as there is no PEP517 compliance
		shopt -s globstar
		package_data=(
			include/ck/**/*.hpp
			library/src/tensor_operation_instance/gpu/gemm_universal/**/*.hpp
		)
		shopt -u globstar

		inst_path="${D}$(python_get_sitedir)/ck4inductor"
		for file in "${package_data[@]}"; do
			location="${inst_path}/$(dirname "$file")"
			mkdir -p "${location}"
			cp "${file}" "${location}"
		done
	}
	python_foreach_impl installation
}

src_test() {
	check_amdgpu
	LD_LIBRARY_PATH="${BUILD_DIR}"/lib cmake_src_test -j1
}
