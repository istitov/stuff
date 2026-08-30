# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ROCM_VERSION=${PV}
inherit cmake flag-o-matic rocm

DESCRIPTION="HIP parallel primitives for developing performant GPU-accelerated code on ROCm"
HOMEPAGE="https://github.com/ROCm/rocm-libraries/tree/develop/projects/rocprim"
# AMD retired the rocm-* release line at rocm-7.2.4 (2026-05-28); the same
# per-component assets ship under therock-<major.minor> tags now. ROCm 10.0 is
# the renumbering of the 7.13 -> 7.14 line (2026-08-27).
SRC_URI="https://github.com/ROCm/rocm-libraries/releases/download/therock-$(ver_cut 1-2)/rocprim.tar.gz -> rocprim-${PV}.tar.gz"
S="${WORKDIR}/rocprim"

LICENSE="MIT"
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"
IUSE="benchmark test"
REQUIRED_USE="
	benchmark? ( ${ROCM_REQUIRED_USE} )
	test? ( ${ROCM_REQUIRED_USE} )
"

RDEPEND="
	benchmark? (
		dev-util/hip:${SLOT}
		dev-cpp/benchmark:=
	)
"
DEPEND="
	${RDEPEND}
	dev-util/hip:${SLOT}
	test? ( dev-cpp/gtest )
"
BDEPEND="dev-build/rocm-cmake:${SLOT}"

RESTRICT="!test? ( test )"

src_prepare() {
	# install benchmark files
	if use benchmark; then
		# Both expressions are load-bearing and both are address-matched, so
		# `sed` would exit 0 having done nothing if either anchor moved: the
		# first namespaces the benchmark binaries so they do not collide with
		# other rocm libraries' benchmarks, the second appends the install()
		# rule that ships them at all. A silent no-op yields a USE=benchmark
		# build that looks successful and installs no benchmarks.
		# verified 2026-08-30 against the therock-10.0 source.
		grep -q 'get_filename_component' benchmark/CMakeLists.txt ||
			die "get_filename_component anchor moved; benchmark names would not be namespaced"
		grep -q 'add_executable' benchmark/CMakeLists.txt ||
			die "add_executable anchor moved; benchmarks would build but never install"
		sed -e "/get_filename_component/s,\${BENCHMARK_SOURCE},${PN}_\${BENCHMARK_SOURCE}," \
			-e "/add_executable/a\  install(TARGETS \${BENCHMARK_TARGET})" -i benchmark/CMakeLists.txt || die
	fi

	cmake_src_prepare
}

src_configure() {
	rocm_use_clang

	# too many warnings in tests
	append-cxxflags -Wno-explicit-specialization-storage-class -Wno-deprecated-declarations

	local mycmakeargs=(
		-DCMAKE_SKIP_RPATH=ON
		-DAMDGPU_TARGETS="$(get_amdgpu_flags)"
		-DBUILD_TEST=$(usex test ON OFF)
		-DBUILD_BENCHMARK=$(usex benchmark ON OFF)
		-DROCM_SYMLINK_LIBS=OFF
	)

	cmake_src_configure
}

src_test() {
	check_amdgpu
	# uses HMM to fit tests to default <512M iGPU VRAM
	ROCPRIM_USE_HMM="1" cmake_src_test -j1
}
