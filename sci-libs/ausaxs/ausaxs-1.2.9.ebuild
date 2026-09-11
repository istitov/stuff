# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

PATCHES=(
	"${FILESDIR}/${PN}-1.2-tests-no-dlib.patch"
	"${FILESDIR}/${PN}-1.3.0-simd-unaligned-access.patch"
)

DESCRIPTION="Efficient small-angle X-ray scattering (SAXS) fitting and analysis"
HOMEPAGE="https://github.com/AUSAXS/AUSAXS"
SRC_URI="https://github.com/AUSAXS/AUSAXS/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz"
S="${WORKDIR}/AUSAXS-${PV}"

LICENSE="LGPL-3+"
SLOT="0/1.2"
KEYWORDS="~amd64 ~arm64"
IUSE="doc executables test"

# DLIB always uses FetchContent; disable it because the needed SANS Debye path
# does not use its minimizers.
# pyausaxs coexists by loading its bundled libausaxs through an absolute path.
# That six-symbol ABI remains distinct from this library's ~44-symbol C API;
# this package serves its CLI tools and direct C/C++ consumers.
# verified 2026-05-16
RDEPEND="
	net-misc/curl
	dev-cpp/gcem
	dev-cpp/backward-cpp
	dev-cpp/cli11
	dev-cpp/bshoshany-thread-pool
"
DEPEND="${RDEPEND}"
BDEPEND="
	doc? ( app-text/doxygen )
	test? ( dev-cpp/catch )
"
RESTRICT="!test? ( test )"

src_prepare() {
	# Produce a normal dynamically linked library.
	sed -i \
		-e 's/-static-libgcc//g' \
		-e 's/-static-libstdc++//g' \
		CMakeLists.txt || die

	# Use user-selected optimization and architecture flags.
	sed -i \
		-e '/^[[:space:]]*-O3$/d' \
		-e '/^[[:space:]]*-ffast-math$/d' \
		-e '/^[[:space:]]*-pipe$/d' \
		-e '/list(APPEND CompilerFlags ${MARCH_FLAG})/d' \
		cmake/setup_compile_commands.cmake || die

	if use test; then
		sed -i '/^add_subdirectory(tests)/i enable_testing()' \
			CMakeLists.txt || die
		sed -i \
			-e '/^set(CMAKE_CXX_FLAGS "")/d' \
			-e 's/"-Os /"/' \
			tests/CMakeLists.txt || die
	else
		sed -i '/^add_subdirectory(tests)/d' CMakeLists.txt || die
	fi

	# Parallel targets race while copying uninstalled plotting helpers to one
	# directory; drop their POST_BUILD hooks. verified 2026-06-10
	sed -i \
		-e '/^add_plot_scripts_to_target(/d' \
		executable/CMakeLists.txt || die

	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_BUILD_TYPE=Release
		-DGUI=OFF
		-DDLIB=OFF
		-DBUILD_PLOT_EXE=OFF
		-DARCH=auto
		-DUSE_SYSTEM_GCEM=ON
		-DUSE_SYSTEM_BACKWARD=ON
		-DUSE_SYSTEM_CLI11=ON
		-DUSE_SYSTEM_THREADPOOL=ON
		-DUSE_SYSTEM_CATCH=ON
		-DFETCHCONTENT_FULLY_DISCONNECTED=ON
	)
	cmake_src_configure
}

src_compile() {
	# Since 1.2.3 the public shared library is no longer a transitive target.
	local targets=( ausaxs libausaxs )
	use executables && targets+=( saxs_fitter em_fitter rigidbody_optimizer )
	use test && targets+=( tests )
	cmake_src_compile "${targets[@]}"

	if use doc; then
		cmake_src_compile doc
	fi
}

src_test() {
	cmake_src_test -j 8
}

src_install() {
	# Upstream defines no install targets.
	dolib.so "${BUILD_DIR}/lib/libausaxs.so"

	if use executables; then
		dobin "${BUILD_DIR}/bin/saxs_fitter"
		dobin "${BUILD_DIR}/bin/em_fitter"
		dobin "${BUILD_DIR}/bin/rigidbody_optimizer"
	fi

	# Install the public C/C++ API headers.
	insinto /usr/include/ausaxs
	doins -r include/api/.
	doins -r include/core/.
	doins -r include/em/.
	doins -r include/math/.
	doins -r include/rigidbody/.

	if use doc; then
		HTML_DOCS=( "${BUILD_DIR}/html/." )
	fi
	einstalldocs
}
