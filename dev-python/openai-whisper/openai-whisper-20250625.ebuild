# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1

MY_PN="whisper"
DESCRIPTION="Robust speech recognition via large-scale weak supervision"
HOMEPAGE="
	https://github.com/openai/whisper
	https://pypi.org/project/openai-whisper/
"
SRC_URI="https://github.com/openai/${MY_PN}/archive/refs/tags/v${PV}.tar.gz
	-> ${P}.gh.tar.gz"
S="${WORKDIR}/${MY_PN}-${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# Leave upstream's optional x86_64 Triton fast path undeclared: gfx1150 showed
# no useful gain, and virtual/triton remains unvalidated here on CUDA. The
# pure-PyTorch fallback is functional.

# Block Graphite's unrelated dev-python/whisper; both install `whisper`.
RDEPEND="
	!dev-python/whisper
	${PYTHON_DEPS}
	sci-ml/pytorch[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		dev-python/more-itertools[${PYTHON_USEDEP}]
		dev-python/numba[${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
		dev-python/tiktoken[${PYTHON_USEDEP}]
		dev-python/tqdm[${PYTHON_USEDEP}]
	')
"
DEPEND="${RDEPEND}"
BDEPEND="${PYTHON_DEPS}"

# Tests download model checkpoints and require substantial GPU memory.
RESTRICT="test"

pkg_postinst() {
	elog "openai-whisper has been installed without sci-ml/triton — the"
	elog "Triton-fused attention decoder fastpath is unavailable on this"
	elog "system. Decoding falls back to the pure-PyTorch path: functional"
	elog "but slower for long-form transcription."
	elog ""
	elog "Models download from huggingface.co into ~/.cache/whisper/ on"
	elog "first use. Recommended starting points:"
	elog "  whisper.load_model('base.en')   # 74M params, English only"
	elog "  whisper.load_model('small.en')  # 244M params, English only"
	elog "  whisper.load_model('medium')    # 769M params, multilingual"
}
