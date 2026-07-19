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
KEYWORDS="~amd64"
# comfy_aimdo / comfy_kitchen are hard imports. USE=cuda picks their CUDA
# wheels via the cuda= propagation below; otherwise the py3-none-any fallbacks
# (eager kernels, no GPU offload). USE=rocm builds the AMD path: caffe2[rocm] +
# those fallbacks + triton-bin, whose Triton backend supplies
# comfy_kitchen.apply_rope on AMD. cuda/rocm are mutually exclusive; neither = CPU.
# USE=compile adds triton-bin for torch.compile + comfy_kitchen's Triton backend.
IUSE="+cuda compile +templates extra opengl rocm audio"

REQUIRED_USE="${PYTHON_REQUIRED_USE}
	?? ( cuda rocm )"

# comfy_aimdo is imported unconditionally at module load (execution.py,
# model_management.py, model_patcher.py, pinned_memory.py); comfy_kitchen
# provides the RoPE/quant kernels comfy.quant_ops.ck.apply_rope uses
# unconditionally for the flux/lumina/z-image families. Both are hard deps:
# comfy_kitchen's import is try/except-wrapped but the wrapper only degrades the
# fp8/fp4 *message* -- the RoPE path assumes ck is present, so those models
# crash at sampling without it. The gguf freeze entry is the ComfyUI-GGUF custom
# node, not core, and is excluded.
RDEPEND="${PYTHON_DEPS}
	sci-ml/caffe2[${PYTHON_SINGLE_USEDEP},cuda?,rocm?]
	sci-ml/torchvision[${PYTHON_SINGLE_USEDEP}]
	sci-ml/transformers[${PYTHON_SINGLE_USEDEP}]
	sci-ml/tokenizers[${PYTHON_SINGLE_USEDEP}]
	dev-python/torchsde[${PYTHON_SINGLE_USEDEP}]
	~dev-python/comfyui-frontend-package-1.45.21[${PYTHON_SINGLE_USEDEP}]
	~dev-python/comfyui-embedded-docs-0.5.8[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		dev-python/comfy-aimdo-bin[${PYTHON_USEDEP},cuda=]
		dev-python/comfy-kitchen-bin[${PYTHON_USEDEP},cuda=]
		sci-ml/safetensors[${PYTHON_USEDEP}]
		sci-ml/sentencepiece[${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
		dev-python/einops[${PYTHON_USEDEP}]
		dev-python/aiohttp[${PYTHON_USEDEP}]
		dev-python/yarl[${PYTHON_USEDEP}]
		dev-python/pyyaml[${PYTHON_USEDEP}]
		dev-python/pillow[${PYTHON_USEDEP}]
		dev-python/scipy[${PYTHON_USEDEP}]
		dev-python/tqdm[${PYTHON_USEDEP}]
		dev-python/psutil[${PYTHON_USEDEP}]
		dev-python/alembic[${PYTHON_USEDEP}]
		dev-python/sqlalchemy[${PYTHON_USEDEP}]
		dev-python/filelock[${PYTHON_USEDEP}]
		>=dev-python/av-16.0.0[${PYTHON_USEDEP}]
		dev-python/requests[${PYTHON_USEDEP}]
		>=dev-python/simpleeval-1.0.0[${PYTHON_USEDEP}]
		dev-python/blake3[${PYTHON_USEDEP}]
		dev-python/pydantic[${PYTHON_USEDEP}]
		dev-python/pydantic-settings[${PYTHON_USEDEP}]
	')
	templates? ( ~dev-python/comfyui-workflow-templates-0.11.12[${PYTHON_SINGLE_USEDEP}] )
	extra? (
		dev-python/spandrel[${PYTHON_SINGLE_USEDEP}]
		dev-python/kornia[${PYTHON_SINGLE_USEDEP}]
	)
	opengl? (
		$(python_gen_cond_dep '
			dev-python/pyopengl[${PYTHON_USEDEP}]
		')
	)
	compile? (
		$(python_gen_cond_dep '
			~dev-python/triton-bin-3.6.0[${PYTHON_USEDEP}]
		')
	)
	rocm? (
		$(python_gen_cond_dep '
			~dev-python/triton-bin-3.6.0[${PYTHON_USEDEP}]
		')
	)
	audio? ( sci-ml/torchaudio[${PYTHON_SINGLE_USEDEP}] )
"
# USE=audio pulls torchaudio for the audio nodes (comfy.audio_encoders, lumina
# audio VAE), imported lazily and degrading gracefully if absent. torchaudio
# tops out at 2.11 (pins ~sci-ml/pytorch-2.11) and conflicts with the
# pytorch-2.12 stack, so USE=audio only resolves once a matching torchaudio
# exists. verified 2026-06-15.
#
# 0.27.0 dropped glfw (no remaining consumer). Its only PyOpenGL consumer,
# comfy_extras/nodes_glsl.py, now imports comfy_angle first to pre-load the
# ANGLE EGL/GLES runtime. comfy-angle (a Comfy-Org binary wheel) isn't packaged
# here yet, so the GLSL shader nodes stay unavailable regardless of USE=opengl;
# init_builtin_extra_nodes() catches the missing import and skips that node file
# (no startup crash). USE=opengl still installs PyOpenGL for when comfy-angle
# lands. verified 2026-07-01.
BDEPEND="${PYTHON_DEPS}"

src_install() {
	python_setup

	local dest="/opt/${PN}"
	dodir "${dest}"
	cp -r . "${ED}${dest}/" || die
	# Drop test suites and VCS/CI leftovers from the runtime image.
	rm -rf "${ED}${dest}"/{tests,tests-unit,pytest.ini,.github,.gitignore} || die

	python_optimize "${ED}${dest}"

	# System-wide custom_nodes dir (for admin/emerge-dropped nodes); ComfyUI
	# auto-loads extra_model_paths.yaml from its root and merges this path with
	# the per-user <base>/custom_nodes.
	printf 'comfyui_system:\n    base_path: %s/usr/share/%s/\n    custom_nodes: custom_nodes/\n' \
		"${EPREFIX}" "${PN}" > "${ED}${dest}/extra_model_paths.yaml" || die
	keepdir "/usr/share/${PN}/custom_nodes"

	# Launcher: ComfyUI runs from its own directory; per-user writable state
	# (models, custom_nodes, input, output, user, temp) is redirected to a base
	# dir via --base-directory so the /opt tree stays read-only.
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
		elog "flux/lumina/z-image families) runs on dev-python/triton-bin's AMD Triton"
		elog "backend. comfy_aimdo's VRAM offload is a no-op on ROCm."
	else
		elog "USE=-cuda -rocm: comfy_aimdo/comfy_kitchen install their pure-python"
		elog "fallbacks (no GPU offload, eager kernels) and ComfyUI runs on CPU -- slow."
	fi
	if use compile; then
		elog ""
		elog "USE=compile pulled dev-python/triton-bin for torch.compile / inductor"
		elog "custom nodes and comfy_kitchen's Triton backend."
	fi
}
