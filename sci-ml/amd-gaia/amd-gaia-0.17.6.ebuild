# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

DESCRIPTION="Lightweight agent framework for the edge and AMD Ryzen AI PCs"
HOMEPAGE="https://github.com/amd/gaia"
SRC_URI="https://github.com/amd/gaia/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz"
S="${WORKDIR}/gaia-${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+api audio +mcp eval"

# Upstream pytest config marks tests as needing a live Lemonade server,
# Docker, the Gmail API, and other integration targets that aren't
# reachable from a sandboxed build. RESTRICT until someone wants to
# split out a unit-only subset.
RESTRICT="test"

# Core install_requires per setup.py (verified against v0.17.6 sdist).
# Lemonade Server is the recommended OpenAI-compatible LLM backend but
# isn't a hard dep — gaia speaks any OpenAI-compatible endpoint, so the
# RDEPEND only mentions the bundled Python deps. See pkg_postinst.
#
# audio? — gaia code only `import torch`s (gaia/audio/whisper_asr.py:19);
# never imports torchvision OR torchaudio. Upstream's `audio` extra caps
# torch<2.4 because of old-era openai-whisper transitive deps; verified
# 2026-05-09 the cap is stale (current openai-whisper has unbounded torch
# and no torchvision dep), so we ship without the cap and without the
# unused torchvision/torchaudio. RDEPEND on sci-ml/pytorch alone.
RDEPEND="
	${PYTHON_DEPS}
	dev-python/aiohttp[${PYTHON_USEDEP}]
	dev-python/openai[${PYTHON_USEDEP}]
	dev-python/pillow[${PYTHON_USEDEP}]
	>=dev-python/pydantic-2.9.2[${PYTHON_USEDEP}]
	dev-python/python-dotenv[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	dev-python/rich[${PYTHON_USEDEP}]
	>=dev-python/watchdog-2.1.0[${PYTHON_USEDEP}]
	sci-ml/accelerate[${PYTHON_USEDEP}]
	sci-ml/transformers[${PYTHON_USEDEP}]
	api? (
		>=dev-python/fastapi-0.115.0[${PYTHON_USEDEP}]
		>=dev-python/python-multipart-0.0.9[${PYTHON_USEDEP}]
		>=dev-python/uvicorn-0.32.0[${PYTHON_USEDEP}]
	)
	audio? (
		sci-ml/pytorch[${PYTHON_USEDEP}]
	)
	mcp? (
		>=dev-python/mcp-1.1.0[${PYTHON_USEDEP}]
		dev-python/starlette[${PYTHON_USEDEP}]
		dev-python/uvicorn[${PYTHON_USEDEP}]
	)
	eval? (
		dev-python/anthropic[${PYTHON_USEDEP}]
		dev-python/beautifulsoup4[${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
		dev-python/pypdf[${PYTHON_USEDEP}]
		dev-python/reportlab[${PYTHON_USEDEP}]
		>=dev-python/scikit-learn-1.5.0[${PYTHON_USEDEP}]
	)
"

DEPEND="${RDEPEND}"
BDEPEND="${PYTHON_DEPS}"

pkg_postinst() {
	elog "GAIA is an LLM-agent framework. It speaks any OpenAI-compatible"
	elog "endpoint; the AMD-recommended local backend is Lemonade Server"
	elog "(sci-ml/lemonade in this overlay), which runs models on Ryzen AI"
	elog "hardware (NPU + iGPU). Point gaia at a server with:"
	elog ""
	elog "  export OPENAI_BASE_URL=http://localhost:8000/api/v1"
	elog ""
	elog "Extras still not built (deps not all in tree):"
	elog "  ui     — needs PyMuPDF (4nykey overlay or fork chain)"
	elog "  talk   — sounddevice + openai-whisper landed; kokoro chain"
	elog "           (kokoro + misaki + spacy + ...) deferred"
	elog "  image  — term-image (paused on pillow cap mismatch)"
	elog "  blender — bpy (Blender Python module — heavy)"
	elog ""
	elog "USE=audio is supported (pulls sci-ml/pytorch only; gaia code"
	elog "doesn't touch torchvision/torchaudio despite upstream's extra)."
	elog "Use the upstream pip install if you need an extra flavour."
}
