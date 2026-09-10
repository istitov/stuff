# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=no
PYTHON_COMPAT=( python3_{12..13} )

inherit distutils-r1

DESCRIPTION="Fast diffusion-inference kernel library (RoPE + FP8/FP4 quant, binary wheel)"
HOMEPAGE="https://pypi.org/project/comfy-kitchen/"
# No sdist. USE=cuda selects the x86-64 abi3 CUDA wheel; otherwise install the
# architecture-independent eager/Triton wheel for CPU or ROCm.
SRC_URI="
	cuda? ( https://files.pythonhosted.org/packages/b5/2b/250f5285bed699b85b3c2ee4280bcee399c43d54a785d3fa3c8a2b0e4dad/comfy_kitchen-${PV}-cp312-abi3-manylinux_2_24_x86_64.manylinux_2_28_x86_64.whl )
	!cuda? ( https://files.pythonhosted.org/packages/dc/a4/ab676a2078663b09324b30f177e0b173f99f0ad54fac0465688f7327b511/comfy_kitchen-${PV}-py3-none-any.whl )
"
S="${WORKDIR}"

# Classifier and bundled license both identify Apache-2.0. verified 2026-07-01
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
IUSE="cuda"
RESTRICT="bindist mirror strip"

QA_PREBUILT="usr/lib/python3.*/site-packages/comfy_kitchen/*"

# Provides ComfyUI's unconditional RoPE path plus FP8/FP4 kernels.

src_unpack() {
	cp "${DISTDIR}/${A}" "${WORKDIR}/" || die
}

src_compile() { :; }

python_install() {
	${EPYTHON} -m installer --destdir="${D}" "${WORKDIR}/${A}" || die
	python_optimize
}
