# Copyright 2025-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_EXT=1
PYTHON_COMPAT=( python3_{11..14} )
inherit cmake distutils-r1 dot-a

DESCRIPTION="Text tokenizer for Neural Network-based text generation"
HOMEPAGE="https://github.com/google/sentencepiece"
SRC_URI="https://github.com/google/${PN}/archive/refs/tags/v${PV}.tar.gz
	-> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# Protobuf targets require Abseil.
RDEPEND="
	dev-cpp/abseil-cpp:=
	dev-libs/protobuf:=
	dev-util/google-perftools
"
DEPEND="${RDEPEND}"
BDEPEND="
	$(python_gen_cond_dep '
		>=dev-python/pybind11-2.12[${PYTHON_USEDEP}]
	')
	virtual/pkgconfig
"

DOCS=(
	README.md
	doc/cli.md
	doc/cpp.md
	doc/model_proto.md
	doc/normalization.md
	doc/options.md
	doc/performance_benchmark.md
	doc/piece_constraints.md
	doc/special_symbols.md
)

PATCHES=(
	"${FILESDIR}"/${P}-abseil-status-builder.patch
	"${FILESDIR}"/${P}-noStatic.patch
	"${FILESDIR}"/${P}-nostrip.patch
	"${FILESDIR}"/${P}-system-libs.patch
)

src_prepare() {
	distutils-r1_src_prepare
	cmake_prepare
	grep -qF '@libprotobuf_lite@' ${PN}.pc.in || die "protobuf anchor moved"
	grep -qF '@includedir_for_pc_file@' ${PN}.pc.in || die "includedir anchor moved"
	grep -qF '@libdir_for_pc_file@' ${PN}.pc.in || die "libdir anchor moved"
	grep -qF 'Cflags: -I${includedir}' ${PN}.pc.in || die "Cflags anchor moved"
	sed \
		-e 's|@libprotobuf_lite@|protobuf-lite|' \
		-e "s|@includedir_for_pc_file@|${BUILD_DIR}/src/installed_headers|" \
		-e "s|@libdir_for_pc_file@|${BUILD_DIR}/src|" \
		-e "s|Cflags: -I\${includedir}|Cflags: -I\${includedir} -I${BUILD_DIR}/src|" \
		${PN}.pc.in \
		> python/${PN}.pc \
		|| die

	grep -q 'CMAKE_CXX_STANDARD ' CMakeLists.txt || die "C++ standard anchor moved"
	sed -e '/CMAKE_CXX_STANDARD /{s/)/ CACHE STRING "")/g}' -i CMakeLists.txt || die
}

src_configure() {
	lto-guarantee-fat
	local mycmakeargs=(
		-DSPM_ABSL_PROVIDER=package
		-DSPM_PROTOBUF_PROVIDER=package
	)

	if has_version ">=dev-cpp/abseil-cpp-20260107.0"; then
		# Abseil >=20260107 requires C++20.
		mycmakeargs+=(
			-DCMAKE_CXX_STANDARD=20
		)
	fi

	cmake_src_configure
}

src_compile() {
	cmake_src_compile
	cd python
	PKG_CONFIG_PATH=. distutils-r1_src_compile
}

src_test() {
	LD_LIBRARY_PATH=${BUILD_DIR}/src distutils-r1_src_test
}

python_test() {
	cd python
	${EPYTHON} test/sentencepiece_test.py || die
}

src_install() {
	cmake_src_install
	distutils-r1_src_install
	strip-lto-bytecode
}
