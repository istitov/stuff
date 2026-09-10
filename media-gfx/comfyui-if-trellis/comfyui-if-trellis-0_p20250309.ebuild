# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..13} )

inherit python-single-r1

# The latest tag predates this default-branch commit, so pin the commit.
# Preserve MY_NODE's upstream spelling for bundled workflow lookup.
COMMIT="51bdfc6fae11bb3966f0cbe22239c13ba612c57e"
MY_NODE="ComfyUI-IF_Trellis"

DESCRIPTION="ComfyUI custom node: TRELLIS image-to-3D (Gaussian/.ply generation)"
HOMEPAGE="https://github.com/if-ai/ComfyUI-IF_Trellis"
SRC_URI="
	https://github.com/if-ai/${MY_NODE}/archive/${COMMIT}.tar.gz
		-> ${P}.gh.tar.gz
"
S="${WORKDIR}/${MY_NODE}-${COMMIT}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="mesh"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

# TRELLIS imports the core image/GPU stack eagerly. Its lazy CUDA extensions
# remain hard dependencies because generation needs them; pretrained weights
# use spconv's format and are incompatible with torchsparse.
# imageio-ffmpeg supplies the optional .mp4 preview backend (verified 2026-07-27).
# USE=mesh adds .glb post-processing; without it the patched Gaussian .ply path
# works, while save_glb=True fails. Unpackaged kaolin/open3d are stubbed/avoided.
RDEPEND="
	${PYTHON_DEPS}
	media-gfx/comfyui[${PYTHON_SINGLE_USEDEP}]
	sci-ml/caffe2[${PYTHON_SINGLE_USEDEP}]
	sci-ml/torchvision[${PYTHON_SINGLE_USEDEP}]
	sci-ml/huggingface_hub[${PYTHON_SINGLE_USEDEP}]
	dev-python/spconv-cu126[${PYTHON_SINGLE_USEDEP}]
	dev-python/flash-attn[${PYTHON_SINGLE_USEDEP}]
	dev-python/nvdiffrast[${PYTHON_SINGLE_USEDEP}]
	dev-python/diff-gaussian-rasterization[${PYTHON_SINGLE_USEDEP}]
	dev-python/diffoctreerast[${PYTHON_SINGLE_USEDEP}]
	dev-python/vox2seq[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		dev-python/easydict[${PYTHON_USEDEP}]
		dev-python/utils3d[${PYTHON_USEDEP}]
		dev-python/plyfile[${PYTHON_USEDEP}]
		dev-python/einops[${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
		dev-python/scipy[${PYTHON_USEDEP}]
		dev-python/tqdm[${PYTHON_USEDEP}]
		dev-python/imageio[${PYTHON_USEDEP}]
		dev-python/imageio-ffmpeg[${PYTHON_USEDEP}]
		dev-python/pillow[${PYTHON_USEDEP}]
		dev-python/trimesh[${PYTHON_USEDEP}]
		sci-ml/safetensors[${PYTHON_USEDEP}]
		media-libs/opencv[${PYTHON_USEDEP},python]
	')
	mesh? (
		dev-python/pyvista[${PYTHON_SINGLE_USEDEP}]
		$(python_gen_cond_dep '
			dev-python/xatlas[${PYTHON_USEDEP}]
			dev-python/python-igraph[${PYTHON_USEDEP}]
			dev-python/pymeshfix[${PYTHON_USEDEP}]
		')
	)
"

PATCHES=(
	# Only automatic masking of non-alpha inputs needs unpackaged rembg.
	"${FILESDIR}/0001-rembg-lazy-import.patch"
	"${FILESDIR}/0002-postprocess-optional-mesh-deps.patch"
	# kaolin only provides optional FlexiCubes shape assertions.
	"${FILESDIR}/0003-flexicube-optional-kaolin.patch"
	"${FILESDIR}/0004-gaussian-only-texture-guard.patch"
)

src_prepare() {
	# Normalize CRLF so 0004 applies.
	sed -i 's/\r$//' IF_Trellis.py || die
	default
}

src_install() {
	python_setup

	local dest="/usr/share/comfyui/custom_nodes/${MY_NODE}"
	insinto "${dest}"
	# Exclude incompatible prebuilt wheels and separately packaged extensions.
	doins -r \
		__init__.py \
		IF_Trellis.py \
		IF_TrellisCheckpointLoader.py \
		trellis_model_manager.py \
		trellis \
		workflow \
		assets \
		LICENSE \
		README.md

	python_optimize "${ED}${dest}"
}

pkg_postinst() {
	elog "TRELLIS image-to-3D node installed to:"
	elog "  ${EROOT}/usr/share/comfyui/custom_nodes/${MY_NODE}"
	elog ""
	elog "Place the model under your ComfyUI base dir before first use:"
	elog "  \${COMFYUI_BASE:-~/.local/share/comfyui}/models/checkpoints/TRELLIS-image-large/"
	elog "(pipeline.json + ckpts/, from huggingface microsoft/TRELLIS-image-large)."
	elog ""
	elog "The Gaussian (.ply) output path works out of the box. For mesh (.glb)"
	elog "export, rebuild with USE=mesh (pulls xatlas, pyvista, python-igraph and"
	elog "pymeshfix; note pyvista drags in sci-libs/vtk)."
}
