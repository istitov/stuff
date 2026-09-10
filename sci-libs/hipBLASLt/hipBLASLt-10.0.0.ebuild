# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ROCM_SKIP_GLOBALS=1
PYTHON_COMPAT=( python3_{12..14} )

# The subslot-pinned ROCm stack must use one LLVM major.
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
# rocisa requires unpackaged stinkytofu; co-unpack its release asset and redirect
# the monorepo sibling lookup. verified 2026-08-29
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

# TensileLite generates gfx1150 assembly rejected by vanilla LLVM, so require
# hipcc to select AMD LLVM. Keep this unconditional until a vanilla-LLVM CDNA
# build is verified. verified 2026-08-30
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

# Upstream couples tests to the installed benchmark clients.
REQUIRED_USE="test? ( benchmark )"

# The embedded rocisa branch still FetchContents nanobind; use the system
# package. The standalone branch already does so. verified 2026-08-29
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
	# Release assets provide their own top-level directories.
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

	# Make validation accept the selected Clang driver.
	local f
	for f in tensilelite/Tensile/Toolchain/Validators.py \
		tensilelite/Tensile/Tests/unit/test_MatrixInstructionConversion.py; do
		grep -qF 'amdclang' "${f}" || die "amdclang anchor moved in ${f}"
	done
	sed -e "s/amdclang/$(basename "$CC")/g" \
		-i tensilelite/Tensile/Toolchain/Validators.py \
		-i tensilelite/Tensile/Tests/unit/test_MatrixInstructionConversion.py || die

	# A missed rewrite silently installs test binaries, so require its anchor.
	grep -qF 'COMPONENT tests' CMakeLists.txt ||
		die "COMPONENT tests anchor moved; tests would be installed"
	sed -e "s/COMPONENT tests/COMPONENT tests EXCLUDE_FROM_ALL/" -i CMakeLists.txt || die

	# Redirect monorepo sibling paths to co-unpacked assets. A missed rewrite
	# fetches origami or fails to find stinkytofu, so require both anchors.
	# verified 2026-08-29
	grep -q '\.\./\.\./shared/origami' CMakeLists.txt ||
		die "origami sibling-path anchor moved"
	sed -e 's:../../shared/origami:../origami:' -i CMakeLists.txt || die

	grep -q '\.\./\.\./\.\./\.\./shared/stinkytofu' tensilelite/rocisa/CMakeLists.txt ||
		die "stinkytofu sibling-path anchor moved"
	sed -e 's:\.\./\.\./\.\./\.\./shared/stinkytofu:../../../stinkytofu:' \
		-i tensilelite/rocisa/CMakeLists.txt || die

	# hipBLASLt overrides stinkytofu's default and enables -Werror. With NDEBUG,
	# an assert-only iterator becomes unused and breaks the build; restore the
	# subproject default. verified 2026-08-30
	grep -q 'set(STINKYTOFU_ENABLE_WERROR ON)' tensilelite/rocisa/CMakeLists.txt ||
		die "STINKYTOFU_ENABLE_WERROR anchor moved"
	sed -e 's:set(STINKYTOFU_ENABLE_WERROR ON):set(STINKYTOFU_ENABLE_WERROR OFF):' \
		-i tensilelite/rocisa/CMakeLists.txt || die

	cmake_src_prepare

	# Outside the monorepo, stinkytofu cannot reach shared clang-tidy modules.
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

	# cmake.eclass clears release flags, leaving rocisa assertions active and
	# aborting macro expansion. Match AMD's NDEBUG Release build; this does not
	# fix the underlying invariant, so revisit if kernels miscompile.
	# verified 2026-08-30
	append-cflags "-DNDEBUG"
	append-cxxflags "-DNDEBUG"
	CMAKE_BUILD_TYPE="Release"

	append-cxxflags -Wno-explicit-specialization-storage-class

	# Tensile's generated code requires lld.
	append-cxxflags -DCMAKE_CXX_FLAGS="-fuse-ld=lld"

	local targets="$(get_amdgpu_flags)"
	local Tensile_SKIP_BUILD=$([ "${AMDGPU_TARGETS[*]}" = "" ] && echo ON || echo OFF )
	local HIPBLASLT_ENABLE_DEVICE=$([ "${AMDGPU_TARGETS[*]}" != "" ] && echo ON || echo OFF )

	# Tensile rejects get_amdgpu_flags' trailing semicolon.
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
	# Load the build's Tensile, not a system copy.
	local -x PYTHONPATH="${S}_build/virtualenv/lib/${EPYTHON}/site-packages"
	# TensileLite ignores the old TENSILE_ROCM_ASSEMBLER_PATH and follows
	# ROCM_PATH, but still reads CMAKE_CXX_COMPILER from the environment.
	# verified 2026-08-30
	local -x CMAKE_CXX_COMPILER="$(get_llvm_prefix)/bin/clang++"
	cmake_src_compile
}

src_install() {
	cmake_src_install

	# Stripping .strtab from HSACO files crashes rocclr's ELF loader.
	dostrip -x /usr/$(get_libdir)/hipblaslt/library/
}

src_test() {
	check_amdgpu

	# Avoid the known dGPU+iGPU MatrixTransformTest.MultipleDevices failure.
	HIP_VISIBLE_DEVICES=0 cmake_src_test
}
