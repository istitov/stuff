# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ROCM_VERSION=${PV}

inherit cmake rocm

DESCRIPTION="CU / ROCM agnostic marshalling library for LAPACK routines on the GPU"
HOMEPAGE="https://github.com/ROCm/rocm-libraries/tree/develop/projects/hipsolver"
# Post-7.2.4 component assets use therock-* tags.
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
		# Avoid the default static OpenBLAS network build; system LAPACK supplies
		# the required geev symbols. # verified 2026-08-30
		-DHIPSOLVER_INTERNAL_LAPACK_BUILD=OFF
		# Providers lack LAPACKConfig.cmake; use CMake's FindLAPACK module.
		-DHIPSOLVER_FIND_PACKAGE_LAPACK_CONFIG=OFF
		# Prevent automagic host MKL selection. FlexiBLAS matches rocBLAS and
		# retains runtime provider choice. # verified 2026-08-30
		-DBLA_PREFER_PKGCONFIG=ON
		-DBLA_PKGCONFIG_BLAS=flexiblas
		-DBLA_PKGCONFIG_LAPACK=flexiblas
		-DBLA_VENDOR=FlexiBLAS
	)

	cmake_src_configure
}
