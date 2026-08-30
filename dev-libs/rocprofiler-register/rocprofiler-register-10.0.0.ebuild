# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Registration library that brokers profiler attachment to the ROCm runtimes"
HOMEPAGE="https://github.com/ROCm/rocm-systems/tree/develop/projects/rocprofiler-register"
# New package. Nothing in ::gentoo carries any part of the rocprofiler family,
# and dev-util/rocprofiler-sdk hard-depends on this library, so it has to land
# first.
#
# AMD retired the rocm-* release line at rocm-7.2.4 (2026-05-28); the 10.0
# source ships as the rocprofiler-register.tar.gz asset on the rocm-systems
# therock-<major.minor> release, the same shape dev-util/roctracer uses.
SRC_URI="https://github.com/ROCm/rocm-systems/releases/download/therock-$(ver_cut 1-2)/${PN}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN}"

LICENSE="MIT"
# Versioned by the ROCm release rather than by upstream's own VERSION file
# (0.6.0 at ROCm 10.0), matching the rest of the stack: the subslot is what
# keys rebuilds across a ROCm bump, and the soname carries the real 0.6.0.
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"

IUSE="test"
RESTRICT="!test? ( test )"

# glog and fmt are vendored as git submodules that the release tarball does NOT
# contain -- external/glog and external/fmt are empty directories. Upstream
# defaults ROCPROFILER_REGISTER_BUILD_{GLOG,FMT} to ON, which would make CMake
# clone them at configure time; that cannot work under network-sandbox. Both
# options have a system-package branch (find_package(glog|fmt REQUIRED GLOBAL)),
# so src_configure turns them OFF and these become real dependencies.
#
# Both carry := because the built library links them directly -- objdump -p on
# librocprofiler-register.so.0.6.0 shows NEEDED libfmt.so.12 and libglog.so.1 --
# and both packages subslot on their full version, so an soname bump has to
# force a rebuild here. verified 2026-08-30.
DEPEND="
	dev-cpp/glog:=
	dev-libs/libfmt:=
"
RDEPEND="${DEPEND}"
BDEPEND="
	test? ( dev-cpp/gtest )
"

src_prepare() {
	# Upstream hardcodes CMAKE_INSTALL_LIBDIR to "lib" ("ROCm does not use
	# lib64") AFTER include(GNUInstallDirs), which also overrides any -D on the
	# command line -- so this cannot be fixed from src_configure.
	#
	# The anchor is asserted first: `sed` exits 0 on no-match, so if upstream
	# ever drops the line the substitution goes silently inert and everything
	# installs into /usr/lib on a multilib profile, which is a broken merge
	# rather than a build failure. verified 2026-08-30.
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

	# Both of these assume upstream's self-contained /opt/rocm prefix and are
	# actively wrong once the package is merged into /usr: the modulefile
	# resolves its ROOT to /usr and then prepends /usr/lib64 to LD_LIBRARY_PATH
	# and /usr/ to PYTHONPATH, and setup-env.sh does the same in shell form.
	rm -r "${ED}"/usr/share/modulefiles || die
	rm "${ED}"/usr/share/${PN}/setup-env.sh || die

	# Upstream installs the test SOURCES unconditionally -- they are a separate
	# install rule, not gated on ROCPROFILER_REGISTER_BUILD_TESTS -- so with
	# USE=-test they are 300K of dead weight.
	if ! use test; then
		rm -r "${ED}"/usr/share/${PN}/tests || die
	fi

	rmdir "${ED}"/usr/share/${PN} 2>/dev/null
}
