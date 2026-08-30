# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="AMD Debugger API"
HOMEPAGE="https://github.com/ROCm/rocm-systems/tree/develop/projects/rocdbgapi"
# Forked into ::stuff for ROCm 10.0. ::gentoo stops at 7.2.x, and rocdbgapi
# RDEPENDs on dev-libs/rocm-comgr:${SLOT} -- a RUNTIME subslot pin, so an
# installed 7.2.0 keeps the whole 7.2 closure alive and makes the 10.0 stack
# unresolvable for @world. It is not orphaned either: dev-debug/gdb pulls it
# in for AMD GPU debugging, so dropping it is not an option. verified
# 2026-08-30.
#
# AMD retired the rocm-* release line at rocm-7.2.4 (2026-05-28); the 10.0
# source ships as the rocdbgapi.tar.gz asset on the rocm-systems
# therock-<major.minor> release, the same shape dev-util/roctracer and
# dev-util/amdsmi use.
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

# ::gentoo carries rocdbgapi-6.3.0-fix-libcxx.patch. Not forked in: it is not
# applied by the 7.2.0 ebuild either (that ebuild declares no PATCHES at all),
# so it is dead weight in ::gentoo rather than something 10.0 dropped.

src_prepare() {
	# Each substitution asserts its anchor first. `sed` exits 0 on no-match, so
	# without these an upstream rename leaves the edit silently inert with a
	# green build -- and three of the four decide install paths, which is the
	# quietest way for this to go wrong.
	# All anchors verified 2026-08-30 against the therock-10.0 source.
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
