# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_EXT=1
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

DESCRIPTION="Industrial-strength Natural Language Processing (NLP) in Python"
HOMEPAGE="
	https://spacy.io
	https://github.com/explosion/spacy
	https://pypi.org/project/spacy/
"
SRC_URI="https://github.com/explosion/${PN}/archive/refs/tags/release-v${PV}.tar.gz
	-> ${P}.gh.tar.gz"
S="${WORKDIR}/spaCy-release-v${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# Pinned to 3.8.x: this is the version-line that solves against
# thinc 8.3.x. spacy 3.9+ might want thinc 9.x; revisit when bumping.
RDEPEND="
	${PYTHON_DEPS}
	>=dev-python/spacy-legacy-3.0.11[${PYTHON_USEDEP}]
	<dev-python/spacy-legacy-3.1[${PYTHON_USEDEP}]
	>=dev-python/spacy-loggers-1.0.0[${PYTHON_USEDEP}]
	<dev-python/spacy-loggers-2[${PYTHON_USEDEP}]
	>=dev-python/murmurhash-0.28.0[${PYTHON_USEDEP}]
	<dev-python/murmurhash-1.1[${PYTHON_USEDEP}]
	>=dev-python/cymem-2.0.2[${PYTHON_USEDEP}]
	<dev-python/cymem-2.1[${PYTHON_USEDEP}]
	>=dev-python/preshed-3.0.2[${PYTHON_USEDEP}]
	<dev-python/preshed-3.1[${PYTHON_USEDEP}]
	>=dev-python/thinc-8.3.12[${PYTHON_USEDEP}]
	<dev-python/thinc-8.4[${PYTHON_USEDEP}]
	>=dev-python/wasabi-0.9.1[${PYTHON_USEDEP}]
	<dev-python/wasabi-1.2[${PYTHON_USEDEP}]
	>=dev-python/srsly-2.5.3[${PYTHON_USEDEP}]
	<dev-python/srsly-3[${PYTHON_USEDEP}]
	>=dev-python/catalogue-2.0.6[${PYTHON_USEDEP}]
	<dev-python/catalogue-2.1[${PYTHON_USEDEP}]
	>=dev-python/weasel-1.0.0[${PYTHON_USEDEP}]
	<dev-python/weasel-2[${PYTHON_USEDEP}]
	>=dev-python/confection-1.3.2[${PYTHON_USEDEP}]
	<dev-python/confection-2[${PYTHON_USEDEP}]
	>=dev-python/typer-0.3.0[${PYTHON_USEDEP}]
	<dev-python/typer-1[${PYTHON_USEDEP}]
	>=dev-python/tqdm-4.38.0[${PYTHON_USEDEP}]
	>=dev-python/numpy-1.19.0[${PYTHON_USEDEP}]
	>=dev-python/requests-2.13.0[${PYTHON_USEDEP}]
	<dev-python/requests-3[${PYTHON_USEDEP}]
	>=dev-python/pydantic-2.0.0[${PYTHON_USEDEP}]
	<dev-python/pydantic-3[${PYTHON_USEDEP}]
	dev-python/jinja2[${PYTHON_USEDEP}]
	dev-python/setuptools[${PYTHON_USEDEP}]
	>=dev-python/packaging-20.0[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
BDEPEND="
	${PYTHON_DEPS}
	dev-python/cython[${PYTHON_USEDEP}]
"
