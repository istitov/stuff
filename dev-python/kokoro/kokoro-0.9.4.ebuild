# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
# src_prepare lifts the release metadata's Python cap.
PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1 pypi

DESCRIPTION="Kokoro lightweight TTS — Python interface to the Kokoro family of voices"
HOMEPAGE="
	https://github.com/hexgrad/kokoro
	https://pypi.org/project/kokoro/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	${PYTHON_DEPS}
	sci-ml/huggingface_hub[${PYTHON_SINGLE_USEDEP}]
	sci-ml/pytorch[${PYTHON_SINGLE_USEDEP}]
	sci-ml/transformers[${PYTHON_SINGLE_USEDEP}]
	>=dev-python/misaki-0.9.4[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		dev-python/loguru[${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
	')
"
DEPEND="${RDEPEND}"
BDEPEND="${PYTHON_DEPS}"

src_prepare() {
	# Upstream dfb907a0 raised this cap to 3.14 without touching code, but never
	# tagged a release carrying it, and has not moved it since. 3.14 goes one
	# step past that: every module byte-compiles on it and none import stdlib it
	# removed, and the whole dependency chain already builds for it.
	# verified 2026-09-26
	sed -i 's|>=3.10, <3.13|>=3.10, <3.15|' pyproject.toml || die
	distutils-r1_src_prepare
}

pkg_postinst() {
	elog "Kokoro is a small TTS model — pretrained weights download"
	elog "from HuggingFace at first use into ~/.cache/huggingface/hub/."
	elog ""
	elog "First-call example:"
	elog "  from kokoro import KPipeline"
	elog "  pipeline = KPipeline(lang_code='a')  # American English"
	elog "  for graphemes, phonemes, audio in pipeline(text, voice='af_heart'):"
	elog "      ...  # audio is a 24 kHz numpy array"
}
