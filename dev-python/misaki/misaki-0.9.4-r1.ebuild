# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
# Upstream PyPI requires-python = "<3.13,>=3.8" (verified 2026-05-30).
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

# Hard-pulls the [en] extra deps because dev-python/kokoro requires
# misaki[en]. Other-language extras (ja, ko, vi, zh, he) are not
# pulled — they bring fugashi / pyopenjtalk / jieba etc. which we
# don't have. en_core_web_sm is the spaCy model misaki's English G2P
# loads for the higher-quality path; without it misaki falls back to
# espeak-ng (espeakng-loader / phonemizer-fork).
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
	# Cap-relax (per feedback_cap_relax_recipe.md). Upstream commit
	# fba12365 (2025-08-11, "Enable Python 3.13 (#85)") relaxes the
	# requires-python cap from <3.13 to <3.14 — a one-line pyproject
	# change with no code edits, confirming py3.13 works as-is. The
	# 0.9.4 PyPI release predates that commit; the sed below applies
	# the same change verified 2026-05-09.
	sed -i 's|>=3.8, <3.13|>=3.8, <3.14|' pyproject.toml || die
	distutils-r1_src_prepare
}
