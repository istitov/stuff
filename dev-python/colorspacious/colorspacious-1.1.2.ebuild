# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

#DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{9..12} )

inherit distutils-r1 pypi

DESCRIPTION="Powerful, accurate, and easy-to-use Python library for colorspace conversions"
HOMEPAGE="https://colorspacious.readthedocs.org"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc"

RDEPEND="dev-python/numpy[${PYTHON_USEDEP}]"
BDEPEND="${RDEPEND}
	doc? (
		${RDEPEND}
		dev-python/sphinxcontrib-bibtex[${PYTHON_USEDEP}]
		dev-python/sphinx-rtd-theme[${PYTHON_USEDEP}]
		dev-python/ipython[${PYTHON_USEDEP}]
		dev-python/matplotlib[${PYTHON_USEDEP}]
		media-gfx/graphviz
	)
"

PATCHES=( "${FILESDIR}"/${P}-fix-deprecated-confpy.patch )

#distutils_enable_tests nose
# FileNotFoundError: [Errno 2] No such file or directory: '_static/colorspacious-graph.dot'
#distutils_enable_sphinx doc dev-python/sphinxcontrib-bibtex \
#	dev-python/sphinx-rtd-theme \
#	dev-python/ipython \
#	dev-python/matplotlib

python_compile_all() {
	if use doc; then
		VARTEXFONTS="${T}"/fonts MPLCONFIGDIR="${T}" PYTHONPATH="${BUILD_DIR}"/lib \
			emake -C doc html
		HTML_DOCS=( doc/_build/html/. )
	fi
}

#python_test() {
#	nosetests -v --all-modules || die "Tests fail with ${EPYTHON}"
#}
