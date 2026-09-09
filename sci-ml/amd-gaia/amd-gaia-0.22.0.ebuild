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

# Upstream's UI extra includes the API dependencies.
REQUIRED_USE="ui? ( api )"

# Tests require live Lemonade, Docker, Gmail, and other integration services;
# restrict until a unit-only subset is available.
RESTRICT="test"

# Dependency mapping verified against v0.22.0 on 2026-07-17.
# Lemonade is recommended, not required; any OpenAI-compatible endpoint works.
# python-multipart is core because gaia-mcp imports it at startup.
# keyring is core for connector imports; preserve upstream's >=24,<26 pin.
# Tavily is a declared core dependency, though imports retain DuckDuckGo fallback.
# apscheduler and tomli-w implement scheduling; Python >=3.12 supplies tomllib.
# audio imports only torch. Ignore upstream's stale <2.14 cap and unused
# torchvision/torchaudio declarations. rechecked 2026-07-17
# UI lazily imports python-pptx and python-docx for document ingestion.
# httpx is required by UI; accept its Gentoo deprecation because no replacement
# exists. verified 2026-06-20
# Eval's tiktoken import has a char-count fallback; carry it without upstream's
# <1 cap. Omit numpy's <2.3 cap because Gentoo carries 2.4+.
# Talk needs pip because Kokoro/misaki installs its spaCy model at runtime.
RDEPEND="
	${PYTHON_DEPS}
	sci-ml/accelerate[${PYTHON_SINGLE_USEDEP}]
	sci-ml/transformers[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		dev-python/aiohttp[${PYTHON_USEDEP}]
		>=dev-python/apscheduler-3.10.0[${PYTHON_USEDEP}]
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
		>=dev-python/tavily-python-0.5.0[${PYTHON_USEDEP}]
		>=dev-python/tomli-w-1.0.0[${PYTHON_USEDEP}]
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
			>=dev-python/python-docx-1.1.0[${PYTHON_USEDEP}]
			>=dev-python/python-pptx-0.6.21[${PYTHON_USEDEP}]
			sci-ml/safetensors[${PYTHON_USEDEP}]
		)
		mcp? (
			>=dev-python/mcp-1.1.0[${PYTHON_USEDEP}]
			<dev-python/mcp-2.0[${PYTHON_USEDEP}]
			dev-python/starlette[${PYTHON_USEDEP}]
			dev-python/uvicorn[${PYTHON_USEDEP}]
		)
		eval? (
			dev-python/anthropic[${PYTHON_USEDEP}]
			dev-python/numpy[${PYTHON_USEDEP}]
			dev-python/pypdf[${PYTHON_USEDEP}]
			dev-python/reportlab[${PYTHON_USEDEP}]
			>=dev-python/scikit-learn-1.5.0[${PYTHON_USEDEP}]
			>=dev-python/tiktoken-0.7.0[${PYTHON_USEDEP}]
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
		sci-libs/faiss[python,${PYTHON_SINGLE_USEDEP}]
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
	elog "  ui     — full RAG web frontend over PDF/DOCX/PPTX (faiss +"
	elog "           sentence-transformers + PyMuPDF + pypdf + python-docx +"
	elog "           python-pptx + safetensors); implies +api"
	elog ""
	elog "Extras still not built (deps not all in tree):"
	elog "  blender — bpy (Blender Python module — heavy)"
	elog ""
	elog "Web search uses the Tavily SDK (dev-python/tavily-python, not"
	elog "packaged); without it gaia falls back to DuckDuckGo automatically."
	elog ""
	elog "Use the upstream pip install if you need an extra flavour we"
	elog "haven't packaged yet."
}
