# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ROCM_VERSION=${PV}

inherit cmake rocm

DESCRIPTION="ROCm SPARSE marshalling library"
HOMEPAGE="https://github.com/ROCm/rocm-libraries/tree/develop/projects/hipsparse"
# ROCm 10 component assets use therock tags; rocm tags end at 7.2.4.
MY_URI="https://github.com/ROCm/rocm-libraries/releases/download/therock-$(ver_cut 1-2)"
SRC_URI="${MY_URI}/hipsparse.tar.gz -> hipsparse-${PV}.tar.gz"
S="${WORKDIR}/hipsparse"

LICENSE="MIT"
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"
IUSE="benchmark"
REQUIRED_USE="${ROCM_REQUIRED_USE}"

# Tests perform out-of-bounds accesses and fail with hardened libc++.
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
	# Upstream adds -Wall after user flags; guard its remaining anchors before
	# adding the required suppression. verified 2026-08-30
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
