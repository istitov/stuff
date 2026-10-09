# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="AMD Debugger API"
HOMEPAGE="https://github.com/ROCm/rocm-systems/tree/develop/projects/rocdbgapi"
# ::gentoo stops at 7.2, whose runtime subslot pin would retain that closure;
# gdb still needs rocdbgapi. Post-7.2.4 sources use therock-* assets.
# verified 2026-08-30
SRC_URI="https://github.com/ROCm/rocm-systems/releases/download/therock-$(ver_cut 1-2)/${PN}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN}"

LICENSE="MIT"
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"

IUSE="doc"

BDEPEND="
	doc? (
		app-text/doxygen[dot]
		virtual/latex-base
		dev-texlive/texlive-latexextra
		dev-texlive/texlive-plaingeneric
	)
"
RDEPEND="
	dev-libs/rocm-comgr:${SLOT}
"
DEPEND="
	${RDEPEND}
	dev-libs/rocr-runtime:${SLOT}
"

src_prepare() {
	# Guard substitutions because sed succeeds on missing anchors; three alter
	# install paths. # verified 2026-08-30 against therock-10.0
	grep -q -- '-Werror' CMakeLists.txt ||
		die "-Werror gone from CMakeLists.txt; upstream likely dropped it, so drop that expression"
	# shellcheck disable=SC2016
	grep -q '${CMAKE_INSTALL_DATADIR}/html/amd-dbgapi' CMakeLists.txt ||
		die "html docdir anchor moved; generated docs would install outside the docdir"
	# shellcheck disable=SC2016
	grep -q '${CMAKE_INSTALL_DATADIR}/doc/${CPACK_PACKAGE_NAME}' CMakeLists.txt ||
		die "docdir anchor moved; docs would install under CPACK_PACKAGE_NAME"
	grep -q 'COMPONENT asan' CMakeLists.txt ||
		die "COMPONENT asan anchor moved; the asan component would be installed"
	sed -e "s/-Werror//" \
		-e "s:\${CMAKE_INSTALL_DATADIR}/html/amd-dbgapi:\${CMAKE_INSTALL_DOCDIR}/html:" \
		-e "s:\${CMAKE_INSTALL_DATADIR}/doc/\${CPACK_PACKAGE_NAME}:\${CMAKE_INSTALL_DOCDIR}:" \
		-e "s/COMPONENT asan/COMPONENT asan EXCLUDE_FROM_ALL/" \
		-i CMakeLists.txt || die
	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_REQUIRE_FIND_PACKAGE_Doxygen=$(usex doc)
		-DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=$(usex !doc)
	)
	cmake_src_configure
}

src_compile() {
	cmake_src_compile
	use doc && cmake_src_compile doc
}
