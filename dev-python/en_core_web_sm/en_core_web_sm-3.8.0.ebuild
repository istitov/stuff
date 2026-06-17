# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=no
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

DESCRIPTION="spaCy English pipeline (small): en_core_web_sm model"
HOMEPAGE="
	https://spacy.io/models/en
	https://github.com/explosion/spacy-models
"
# Not on PyPI; spaCy ships models as wheels on GitHub releases. The py3-none-any
# wheel is pure model data + a thin loader and is tied to the spaCy minor series.
SRC_URI="
	https://github.com/explosion/spacy-models/releases/download/${P}/${P}-py3-none-any.whl
"
S="${WORKDIR}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="mirror"

RDEPEND="
	>=dev-python/spacy-3.8.0[${PYTHON_USEDEP}]
	<dev-python/spacy-3.9.0[${PYTHON_USEDEP}]
"

src_unpack() {
	cp "${DISTDIR}/${A}" "${WORKDIR}/" || die
}

src_compile() { :; }

src_install() {
	python_foreach_impl install_wheel
}

install_wheel() {
	"${EPYTHON}" -m installer --destdir="${D}" "${WORKDIR}/${A}" || die
	python_optimize
}
