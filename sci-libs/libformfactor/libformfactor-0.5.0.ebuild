# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

MY_P="${PN}-v${PV}"
DESCRIPTION="Computes Fourier shape transforms (form factors) for BornAgain"
HOMEPAGE="https://jugit.fz-juelich.de/mlz/lib/formfactor"
SRC_URI="https://jugit.fz-juelich.de/mlz/lib/formfactor/-/archive/v${PV}/${MY_P}.tar.gz"
# Jugit appends the full tag commit to its archive root; pin it for S.
# verified 2026-08-05
COMMIT="e534de540b66df43878100b66859e84df4af0c5e"
S="${WORKDIR}/formfactor-v${PV}-${COMMIT}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# CMake requests no version; require the current LibHeinz major and avoid the
# legacy interface fallback. verified 2026-08-05
DEPEND=">=sci-libs/libheinz-4.0"
RDEPEND="${DEPEND}"

src_configure() {
	local mycmakeargs=(
		-DPEDANTIC=OFF
		-DWERROR=OFF
	)
	cmake_src_configure
}
