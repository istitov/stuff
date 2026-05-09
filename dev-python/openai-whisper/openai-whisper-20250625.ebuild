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
KEYWORDS="~amd64"

# Upstream's optional `triton>=2` dep (gated to x86_64 Linux) enables a
# fused-attention decoder fastpath. The fastpath is primarily a CUDA
# acceleration story — on a Strix Point host (gfx1150 / iGPU + NPU)
# the value is small to nonexistent: triton's ROCm backend doesn't
# bless gfx1150, and CPU-only triton is functional but doesn't beat
# the pure-PyTorch fallback meaningfully. Wire up when (a) sci-ml/triton
# lands in this overlay AND (b) a real workload measures a win on a
# CUDA-equipped host. Until then the comment is the design record.
#
# IUSE="+triton"
# RDEPEND+=" triton? ( sci-ml/triton[${PYTHON_SINGLE_USEDEP}] )"

# OpenAI's openai-whisper and Graphite's dev-python/whisper both install
# a top-level Python module named `whisper`. Only one can win at
# `import whisper`. Blocker is unavoidable; the projects are unrelated
# (Graphite's is a round-robin time-series database).
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

# Tests need network (downloads model checkpoints from huggingface.co)
# and large GPU memory; no unit-only subset upstream.
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
