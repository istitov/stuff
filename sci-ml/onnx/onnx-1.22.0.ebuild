# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=scikit-build-core
DISTUTILS_EXT=1
PYTHON_COMPAT=( python3_{11..14} )

inherit cmake distutils-r1

DESCRIPTION="Open Neural Network Exchange (ONNX)"
HOMEPAGE="https://github.com/onnx/onnx"
SRC_URI="https://github.com/onnx/${PN}/archive/refs/tags/v${PV}.tar.gz
	-> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="disableStaticReg"
RESTRICT="test"

RDEPEND="
	dev-cpp/abseil-cpp:=
	>=dev-libs/protobuf-4.25.1:=[protoc(+)]
	>=dev-python/ml-dtypes-0.5.4[${PYTHON_USEDEP}]
	>=dev-python/numpy-1.23.2[${PYTHON_USEDEP}]
	>=dev-python/protobuf-4.25.1[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.15.0[${PYTHON_USEDEP}]
"
DEPEND=${RDEPEND}
BDEPEND="
	>=dev-python/scikit-build-core-0.11[${PYTHON_USEDEP}]
	dev-python/nanobind[${PYTHON_USEDEP}]
"

src_prepare() {
	cmake_src_prepare
	distutils-r1_src_prepare
}

src_configure() {
	mycmakeargs=(
		-DONNX_USE_PROTOBUF_SHARED_LIBS=ON
		-DONNX_USE_LITE_PROTO=ON
		-DBUILD_SHARED_LIBS=ON
		-DONNX_DISABLE_STATIC_REGISTRATION=$(usex disableStaticReg ON OFF)
	)
	cmake_src_configure
}

python_compile() {
	local mycmakeargs=(
		"${mycmakeargs[@]}"
		-DBUILD_SHARED_LIBS=OFF
		-Dnanobind_DIR="$(python_get_sitedir)/nanobind/cmake"
	)
	rm -rf .setuptools-cmake-build || die
	CMAKE_ARGS="${mycmakeargs[@]}" distutils-r1_python_compile
}

src_compile() {
	cmake_src_compile
	distutils-r1_src_compile
}

src_install() {
	cmake_src_install
	distutils-r1_src_install
}
