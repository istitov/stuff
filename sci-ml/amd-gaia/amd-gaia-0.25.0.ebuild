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
IUSE="+api +mcp eval image talk ui"

# Upstream's UI extra includes the API dependencies.
REQUIRED_USE="ui? ( api )"

# Tests require live Lemonade, Docker, Gmail, and other integration services;
# restrict until a unit-only subset is available.
RESTRICT="test"

# Dependency map checked against v0.25.0 on 2026-10-19.
# 0.25 dropped transformers/accelerate from core and torch,
# sentence-transformers, Whisper and Kokoro from the extras: speech and the
# UI's models run inside Lemonade Server now, and no gaia module imports them.
# Skill installation needs cryptography for Ed25519 verification.
# Omit unpackaged lazy eval-only cvss and Windows-only pywin32.
# Lemonade is the default backend, not a requirement: gaia also has OpenAI
# and Claude providers.
# Connectors need keyring >=24,<26.
# Tavily is a declared core dependency, though imports retain DuckDuckGo fallback.
# apscheduler <4 and tomli-w implement scheduling; tzlocal names the local
# zone for schedules; Python >=3.12 supplies tomllib.
# httpx is core and capped <1.0 upstream; accept its deprecation because no
# replacement exists.
# python-multipart backs the UI's FastAPI upload routes (api and ui extras).
# Talk lists websockets, but no gaia module imports it; omit it.
# Eval has a char-count fallback for tiktoken; omit its <1 and numpy's <2.3 caps.
# verified 2026-10-19
RDEPEND="
	${PYTHON_DEPS}
	$(python_gen_cond_dep '
		dev-python/aiohttp[${PYTHON_USEDEP}]
		>=dev-python/apscheduler-3.10.0[${PYTHON_USEDEP}]
		<dev-python/apscheduler-4.0[${PYTHON_USEDEP}]
		dev-python/beautifulsoup4[${PYTHON_USEDEP}]
		>=dev-python/cryptography-42.0.0[${PYTHON_USEDEP}]
		>=dev-python/httpx-0.27.0[${PYTHON_USEDEP}]
		<dev-python/httpx-1.0[${PYTHON_USEDEP}]
		>=dev-python/keyring-24.0.0[${PYTHON_USEDEP}]
		<dev-python/keyring-26[${PYTHON_USEDEP}]
		>=dev-python/numpy-1.24.0[${PYTHON_USEDEP}]
		>=dev-python/openai-1.58.0[${PYTHON_USEDEP}]
		>=dev-python/pillow-9.0.0[${PYTHON_USEDEP}]
		>=dev-python/psutil-5.9.0[${PYTHON_USEDEP}]
		>=dev-python/pydantic-2.9.2[${PYTHON_USEDEP}]
		>=dev-python/python-dateutil-2.8.2[${PYTHON_USEDEP}]
		dev-python/python-dotenv[${PYTHON_USEDEP}]
		>=dev-python/pyyaml-6.0.1[${PYTHON_USEDEP}]
		>=dev-python/requests-2.32.3[${PYTHON_USEDEP}]
		dev-python/rich[${PYTHON_USEDEP}]
		>=dev-python/tavily-python-0.5.0[${PYTHON_USEDEP}]
		>=dev-python/tomli-w-1.0.0[${PYTHON_USEDEP}]
		>=dev-python/truststore-0.10.0[${PYTHON_USEDEP}]
		>=dev-python/tzlocal-4.0[${PYTHON_USEDEP}]
		>=dev-python/watchdog-2.1.0[${PYTHON_USEDEP}]
		api? (
			>=dev-python/fastapi-0.115.0[${PYTHON_USEDEP}]
			>=dev-python/python-multipart-0.0.9[${PYTHON_USEDEP}]
			>=dev-python/uvicorn-0.32.0[${PYTHON_USEDEP}]
		)
		image? (
			>=dev-python/term-image-0.7.0[${PYTHON_USEDEP}]
			<dev-python/term-image-0.8[${PYTHON_USEDEP}]
		)
		talk? (
			dev-python/sounddevice[${PYTHON_USEDEP}]
		)
		ui? (
			>=dev-python/openpyxl-3.1.0[${PYTHON_USEDEP}]
			>=dev-python/pymupdf-1.24.0[${PYTHON_USEDEP}]
			dev-python/pypdf[${PYTHON_USEDEP}]
			>=dev-python/python-docx-1.1.0[${PYTHON_USEDEP}]
			>=dev-python/python-pptx-0.6.21[${PYTHON_USEDEP}]
			>=dev-python/reportlab-4.0.0[${PYTHON_USEDEP}]
		)
		mcp? (
			>=dev-python/mcp-2.0.0[${PYTHON_USEDEP}]
			<dev-python/mcp-3.0[${PYTHON_USEDEP}]
			dev-python/starlette[${PYTHON_USEDEP}]
			dev-python/uvicorn[${PYTHON_USEDEP}]
		)
		eval? (
			dev-python/anthropic[${PYTHON_USEDEP}]
			dev-python/pyarrow[${PYTHON_USEDEP}]
			dev-python/pypdf[${PYTHON_USEDEP}]
			dev-python/reportlab[${PYTHON_USEDEP}]
			>=dev-python/tiktoken-0.7.0[${PYTHON_USEDEP}]
		)
	')
	ui? (
		sci-libs/faiss[python,${PYTHON_SINGLE_USEDEP}]
	)
"

DEPEND="${RDEPEND}"
BDEPEND="${PYTHON_DEPS}"

pkg_postinst() {
	elog "GAIA is an LLM-agent framework. Its default backend is Lemonade"
	elog "Server (sci-ml/lemonade in this overlay), which runs models on Ryzen"
	elog "AI hardware (NPU + iGPU). gaia expects it at lemond's default address,"
	elog "http://localhost:13305/api/v1; point it at another server with:"
	elog ""
	elog "  export LEMONADE_BASE_URL=http://HOST:PORT/api/v1"
	elog ""
	elog "Since 0.25, speech recognition (Whisper), voice output (Kokoro) and"
	elog "the UI's models all run inside Lemonade Server, so no USE flag pulls"
	elog "a local model runtime any more."
	elog ""
	elog "Extras supported via USE flags:"
	elog "  image  — dev-python/term-image"
	elog "  talk   — dev-python/sounddevice (microphone and speaker I/O)"
	elog "  ui     — RAG web frontend over PDF/DOCX/PPTX/XLSX (faiss +"
	elog "           PyMuPDF + pypdf + python-docx + python-pptx + openpyxl +"
	elog "           reportlab); implies +api"
	elog ""
	elog "Extras not built (deps not in tree):"
	elog "  browser  — playwright (live-browser automation)"
	elog "  slack    — slack-sdk (Slack messaging)"
	elog "  youtube  — llama-index-readers-youtube-transcript"
	elog ""
	elog "Extras without a USE flag; install their deps by hand to use them:"
	elog "  diarize  — sci-ml/sherpa-onnx (speaker diarization)"
	elog "  telegram — dev-python/python-telegram-bot"
	elog ""
	elog "Use the upstream pip install if you need an extra flavour we"
	elog "haven't packaged yet."
}
