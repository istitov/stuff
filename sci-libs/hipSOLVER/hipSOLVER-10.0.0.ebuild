# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ROCM_VERSION=${PV}

inherit cmake rocm

DESCRIPTION="CU / ROCM agnostic marshalling library for LAPACK routines on the GPU"
HOMEPAGE="https://github.com/ROCm/rocm-libraries/tree/develop/projects/hipsolver"
# AMD retired the rocm-* release line at rocm-7.2.4 (2026-05-28); the same
# per-component assets ship under therock-<major.minor> tags now.
SRC_URI="https://github.com/ROCm/rocm-libraries/releases/download/therock-$(ver_cut 1-2)/hipsolver.tar.gz -> hipsolver-${PV}.tar.gz"
S="${WORKDIR}/hipsolver"

REQUIRED_USE="${ROCM_REQUIRED_USE}"

LICENSE="MIT"
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"
IUSE="sparse"

RESTRICT="test"

RDEPEND="
	dev-util/hip:${SLOT}
	sci-libs/rocSOLVER:${SLOT}
	sci-libs/rocBLAS:${SLOT}
	sci-libs/flexiblas
	sparse? (
		sci-libs/suitesparseconfig
		sci-libs/rocSPARSE:${SLOT}
		sci-libs/cholmod:=
	)
"
DEPEND="${RDEPEND}"

PATCHES=(
	"${FILESDIR}"/${PN}-7.0.1-find-cholmod.patch
)

src_configure() {
	rocm_use_clang

	local mycmakeargs=(
		-DGPU_TARGETS="$(get_amdgpu_flags)"
		-DBUILD_FILE_REORG_BACKWARD_COMPATIBILITY=OFF
		-DROCM_SYMLINK_LIBS=OFF
		-DBUILD_WITH_SPARSE=$(usex sparse ON OFF)
		# New at 10.0 and defaulting to ON: it ExternalProject_Add()s OpenBLAS
		# straight from GitHub, which the sandbox has no network for, and
		# statically bundles it. The else() branch takes LAPACK from
		# find_package instead. Nothing is lost -- upstream wants it only for
		# geev, which needs the plain Fortran ?geev_ symbols any LAPACK
		# provides, and hipsolver links lapack_libraries unconditionally
		# either way. verified 2026-08-30.
		-DHIPSOLVER_INTERNAL_LAPACK_BUILD=OFF
		# ... and with the internal build off, LAPACK is found for real. This
		# one defaults to ON ("Skip module mode search for LAPACK"), which wants
		# a LAPACKConfig.cmake; virtual/lapack providers ship no CMake package
		# config, so use CMake's own FindLAPACK module instead.
		-DHIPSOLVER_FIND_PACKAGE_LAPACK_CONFIG=OFF
		# Pin the provider. Left to itself CMake's FindLAPACK walked off into
		# /opt/intel/oneapi/mkl and linked an MKL nothing declares a dependency
		# on -- automagic, and not reproducible on another host. FlexiBLAS is
		# the same pattern sci-libs/rocBLAS uses, and it dispatches at RUNTIME
		# to whichever provider the user selected, so pinning it here is the
		# least restrictive choice rather than the most. verified 2026-08-30.
		-DBLA_PREFER_PKGCONFIG=ON
		-DBLA_PKGCONFIG_BLAS=flexiblas
		-DBLA_PKGCONFIG_LAPACK=flexiblas
		-DBLA_VENDOR=FlexiBLAS
	)

	cmake_src_configure
}
