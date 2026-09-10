# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Registration library that brokers profiler attachment to the ROCm runtimes"
HOMEPAGE="https://github.com/ROCm/rocm-systems/tree/develop/projects/rocprofiler-register"
# AMD retired rocm-* releases; use the rocprofiler-register asset from the
# matching TheRock release.
SRC_URI="https://github.com/ROCm/rocm-systems/releases/download/therock-$(ver_cut 1-2)/${PN}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN}"

LICENSE="MIT"
# Slot by ROCm release for closure rebuilds; the SONAME carries upstream's 0.6.0.
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"

IUSE="test"
RESTRICT="!test? ( test )"

# The release omits its glog/fmt submodules, so disable configure-time fetching
# and use system libraries. Direct SONAME links require := rebuild operators.
# verified 2026-08-30
DEPEND="
	dev-cpp/glog:=
	dev-libs/libfmt:=
"
RDEPEND="${DEPEND}"
BDEPEND="
	test? ( dev-cpp/gtest )
"

src_prepare() {
	# Upstream overwrites the libdir after including GNUInstallDirs. Patch it and
	# assert the anchor to avoid a silent /usr/lib merge. # verified 2026-08-30
	grep -q 'set(CMAKE_INSTALL_LIBDIR "lib")' CMakeLists.txt ||
		die "CMAKE_INSTALL_LIBDIR anchor moved; libraries would install to /usr/lib"
	sed -e '/set(CMAKE_INSTALL_LIBDIR/s:"lib":"'"$(get_libdir)"'":' \
		-i CMakeLists.txt || die

	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DROCPROFILER_REGISTER_BUILD_GLOG=OFF
		-DROCPROFILER_REGISTER_BUILD_FMT=OFF
		-DROCPROFILER_REGISTER_BUILD_TESTS=$(usex test)
		-DROCPROFILER_REGISTER_BUILD_SAMPLES=OFF
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install

	# These assume /opt/rocm and corrupt the environment under /usr.
	rm -r "${ED}"/usr/share/modulefiles || die
	rm "${ED}"/usr/share/${PN}/setup-env.sh || die

	# Upstream installs test sources even with tests disabled.
	if ! use test; then
		rm -r "${ED}"/usr/share/${PN}/tests || die
	fi

	rmdir "${ED}"/usr/share/${PN} 2>/dev/null
}
