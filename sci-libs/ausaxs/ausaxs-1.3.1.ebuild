# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

PATCHES=( "${FILESDIR}/${P}-tests-ctest.patch" )

DESCRIPTION="Efficient small-angle X-ray scattering (SAXS) fitting and analysis"
HOMEPAGE="https://github.com/AUSAXS/AUSAXS"
SRC_URI="https://github.com/AUSAXS/AUSAXS/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz"
S="${WORKDIR}/AUSAXS-${PV}"

LICENSE="LGPL-3+"
# libausaxs carries no SONAME; 1.3.1 breaks the 1.3.0 ABI (the flags
# namespace became internal_state). verified 2026-10-17
SLOT="0/1.3.1"
KEYWORDS="~amd64 ~arm ~arm64"
IUSE="doc executables test"

RDEPEND="net-misc/curl:="
DEPEND="
	${RDEPEND}
	dev-cpp/gcem
	dev-cpp/cli11
	dev-cpp/bshoshany-thread-pool
	dev-libs/pocketfft
"
BDEPEND="
	doc? ( app-text/doxygen )
	test? ( dev-cpp/catch )
"
RESTRICT="!test? ( test )"

src_prepare() {
	# Use the dynamic toolchain and user flags.
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
	sed -i -e '/^set(CMAKE_CXX_FLAGS "")/d' tests/CMakeLists.txt || die

	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_BUILD_TYPE=Release
		-DPOCKETFFT=ON
		-DUSE_SYSTEM_POCKETFFT=ON
		# The SYCL GPU backend needs AdaptiveCpp, which is not packaged.
		-DCMAKE_DISABLE_FIND_PACKAGE_AdaptiveCpp=ON
		-DBUILD_TESTS=$(usex test)
		-DBUILD_EXECUTABLES=$(usex executables)
		-DSTATIC_CURL=OFF
		-DARCH=auto
		# The per-architecture -march flag is dropped in src_prepare, so the
		# upstream allow-list only serves to reject other architectures.
		-DALLOW_UNKNOWN_ARCHITECTURE=ON
		-DUSE_SYSTEM_GCEM=ON
		-DUSE_SYSTEM_CLI11=ON
		-DUSE_SYSTEM_THREADPOOL=ON
		-DUSE_SYSTEM_CATCH=ON
		-DFETCHCONTENT_FULLY_DISCONNECTED=ON
	)
	cmake_src_configure
}

src_compile() {
	local targets=( libausaxs )
	use executables && targets+=( ausaxs )
	use test && targets+=( tests )
	cmake_src_compile "${targets[@]}"

	use doc && cmake_src_compile doc
}

src_test() {
	# These download residue definitions from files.rcsb.org and pass with
	# the network sandbox off. verified 2026-10-17
	# cmake.eclass word-splits the patterns, so "." stands in for spaces.
	local CMAKE_SKIP_TESTS=()
	if has network-sandbox ${FEATURES}; then
		CMAKE_SKIP_TESTS+=(
			"^CIFReader:.file.residues.agrees.with.PDB$"
			"^ResidueParser:.cif_reader_all$"
			"^ResidueParser:.cif_reader_single$"
			"^ResidueParser:.parse_all$"
			"^Curl::download$"
		)
	fi
	cmake_src_test -j 8
}

src_install() {
	cmake_src_install

	use executables && dobin "${BUILD_DIR}/bin/ausaxs"

	# Upstream's install target omits its public headers.
	insinto /usr/include/ausaxs
	doins -r include/api/.
	doins -r include/core/.
	doins -r include/em/.
	doins -r include/gpu/.
	doins -r include/math/.
	doins -r include/rigidbody/.

	if use doc; then
		HTML_DOCS=( "${BUILD_DIR}/docs/html/." )
	fi
	einstalldocs
}
