# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Common in-memory tensor structure"
HOMEPAGE="https://github.com/dmlc/dlpack"
SRC_URI="https://github.com/dmlc/dlpack/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64"
IUSE="doc test"
RESTRICT="!test? ( test )"

BDEPEND="doc? (
	app-text/doxygen
	dev-python/breathe
	dev-python/pydata-sphinx-theme
	dev-python/sphinx
)"

PATCHES=(
	"${FILESDIR}/${PN}-1.1-dont-turn-warnings-into-errors-when-building-docs.patch"
)

src_prepare() {
	# Upstream's project() still declares VERSION 0.6, which ends up in
	# dlpackConfigVersion.cmake, so find_package(dlpack 1.3) rejects the
	# install. Declare the real version. verified 2026-11-05
	sed -i -e "s/^project(dlpack VERSION 0\.6 /project(dlpack VERSION $(ver_cut 1-2) /" \
		CMakeLists.txt || die
	grep -q "^project(dlpack VERSION $(ver_cut 1-2) " CMakeLists.txt ||
		die "project version not set"
	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_DOCS=$(usex doc)
		-DBUILD_MOCK=$(usex test)
	)

	cmake_src_configure
}
