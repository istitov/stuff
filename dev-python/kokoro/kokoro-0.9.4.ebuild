# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_SINGLE_IMPL=1
# Upstream caps requires-python<3.13. py3_12 is the only solving
# target on our overlay.
PYTHON_COMPAT=( python3_12 )

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
	dev-python/loguru[${PYTHON_SINGLE_USEDEP}]
	>=dev-python/misaki-0.9.4[${PYTHON_SINGLE_USEDEP}]
	dev-python/numpy[${PYTHON_SINGLE_USEDEP}]
	sci-ml/pytorch[${PYTHON_SINGLE_USEDEP}]
	sci-ml/transformers[${PYTHON_SINGLE_USEDEP}]
"
DEPEND="${RDEPEND}"
BDEPEND="${PYTHON_DEPS}"

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
