# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

DESCRIPTION="Fine-tune and run large language models efficiently"
HOMEPAGE="
	https://github.com/unslothai/unsloth
	https://pypi.org/project/unsloth/
"
# PyPI withdrew recent sdists; use the monorepo desktop tag whose _version.py
# matches ${PV}. Its library tree matches the 2026.8.22 sdist byte-for-byte.
# GitHub archives are mutable, so review any Manifest rehash.
# verified 2026-09-09
MY_TAG="v0.1.804-beta"
SRC_URI="https://github.com/unslothai/unsloth/archive/refs/tags/${MY_TAG}.tar.gz -> unsloth-monorepo-${MY_TAG#v}.gh.tar.gz"
S="${WORKDIR}/${PN}-${MY_TAG#v}"

# The wheel always includes the Apache-2.0 core and AGPL-3 CLI/backend.
# USE=studio also installs the OFL-1.1 web fonts; proprietary Hellix is stripped.
LICENSE="Apache-2.0 AGPL-3 studio? ( OFL-1.1 )"
SLOT="0"
KEYWORDS="~amd64"
# Studio runs its FastAPI backend in the system interpreter instead of a
# downloaded venv and builds the bundled React UI with npm.
IUSE="studio"

# Tests need model downloads and accelerator hardware; Studio's npm build needs
# registry access.
RESTRICT="test studio? ( network-sandbox )"
PROPERTIES="studio? ( live )"

# Studio pins older dependencies. Overlay pymupdf4llm/PyMuPDF 1.28.2 preserves
# its to_markdown API but adds pymupdf-layout/onnxruntime; accept that in-tree dep.
# ddgs 9.15 retains the used DDGS and exception APIs. verified 2026-08-24
# Studio requires deprecated httpx; no drop-in replacement exists.

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
		>=dev-python/setuptools-scm-9.2.0[${PYTHON_USEDEP}]
	')
	studio? ( net-libs/nodejs[npm] )
"

src_prepare() {
	# Add the system-interpreter path selected by UNSLOTH_STUDIO_SYSTEM.
	use studio && PATCHES+=( "${FILESDIR}/${PN}-system-studio.patch" )
	distutils-r1_src_prepare
}

src_compile() {
	if use studio; then
		# Build the unbundled React UI served by the backend.
		einfo "Building the Unsloth Studio web frontend (npm ci + vite build)"
		pushd studio/frontend > /dev/null || die
		npm ci --no-audit --no-fund || die "npm ci failed"
		npm run build || die "vite build failed"
		# Remove proprietary Hellix; retain OFL-1.1 fonts.
		find dist -iname '*hellix*' -exec rm -rf {} + || die
		popd > /dev/null || die
	fi
	distutils-r1_src_compile
}

python_install() {
	distutils-r1_python_install

	if use studio; then
		# Package data also captures frontend sources/tests; runtime needs only dist.
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
		# System-interpreter launcher for the installed Studio UI/API.
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
