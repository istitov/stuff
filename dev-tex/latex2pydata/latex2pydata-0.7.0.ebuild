# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..15} )

inherit distutils-r1 latex-package

DESCRIPTION="Allows LaTeX to save data to files using Python"
HOMEPAGE="
	https://github.com/gpoore/latex2pydata
	https://pypi.org/project/latex2pydata/
"
# PV tracks the LaTeX release, not the python one. Upstream tags the two
# halves independently -- python/ tops out at v0.5.0 while latex/ is at v0.7.0
# -- and this package lives in dev-tex because the .sty is the reason it
# exists. Earlier ebuilds fetched the python/vX.Y.Z tag, which picks up
# whatever unreleased state latex/ happened to be in: python/v0.5.0 ships
# latex2pydata.sty [2025/03/03 v0.5.0dev2], a development build. dev-tex/minted
# 3.8.0 hard-gates on \IfPackageAtLeastTF{latex2pydata}{2026/02/25} and
# fatal-errors below it, which that dev .sty does not satisfy.
# The python package inside this tag is still 0.5.0 final, identical to what
# the 0.5.0 ebuild installs, so nothing regresses on that side.
# verified 2026-07-27
SRC_URI="
	https://github.com/gpoore/${PN}/archive/refs/tags/latex/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
"

S="${WORKDIR}/${PN}-latex-v${PV}"

LICENSE="LPPL-1.3c"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# fontsextra for fourier.sty
# latexextra for upquote.sty
BDEPEND="
	>=dev-texlive/texlive-fontsextra-2024
	>=dev-texlive/texlive-latexextra-2024
"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

src_compile() {
	pushd python > /dev/null || die
	distutils-r1_src_compile
	popd > /dev/null || die

	pushd latex/latex2pydata > /dev/null || die
	latex-package_src_compile
	popd > /dev/null || die
}

src_test() {
	pushd python > /dev/null || die
	distutils-r1_src_test
	popd > /dev/null || die
}

src_install() {
	dodoc README.md

	pushd python > /dev/null || die
	distutils-r1_src_install
	docinto python
	dodoc CHANGELOG.md README.md
	popd > /dev/null || die

	pushd latex  > /dev/null || die
	docinto latex
	dodoc CHANGELOG.md README.md
	popd > /dev/null || die

	pushd latex/latex2pydata > /dev/null || die
	latex-package_src_install
	popd > /dev/null || die
}
