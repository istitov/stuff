# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ROCM_VERSION=${PV}

inherit cmake rocm

DESCRIPTION="CU / ROCM agnostic hip FFT implementation"
HOMEPAGE="https://github.com/ROCm/rocm-libraries/tree/develop/projects/hipfft"
# AMD retired the rocm-* release line at rocm-7.2.4 (2026-05-28); the same
# per-component assets ship under therock-<major.minor> tags now.
SRC_URI="https://github.com/ROCm/rocm-libraries/releases/download/therock-$(ver_cut 1-2)/hipfft.tar.gz -> hipfft-${PV}.tar.gz"
S="${WORKDIR}/hipfft"

REQUIRED_USE="${ROCM_REQUIRED_USE}"

LICENSE="MIT"
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"

RDEPEND="
	dev-util/hip:${SLOT}
	sci-libs/rocFFT:${SLOT}
"
DEPEND="${RDEPEND}"

src_configure() {
	rocm_use_clang

	local mycmakeargs=(
		-DROCM_SYMLINK_LIBS=OFF
		-DBUILD_CLIENTS_TESTS=OFF
		-DBUILD_CLIENTS_RIDER=OFF
		-DGPU_TARGETS="$(get_amdgpu_flags)"
	)

	cmake_src_configure
}
