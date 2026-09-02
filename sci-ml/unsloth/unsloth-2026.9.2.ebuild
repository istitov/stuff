# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Fine-tune and run large language models efficiently"
HOMEPAGE="
	https://github.com/unslothai/unsloth
	https://pypi.org/project/unsloth/
"

# Apache-2.0: the core library. USE=studio also builds/installs the studio
# frontend (AGPL-3, studio/LICENSE.AGPL-3.0) and its bundled Figtree/Inter/
# Space-Grotesk web fonts (OFL-1.1); the proprietary Hellix font is stripped.
LICENSE="Apache-2.0 studio? ( AGPL-3 OFL-1.1 )"
SLOT="0"
KEYWORDS="~amd64"
# USE=studio enables the bundled Unsloth Studio web backend (studio/backend, a
# FastAPI server driven by the `unsloth studio` CLI command) to run against the
# system interpreter, instead of the desktop app's self-downloaded venv. It pulls
# the server's runtime deps and applies a patch adding a UNSLOTH_STUDIO_SYSTEM
# in-process launch path, and builds the React web UI (studio/frontend) with npm
# so the backend serves the full app (not just the API).
IUSE="studio"

# Tests require model downloads and supported accelerator hardware. USE=studio's
# frontend build (npm) fetches its dependency set from the registry, which the
# network sandbox forbids, so it is live + network like the overlay's other
# web-UI-bundling ebuilds (sci-misc/llama-swap[ui]).
RESTRICT="test studio? ( network-sandbox )"
PROPERTIES="studio? ( live )"

# USE=studio dep-version notes -- the studio server deps below are intentionally
# newer than the studio backend's own requirements pins, verified API-compatible
# 2026-08-24 (comments here, not in RDEPEND: a `#` inside a quoted dep silently
# masks it):
#  - pymupdf4llm: upstream pins ==0.3.4 (+ pymupdf 1.27.2.3); we ship the
#    PyMuPDF-matched 1.28.2 pair. The backend calls only pymupdf4llm.to_markdown()
#    (core/rag/parsers.py, routes/data_recipe/seed.py), stable across the
#    0.3->1.28 versioning realignment. 1.28.2 hard-deps pymupdf-layout
#    (onnxruntime), which 0.3.x kept optional -- accepted, onnxruntime is in-tree.
#  - ddgs: upstream pins ==9.14.4; we ship 9.15.0 (patch). The backend uses only
#    DDGS() + the DDGSException/RatelimitException classes, both present in 9.15.0.

RDEPEND="
	>=dev-python/unsloth-zoo-2026.8.16[${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/accelerate-0.34.1[${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/bitsandbytes-0.45.5[${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/datasets-3.4.1[${PYTHON_SINGLE_USEDEP}]
	<sci-ml/datasets-4.4[${PYTHON_SINGLE_USEDEP}]
	sci-ml/diffusers[${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/huggingface_hub-0.34[${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/peft-0.18[${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/pytorch-2.4[${PYTHON_SINGLE_USEDEP}]
	<sci-ml/pytorch-2.12[${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/transformers-4.51.3[${PYTHON_SINGLE_USEDEP}]
	<=sci-ml/transformers-5.5.0-r0[${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/trl-0.18.2[${PYTHON_SINGLE_USEDEP}]
	<=sci-ml/trl-0.24.0-r0[${PYTHON_SINGLE_USEDEP}]
	sci-ml/torchvision[${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/xformers-0.0.27_p2[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		dev-python/click[${PYTHON_USEDEP}]
		dev-python/hf-transfer[${PYTHON_USEDEP}]
		dev-python/nest-asyncio[${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
		dev-python/packaging[${PYTHON_USEDEP}]
		dev-python/protobuf[${PYTHON_USEDEP}]
		dev-python/psutil[${PYTHON_USEDEP}]
		dev-python/pydantic[${PYTHON_USEDEP}]
		dev-python/pyyaml[${PYTHON_USEDEP}]
		dev-python/rich[${PYTHON_USEDEP}]
		>=dev-python/structlog-24.1[${PYTHON_USEDEP}]
		dev-python/tqdm[${PYTHON_USEDEP}]
		>=virtual/triton-3[${PYTHON_USEDEP}]
		>=dev-python/typer-0.12[${PYTHON_USEDEP}]
		dev-python/tyro[${PYTHON_USEDEP}]
		>=dev-python/wheel-0.42[${PYTHON_USEDEP}]
		>=sci-ml/sentencepiece-0.2[${PYTHON_USEDEP}]
	')
	studio? (
		$(python_gen_cond_dep '
			dev-python/fastapi[${PYTHON_USEDEP}]
			dev-python/uvicorn[${PYTHON_USEDEP}]
			dev-python/matplotlib[${PYTHON_USEDEP}]
			dev-python/pandas[${PYTHON_USEDEP}]
			dev-python/pyjwt[${PYTHON_USEDEP}]
			dev-python/urllib3[${PYTHON_USEDEP}]
			dev-python/cryptography[${PYTHON_USEDEP}]
			dev-python/boto3[${PYTHON_USEDEP}]
			dev-python/httpx[${PYTHON_USEDEP}]
			dev-python/av[${PYTHON_USEDEP}]
			dev-python/gguf[${PYTHON_USEDEP}]
			dev-python/python-docx[${PYTHON_USEDEP}]
			dev-python/diceware[${PYTHON_USEDEP}]
			dev-python/ddgs[${PYTHON_USEDEP}]
			dev-python/fastmcp[${PYTHON_USEDEP}]
			dev-python/pymupdf4llm[${PYTHON_USEDEP}]
			dev-python/PyMuPDF[${PYTHON_USEDEP}]
			dev-python/sqlite-vec-bin[${PYTHON_USEDEP}]
		')
	)
"
BDEPEND="
	$(python_gen_cond_dep '
		dev-python/setuptools-scm[${PYTHON_USEDEP}]
	')
	studio? ( net-libs/nodejs[npm] )
"

src_prepare() {
	# System-mode launch path for the bundled studio backend (skip the
	# ~/.unsloth/studio venv re-exec + install.sh); inert without USE=studio and
	# without UNSLOTH_STUDIO_SYSTEM=1 at runtime.
	use studio && PATCHES+=( "${FILESDIR}/${PN}-system-studio.patch" )
	distutils-r1_src_prepare
}

src_compile() {
	if use studio; then
		# Build the React web UI (studio/frontend) that the backend serves. The
		# sdist ships no prebuilt dist; vite writes it to studio/frontend/dist.
		einfo "Building the Unsloth Studio web frontend (npm ci + vite build)"
		pushd studio/frontend > /dev/null || die
		npm ci --no-audit --no-fund || die "npm ci failed"
		npm run build || die "vite build failed"
		# Strip the proprietary Hellix font (copied public/ -> dist/); the OFL-1.1
		# @fontsource fonts (Figtree/Inter/Space-Grotesk) stay.
		find dist -iname '*hellix*' -exec rm -rf {} + || die
		popd > /dev/null || die
	fi
	distutils-r1_src_compile
}

python_install() {
	distutils-r1_python_install

	if use studio; then
		# setuptools' package-data glob (studio/frontend/dist/**) already bundles
		# the vite-built UI into the wheel, but it also drags in the whole
		# studio/frontend source tree (TS sources, tests, configs). Only the built
		# dist/ is served at runtime, so drop the rest to trim the install.
		local fe="${D}$(python_get_sitedir)/studio/frontend"
		if [[ -d ${fe} ]]; then
			find "${fe}" -mindepth 1 -maxdepth 1 ! -name dist \
				-exec rm -rf {} + || die
		fi
	fi
}

python_install_all() {
	distutils-r1_python_install_all

	if use studio; then
		# Launcher that serves the studio UI/API in-process against the system
		# interpreter (the base package already installs the `unsloth` CLI + the
		# studio/backend package). See the system-studio patch.
		newbin - unsloth-studio <<-'EOF'
			#!/bin/sh
			export UNSLOTH_STUDIO_SYSTEM=1
			exec unsloth studio "$@"
		EOF
	fi
}

pkg_postinst() {
	if use studio; then
		elog "USE=studio: run the Unsloth Studio web app on the system stack with:"
		elog "  unsloth-studio            # serves the full web UI on http://127.0.0.1:PORT"
		elog "  unsloth-studio --api-only # API only (no web UI)"
		elog "It runs in-process against the system interpreter -- no ~/.unsloth/studio"
		elog "venv and no runtime download."
	fi
}
