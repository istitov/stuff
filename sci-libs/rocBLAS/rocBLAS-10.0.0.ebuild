# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DOCS_BUILDER="doxygen"
DOCS_DIR="docs/doxygen"
DOCS_DEPEND="media-gfx/graphviz"
# Keep the subslot-pinned ROCm cohort on one LLVM major.
LLVM_COMPAT=( 23 )
ROCM_VERSION=${PV}

inherit cmake docs edo flag-o-matic llvm-r2 multiprocessing rocm

DESCRIPTION="AMD's library for BLAS on ROCm"
HOMEPAGE="https://github.com/ROCm/rocm-libraries/tree/develop/projects/rocblas"

if [[ "${PV}" == 9999 ]] ; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/ROCm/rocm-libraries.git"
	EGIT_BRANCH="develop"
	S="${WORKDIR}/${P}/projects/rocblas"
	SLOT="0/9999"
	SLOT_NOLIVE="0/10.0"
else
	# Per-component assets moved from rocm-* to therock-X.Y after 7.2.4.
	SRC_URI="https://github.com/ROCm/rocm-libraries/releases/download/therock-$(ver_cut 1-2)/rocblas.tar.gz -> rocblas-${PV}.tar.gz"
	S="${WORKDIR}/rocblas"
	SLOT="0/$(ver_cut 1-2)"
	SLOT_NOLIVE=${SLOT}
	KEYWORDS="~amd64"
fi

LICENSE="MIT BSD"
IUSE="benchmark hipblaslt roctracer test"
RESTRICT="!test? ( test )"
REQUIRED_USE="${ROCM_REQUIRED_USE}"

# Tensile emits gfx11/12 assembly rejected by vanilla LLVM; hipcc[amd-llvm]
# makes hipconfig select AMD's toolchain. Keep it unconditional until a
# vanilla-LLVM CDNA-only build is verified. verified 2026-08-30
BDEPEND="
	dev-build/rocm-cmake:${SLOT_NOLIVE}
	dev-util/hipcc:${SLOT_NOLIVE}[amd-llvm]
"

RDEPEND="
	dev-util/hip:${SLOT_NOLIVE}
	roctracer? ( dev-util/roctracer:${SLOT_NOLIVE} )
	hipblaslt? ( sci-libs/hipBLASLt:${SLOT_NOLIVE} )
	benchmark? (
		dev-cpp/gtest:=
		dev-util/rocm-smi:${SLOT_NOLIVE}
		llvm-runtimes/openmp
		sci-libs/flexiblas
	)
"

DEPEND="
	${RDEPEND}
	>=dev-cpp/msgpack-cxx-6.0.0
	test? (
		dev-cpp/gtest:=
		dev-util/rocm-smi:${SLOT_NOLIVE}
		llvm-runtimes/openmp
		sci-libs/flexiblas
	)
	dev-util/Tensile:${SLOT}
"

QA_FLAGS_IGNORED="/usr/lib64/rocblas/library/.*"

PATCHES=(
	"${FILESDIR}"/${PN}-10.0.0-expand-isa-compatibility.patch
	"${FILESDIR}"/${PN}-7.1.0-no-git.patch
)

src_prepare() {
	cmake_src_prepare

	# Disable client RPATHs for multilib; guard the sed anchor against silent drift.
	grep -qF 'apply_omp_settings' clients/CMakeLists.txt ||
		die 'apply_omp_settings anchor moved in clients/CMakeLists.txt'
	sed -e "/apply_omp_settings/a return()" -i clients/CMakeLists.txt || die

	# Gate automagic roctracer linking; guard the sed anchor against silent drift.
	grep -qF 'if(ROCTRACER_INCLUDE_DIR' library/CMakeLists.txt ||
		die 'ROCTRACER_INCLUDE_DIR anchor moved in library/CMakeLists.txt'
	sed -e "s/if(ROCTRACER_INCLUDE_DIR/if(ROCBLAS_ENABLE_MARKER AND ROCTRACER_INCLUDE_DIR/" \
		-i library/CMakeLists.txt || die
}

src_configure() {
	llvm_prepend_path "${LLVM_SLOT}"
	rocm_use_clang

	# Tensile takes CXX for compilation but resolves its assembler and bundler from
	# PATH. Prepend the same toolchain to avoid mixing AMD and vanilla LLVM.
	# verified 2026-08-30
	export PATH="${CXX%/*}:${PATH}"

	append-cxxflags -Wno-explicit-specialization-storage-class -Wno-unused-value

	local mycmakeargs=(
		-DCMAKE_SKIP_RPATH=ON
		-DROCM_SYMLINK_LIBS=OFF
		-DAMDGPU_TARGETS="$(get_amdgpu_flags)"
		-DBUILD_WITH_TENSILE=ON
		-DCMAKE_INSTALL_INCLUDEDIR="include/rocblas"
		-DBUILD_CLIENTS_SAMPLES=OFF
		-DBUILD_CLIENTS_TESTS="$(usex test ON OFF)"
		-DBUILD_CLIENTS_BENCHMARKS="$(usex benchmark ON OFF)"
		-DBUILD_WITH_PIP=OFF
		-DBUILD_WITH_HIPBLASLT="$(usex hipblaslt ON OFF)"
		-DROCBLAS_ENABLE_MARKER="$(usex roctracer ON OFF)"
		-DLINK_BLIS=OFF
		-DTensile_COMPILER="${CXX}"
		-DTensile_ROOT="${EPREFIX}/usr/share/Tensile"
		-DTensile_CPU_THREADS="$(makeopts_jobs)"
		-Wno-dev
	)

	if use benchmark || use test; then
		mycmakeargs+=(
			-DBLA_PREFER_PKGCONFIG=ON
			-DBLA_PKGCONFIG_BLAS=flexiblas
			-DBLA_VENDOR=FlexiBLAS
		)
	fi

	cmake_src_configure
}

src_compile() {
	docs_compile
	cmake_src_compile
}

src_test() {
	check_amdgpu
	cd "${BUILD_DIR}"/clients/staging || die
	export ROCBLAS_TEST_TIMEOUT=3600 ROCBLAS_TENSILE_LIBPATH="${BUILD_DIR}/Tensile/library"
	export LD_LIBRARY_PATH="${BUILD_DIR}/clients:${BUILD_DIR}/library/src"

	# The broader quick/pre_checkin filter takes over an hour on a 7900XTX.
	edob ./rocblas-test --yaml rocblas_smoke.yaml
}

src_install() {
	cmake_src_install

	if use benchmark; then
		cd "${BUILD_DIR}" || die
		dolib.a clients/librocblas_fortran_client.a
		dobin clients/staging/rocblas-bench
	fi

	# Removing HSACO .strtab makes rocclr reject the kernels as null sections.
	dostrip -x "/usr/$(get_libdir)/rocblas/library/"
}
