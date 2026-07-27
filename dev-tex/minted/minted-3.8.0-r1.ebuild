# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..15} )

inherit distutils-r1 latex-package

DESCRIPTION="LaTeX package for source code syntax highlighting"
HOMEPAGE="https://github.com/gpoore/minted/"
SRC_URI="
	https://github.com/gpoore/${PN}/archive/refs/tags/latex/v${PV}.tar.gz
		-> ${P}.tar.gz
"

S="${WORKDIR}"/${PN}-latex-v${PV}

LICENSE="|| ( BSD LPPL-1.3 )"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

IUSE="doc"

# minted.sty opens with two hard gates, each followed by \minted@fatalerror:
#   \IfPackageAtLeastTF{fvextra}{2026/02/25}
#   \IfPackageAtLeastTF{latex2pydata}{2026/02/25}
# so a too-old provider of either aborts every document rather than degrading.
# fvextra 1.14.0 [2026/02/25] arrives with texlive-latexextra-2026_p79458,
# which pins fvextra.r78296; the 2025_p78212 ebuild pins r78177 and is below
# the gate. latex2pydata.sty [2026/02/25 v0.7.0] comes from the 0.7.0 ebuild --
# 0.5.0 ships a [2025/03/03 v0.5.0dev2] development .sty, which is why an
# unfloored dependency here produced an installable but unusable minted.
# verified 2026-07-27
RDEPEND="
	>=dev-python/latexrestricted-0.6.2[${PYTHON_USEDEP}]
	>=dev-python/pygments-2.17.0[${PYTHON_USEDEP}]
	>=dev-tex/latex2pydata-0.7.0[${PYTHON_USEDEP}]
	>=dev-texlive/texlive-latexextra-2026
"
BDEPEND="
	doc? (
		dev-texlive/texlive-fontsextra
	)
"

src_prepare() {
	default

	rm latex/minted/${PN}.pdf || die
}

src_compile() {
	pushd python &> /dev/null || die
	distutils-r1_src_compile
	popd &> /dev/null || die

	pushd latex/minted &> /dev/null || die
	latex-package_src_compile
	popd &> /dev/null || die
}

src_install() {
	dodoc README.md

	pushd python &> /dev/null || die
	docinto python
	dodoc *.md
	distutils-r1_src_install
	popd &> /dev/null || die

	pushd latex &> /dev/null || die
	docinto latex
	dodoc *.md
	popd &> /dev/null || die

	pushd latex/minted &> /dev/null || die
	latex-package_src_doinstall styles fonts bin
	if use doc; then
		python_setup
		local -x LATEX_DOC_ARGUMENTS="-shell-escape"
		local -x PYTHONPATH="${ED}/usr/lib/${EPYTHON}/site-packages"
		local -x PATH="${ED}/usr/lib/python-exec/${EPYTHON}:${PATH}"
		latex-package_src_doinstall doc
	fi
	popd &> /dev/null || die
}
