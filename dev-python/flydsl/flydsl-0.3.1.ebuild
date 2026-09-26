# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_SINGLE_IMPL=1
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit check-reqs distutils-r1 multiprocessing optfeature pypi

# sci-libs/aotriton 0.14.2b pins FlyDSL v0.3.1 built against this ROCm LLVM
# fork commit (its third_party/flydsl-llvm.txt): upstream LLVM miscompiles
# register spills, which yields wrong kernels rather than a failed build.
# The fork is built privately and linked statically into the MLIR bindings.
LLVM_COMMIT="78302f03ff2523524989bd010a4896101a690330"
# Submodule gitlink at v0.3.1; FlyDSL only needs its header.
DLPACK_COMMIT="84d107bf416c6bab9ae68ad285876600d230490d"
# MLIR at LLVM_COMMIT asks for nanobind 2.9+ with a same-major version check,
# which the system nanobind 3 fails; build against upstream's 2.12.0.
# verified 2026-09-26
NANOBIND_PV="2.12.0"

DESCRIPTION="Python DSL and MLIR compiler for AMD GPU kernels"
HOMEPAGE="https://github.com/ROCm/FlyDSL"
SRC_URI="
	https://github.com/ROCm/FlyDSL/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
	https://github.com/ROCm/llvm-project/archive/${LLVM_COMMIT}.tar.gz
		-> llvm-project-rocm-${LLVM_COMMIT}.tar.gz
	https://github.com/dmlc/dlpack/archive/${DLPACK_COMMIT}.tar.gz
		-> dlpack-${DLPACK_COMMIT}.gh.tar.gz
	$(pypi_sdist_url nanobind "${NANOBIND_PV}")
"
S="${WORKDIR}/FlyDSL-${PV}"

# FlyDSL and dlpack are Apache-2.0, the embedded MLIR and lld are
# Apache-2.0-with-LLVM-exceptions, nanobind is BSD and its robin_map MIT.
LICENSE="Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD MIT"
SLOT="0"
KEYWORDS="-* ~amd64"
# The tests launch kernels on a ROCm GPU.
RESTRICT="test"

# FlyJitRuntime links HIP. MLIR links code objects with the bundled ld.lld and
# reads device bitcode through the toolkit tree installed below.
RDEPEND="
	${PYTHON_DEPS}
	dev-libs/rocm-device-libs
	dev-util/hip:=
	$(python_gen_cond_dep '
		dev-python/numpy[${PYTHON_USEDEP}]
	')
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-build/cmake
	dev-build/ninja
	$(python_gen_cond_dep '
		dev-python/pybind11[${PYTHON_USEDEP}]
	')
"

CHECKREQS_DISK_BUILD="25G"
CHECKREQS_MEMORY="16G"

pkg_pretend() {
	check-reqs_pkg_pretend
}

pkg_setup() {
	check-reqs_pkg_setup
	python-single-r1_pkg_setup
}

src_prepare() {
	rmdir thirdparty/dlpack || die
	mv "${WORKDIR}/dlpack-${DLPACK_COMMIT}" thirdparty/dlpack || die

	distutils-r1_src_prepare
}

src_configure() {
	# The sdist carries no nanobind-config-version.cmake, so find_package()
	# cannot check its version; nanobind's own install rules generate it.
	cmake -G Ninja -Wno-dev \
		-S "${WORKDIR}/nanobind-${NANOBIND_PV}" \
		-B "${WORKDIR}/nanobind-build" \
		-DNB_TEST=OFF \
		-DNB_CREATE_INSTALL_RULES=ON \
		-DCMAKE_INSTALL_PREFIX="${WORKDIR}/nanobind-install" ||
		die "nanobind configure failed"
	cmake --install "${WORKDIR}/nanobind-build" || die

	# Upstream's recipe (aotriton .ci/runc-build-llvm-tarball.sh) also builds
	# clang, compiler-rt and NVPTX; FlyDSL links only MLIR and needs ld.lld.
	# Disable host-library probes so the private build has no automagic deps.
	local llvm_args=(
		-G Ninja
		-S "${WORKDIR}/llvm-project-${LLVM_COMMIT}/llvm"
		-B "${WORKDIR}/llvm-build"
		-DCMAKE_BUILD_TYPE=Release
		-DCMAKE_INSTALL_PREFIX="${WORKDIR}/mlir-install"
		-DCMAKE_CXX_STANDARD=17
		-DLLVM_ENABLE_PROJECTS="mlir;lld"
		-DLLVM_TARGETS_TO_BUILD="X86;AMDGPU"
		-DLLVM_ENABLE_ASSERTIONS=ON
		# Otherwise a host OCaml turns on bindings that install into /usr.
		-DLLVM_ENABLE_BINDINGS=OFF
		-DLLVM_INSTALL_UTILS=ON
		-DLLVM_INCLUDE_BENCHMARKS=OFF
		-DLLVM_INCLUDE_DOCS=OFF
		-DLLVM_INCLUDE_EXAMPLES=OFF
		-DLLVM_INCLUDE_TESTS=OFF
		-DMLIR_INCLUDE_TESTS=OFF
		-DBUILD_SHARED_LIBS=OFF
		-DLLVM_BUILD_LLVM_DYLIB=OFF
		-DLLVM_LINK_LLVM_DYLIB=OFF
		-DLLVM_ENABLE_FFI=OFF
		-DLLVM_ENABLE_LIBEDIT=OFF
		-DLLVM_ENABLE_LIBPFM=OFF
		-DLLVM_ENABLE_LIBXML2=OFF
		-DLLVM_ENABLE_ZLIB=OFF
		-DLLVM_ENABLE_ZSTD=OFF
		-DLLVM_PARALLEL_LINK_JOBS=4
		-DMLIR_ENABLE_BINDINGS_PYTHON=ON
		-DMLIR_BINDINGS_PYTHON_NB_DOMAIN=mlir
		-DPython3_EXECUTABLE="${PYTHON}"
		-Dnanobind_DIR="${WORKDIR}/nanobind-install/nanobind/cmake"
		# Compiled-in fallback for ROCM_PATH: the toolkit tree installed below.
		-DDEFAULT_ROCM_PATH="${EPREFIX}/usr/lib/${PN}/rocm"
	)
	cmake "${llvm_args[@]}" || die "LLVM configure failed"
}

src_compile() {
	cmake --build "${WORKDIR}/llvm-build" -j$(makeopts_jobs) || die
	cmake --install "${WORKDIR}/llvm-build" || die

	# The steps of scripts/build.sh, which setup.py would otherwise run with
	# -j$(nproc).
	local fly_args=(
		-G Ninja
		-S "${S}"
		-B "${S}/build-fly"
		-DCMAKE_BUILD_TYPE=Release
		-DMLIR_DIR="${WORKDIR}/mlir-install/lib/cmake/mlir"
		-DPython3_EXECUTABLE="${PYTHON}"
		-DHIP_PLATFORM=amd
		-Dnanobind_DIR="${WORKDIR}/nanobind-install/nanobind/cmake"
	)
	cmake "${fly_args[@]}" || die "FlyDSL configure failed"
	cmake --build "${S}/build-fly" -j$(makeopts_jobs) || die

	# Package the tree built above: no rebuild, no strip (Portage strips),
	# no auditwheel. The local version records the LLVM commit, which
	# sci-libs/aotriton checks in place of upstream's wheel-name cache key.
	local -x FLY_REBUILD=0 FLY_BUILD_WHEEL=0
	local -x FLYDSL_PACKAGE_VERSION_OVERRIDE="${PV}+llvm${LLVM_COMMIT:0:12}"
	distutils-r1_src_compile
}

src_install() {
	distutils-r1_src_install

	# The layout MLIR's ROCDL serializer expects under a ROCm root: the
	# linker from the same LLVM as the code generator, and the system
	# device bitcode.
	local toolkit=/usr/lib/${PN}/rocm
	exeinto "${toolkit}"/llvm/bin
	newexe "${WORKDIR}"/mlir-install/bin/lld ld.lld
	# aotriton's flyc_compile inspects each code object with this readelf.
	newexe "${WORKDIR}"/mlir-install/bin/llvm-readobj llvm-readelf
	dosym -r /usr/lib/amdgcn "${toolkit}"/amdgcn
}

pkg_postinst() {
	# Upstream declares no dependencies. flydsl.compiler imports torch;
	# sci-libs/aotriton's build substitutes a stub instead.
	optfeature "the flydsl.compiler module" "sci-ml/pytorch[${PYTHON_SINGLE_USEDEP}]"
}
