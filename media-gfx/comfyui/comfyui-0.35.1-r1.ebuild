# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..13} )

inherit python-single-r1

DESCRIPTION="Node-based diffusion / generative-AI workflow GUI and inference engine"
HOMEPAGE="
	https://github.com/comfy-org/comfyui
	https://www.comfy.org/
"
SRC_URI="https://github.com/comfy-org/comfyui/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz"
S="${WORKDIR}/ComfyUI-${PV}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
# comfy_aimdo/kitchen are hard dependencies. CUDA selects their GPU wheels;
# ROCm uses pure-Python fallbacks plus Triton for apply_rope; neither flag is CPU.
# compile also enables Triton. CUDA and ROCm are exclusive.
IUSE="cuda compile +templates extra opengl rocm audio"

REQUIRED_USE="${PYTHON_REQUIRED_USE}
	?? ( cuda rocm )"

# 0.35 imports comfy_aimdo unguarded at nine module-load sites. comfy_kitchen's
# guarded import only degrades FP messages; Flux/Lumina/Z-Image RoPE still needs
# it at sampling. The GGUF freeze entry belongs to a custom node, not core.
# verified 2026-09-09
RDEPEND="${PYTHON_DEPS}
	sci-ml/caffe2[${PYTHON_SINGLE_USEDEP},cuda?,rocm?]
	sci-ml/torchvision[${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/transformers-4.50.3[${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/tokenizers-0.13.3[${PYTHON_SINGLE_USEDEP}]
	dev-python/torchsde[${PYTHON_SINGLE_USEDEP}]
	~dev-python/comfyui-frontend-package-1.51.10[${PYTHON_SINGLE_USEDEP}]
	~dev-python/comfyui-embedded-docs-0.5.11[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		~dev-python/comfy-aimdo-bin-0.5.3[${PYTHON_USEDEP},cuda=]
		~dev-python/comfy-kitchen-bin-0.2.33[${PYTHON_USEDEP},cuda=]
		>=sci-ml/safetensors-0.4.2[${PYTHON_USEDEP}]
		sci-ml/sentencepiece[${PYTHON_USEDEP}]
		>=dev-python/numpy-1.25.0[${PYTHON_USEDEP}]
		dev-python/einops[${PYTHON_USEDEP}]
		>=dev-python/aiohttp-3.11.8[${PYTHON_USEDEP}]
		>=dev-python/yarl-1.18.0[${PYTHON_USEDEP}]
		dev-python/pyyaml[${PYTHON_USEDEP}]
		dev-python/pillow[${PYTHON_USEDEP}]
		dev-python/scipy[${PYTHON_USEDEP}]
		dev-python/tqdm[${PYTHON_USEDEP}]
		dev-python/psutil[${PYTHON_USEDEP}]
		dev-python/alembic[${PYTHON_USEDEP}]
		>=dev-python/sqlalchemy-2.0.0[${PYTHON_USEDEP}]
		dev-python/filelock[${PYTHON_USEDEP}]
		>=dev-python/av-17.0.0[${PYTHON_USEDEP}]
		dev-python/requests[${PYTHON_USEDEP}]
		>=dev-python/simpleeval-1.0.0[${PYTHON_USEDEP}]
		dev-python/blake3[${PYTHON_USEDEP}]
		>=dev-python/pydantic-2.0[${PYTHON_USEDEP}]
		<dev-python/pydantic-3[${PYTHON_USEDEP}]
		>=dev-python/pydantic-settings-2.0[${PYTHON_USEDEP}]
		<dev-python/pydantic-settings-3[${PYTHON_USEDEP}]
	')
	templates? ( ~dev-python/comfyui-workflow-templates-0.11.59[${PYTHON_SINGLE_USEDEP}] )
	extra? (
		dev-python/spandrel[${PYTHON_SINGLE_USEDEP}]
		>=dev-python/kornia-0.7.1[${PYTHON_SINGLE_USEDEP}]
	)
	opengl? (
		dev-python/comfy-angle-bin[${PYTHON_SINGLE_USEDEP}]
		$(python_gen_cond_dep '
			>=dev-python/pyopengl-3.1.8[${PYTHON_USEDEP}]
		')
	)
	compile? (
		$(python_gen_cond_dep '
			virtual/triton[${PYTHON_USEDEP}]
		')
	)
	rocm? (
		$(python_gen_cond_dep '
			virtual/triton[${PYTHON_USEDEP}]
		')
	)
	audio? ( sci-ml/torchaudio[${PYTHON_SINGLE_USEDEP}] )
"
# Triton floats because caffe2/torchvision do not pin torch; pin the full stack
# before Triton. verified 2026-09-09
# Audio is lazy; packaged torchaudio pairs with torch 2.11/2.13, not 2.14.
# rechecked 2026-09-10
# nodes_glsl needs both PyOpenGL and comfy_angle; without the latter it is
# silently skipped. The import target exists, but GL runtime remains unverified.
# verified against 0.34.3 on 2026-09-03
BDEPEND="${PYTHON_DEPS}"

PATCHES=(
	"${FILESDIR}/${P}-optional-torchaudio.patch"
)

src_install() {
	python_setup

	local dest="/opt/${PN}"
	dodir "${dest}"
	cp -r . "${ED}${dest}/" || die
	# Drop test suites and VCS/CI leftovers from the runtime image.
	rm -rf "${ED}${dest}"/{tests,tests-unit,pytest.ini,.github,.gitignore} || die

	python_optimize "${ED}${dest}"

	# Merge system-managed custom nodes with each user's base directory.
	printf 'comfyui_system:\n    base_path: %s/usr/share/%s/\n    custom_nodes: custom_nodes/\n' \
		"${EPREFIX}" "${PN}" > "${ED}${dest}/extra_model_paths.yaml" || die
	keepdir "/usr/share/${PN}/custom_nodes"

	# Redirect writable state to a per-user base, keeping /opt read-only.
	newbin - "${PN}" <<-EOF
		#!/bin/sh
		: "\${COMFYUI_BASE:=\${XDG_DATA_HOME:-\$HOME/.local/share}/${PN}}"
		for d in custom_nodes input output user temp models; do
			mkdir -p "\${COMFYUI_BASE}/\$d" || exit 1
		done
		cd "${EPREFIX}/opt/${PN}" || exit 1
		db="sqlite:///\${COMFYUI_BASE}/user/comfyui.db"
		exec ${EPYTHON} main.py --base-directory "\${COMFYUI_BASE}" --database-url "\$db" "\$@"
	EOF
}

pkg_postinst() {
	elog "Launch ComfyUI with:  comfyui"
	elog "Code is installed read-only under ${EPREFIX}/opt/${PN}."
	elog "Per-user models/custom_nodes/input/output/user live under"
	elog "  \${COMFYUI_BASE:-~/.local/share/${PN}}  (export COMFYUI_BASE to relocate)."
	elog "ComfyUI's own flags pass straight through, e.g.:  comfyui --listen --port 8189"
	elog ""
	elog "Custom nodes: git-clone into \${COMFYUI_BASE:-~/.local/share/${PN}}/custom_nodes"
	elog "(per-user) or ${EPREFIX}/usr/share/${PN}/custom_nodes (system-wide). E.g. for"
	elog "GGUF models (dev-python/gguf is already packaged):"
	elog "  git clone https://github.com/city96/ComfyUI-GGUF \\"
	elog "    ${EPREFIX}/usr/share/${PN}/custom_nodes/ComfyUI-GGUF"
	elog ""
	if use cuda; then
		elog "USE=cuda: the comfy_aimdo VRAM allocator + comfy_kitchen kernels use"
		elog "their CUDA wheels -- an NVIDIA GPU with a CUDA 12.8+ runtime is needed."
	elif use rocm; then
		elog "USE=rocm: built against caffe2[rocm]. comfy_aimdo/comfy_kitchen install"
		elog "their py3-none-any fallbacks; comfy_kitchen.apply_rope (needed by the"
		elog "flux/lumina/z-image families) runs on virtual/triton's AMD Triton"
		elog "backend. comfy_aimdo's VRAM offload is a no-op on ROCm."
	else
		elog "USE=-cuda -rocm: comfy_aimdo/comfy_kitchen install their pure-python"
		elog "fallbacks (no GPU offload, eager kernels) and ComfyUI runs on CPU -- slow."
	fi
	if use compile; then
		elog ""
		elog "USE=compile pulled virtual/triton for torch.compile / inductor"
		elog "custom nodes and comfy_kitchen's Triton backend."
	fi
}
