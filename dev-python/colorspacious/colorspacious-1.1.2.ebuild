# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Powerful, accurate, and easy-to-use Python library for colorspace conversions"
HOMEPAGE="https://colorspacious.readthedocs.io/"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"
IUSE="doc"

RDEPEND="dev-python/numpy[${PYTHON_USEDEP}]"
# The docs build once, under any implementation that has the Sphinx stack;
# ::gentoo's sphinxcontrib-bibtex lacks python3_12. verified 2026-10-26
BDEPEND="${RDEPEND}
	doc? (
		$(python_gen_any_dep '
			dev-python/ipython[${PYTHON_USEDEP}]
			dev-python/matplotlib[${PYTHON_USEDEP}]
			dev-python/numpy[${PYTHON_USEDEP}]
			dev-python/sphinx-rtd-theme[${PYTHON_USEDEP}]
			dev-python/sphinxcontrib-bibtex[${PYTHON_USEDEP}]
		')
		media-gfx/graphviz
	)
"

PATCHES=( "${FILESDIR}"/${P}-fix-deprecated-confpy.patch )

python_check_deps() {
	use doc || return 0
	python_has_version \
		"dev-python/ipython[${PYTHON_USEDEP}]" \
		"dev-python/matplotlib[${PYTHON_USEDEP}]" \
		"dev-python/numpy[${PYTHON_USEDEP}]" \
		"dev-python/sphinx-rtd-theme[${PYTHON_USEDEP}]" \
		"dev-python/sphinxcontrib-bibtex[${PYTHON_USEDEP}]"
}

python_compile_all() {
	if use doc; then
		VARTEXFONTS="${T}"/fonts MPLCONFIGDIR="${T}" PYTHONPATH="${BUILD_DIR}"/lib \
			emake -C doc html
		HTML_DOCS=( doc/_build/html/. )
	fi
}
