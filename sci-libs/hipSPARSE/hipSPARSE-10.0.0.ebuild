# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ROCM_VERSION=${PV}

inherit cmake rocm

DESCRIPTION="ROCm SPARSE marshalling library"
HOMEPAGE="https://github.com/ROCm/rocm-libraries/tree/develop/projects/hipsparse"
# share some test datasets with rocSPARSE
# AMD retired the rocm-* release line at rocm-7.2.4 (2026-05-28); the same
# per-component assets ship under therock-<major.minor> tags now.
MY_URI="https://github.com/ROCm/rocm-libraries/releases/download/therock-$(ver_cut 1-2)"
SRC_URI="${MY_URI}/hipsparse.tar.gz -> hipsparse-${PV}.tar.gz"
S="${WORKDIR}/hipsparse"

LICENSE="MIT"
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"
IUSE="benchmark"
REQUIRED_USE="${ROCM_REQUIRED_USE}"

# The tests heavily abuse out-of-bounds array access and fail with hardened
# libc++. Do not expose dead USE=test plumbing while the phase is restricted.
RESTRICT="test"

RDEPEND="
	dev-util/rocminfo:${SLOT}
	dev-util/hip:${SLOT}
	sci-libs/rocSPARSE:${SLOT}
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-build/rocm-cmake
"

src_prepare() {
	# too many warnings from -Wall (applied after user CXXFLAGS)
	#
	# Guarded because `sed` exits 0 on no-match, so an upstream that stops
	# spelling -Wall here would leave the suppression silently inert rather
	# than failing.
	#
	# clients/tests/CMakeLists.txt was in this list through 7.2.4 but carries
	# no -Wall at 10.0 (the file still exists; the flag is gone), so listing it
	# was a silent no-op -- dropped rather than left to imply coverage it does
	# not provide. The guard below is what caught it.
	# verified 2026-08-30 against the therock-10.0 source.
	local f
	for f in clients/benchmarks/CMakeLists.txt library/CMakeLists.txt; do
		grep -q -- '-Wall' "${f}" ||
			die "-Wall anchor moved in ${f}; -Wno-unused-value would not apply"
	done
	sed -e "s/-Wall/-Wall -Wno-unused-value/g" \
		-i clients/benchmarks/CMakeLists.txt \
		-i library/CMakeLists.txt || die

	cmake_src_prepare
}

src_configure() {
	rocm_use_clang

	local mycmakeargs=(
		-DHIP_RUNTIME="ROCclr"
		-DBUILD_CLIENTS_TESTS=OFF
		-DBUILD_CLIENTS_SAMPLES=OFF
		-DBUILD_CLIENTS_BENCHMARKS=$(usex benchmark ON OFF)
		-DROCM_SYMLINK_LIBS=OFF
		-DBUILD_FILE_REORG_BACKWARD_COMPATIBILITY=OFF
	)

	cmake_src_configure
}
