# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ROCM_VERSION=${PV}

inherit cmake rocm

DESCRIPTION="Sparse iterative solvers and preconditioners on the ROCm platform"
HOMEPAGE="https://github.com/ROCm/rocm-libraries/tree/develop/projects/rocalution"
# AMD retired rocm-* releases; use the rocalution asset from the matching
# TheRock release.
SRC_URI="https://github.com/ROCm/rocm-libraries/releases/download/therock-$(ver_cut 1-2)/rocalution.tar.gz -> rocalution-${PV}.tar.gz"
S="${WORKDIR}/rocalution"

LICENSE="MIT"
# Slot by ROCm release, not upstream's rocm_setup_version(4.1.0).
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"

IUSE="+openmp mpi test"
REQUIRED_USE="${ROCM_REQUIRED_USE}"

RESTRICT="!test? ( test )"

# The HIP backend requires all four ROCm libraries. The shared object links
# everything except header-only rocPRIM, which is build-time only.
# verified 2026-08-30
RDEPEND="
	dev-util/hip:${SLOT}
	sci-libs/rocBLAS:${SLOT}
	sci-libs/rocRAND:${SLOT}
	sci-libs/rocSPARSE:${SLOT}
	mpi? ( virtual/mpi )
"
DEPEND="
	${RDEPEND}
	sci-libs/rocPRIM:${SLOT}
"
BDEPEND="
	dev-build/rocm-cmake:${SLOT}
	test? ( dev-cpp/gtest )
"

src_configure() {
	rocm_use_clang

	local mycmakeargs=(
		-DCMAKE_SKIP_RPATH=ON
		# Legacy FindHIP provides hip_add_library but lies outside CMake's default
		# module path. Without it SUPPORT_HIP silently disables itself; src_install
		# asserts the resulting backend. # verified 2026-08-30
		-DCMAKE_MODULE_PATH="${EPREFIX}/usr/$(get_libdir)/cmake/hip"
		-DAMDGPU_TARGETS="$(get_amdgpu_flags)"
		-DROCM_SYMLINK_LIBS=OFF
		# Pin optional backends rather than inherit upstream defaults.
		-DSUPPORT_OMP=$(usex openmp ON OFF)
		-DSUPPORT_MPI=$(usex mpi ON OFF)
		-DBUILD_CLIENTS_SAMPLES=OFF
		-DBUILD_CLIENTS_TESTS=$(usex test ON OFF)
		-DBUILD_CLIENTS_BENCHMARKS=OFF
		-Wno-dev
	)

	cmake_src_configure
}

src_install() {
	# A missing GPU backend otherwise produces a successful CPU-only build.
	[[ -f ${BUILD_DIR}/src/librocalution_hip.so ]] ||
		die "librocalution_hip.so was not built -- SUPPORT_HIP silently degraded to a CPU-only build"

	cmake_src_install
}
