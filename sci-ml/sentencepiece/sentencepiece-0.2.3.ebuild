# Copyright 2025-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_EXT=1
PYTHON_COMPAT=( python3_{11..15} )
inherit cmake distutils-r1 dot-a

DESCRIPTION="Text tokenizer for Neural Network-based text generation"
HOMEPAGE="https://github.com/google/sentencepiece"
SRC_URI="https://github.com/google/${PN}/archive/refs/tags/v${PV}.tar.gz
	-> ${P}.tar.gz"

# Bundled darts-clone is BSD, libsais Apache-2.0, rapidhash BSD-2.
# verified 2026-11-05
LICENSE="Apache-2.0 BSD BSD-2"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64"

# Protobuf targets require Abseil. 0.2.3 compiles the Lite converter, and
# its FlatBuffers schema, into libsentencepiece itself.
RDEPEND="
	dev-cpp/abseil-cpp:=
	dev-libs/flatbuffers:=
	dev-libs/protobuf:=
	dev-util/google-perftools
"
DEPEND="${RDEPEND}"
# Upstream caps pybind11 below 3.1 for speed only: 3.1's per-element
# keep-alive slows batch decode two- to threefold. The cap is not kept,
# since fastsafetensors needs pybind11 >=3.1 at build time and the slot is
# shared; 0.2.3 builds and passes its tests with 3.1.0. verified 2026-11-05
BDEPEND="
	dev-libs/flatbuffers
	$(python_gen_cond_dep '
		>=dev-python/pybind11-2.13[${PYTHON_USEDEP}]
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

# 0.2.3 rewrote the CMake build and python/setup.py, so the 0.2.2 patches
# were re-derived rather than rebased. The static libraries are no longer
# patched out of the build; src_install removes them instead.
PATCHES=(
	"${FILESDIR}"/${P}-abseil-status-builder.patch
	"${FILESDIR}"/${P}-system-flatbuffers.patch
	"${FILESDIR}"/${P}-system-libs.patch
	"${FILESDIR}"/${P}-nostrip.patch
)

src_prepare() {
	distutils-r1_src_prepare
	cmake_prepare

	# 0.2.3 includes absl/status/status_builder.h and status_macros.h, which
	# ::gentoo's Abseil (20260107.1) does not ship. Header-only shims in the
	# source tree, which precedes the system include path, cover the API
	# sentencepiece uses until a newer Abseil provides the real ones.
	# verified 2026-11-05
	local h
	for h in status_builder status_macros; do
		if [[ ! -e ${ESYSROOT}/usr/include/absl/status/${h}.h ]]; then
			mkdir -p src/absl/status || die
			cp "${FILESDIR}/${P}-absl-${h}.h" "src/absl/status/${h}.h" || die
		fi
	done

	grep -qF '@libprotobuf_lite@' ${PN}.pc.in || die "protobuf anchor moved"
	grep -qF '@includedir_for_pc_file@' ${PN}.pc.in || die "includedir anchor moved"
	grep -qF '@libdir_for_pc_file@' ${PN}.pc.in || die "libdir anchor moved"
	grep -qF '@datadir_for_pc_file@' ${PN}.pc.in || die "datadir anchor moved"
	grep -qF 'Cflags: -I${includedir}' ${PN}.pc.in || die "Cflags anchor moved"
	sed \
		-e 's|@libprotobuf_lite@|protobuf-lite|' \
		-e "s|@includedir_for_pc_file@|${S}/src|" \
		-e "s|@libdir_for_pc_file@|${BUILD_DIR}/src|" \
		-e "s|@datadir_for_pc_file@|${S}/data|" \
		-e "s|Cflags: -I\${includedir}|Cflags: -I\${includedir} -I${BUILD_DIR}/src|" \
		${PN}.pc.in \
		> python/${PN}.pc \
		|| die
}

src_configure() {
	lto-guarantee-fat
	local mycmakeargs=(
		-DSPM_ABSL_PROVIDER=package
		-DSPM_PROTOBUF_PROVIDER=package
		-DSPM_USE_SYSTEM_FLATBUFFERS=ON
		# The standalone Lite tools fetch their own FlatBuffers and Abseil.
		-DSPM_ENABLE_LITE=OFF
	)

	cmake_src_configure
}

src_compile() {
	cmake_src_compile
	cd python || die
	PKG_CONFIG_PATH=. distutils-r1_src_compile
}

src_test() {
	LD_LIBRARY_PATH=${BUILD_DIR}/src distutils-r1_src_test
}

python_test() {
	cd python || die
	${EPYTHON} test/sentencepiece_test.py || die
}

src_install() {
	cmake_src_install
	distutils-r1_src_install
	# Upstream installs the static archives beside the shared libraries.
	find "${ED}" -name '*.a' -delete || die
	strip-lto-bytecode
}
