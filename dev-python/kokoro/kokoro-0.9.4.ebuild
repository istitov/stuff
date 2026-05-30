# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
# Upstream PyPI requires-python = "<3.13,>=3.10" (verified 2026-05-30).
PYTHON_COMPAT=( python3_{12..13} )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1 pypi

DESCRIPTION="Kokoro lightweight TTS — Python interface to the Kokoro family of voices"
HOMEPAGE="
	https://github.com/hexgrad/kokoro
	https://pypi.org/project/kokoro/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

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
	# Cap-relax (per feedback_cap_relax_recipe.md). Upstream commit
	# dfb907a0 (2025-08-06, "Enable Python 3.13 (#244)") relaxes the
	# requires-python cap from <3.13 to <3.14 — a one-line pyproject
	# change with no code edits, confirming py3.13 works as-is. The
	# 0.9.4 PyPI release predates that commit; the sed below applies
	# the same change verified 2026-05-09.
	sed -i 's|>=3.10, <3.13|>=3.10, <3.14|' pyproject.toml || die
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
