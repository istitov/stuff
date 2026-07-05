# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1

DESCRIPTION="Lightweight agent framework for the edge and AMD Ryzen AI PCs"
HOMEPAGE="https://github.com/amd/gaia"
SRC_URI="https://github.com/amd/gaia/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz"
S="${WORKDIR}/gaia-${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+api audio +mcp eval image talk ui"

# ui implies api: upstream's ui extra restates fastapi/uvicorn/python-
# multipart on top of its own RAG deps.
REQUIRED_USE="ui? ( api )"

# Upstream pytest config marks tests as needing a live Lemonade server,
# Docker, the Gmail API, and other integration targets that aren't
# reachable from a sandboxed build. RESTRICT until someone wants to
# split out a unit-only subset.
RESTRICT="test"

# Core install_requires per setup.py (verified against v0.21.0 sdist).
# Lemonade Server is the AMD-recommended backend but not a hard dep — gaia
# speaks any OpenAI-compatible endpoint (see pkg_postinst).
#
# python-multipart — base install_requires since v0.20.1: base `gaia-mcp`
# console_script imports python_multipart at import time, so needed even
# without USE=api. Dropped from api? as redundant. verified 2026-06-13.
#
# keyring — v0.21.0 promotes it from ui/api extras to base install_requires
# (upstream #1621): gaia.connectors.{store,mcp_server} import keyring at
# module load, and `gaia connectors` is a base CLI command. >=24,<26 is
# upstream's supply-chain pin. Dropped from ui? as redundant. verified
# 2026-06-13.
#
# audio? — gaia only `import torch`s (gaia/audio/whisper_asr.py:19), never
# torchvision/torchaudio (re-grepped src/ 2026-06-13). Upstream's audio
# extra caps torch<2.13 for old-era openai-whisper deps; cap is stale
# (verified 2026-06-04: current openai-whisper unbounded torch, no
# torchvision), so we ship uncapped on sci-ml/pytorch alone.
#
# ui? — upstream 0.20.0 added python-pptx>=0.6.21 (PPTX RAG ingestion,
# lazy `from pptx import`); not packaged in ::gentoo or this overlay, so
# omitted — only surfaces if a user ingests a .pptx. verified 2026-06-13.
#
# talk? — v0.21.0 adds `pip` to the talk extra: Kokoro/misaki TTS downloads
# its spaCy model at runtime via pip. verified 2026-06-13.
#
# httpx (ui?) — hard upstream req: ui extra declares httpx>=0.27.0 and 9
# src/gaia modules import it. ::gentoo-deprecated 2026-04-01 (no drop-in
# replacement), so the DeprecatedDep warning is knowingly accepted.
# verified 2026-06-20.
RDEPEND="
	${PYTHON_DEPS}
	sci-ml/accelerate[${PYTHON_SINGLE_USEDEP}]
	sci-ml/transformers[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		dev-python/aiohttp[${PYTHON_USEDEP}]
		dev-python/beautifulsoup4[${PYTHON_USEDEP}]
		>=dev-python/keyring-24.0.0[${PYTHON_USEDEP}]
		<dev-python/keyring-26[${PYTHON_USEDEP}]
		dev-python/openai[${PYTHON_USEDEP}]
		>=dev-python/pillow-9.0.0[${PYTHON_USEDEP}]
		>=dev-python/pydantic-2.9.2[${PYTHON_USEDEP}]
		dev-python/python-dotenv[${PYTHON_USEDEP}]
		>=dev-python/python-multipart-0.0.9[${PYTHON_USEDEP}]
		dev-python/requests[${PYTHON_USEDEP}]
		dev-python/rich[${PYTHON_USEDEP}]
		>=dev-python/watchdog-2.1.0[${PYTHON_USEDEP}]
		api? (
			>=dev-python/fastapi-0.115.0[${PYTHON_USEDEP}]
			>=dev-python/uvicorn-0.32.0[${PYTHON_USEDEP}]
		)
		image? (
			dev-python/term-image[${PYTHON_USEDEP}]
		)
		talk? (
			dev-python/pip[${PYTHON_USEDEP}]
			dev-python/sounddevice[${PYTHON_USEDEP}]
			dev-python/soundfile[${PYTHON_USEDEP}]
			dev-python/psutil[${PYTHON_USEDEP}]
		)
		ui? (
			>=dev-python/httpx-0.27.0[${PYTHON_USEDEP}]
			>=dev-python/psutil-5.9.0[${PYTHON_USEDEP}]
			dev-python/PyMuPDF[${PYTHON_USEDEP}]
			dev-python/pypdf[${PYTHON_USEDEP}]
			sci-ml/safetensors[${PYTHON_USEDEP}]
		)
		mcp? (
			>=dev-python/mcp-1.1.0[${PYTHON_USEDEP}]
			dev-python/starlette[${PYTHON_USEDEP}]
			dev-python/uvicorn[${PYTHON_USEDEP}]
		)
		eval? (
			dev-python/anthropic[${PYTHON_USEDEP}]
			dev-python/numpy[${PYTHON_USEDEP}]
			dev-python/pypdf[${PYTHON_USEDEP}]
			dev-python/reportlab[${PYTHON_USEDEP}]
			>=dev-python/scikit-learn-1.5.0[${PYTHON_USEDEP}]
		)
	')
	audio? (
		sci-ml/pytorch[${PYTHON_SINGLE_USEDEP}]
	)
	talk? (
		dev-python/kokoro[${PYTHON_SINGLE_USEDEP}]
		dev-python/openai-whisper[${PYTHON_SINGLE_USEDEP}]
	)
	ui? (
		sci-libs/faiss[python]
		sci-ml/sentence-transformers[${PYTHON_SINGLE_USEDEP}]
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
	elog "Extras supported via USE flags:"
	elog "  audio  — sci-ml/pytorch (gaia code doesn't touch torchvision/"
	elog "           torchaudio despite upstream's audio extra listing them)"
	elog "  image  — dev-python/term-image"
	elog "  talk   — dev-python/openai-whisper + dev-python/sounddevice +"
	elog "           dev-python/kokoro (full upstream parity)."
	elog "  ui     — full RAG-over-PDFs web frontend (faiss + sentence-"
	elog "           transformers + PyMuPDF + pypdf + safetensors);"
	elog "           implies +api"
	elog ""
	elog "Extras still not built (deps not all in tree):"
	elog "  blender — bpy (Blender Python module — heavy)"
	elog ""
	elog "Use the upstream pip install if you need an extra flavour we"
	elog "haven't packaged yet."
}
