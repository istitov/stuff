# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

PATCHES=(
	"${FILESDIR}/${P}-tests-no-dlib.patch"
	"${FILESDIR}/${P}-simd-unaligned-access.patch"
)

DESCRIPTION="Efficient small-angle X-ray scattering (SAXS) fitting and analysis"
HOMEPAGE="https://github.com/AUSAXS/AUSAXS"
SRC_URI="https://github.com/AUSAXS/AUSAXS/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz"
S="${WORKDIR}/AUSAXS-${PV}"

LICENSE="LGPL-3+"
SLOT="0/1.3"
KEYWORDS="~amd64 ~arm64"
IUSE="doc executables test"

# The library API used here does not need dlib minimizers. Keeping DLIB off
# also avoids upstream's unpackageable dlib FetchContent path.
#
# pyausaxs loads its bundled six-symbol libausaxs.so by absolute path, so it
# does not collide with this system library's broader ABI.
RDEPEND="net-misc/curl:="
DEPEND="
	${RDEPEND}
	dev-cpp/gcem
	dev-cpp/backward-cpp
	dev-cpp/cli11
	dev-cpp/bshoshany-thread-pool
"
BDEPEND="
	doc? ( app-text/doxygen )
	test? ( dev-cpp/catch )
"
RESTRICT="!test? ( test )"

src_prepare() {
	# Use Gentoo's dynamic toolchain and user-selected optimization flags.
	sed -i \
		-e 's/-static-libgcc//g' \
		-e 's/-static-libstdc++//g' \
		CMakeLists.txt || die
	sed -i \
		-e '/^[[:space:]]*-O3$/d' \
		-e '/^[[:space:]]*-ffast-math$/d' \
		-e '/^[[:space:]]*-pipe$/d' \
		-e '/list(APPEND CompilerFlags ${MARCH_FLAG})/d' \
		cmake/setup_compile_commands.cmake || die
	sed -i \
		-e '/^set(CMAKE_CXX_FLAGS "")/d' \
		-e 's/"-Os /"/' \
		tests/CMakeLists.txt || die

	# The helpers are embedded in the binaries; avoid their parallel copy race.
	sed -i '/^add_plot_scripts_to_target(/d' \
		executable/CMakeLists.txt || die

	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_BUILD_TYPE=Release
		-DGUI=OFF
		-DDLIB=OFF
		-DBUILD_PLOT_EXE=OFF
		-DBUILD_TESTS=$(usex test)
		-DBUILD_EXECUTABLES=$(usex executables)
		-DSTATIC_CURL=OFF
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
	local targets=( libausaxs )
	use executables && targets+=(
		ausaxs saxs_fitter em_fitter rigidbody_optimizer
	)
	use test && targets+=( tests )
	cmake_src_compile "${targets[@]}"

	use doc && cmake_src_compile doc
}

src_test() {
	cmake_src_test -j 8
}

src_install() {
	cmake_src_install

	if use executables; then
		dobin "${BUILD_DIR}/bin/ausaxs"
		dobin "${BUILD_DIR}/bin/saxs_fitter"
		dobin "${BUILD_DIR}/bin/em_fitter"
		dobin "${BUILD_DIR}/bin/rigidbody_optimizer"
	fi

	# Upstream's install target omits its public headers.
	insinto /usr/include/ausaxs
	doins -r include/api/.
	doins -r include/core/.
	doins -r include/em/.
	doins -r include/math/.
	doins -r include/rigidbody/.

	if use doc; then
		HTML_DOCS=( "${BUILD_DIR}/docs/html/." )
	fi
	einstalldocs
}
