# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ROCM_VERSION=${PV}

inherit cmake rocm

DESCRIPTION="Wrapper of rocPRIM or CUB for GPU parallel primitives"
HOMEPAGE="https://github.com/ROCm/rocm-libraries/tree/develop/projects/hipcub"
# AMD retired the rocm-* release line at rocm-7.2.4 (2026-05-28); the same
# per-component assets ship under therock-<major.minor> tags now.
SRC_URI="https://github.com/ROCm/rocm-libraries/releases/download/therock-$(ver_cut 1-2)/hipcub.tar.gz -> hipcub-${PV}.tar.gz"
S="${WORKDIR}/hipcub"

LICENSE="BSD"
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"
IUSE="benchmark test"
REQUIRED_USE="
	benchmark? ( ${ROCM_REQUIRED_USE} )
	test? ( ${ROCM_REQUIRED_USE} )
"
RESTRICT="!test? ( test )"

RDEPEND="
	benchmark? (
		dev-util/hip:${SLOT}
		dev-cpp/benchmark:=
	)
"
DEPEND="
	${RDEPEND}
	dev-util/hip:${SLOT}
	sci-libs/rocPRIM:${SLOT}
	test? ( dev-cpp/gtest )
"

PATCHES=(
	"${FILESDIR}"/${PN}-10.0.0-no-tests-install.patch
)

src_prepare() {
	# `sed` exits 0 on no-match, so a stale anchor here would silently install
	# the CMake package config under /usr/lib on a multilib profile.
	grep -qF 'set(ROCM_INSTALL_LIBDIR lib)' cmake/ROCMExportTargetsHeaderOnly.cmake ||
		die 'ROCM_INSTALL_LIBDIR anchor moved in cmake/ROCMExportTargetsHeaderOnly.cmake'
	sed -e "s:set(ROCM_INSTALL_LIBDIR lib):set(ROCM_INSTALL_LIBDIR $(get_libdir)):" \
		-i cmake/ROCMExportTargetsHeaderOnly.cmake || die

	cmake_src_prepare
}

src_configure() {
	rocm_use_clang

	local mycmakeargs=(
		-DGPU_TARGETS="$(get_amdgpu_flags)"
		-DBUILD_TEST=$(usex test ON OFF)
		-DBUILD_BENCHMARK=$(usex benchmark ON OFF)
	)

	cmake_src_configure
}

src_test() {
	check_amdgpu
	# Expected time on gfx1100 (-j32) is 85s
	# HipcubDeviceHistogramMultiEven/0.MultiEven in 6.4.1 has bad array access (probably fixed in the future release)
	local CMAKE_SKIP_TESTS=(hipcub.DeviceHistogram)
	cmake_src_test
}
