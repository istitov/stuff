# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ROCM_VERSION=${PV}

inherit cmake rocm

DESCRIPTION="Generate pseudo-random and quasi-random numbers"
HOMEPAGE="https://github.com/ROCm/rocRAND"
# ROCm/rocRAND was FOLDED INTO the rocm-libraries monorepo for 10.0: the
# standalone repo has no therock-* tags at all (its last tag is rocm-7.2.4),
# and the 10.0 sources ship only as the rocrand.tar.gz release asset. So this
# is a source-shape change, not just a tag swap -- the git-archive form is gone
# and S= follows the asset's own root instead of ${PN}-rocm-${PV}.
# verified 2026-08-29.
SRC_URI="https://github.com/ROCm/rocm-libraries/releases/download/therock-$(ver_cut 1-2)/rocrand.tar.gz -> rocrand-${PV}.tar.gz"
S="${WORKDIR}/rocrand"

LICENSE="MIT"
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"
IUSE="benchmark test"
REQUIRED_USE="${ROCM_REQUIRED_USE}"

RESTRICT="!test? ( test )"

# cmake/Dependencies.cmake does find_package(benchmark 1.9.1 QUIET) and, on
# failure, falls through to a FetchContent clone of github.com/google/benchmark,
# which cannot work inside portage's network sandbox. ::gentoo still ships 1.8.4
# next to the 1.9.x line, so an existing 1.8.4 install satisfied the bare atom,
# got no upgrade, and sent USE=benchmark builds down the fetch path.
# verified 2026-07-27
RDEPEND="
	dev-util/hip:${SLOT}
	benchmark? ( >=dev-cpp/benchmark-1.9.1 )
"
DEPEND="${RDEPEND}
	dev-build/rocm-cmake:${SLOT}
	test? ( dev-cpp/gtest )"
BDEPEND="dev-build/rocm-cmake:${SLOT}"

PATCHES=(
	"${FILESDIR}/${PN}-10.0.0-no-tests-install.patch"
)

src_configure() {
	rocm_use_clang

	export ROCM_PATH="${EPREFIX}/usr"

	local mycmakeargs=(
		-DCMAKE_SKIP_RPATH=ON
		-DAMDGPU_TARGETS="$(get_amdgpu_flags)"
		-DROCM_SYMLINK_LIBS=OFF
		-DBUILD_TEST=$(usex test ON OFF)
		-DBUILD_BENCHMARK=$(usex benchmark ON OFF)
	)

	cmake_src_configure
}

src_test() {
	check_amdgpu
	export LD_LIBRARY_PATH="${BUILD_DIR}/library"
	# uses HMM to fit tests to default <512M iGPU VRAM
	ROCRAND_USE_HMM="1" cmake_src_test -j1
}

src_install() {
	cmake_src_install

	if use benchmark; then
		cd "${BUILD_DIR}"/benchmark || die
		dobin benchmark_rocrand_*
	fi
}
