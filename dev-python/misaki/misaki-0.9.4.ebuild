# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_SINGLE_IMPL=1
# Upstream caps requires-python<3.13 — verify if newer Python works
# before relaxing. py3_12 is the only solving target on our overlay.
PYTHON_COMPAT=( python3_12 )

inherit distutils-r1 pypi

DESCRIPTION="G2P (grapheme-to-phoneme) engine for Kokoro models"
HOMEPAGE="
	https://github.com/hexgrad/misaki
	https://pypi.org/project/misaki/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

# Hard-pulls the [en] extra deps because dev-python/kokoro requires
# misaki[en]. Other-language extras (ja, ko, vi, zh, he) are not
# pulled — they bring fugashi / pyopenjtalk / jieba etc. which we
# don't have.
RDEPEND="
	${PYTHON_DEPS}
	dev-python/addict[${PYTHON_SINGLE_USEDEP}]
	dev-python/regex[${PYTHON_SINGLE_USEDEP}]
	dev-python/num2words[${PYTHON_SINGLE_USEDEP}]
	dev-python/phonemizer-fork[${PYTHON_SINGLE_USEDEP}]
	dev-python/spacy[${PYTHON_SINGLE_USEDEP}]
	dev-python/spacy-curated-transformers[${PYTHON_SINGLE_USEDEP}]
"
DEPEND="${RDEPEND}"
BDEPEND="${PYTHON_DEPS}"

pkg_postinst() {
	elog "misaki[en] requires the espeakng-loader package which isn't"
	elog "in this overlay yet (defers Gentoo-specific packaging — the"
	elog "PyPI wheel ships a bundled libespeak-ng.so binary)."
	elog ""
	elog "Until espeakng-loader lands, misaki's English G2P pipeline"
	elog "may fall back to phonemizer-fork's direct espeak-ng path —"
	elog "ensure app-accessibility/espeak-ng is installed."
}
