# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
# Release metadata caps Python below 3.13; relaxed below.
PYTHON_COMPAT=( python3_{12..13} )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1 pypi

DESCRIPTION="G2P (grapheme-to-phoneme) engine for Kokoro models"
HOMEPAGE="
	https://github.com/hexgrad/misaki
	https://pypi.org/project/misaki/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# Include the English extra required by kokoro; other language stacks are
# unpackaged. en_core_web_sm enables the preferred G2P path.
RDEPEND="
	${PYTHON_DEPS}
	dev-python/spacy-curated-transformers[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		dev-python/addict[${PYTHON_USEDEP}]
		dev-python/en_core_web_sm[${PYTHON_USEDEP}]
		dev-python/espeakng-loader[${PYTHON_USEDEP}]
		dev-python/num2words[${PYTHON_USEDEP}]
		dev-python/phonemizer-fork[${PYTHON_USEDEP}]
		dev-python/regex[${PYTHON_USEDEP}]
		dev-python/spacy[${PYTHON_USEDEP}]
	')
"
DEPEND="${RDEPEND}"
BDEPEND="${PYTHON_DEPS}"

src_prepare() {
	# Backport upstream's metadata-only Python 3.13 enablement.
	# verified 2026-05-09
	sed -i 's|>=3.8, <3.13|>=3.8, <3.14|' pyproject.toml || die
	distutils-r1_src_prepare
}
