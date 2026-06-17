# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..13} )

inherit python-single-r1

# Upstream tags no releases; pin the commit. The repo bundles its own copy of
# Microsoft's TRELLIS library under trellis/ (plus a wheels/ dir of prebuilt
# CUDA extensions and an extensions/ source tree we do not use -- those ship as
# their own ebuilds). MY_NODE is the on-disk custom_nodes directory name ComfyUI
# scans for; keep upstream's spelling so bundled workflows resolve.
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

# The node loads trellis/ at ComfyUI import time, which eagerly pulls torch, the
# renderers (nvdiffrast/diff-gaussian-rasterization), cv2, plyfile, trimesh,
# etc. The sparse/attention CUDA extensions (spconv, flash-attn, diffoctreerast,
# vox2seq) import lazily but are required at generation time, so they are hard
# deps too. spconv is the sparse-conv backend: the TRELLIS pretrained weights
# are spconv-format, so torchsparse (different weight naming/layout) cannot load
# them -- the loader auto-selects spconv when present.
#
# USE=mesh pulls the textured/solid mesh (.glb) post-processing stack
# (xatlas UV unwrap, pyvista decimation, python-igraph hole-fill). Without it the
# node still loads and the Gaussian (.ply) path works -- patches 0002/0003 make
# those imports optional -- but save_glb=True then errors. kaolin/open3d remain
# unpackaged and are stubbed/avoided.
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
	# Defer rembg to call time -- only auto-masking of non-alpha inputs needs
	# it, so the node loads (and RGBA inputs work) without dev-python/rembg.
	"${FILESDIR}/0001-rembg-lazy-import.patch"
	# Make the mesh-only post-processing deps optional so the Gaussian .ply
	# pipeline imports cleanly. .glb export lights up if they are installed.
	"${FILESDIR}/0002-postprocess-optional-mesh-deps.patch"
	# kaolin only backs optional FlexiCubes shape asserts; stub it out.
	"${FILESDIR}/0003-flexicube-optional-kaolin.patch"
	# Guard an unconditional texture_image.shape log so the gaussian-only path
	# (save_glb=False) does not crash before the .ply write.
	"${FILESDIR}/0004-gaussian-only-texture-guard.patch"
)

src_prepare() {
	# IF_Trellis.py ships with CRLF line endings (the bundled trellis/ files are
	# LF); normalise it so the LF 0004 patch applies.
	sed -i 's/\r$//' IF_Trellis.py || die
	default
}

src_install() {
	python_setup

	local dest="/usr/share/comfyui/custom_nodes/${MY_NODE}"
	insinto "${dest}"
	# Ship the node sources + bundled trellis library + example workflows and
	# assets. Exclude the prebuilt wheels/ (wrong ABI -- we build the CUDA
	# extensions from source) and extensions/ (their own ebuilds), plus the pip
	# install scaffolding and VCS/CI leftovers.
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
