# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )

inherit cuda cmake edo flag-o-matic multiprocessing python-r1

EIGEN_COMMIT="1d8b82b0740839c0de7f1242a3585e3390ff5f33"
ABSEIL_VERSION="20250814.1"
CUTLASS_VERSION="4.4.2"
CUDNN_FRONTEND_VERSION="1.24.0"
GTEST_VERSION="1.17.0"

DESCRIPTION="Cross-platform, high performance ML inferencing and training accelerator"
HOMEPAGE="
	https://onnxruntime.ai
	https://github.com/microsoft/onnxruntime
"
SRC_URI="
	https://github.com/microsoft/onnxruntime/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://gitlab.com/libeigen/eigen/-/archive/${EIGEN_COMMIT}/eigen-${EIGEN_COMMIT}.tar.bz2 ->
		eigen-3.4.0_p20250216.tar.bz2
	cuda? (
		https://github.com/abseil/abseil-cpp/archive/refs/tags/${ABSEIL_VERSION}.tar.gz ->
			abseil-cpp-${ABSEIL_VERSION}.tar.gz
		https://github.com/NVIDIA/cutlass/archive/refs/tags/v${CUTLASS_VERSION}.tar.gz ->
			cutlass-${CUTLASS_VERSION}.tar.gz
		https://github.com/NVIDIA/cudnn-frontend/archive/refs/tags/v${CUDNN_FRONTEND_VERSION}.tar.gz ->
			cudnn-frontend-${CUDNN_FRONTEND_VERSION}.tar.gz
	)
	test? (
		https://github.com/google/googletest/archive/refs/tags/v${GTEST_VERSION}.tar.gz ->
			googletest-${GTEST_VERSION}.tar.gz
	)
"

LICENSE="Apache-2.0 BSD MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="cuda python test"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"
RESTRICT="!test? ( test )"

# cmake/deps.txt pins the final ONNX 1.22.0 release. The system-libraries
# patch turns that FetchContent entry into a required find_package call, so
# keep the system package at the exact upstream floor.
RDEPEND="
	!cuda? ( dev-cpp/abseil-cpp:= )
	dev-libs/cpuinfo
	dev-libs/protobuf:=
	dev-libs/re2:=
	>=sci-ml/onnx-1.22.0[disableStaticReg]
	cuda? (
		~dev-cpp/abseil-cpp-20250814.1:=
		dev-libs/cudnn:=
		dev-util/nvidia-cuda-toolkit:=
	)

	python? (
		${PYTHON_DEPS}
		dev-python/flatbuffers[${PYTHON_USEDEP}]
		>=dev-python/numpy-1.21.6[${PYTHON_USEDEP}]
		dev-python/packaging[${PYTHON_USEDEP}]
		>=dev-python/protobuf-4.25.8[${PYTHON_USEDEP}]
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
	cuda? ( sys-devel/gcc:15 )
	python? ( >=dev-python/setuptools-61[${PYTHON_USEDEP}] )

	test? (
		python? ( dev-python/pytest[${PYTHON_USEDEP}] )
	)
"

PATCHES=(
	"${FILESDIR}/${PN}-1.22.2-relax-the-dependency-on-flatbuffers.patch"
	"${FILESDIR}/${PN}-1.24.4-no-werror.patch"
	"${FILESDIR}/${PN}-1.28.0-use-system-libraries.patch"
	"${FILESDIR}/${PN}-1.29.0-fix-cuda-test-linking.patch"
)

CMAKE_USE_DIR="${S}/cmake"

# Throttle nvcc during the compile phase only: flash-attention nvcc jobs
# each consume more than 3 GiB, so cap concurrency to avoid OOM while
# preserving any lower user limit. Not applied to the install phase, which
# only copies files and spawns no compiler.
onnxruntime_cmake_phase() {
	local jobs=$(makeopts_jobs)
	if use cuda && (( jobs > 4 )); then
		local -x MAKEOPTS="${MAKEOPTS} -j4"
	fi
	"$@"
}

src_prepare() {
	cmake_src_prepare

	if use cuda; then
		pushd "${WORKDIR}/abseil-cpp-${ABSEIL_VERSION}" >/dev/null || die
		eapply "${FILESDIR}/${PN}-1.28.0-abseil-nvcc.patch"
		popd >/dev/null || die
	fi
}

src_configure() {
	# Python is used at build time unconditionally
	python_setup

	local mycmakeargs=(
		-Donnxruntime_BUILD_SHARED_LIB=on

		-Donnxruntime_BUILD_UNIT_TESTS=$(usex test)
		-Donnxruntime_ENABLE_PYTHON=$(usex python)
		-Donnxruntime_USE_CUDA=$(usex cuda)

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

	if use cuda; then
		# nvcc rejects gcc newer than the active CUDA toolkit supports
		# (CUDA 13 tops out at gcc 15). cuda_gccdir picks the newest
		# supported slot; pin ordinary C++, CUDA host compilation, and
		# final linking to it so all three share one libstdc++ ABI. The
		# cuda? sys-devel/gcc:15 BDEPEND guarantees a compatible slot is
		# installed for cuda_gccdir to find.
		local cuda_gcc_bindir
		cuda_gcc_bindir="$(cuda_gccdir)" || die
		local -x CC="${cuda_gcc_bindir}/gcc"
		local -x CXX="${cuda_gcc_bindir}/g++"
		local -x CUDAHOSTCXX="${CXX}"
		cuda_add_sandbox -w
		mycmakeargs+=(
			-DCMAKE_CUDA_ARCHITECTURES="${CUDAARCHS:-all-major}"
			-DCMAKE_CUDA_COMPILER="/opt/cuda/bin/nvcc"
			-DCMAKE_CUDA_FLAGS="-I${WORKDIR}/abseil-cpp-${ABSEIL_VERSION}"
			-DCMAKE_CUDA_HOST_COMPILER="${CUDAHOSTCXX}"
			-DFETCHCONTENT_SOURCE_DIR_CUDNN_FRONTEND="${WORKDIR}/cudnn-frontend-${CUDNN_FRONTEND_VERSION}"
			-DFETCHCONTENT_SOURCE_DIR_CUTLASS="${WORKDIR}/cutlass-${CUTLASS_VERSION}"
			-Donnxruntime_CUDA_HOME="/opt/cuda"
			-Donnxruntime_CUDNN_HOME="/opt/cuda"
		)
	fi
	use test && mycmakeargs+=(
		-DFETCHCONTENT_SOURCE_DIR_GOOGLETEST="${WORKDIR}/googletest-${GTEST_VERSION}"
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

src_compile() {
	onnxruntime_cmake_phase cmake_src_compile
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
	use cuda && libs+=( "libonnxruntime_providers_cuda.so" )
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
