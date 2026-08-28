# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

if [[ ${PV} == *9999 ]] ; then
	EGIT_REPO_URI="https://github.com/ROCm/rocm-cmake.git"
	inherit git-r3
else
	# AMD retired the rocm-* tag line at rocm-7.2.4 (2026-05-28); every ROCm
	# repo -- the rocm-libraries/rocm-systems monorepos and the standalone
	# ones like this and llvm-project alike -- has published under
	# therock-<major.minor> since. ROCm 10.0 is the renumbering of the
	# 7.13 -> 7.14 line announced 2026-08-27, not a jump of three majors.
	# The tag carries only major.minor, so it also spells the extracted
	# directory. verified 2026-08-28.
	MY_TAG="therock-$(ver_cut 1-2)"
	SRC_URI="https://github.com/ROCm/rocm-cmake/archive/${MY_TAG}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64"
	S="${WORKDIR}/rocm-cmake-${MY_TAG}"
fi

DESCRIPTION="Radeon Open Compute CMake Modules"
HOMEPAGE="https://github.com/ROCm/rocm-cmake"
LICENSE="MIT"
SLOT="0/$(ver_cut 1-2)"
RESTRICT="test"

DOCS=( CHANGELOG.md LICENSE README.md )

PATCHES=(
	"${FILESDIR}"/${PN}-6.1.1-license.patch
	"${FILESDIR}"/${PN}-6.1.1-no-rocmchecks-warnings.patch
)

src_prepare() {
	sed -e "/CMAKE_INSTALL_LIBDIR/s:lib:$(get_libdir):" \
		-i "share/rocmcmakebuildtools/cmake/ROCMCreatePackage.cmake" \
		-i "share/rocmcmakebuildtools/cmake/ROCMInstallTargets.cmake" || die
	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-Wno-dev
	)
	cmake_src_configure
}
