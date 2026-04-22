# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="A C++ compile-time math library using generalized constant expressions"
HOMEPAGE="https://github.com/kthohr/gcem"
SRC_URI="https://github.com/kthohr/gcem/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test"
RESTRICT="!test? ( test )"

src_configure() {
	local mycmakeargs=(
		-DGCEM_BUILD_TESTS=$(usex test ON OFF)
	)
	cmake_src_configure
}
