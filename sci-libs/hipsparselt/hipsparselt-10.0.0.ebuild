# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ROCM_SKIP_GLOBALS=1
PYTHON_COMPAT=( python3_{12..14} )

# The subslot-pinned ROCm stack must use one LLVM major.
LLVM_COMPAT=( 23 )

inherit cmake flag-o-matic multiprocessing llvm-r2 python-any-r1 rocm
DESCRIPTION="Sparse GEMM operations library for AMD Instinct accelerators"
HOMEPAGE="https://github.com/ROCm/rocm-libraries/tree/develop/projects/hipsparselt"
# ROCm component assets now use therock-<major.minor> tags.
MY_URI="https://github.com/ROCm/rocm-libraries/releases/download/therock-$(ver_cut 1-2)"
SRC_URI="
	${MY_URI}/hipsparselt.tar.gz -> hipsparselt-${PV}.tar.gz
	${MY_URI}/origami.tar.gz -> origami-${PV}.tar.gz
	${MY_URI}/hipblaslt.tar.gz -> hipblaslt-${PV}.tar.gz
	${MY_URI}/stinkytofu.tar.gz -> stinkytofu-${PV}.tar.gz
"

S="${WORKDIR}/hipsparselt"
ORIGAMI_S="${WORKDIR}/origami"
HIPBLASLT_S="${WORKDIR}/hipblaslt"
# Bundled rocisa requires unpackaged stinkytofu; co-unpack its release asset and
# redirect the monorepo sibling lookup. verified 2026-08-30
STINKYTOFU_S="${WORKDIR}/stinkytofu"

LICENSE="MIT"
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"

# From hipsparselt_supported_architectures.cmake
SUPPORTED_GPUS=( gfx942 gfx950 )
IUSE_TARGETS=( "${SUPPORTED_GPUS[@]/#/amdgpu_targets_}" )
IUSE="${IUSE_TARGETS[*]/#/+} benchmark roctracer test"
RESTRICT="!test? ( test )"

RDEPEND="
	dev-util/hip:${SLOT}
	roctracer? ( dev-util/roctracer:${SLOT} )
	benchmark? ( sci-libs/flexiblas )
"

DEPEND="
	${RDEPEND}
	dev-cpp/msgpack-cxx
	dev-libs/rocm-comgr:${SLOT}
	dev-libs/rocr-runtime:${SLOT}
	sci-libs/hipSPARSE:${SLOT}
	dev-util/rocm-smi:${SLOT}
	llvm-runtimes/openmp
"

# Shared TensileLite code emits assembly rejected by vanilla LLVM, so select AMD
# LLVM through hipcc. This is inferred from hipBLASLt, not device-build-verified:
# the available gfx1150 is unsupported here. verified 2026-09-02
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

python_check_deps() {
	python_has_version "dev-python/msgpack[${PYTHON_USEDEP}]" &&
	python_has_version "dev-python/pyyaml[${PYTHON_USEDEP}]" &&
	python_has_version "dev-python/joblib[${PYTHON_USEDEP}]" &&
	python_has_version "dev-python/nanobind[${PYTHON_USEDEP}]" &&
	python_has_version "dev-python/setuptools[${PYTHON_USEDEP}]"
}

pkg_setup() {
	QA_FLAGS_IGNORED="usr/$(get_libdir)/hipsparselt/library/.*"
	python-any-r1_pkg_setup
}

pkg_pretend() {
	if [[ "${AMDGPU_TARGETS[*]}" = "" ]]; then
		ewarn "hipSPARSELt supports only some GPUs: ${SUPPORTED_GPUS[*]},"
		ewarn "but none of them were defined in AMDGPU_TARGETS USE_EXPAND variable."
		ewarn
		ewarn "Library will continue to be built in \"dummy\" mode,"
		ewarn "serving as a non-functional placeholder for end-user applications."
	fi
}

src_unpack() {
	# Release assets provide their own top-level directories. verified 2026-08-30
	unpack "hipsparselt-${PV}.tar.gz"
	unpack "origami-${PV}.tar.gz"
	unpack "hipblaslt-${PV}.tar.gz"
	unpack "stinkytofu-${PV}.tar.gz"
}

src_prepare() {
	rocm_use_clang

	# Silence known ROCm source noise.
	append-cxxflags -Wno-explicit-specialization-storage-class

	# Exclude both quoted binary and end-anchored data test components. Mid-line
	# COMPONENT tests belongs to package metadata and must remain unchanged.
	# Require both anchors because missed rewrites silently install test payloads.
	# verified 2026-08-30
	grep -qF 'COMPONENT "tests"' CMakeLists.txt ||
		die "COMPONENT \"tests\" anchor moved; the test binary would be installed"
	sed -e 's/COMPONENT "tests"/COMPONENT "tests" EXCLUDE_FROM_ALL/' \
		-i CMakeLists.txt || die

	grep -qE 'COMPONENT tests$' CMakeLists.txt ||
		die "unquoted COMPONENT tests anchor moved; test data would be installed"
	sed -E -e 's/COMPONENT tests$/COMPONENT tests EXCLUDE_FROM_ALL/' \
		-i CMakeLists.txt || die

	pushd "${HIPBLASLT_S}" || die
	# Keep this shared-source patch in lockstep with hipBLASLt.
	eapply "${FILESDIR}"/hipBLASLt-10.0.0-rocisa-nanobind.patch

	# Redirect sibling paths to co-unpacked assets. Misses fetch origami or fail
	# to find stinkytofu, so require both anchors.
	grep -q '\.\./\.\./shared/origami' CMakeLists.txt ||
		die "origami sibling-path anchor moved"
	sed -e 's:../../shared/origami:../origami:' -i CMakeLists.txt || die

	grep -q '\.\./\.\./\.\./\.\./shared/stinkytofu' tensilelite/rocisa/CMakeLists.txt ||
		die "stinkytofu sibling-path anchor moved"
	sed -e 's:\.\./\.\./\.\./\.\./shared/stinkytofu:../../../stinkytofu:' \
		-i tensilelite/rocisa/CMakeLists.txt || die

	# Restore stinkytofu's -Werror=OFF distribution default; NDEBUG otherwise
	# exposes an unused assert-only iterator. verified 2026-08-30
	grep -q 'set(STINKYTOFU_ENABLE_WERROR ON)' tensilelite/rocisa/CMakeLists.txt ||
		die "STINKYTOFU_ENABLE_WERROR anchor moved"
	sed -e 's:set(STINKYTOFU_ENABLE_WERROR ON):set(STINKYTOFU_ENABLE_WERROR OFF):' \
		-i tensilelite/rocisa/CMakeLists.txt || die

	local shebangs=($(grep -rl "#!/usr/bin/env python3" tensilelite/Tensile || die))
	python_fix_shebang -q "${shebangs[@]}"

	# Make validation accept the selected Clang driver.
	grep -qF 'amdclang' tensilelite/Tensile/Toolchain/Validators.py ||
		die "amdclang anchor moved in tensilelite/Tensile/Toolchain/Validators.py"
	sed -e "s/amdclang/$(basename "$CC")/g" \
		-i tensilelite/Tensile/Toolchain/Validators.py || die
	grep -qF '$(ROCM_PATH)/bin/amdclang++' tensilelite/Makefile ||
		die "amdclang++ anchor moved in tensilelite/Makefile"
	sed -e "s:\$(ROCM_PATH)/bin/amdclang++:$(get_llvm_prefix)/bin/clang++:g" \
		-i tensilelite/Makefile || die
	popd || die

	cmake_src_prepare

	# Outside the monorepo, stinkytofu cannot reach shared clang-tidy modules.
	pushd "${STINKYTOFU_S}" || die
		local PATCHES=(
			"${FILESDIR}"/stinkytofu-10.0.0-optional-clang-tidy.patch
		)
		cmake_src_prepare
	popd || die
}

src_configure() {
	rocm_use_clang

	# cmake.eclass clears release flags, leaving rocisa assertions active. Match
	# AMD's NDEBUG Release build and hipBLASLt. rocisa/stinkytofu compilation is
	# verified, but device codegen is not: this host's gfx1150 is unsupported.
	# build-verified 2026-08-30
	append-cflags "-DNDEBUG"
	append-cxxflags "-DNDEBUG"
	CMAKE_BUILD_TYPE="Release"

	# Tensile's generated code requires lld.
	append-cxxflags -DCMAKE_CXX_FLAGS="-fuse-ld=lld"

	local targets="$(get_amdgpu_flags)"
	local HIPSPARSELT_ENABLE_DEVICE=$([ "${AMDGPU_TARGETS[*]}" != "" ] && echo ON || echo OFF )

	# Tensile rejects get_amdgpu_flags' trailing semicolon.
	local mycmakeargs=(
		-DGPU_TARGETS="${targets::-1}"
		-DHIPSPARSELT_ENABLE_SAMPLES=OFF
		-DHIPSPARSELT_ENABLE_DEVICE=${HIPSPARSELT_ENABLE_DEVICE}
		-DHIPSPARSELT_BUILD_TESTING="$(usex test ON OFF)"
		-DHIPSPARSELT_ENABLE_BENCHMARKS="$(usex benchmark ON OFF)"

		-DHIPSPARSELT_ENABLE_MARKER="$(usex roctracer ON OFF)"
		-Dnanobind_DIR="$(python_get_sitedir)/nanobind/cmake"
		-DPython_EXECUTABLE="${PYTHON}"
		-DROCM_SYMLINK_LIBS=OFF
		-Wno-dev
	)

	if [[ "${AMDGPU_TARGETS[*]}" != "" ]]; then
		mycmakeargs+=(
			-DTENSILELITE_BUILD_PARALLEL_LEVEL=$(makeopts_jobs)
		)
	fi

	if use test || use benchmark; then
		mycmakeargs+=(
			-DHIPSPARSELT_ENABLE_CLIENT=ON
			-DBLA_VENDOR=FlexiBLAS
		)
	else
		mycmakeargs+=(
			-DHIPSPARSELT_ENABLE_CLIENT=OFF
		)
	fi

	cmake_src_configure
}

src_compile() {
	local -x ROCM_PATH="${EPREFIX}/usr"
	# Load the build's Tensile, not a system copy.
	local -x PYTHONPATH="${S}_build/virtualenv/lib/${EPYTHON}/site-packages"
	local -x TENSILE_ROCM_ASSEMBLER_PATH="$(get_llvm_prefix)/bin/clang++"
	# TensileCreateLibrary rereads this environment variable.
	local -x CMAKE_CXX_COMPILER="$(get_llvm_prefix)/bin/clang++"
	cmake_src_compile
}

src_install() {
	cmake_src_install

	# Stripping .strtab from HSACO files crashes rocclr's ELF loader.
	dostrip -x /usr/$(get_libdir)/hipsparselt/library/
}

src_test() {
	check_amdgpu
	# Non-Instinct GPUs otherwise report success without exercising a device.
	HIP_VISIBLE_DEVICES=0 cmake_src_test
}
