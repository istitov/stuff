# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_EXT=1
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Functional deep-learning library — NN layer underneath ExplosionAI spaCy"
HOMEPAGE="
	https://github.com/explosion/thinc
	https://thinc.ai
	https://pypi.org/project/thinc/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

# Pinned to 8.3.x: dev-python/spacy 3.8.14 caps thinc<8.4.0,>=8.3.12.
# thinc 9.x ships on PyPI but spacy doesn't accept it. Verify when
# spacy bumps its thinc cap upstream.
RDEPEND="
	${PYTHON_DEPS}
	>=dev-python/blis-1.3.0[${PYTHON_USEDEP}]
	<dev-python/blis-1.4[${PYTHON_USEDEP}]
	>=dev-python/cymem-2.0.2[${PYTHON_USEDEP}]
	<dev-python/cymem-2.1[${PYTHON_USEDEP}]
	>=dev-python/murmurhash-1.0.2[${PYTHON_USEDEP}]
	<dev-python/murmurhash-1.1[${PYTHON_USEDEP}]
	>=dev-python/preshed-3.0.2[${PYTHON_USEDEP}]
	<dev-python/preshed-3.1[${PYTHON_USEDEP}]
	>=dev-python/wasabi-0.8.1[${PYTHON_USEDEP}]
	<dev-python/wasabi-1.2[${PYTHON_USEDEP}]
	>=dev-python/srsly-2.4.0[${PYTHON_USEDEP}]
	<dev-python/srsly-3.1[${PYTHON_USEDEP}]
	>=dev-python/catalogue-2.0.4[${PYTHON_USEDEP}]
	<dev-python/catalogue-2.1[${PYTHON_USEDEP}]
	>=dev-python/confection-1.1.0[${PYTHON_USEDEP}]
	<dev-python/confection-2[${PYTHON_USEDEP}]
	>=dev-python/numpy-1.21.0[${PYTHON_USEDEP}]
	dev-python/pydantic[${PYTHON_USEDEP}]
	dev-python/packaging[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
BDEPEND="
	${PYTHON_DEPS}
	dev-python/cython[${PYTHON_USEDEP}]
"
