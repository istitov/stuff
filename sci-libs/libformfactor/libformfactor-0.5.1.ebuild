# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

MY_P="${PN}-v${PV}"
DESCRIPTION="Computes Fourier shape transforms (form factors) for BornAgain"
HOMEPAGE="https://jugit.fz-juelich.de/mlz/libformfactor"
SRC_URI="https://jugit.fz-juelich.de/mlz/libformfactor/-/archive/v${PV}/${MY_P}.tar.gz"
# jugit's v<ver> tag archive unpacks to formfactor-v<ver>-<full-sha> (the mlz
# project path was renamed libformfactor -> formfactor); pin the tag commit so
# S resolves. # verified 2026-08-10
COMMIT="08b97e5b0fbfef49b3f118a5e7b68698a651bf5a"
S="${WORKDIR}/formfactor-v${PV}-${COMMIT}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# find_package(LibHeinz REQUIRED) carries no version; 0.5.0's ff/CMakeLists
# uses the LibHeinz::LibHeinz target exported since LibHeinz 3.0 (older
# versions get an INTERFACE fallback). 2.0.1 is still in tree; floor at 4.0
# to match the current libheinz major. # verified 2026-08-05
DEPEND=">=sci-libs/libheinz-4.0"
RDEPEND="${DEPEND}"

src_configure() {
	local mycmakeargs=(
		-DPEDANTIC=OFF
		-DWERROR=OFF
	)
	cmake_src_configure
}
