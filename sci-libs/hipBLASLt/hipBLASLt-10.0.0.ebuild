# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ROCM_SKIP_GLOBALS=1
PYTHON_COMPAT=( python3_{12..14} )

# Tracks the ROCm 10.0 cohort's LLVM slot. The stack is subslot-pinned as one
# dependency closure, so all of it must be compiled by a single LLVM major.
LLVM_COMPAT=( 23 )

inherit cmake flag-o-matic multiprocessing llvm-r2 python-any-r1 rocm
DESCRIPTION="General matrix-matrix operations library for AMD Instinct accelerators"
HOMEPAGE="https://github.com/ROCm/rocm-libraries/tree/develop/projects/hipblaslt"
MY_BASE="https://github.com/ROCm/rocm-libraries/releases/download/therock-$(ver_cut 1-2)"
SRC_URI="
	${MY_BASE}/hipblaslt.tar.gz -> hipblaslt-${PV}.tar.gz
	${MY_BASE}/origami.tar.gz -> origami-${PV}.tar.gz
	${MY_BASE}/stinkytofu.tar.gz -> stinkytofu-${PV}.tar.gz
"

S="${WORKDIR}/hipblaslt"
ORIGAMI_S="${WORKDIR}/origami"
# NEW at ROCm 10.0: tensilelite/rocisa now requires "stinkytofu", looking for it
# either via find_package or as a monorepo sibling at ../../../../shared/
# stinkytofu, and hard-FATAL_ERRORs when neither is present. It is not packaged
# separately, so co-unpack the release asset the same way as origami and point
# the sibling lookup at it. verified 2026-08-29.
STINKYTOFU_S="${WORKDIR}/stinkytofu"

LICENSE="MIT"
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"

SUPPORTED_GPUS=( gfx908 gfx90a gfx942 gfx950 gfx1100 gfx1101 gfx1103 gfx1150 gfx1151 gfx1200 gfx1201 )
IUSE_TARGETS=( "${SUPPORTED_GPUS[@]/#/amdgpu_targets_}" )
IUSE="${IUSE_TARGETS[*]/#/+} benchmark roctracer test"
RESTRICT="!test? ( test )"

RDEPEND="
	dev-util/hip:${SLOT}
	dev-util/rocm-smi:${SLOT}
	roctracer? ( dev-util/roctracer:${SLOT} )
	benchmark? (
		sci-libs/flexiblas
	)
"

DEPEND="
	${RDEPEND}
	dev-cpp/msgpack-cxx
	sci-libs/hipBLAS-common:${SLOT}
	llvm-runtimes/openmp
"

# dev-util/hipcc[amd-llvm] is a build requirement, not documentation.
# rocm_use_clang() resolves the compiler via `hipconfig --hipclangpath`, and
# hipcc points that at llvm-core/rocm-llvm only when the flag is set. This
# package cannot be compiled by a vanilla LLVM: TensileLite GENERATES gfx1150
# assembly the vanilla assembler rejects ("operands are not valid for this GPU
# or mode" on v_max_f16 with an abs() source modifier), and being generated it
# cannot be patched away. Until now that requirement lived only in a
# profiles/package.mask comment, so building against a hipcc without the flag
# died deep in compilation with no resolver-level signal.
#
# Unconditional deliberately. Every failure on record is a gfx11xx/gfx12xx one,
# so a narrower amdgpu_targets_*? form may well be correct -- but nobody has
# built this against a vanilla LLVM for a CDNA-only target, and claiming
# support that was never verified is the worse error. Narrow it once someone
# has that build. # verified 2026-08-30
BDEPEND="
	${PYTHON_DEPS}
	dev-build/rocm-cmake:${SLOT}
	dev-util/hipcc:${SLOT}[amd-llvm]
	$(python_gen_any_dep "
		dev-python/msgpack[\${PYTHON_USEDEP}]
		dev-python/pyyaml[\${PYTHON_USEDEP}]
		dev-python/joblib[\${PYTHON_USEDEP}]
		dev-python/nanobind[\${PYTHON_USEDEP}]
		dev-python/setuptools[\${PYTHON_USEDEP}]
	")
	$(llvm_gen_dep "llvm-core/clang:\${LLVM_SLOT}")
	test? (
		dev-cpp/gtest
		sci-libs/flexiblas
	)
"

# Since 7.1.0 to build tests one needs to build benchmarks (which will be installed)
# TODO: make build of tests independent benchmarks
REQUIRED_USE="test? ( benchmark )"

# ${PN}-7.1.0-no-git.patch is obsolete at 10.0: cmake/dependencies.cmake no
# longer calls find_package(Git) at all, so there is nothing to remove.
#
# The nanobind patch is still REQUIRED, regenerated for 10.0. Upstream split
# the logic in two: a ROCISA_STANDALONE branch that calls
# find_package(nanobind REQUIRED CONFIG), and an else() branch -- the one taken
# when rocisa builds as a hipblaslt subdirectory, which is our case -- that
# still does a network FetchContent. Only the else() branch needs patching.
# verified 2026-08-29 against the therock-10.0 hipblaslt asset.
PATCHES=(
	"${FILESDIR}"/${PN}-10.0.0-rocisa-nanobind.patch
)

python_check_deps() {
	python_has_version "dev-python/msgpack[${PYTHON_USEDEP}]" &&
	python_has_version "dev-python/pyyaml[${PYTHON_USEDEP}]" &&
	python_has_version "dev-python/joblib[${PYTHON_USEDEP}]" &&
	python_has_version "dev-python/nanobind[${PYTHON_USEDEP}]" &&
	python_has_version "dev-python/setuptools[${PYTHON_USEDEP}]"
}

pkg_setup() {
	QA_FLAGS_IGNORED="usr/$(get_libdir)/hipblaslt/library/.*"
	python-any-r1_pkg_setup
}

pkg_pretend() {
	if [[ "${AMDGPU_TARGETS[*]}" = "" ]]; then
		ewarn "hipBLASLt supports only some GPUs: ${SUPPORTED_GPUS[*]},"
		ewarn "but none of them were defined in AMDGPU_TARGETS USE_EXPAND variable."
		ewarn
		ewarn "Library will continue to be built in \"dummy\" mode,"
		ewarn "serving as a non-functional placeholder for end-user applications."
	fi
}

src_unpack() {
	# rocm 7.2.4's release-asset tarballs carry their own hipblaslt/ and
	# origami/ top-level directories (7.2.3's unpacked flat, hence the manual
	# wrapper dirs previously). Unpack directly so S=/ORIGAMI_S= resolve.
	unpack "hipblaslt-${PV}.tar.gz"
	unpack "origami-${PV}.tar.gz"
	unpack "stinkytofu-${PV}.tar.gz"
}

src_prepare() {
	local shebangs=($(grep -rl "#!/usr/bin/env python3" tensilelite/Tensile || die))
	python_fix_shebang -q "${shebangs[@]}"

	rocm_use_clang

	grep -qF '$(ROCM_PATH)/bin/amdclang++' tensilelite/Makefile ||
		die "amdclang++ anchor moved in tensilelite/Makefile"
	sed -e "s:\$(ROCM_PATH)/bin/amdclang++:$(get_llvm_prefix)/bin/clang++:g" \
		-i tensilelite/Makefile || die

	# Fix compiler validation (just a validation)
	local f
	for f in tensilelite/Tensile/Toolchain/Validators.py \
		tensilelite/Tensile/Tests/unit/test_MatrixInstructionConversion.py; do
		grep -qF 'amdclang' "${f}" || die "amdclang anchor moved in ${f}"
	done
	sed -e "s/amdclang/$(basename "$CC")/g" \
		-i tensilelite/Tensile/Toolchain/Validators.py \
		-i tensilelite/Tensile/Tests/unit/test_MatrixInstructionConversion.py || die

	# Do not install tests. Silent on no-match -- the build succeeds and the
	# test binaries are merged into the image.
	grep -qF 'COMPONENT tests' CMakeLists.txt ||
		die "COMPONENT tests anchor moved; tests would be installed"
	sed -e "s/COMPONENT tests/COMPONENT tests EXCLUDE_FROM_ALL/" -i CMakeLists.txt || die

	# Both of these rewrite a monorepo-relative sibling path to where the
	# co-unpacked release asset actually lands in ${WORKDIR}. `sed` exits 0 on
	# no-match, and a miss means CMake falls back to a network fetch (origami)
	# or a hard FATAL_ERROR (stinkytofu), so assert each anchor.
	# verified 2026-08-29 against therock-10.0.
	grep -q '\.\./\.\./shared/origami' CMakeLists.txt ||
		die "origami sibling-path anchor moved"
	sed -e 's:../../shared/origami:../origami:' -i CMakeLists.txt || die

	# stinkytofu is new at 10.0 and is looked up from tensilelite/rocisa, four
	# levels up: hipblaslt/tensilelite/rocisa/../../../../shared/stinkytofu.
	# Our co-unpacked copy sits at ${WORKDIR}/stinkytofu, which from that same
	# directory is ../../../stinkytofu.
	grep -q '\.\./\.\./\.\./\.\./shared/stinkytofu' tensilelite/rocisa/CMakeLists.txt ||
		die "stinkytofu sibling-path anchor moved"
	sed -e 's:\.\./\.\./\.\./\.\./shared/stinkytofu:../../../stinkytofu:' \
		-i tensilelite/rocisa/CMakeLists.txt || die

	# Do not build stinkytofu with -Werror. hipBLASLt forces
	# set(STINKYTOFU_ENABLE_WERROR ON), overriding stinkytofu's own default of
	# OFF, which is wrong for a distribution build: any warning from a
	# compiler upstream did not test becomes a hard failure.
	#
	# It bites immediately here, and instructively. src/ir/asm/StinkyAsmIR.cpp
	# declares `auto it = IRList::iterator(insertPt);` and then uses it ONLY
	# inside an assert(). Because src_configure sets -DNDEBUG to match
	# upstream's Release build, that assert compiles away, `it` becomes an
	# unused variable, and -Werror turns the resulting -Wunused-variable into
	# an error. The two upstream choices are individually defensible and
	# jointly unbuildable. verified 2026-08-30.
	grep -q 'set(STINKYTOFU_ENABLE_WERROR ON)' tensilelite/rocisa/CMakeLists.txt ||
		die "STINKYTOFU_ENABLE_WERROR anchor moved"
	sed -e 's:set(STINKYTOFU_ENABLE_WERROR ON):set(STINKYTOFU_ENABLE_WERROR OFF):' \
		-i tensilelite/rocisa/CMakeLists.txt || die

	cmake_src_prepare

	# stinkytofu is co-unpacked from its own release asset, so it is built
	# outside the rocm-libraries monorepo and cannot reach the shared
	# cmake/modules its unconditional clang-tidy block includes.
	pushd "${STINKYTOFU_S}" || die
		local PATCHES=(
			"${FILESDIR}"/stinkytofu-10.0.0-optional-clang-tidy.patch
		)
		cmake_src_prepare
	popd || die

	pushd "${ORIGAMI_S}" || die
		local PATCHES=()
		cmake_src_prepare
	popd || die
}

src_configure() {
	rocm_use_clang

	# Build the rocisa codegen extension the way upstream ships it: Release,
	# with NDEBUG. cmake.eclass defaults to RelWithDebInfo AND blanks
	# CMAKE_CXX_FLAGS_RELWITHDEBINFO, so the standard -DNDEBUG never lands and
	# C++ assert()s stay live. TensileLite then aborts partway through
	# generating the assembly kernels:
	#
	#   rocisa/src/pass/macro_inline.cpp:315: void rocisa::expandMacroBody(...):
	#   Assertion `false && "macroToInstruction: unexpected item type in macro
	#   body"' failed.  ->  Fatal Python error: Aborted
	#
	# Be clear about what this does and does not fix: it makes our build match
	# AMD's, where CMAKE_BUILD_TYPE=Release compiles that assert away. The
	# underlying rocisa logic still walks the same path in AMD's own shipped
	# binaries -- it just does not abort there. So this is a build-config
	# alignment, NOT a fix for the assert's root cause; if hipBLASLt ever
	# produces visibly wrong kernels, revisit this rather than assuming the
	# codegen is sound. sci-libs/composable-kernel carries the same idiom.
	# verified 2026-08-30 against therock-10.0.
	append-cflags "-DNDEBUG"
	append-cxxflags "-DNDEBUG"
	CMAKE_BUILD_TYPE="Release"

	# too many warnings
	append-cxxflags -Wno-explicit-specialization-storage-class

	# Tensile guesses weirdly how to compile things, ld.bfd won't work, so force lld
	append-cxxflags -DCMAKE_CXX_FLAGS="-fuse-ld=lld"

	local targets="$(get_amdgpu_flags)"
	local Tensile_SKIP_BUILD=$([ "${AMDGPU_TARGETS[*]}" = "" ] && echo ON || echo OFF )
	local HIPBLASLT_ENABLE_DEVICE=$([ "${AMDGPU_TARGETS[*]}" != "" ] && echo ON || echo OFF )

	# targets has a trailing semicolon, this trips up Tensile's input parser, so carefully prune
	local mycmakeargs=(
		-DGPU_TARGETS="${targets::-1}"
		-DHIPBLASLT_ENABLE_CLIENT="$(usex benchmark ON $(usex test ON OFF))"
		-DHIPBLASLT_ENABLE_SAMPLES=OFF
		-DHIPBLASLT_ENABLE_DEVICE=${HIPBLASLT_ENABLE_DEVICE}
		-DHIPBLASLT_ENABLE_MARKER="$(usex roctracer ON OFF)"
		-DHIPBLASLT_ENABLE_ROCROLLER=OFF
		-DHIPBLASLT_ENABLE_FETCH=OFF
		-DHIPBLASLT_BUNDLE_PYTHON_DEPS=ON
		-Dnanobind_DIR="$(python_get_sitedir)/nanobind/cmake"
		-DPython_EXECUTABLE="${PYTHON}"
		-DROCM_SYMLINK_LIBS=OFF
		-DTENSILELITE_BUILD_PARALLEL_LEVEL=$(makeopts_jobs)
		-DHIPBLASLT_BUILD_TESTING="$(usex test ON OFF)"
		-Wno-dev
	)

	if use test || use benchmark; then
		# HIPBLASLT_ENABLE_CLIENT=ON branch
		mycmakeargs+=(
			-DBLA_PKGCONFIG_BLAS=ON
			-DBLA_VENDOR=FlexiBLAS
			-DHIPBLASLT_ENABLE_BLIS=OFF
		)
	fi

	cmake_src_configure
}

src_compile() {
	local -x ROCM_PATH="${EPREFIX}/usr"
	# set PYTHONPATH to load Tensile from virtualenv, not the system-wide one
	local -x PYTHONPATH="${S}_build/virtualenv/lib/${EPYTHON}/site-packages"
	# TENSILE_ROCM_ASSEMBLER_PATH was exported here through 7.2.4 and is gone:
	# the vendored TensileLite has zero references to it (checked across
	# hipblaslt/, origami/ and stinkytofu/ at therock-10.0). It selects its
	# assembler through Tensile/Toolchain/Validators.py instead, which searches
	# ROCM_PATH/bin, ROCM_PATH/lib/llvm/bin, /opt/rocm/{bin,lib/llvm/bin} and
	# then PATH -- so ROCM_PATH above is what actually steers it, and the dead
	# export only made it look otherwise. verified 2026-08-30.
	#
	# CMAKE_CXX_COMPILER, by contrast, IS read from the environment:
	# Tensile/Common/GlobalParameters.py:869-870 does
	#     if "CMAKE_CXX_COMPILER" in os.environ:
	#         globalParameters["CmakeCxxCompiler"] = os.environ.get(...)
	# so this export is load-bearing, not decoration. verified 2026-08-30.
	local -x CMAKE_CXX_COMPILER="$(get_llvm_prefix)/bin/clang++"
	cmake_src_compile
}

src_install() {
	cmake_src_install

	# Stop llvm-strip from removing .strtab section from *.hsaco files,
	# otherwise rocclr/elf/elf.cpp complains with "failed: null sections(STRTAB)" and crashes
	dostrip -x /usr/$(get_libdir)/hipblaslt/library/
}

src_test() {
	check_amdgpu

	# Expected time for 7900 XTX: 340s (full) or 5s with GTEST_FILTER='*quick*'
	# Fails in `MatrixTransformTest.MultipleDevices` in dGPU+iGPU combination
	HIP_VISIBLE_DEVICES=0 cmake_src_test
}
