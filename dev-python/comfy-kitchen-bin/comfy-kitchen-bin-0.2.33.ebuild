# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=no
PYTHON_COMPAT=( python3_{12..13} )

inherit distutils-r1

DESCRIPTION="Fast diffusion-inference kernel library (RoPE + FP8/FP4 quant, binary wheel)"
HOMEPAGE="https://pypi.org/project/comfy-kitchen/"
# No sdist upstream. USE=cuda installs the cp312-abi3 x86_64 manylinux wheel
# (CUDA + Triton kernels); without cuda the py3-none-any wheel -- eager + Triton
# backends, no CUDA -- for CPU/ROCm (its Triton backend rides on dev-python/
# triton-bin's AMD/CPU support).
SRC_URI="
	cuda? ( https://files.pythonhosted.org/packages/5f/e1/324966117ea9254ece8dbba0e970a92ec8a33535cbf289a6326d386fdf31/comfy_kitchen-${PV}-cp312-abi3-manylinux_2_27_x86_64.manylinux_2_28_x86_64.whl )
	!cuda? ( https://files.pythonhosted.org/packages/ed/af/7effaeade6a7edfd73440971b71b014cb940e967b564ce488852a22176d8/comfy_kitchen-${PV}-py3-none-any.whl )
"
S="${WORKDIR}"

# Apache-2.0 per upstream's classifier and the wheel's bundled LICENSE.
# verified 2026-07-01
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
IUSE="cuda"
RESTRICT="bindist mirror strip"

QA_PREBUILT="usr/lib/python3.*/site-packages/comfy_kitchen/*"

# Provides comfy_kitchen.apply_rope (used unconditionally by ComfyUI's flux/
# lumina/z-image RoPE path via comfy.quant_ops.ck) plus FP8/FP4 quant kernels.

src_unpack() {
	cp "${DISTDIR}/${A}" "${WORKDIR}/" || die
}

src_compile() { :; }

python_install() {
	${EPYTHON} -m installer --destdir="${D}" "${WORKDIR}/${A}" || die
	python_optimize
}
