# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )

inherit cmake edo flag-o-matic python-r1

EIGEN_COMMIT="1d8b82b0740839c0de7f1242a3585e3390ff5f33"

DESCRIPTION="Cross-platform, high performance ML inferencing and training accelerator"
HOMEPAGE="
	https://onnxruntime.ai
	https://github.com/microsoft/onnxruntime
"
SRC_URI="
	https://github.com/microsoft/onnxruntime/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://gitlab.com/libeigen/eigen/-/archive/${EIGEN_COMMIT}/eigen-${EIGEN_COMMIT}.tar.bz2 ->
		eigen-3.4.0_p20250216.tar.bz2
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="python test"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"
RESTRICT="!test? ( test )"

# cmake/deps.txt for v1.29.0 pins onnx v1.22.0, and the
# use-system-libraries patch rewrites that FetchContent entry to
# FIND_PACKAGE_ARGS ... REQUIRED, so the system onnx is what gets used with
# no version guard of its own. That floor is not expressible: sci-ml/onnx
# exists only in ::gentoo and tops out at 1.20.1. Floored at 1.20.1 to keep
# 1.18.0-r1 out, which is further still from the pin. Whether 1.20.1 is
# actually sufficient has NOT been established -- raise this to
# >=sci-ml/onnx-1.22.0 once onnx is packaged that far.
# verified 2026-07-27
RDEPEND="
	dev-cpp/abseil-cpp:=
	dev-libs/cpuinfo
	dev-libs/protobuf:=
	dev-libs/re2:=
	>=sci-ml/onnx-1.20.1[disableStaticReg]

	python? (
		${PYTHON_DEPS}
		dev-python/coloredlogs[${PYTHON_USEDEP}]
		dev-python/flatbuffers[${PYTHON_USEDEP}]
		>=dev-python/numpy-2[${PYTHON_USEDEP}]
		dev-python/packaging[${PYTHON_USEDEP}]
		dev-python/protobuf[${PYTHON_USEDEP}]
		dev-python/sympy[${PYTHON_USEDEP}]
	)
"
DEPEND="
	${RDEPEND}
	dev-cpp/ms-gsl
	dev-cpp/nlohmann_json
	dev-cpp/safeint
	dev-libs/boost
	dev-libs/date
	dev-libs/flatbuffers

	python? (
		dev-python/pybind11[${PYTHON_USEDEP}]
		sci-libs/dlpack
	)
"
BDEPEND="
	${PYTHON_DEPS}

	test? (
		dev-cpp/gtest

		python? ( dev-python/pytest[${PYTHON_USEDEP}] )
	)
"

PATCHES=(
	"${FILESDIR}/${PN}-1.22.2-relax-the-dependency-on-flatbuffers.patch"
	"${FILESDIR}/${PN}-1.24.4-no-werror.patch"
	"${FILESDIR}/${PN}-1.28.0-use-system-libraries.patch"
)

CMAKE_USE_DIR="${S}/cmake"

src_configure() {
	# Python is used at build time unconditionally
	python_setup

	local mycmakeargs=(
		-Donnxruntime_BUILD_SHARED_LIB=on

		-Donnxruntime_BUILD_UNIT_TESTS=$(usex test)
		-Donnxruntime_ENABLE_PYTHON=$(usex python)

		# Use vendored Eigen at a specific 3.4-branch commit (2025-02-15).
		# ::gentoo's dev-cpp/eigen-3.4.0-r3 (Aug 2021) lacks 3+ years of
		# fixes onnxruntime depends on; eigen-3.4.9999 (live) would work
		# but a live ebuild as a build-dep is fragile. Eigen 5.0.1
		# (released 2026) is a major API break; onnxruntime's CMakeLists
		# doesn't yet support it. Drop the vendor when ::gentoo carries
		# a tagged 3.4.x release post-2025-02 or when upstream supports
		# Eigen 5.x. Verified 2026-05-16.
		-DFETCHCONTENT_SOURCE_DIR_EIGEN3="${WORKDIR}/eigen-${EIGEN_COMMIT}"

		# This makes it possible for `find_path` to find the `onnx-ml.proto` file
		-DCMAKE_INCLUDE_PATH="$(python_get_sitedir)"

		-Wno-dev
	)

	# 1.29.0 adds a non-Windows telemetry path (1DS SDK: cpp_client_telemetry
	# plus a bundled static curl + mbedTLS) as three new cmake/deps.txt
	# FetchContent entries. They are gated behind onnxruntime_USE_TELEMETRY
	# (option default OFF, cmake/CMakeLists.txt), which we do not enable, so
	# none of the three are fetched -- no new system deps and nothing to fetch
	# under portage's network sandbox. Revisit if USE_TELEMETRY is ever wired.
	# verified 2026-08-12 against onnxruntime-1.29.0
	append-ldflags -Wl,-z,noexecstack
	cmake_src_configure
}

# Adapted from `run_onnxruntime_tests` in `tools/ci_build/build.py`
python_test() {
	cd "${S}/cmake_build" || die
	epytest --pyargs \
		onnxruntime_test_python.py \
		onnxruntime_test_python_backend.py \
		onnxruntime_test_python_mlops.py \
		onnxruntime_test_python_sparse_matmul.py
}

src_test() {
	local -x GTEST_FILTER="*:-ActivationOpNoInfTest.Softsign:LayoutTransformationPotentiallyAddedOpsTests.OpsHaveLatestVersions"
	cmake_src_test

	if use python ; then
		python_test
	fi
}

# There is some custom logic in `setup.py`
python_install() {
	cd "${S}/cmake_build" || die
	edo "${EPYTHON}" ../setup.py install \
		--prefix="${EPREFIX}/usr" \
		--root="${D}"

	local libs=(
		"libonnxruntime.so.${PV}"
		"libonnxruntime_providers_shared.so"
	)
	for lib in "${libs[@]}"; do
		ln -fsr "${ED}/usr/$(get_libdir)/${lib}" "${D}/$(python_get_sitedir)/onnxruntime/capi/${lib}" || die
	done

	rm -rf "${D}/$(python_get_sitedir)"/*.egg-info || die
	python_optimize
}

src_install() {
	cmake_src_install

	if use python ; then
		python_foreach_impl python_install
	fi

	dodoc "${S}/"{README.md,LICENSE}
}
