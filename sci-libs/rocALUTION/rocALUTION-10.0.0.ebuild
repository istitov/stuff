# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ROCM_VERSION=${PV}

inherit cmake rocm

DESCRIPTION="Sparse iterative solvers and preconditioners on the ROCm platform"
HOMEPAGE="https://github.com/ROCm/rocm-libraries/tree/develop/projects/rocalution"
# New package; ::gentoo carries no rocALUTION at any version. It is the sparse
# ITERATIVE solver layer of the ROCm math stack -- Krylov methods, multigrid
# and the matching preconditioners -- sitting above sci-libs/rocSPARSE, which
# provides only the sparse primitives. Nothing else in the tree provides it.
#
# AMD retired the rocm-* release line at rocm-7.2.4 (2026-05-28); the 10.0
# source ships as the rocalution.tar.gz asset on the rocm-libraries
# therock-<major.minor> release, the same shape sci-libs/rocSOLVER uses.
SRC_URI="https://github.com/ROCm/rocm-libraries/releases/download/therock-$(ver_cut 1-2)/rocalution.tar.gz -> rocalution-${PV}.tar.gz"
S="${WORKDIR}/rocalution"

LICENSE="MIT"
# Versioned by the ROCm release rather than upstream's rocm_setup_version(4.1.0),
# matching the rest of the stack.
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"

IUSE="+openmp mpi test"
REQUIRED_USE="${ROCM_REQUIRED_USE}"

RESTRICT="!test? ( test )"

# All four ROCm math atoms are find_package(... REQUIRED) inside the SUPPORT_HIP
# branch, which is ON whenever HIP is found, so on this profile they are
# unconditional. The split follows what the built artifact actually links:
# objdump -p on librocalution_hip.so.1.0.0 reports librocsparse.so.1,
# librocrand.so.1, librocblas.so.5 and libamdhip64.so.7 -- but NOT rocPRIM,
# which is a header-only library and so is build-time only, matching
# sci-libs/rocSOLVER. verified 2026-08-30.
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
		# REQUIRED, not cosmetic. rocALUTION reaches the GPU backend through
		# the LEGACY FindHIP module (it wants hip_add_library, which the modern
		# hip-config.cmake does not provide), and dev-util/hip installs that
		# module to /usr/$(get_libdir)/cmake/hip -- which is not on CMake's
		# default module path. Without this the find_package(HIP MODULE) fails,
		# and because SUPPORT_HIP is a cmake_dependent_option it then FORCES
		# ITSELF OFF rather than erroring: the build succeeds, but ships a
		# CPU-only librocalution that links no ROCm library at all. -DSUPPORT_HIP=ON
		# cannot rescue it either -- cmake_dependent_option overrides the
		# command line when its condition is false. src_install asserts the
		# result instead of trusting it. verified 2026-08-30.
		-DCMAKE_MODULE_PATH="${EPREFIX}/usr/$(get_libdir)/cmake/hip"
		-DAMDGPU_TARGETS="$(get_amdgpu_flags)"
		-DROCM_SYMLINK_LIBS=OFF
		# Upstream defaults SUPPORT_OMP=ON and SUPPORT_MPI=OFF
		# (cmake/Dependencies.cmake); both are driven explicitly here so a
		# default flip upstream does not silently change what we ship.
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
	# The GPU backend is a SEPARATE library, and a rocALUTION without it still
	# builds, installs and imports -- it just silently runs everything on the
	# CPU. That is the exact failure this package fell into before
	# CMAKE_MODULE_PATH was set above, and nothing in the build reports it as
	# an error, so assert the artifact rather than trusting the configure log.
	[[ -f ${BUILD_DIR}/src/librocalution_hip.so ]] ||
		die "librocalution_hip.so was not built -- SUPPORT_HIP silently degraded to a CPU-only build"

	cmake_src_install
}
