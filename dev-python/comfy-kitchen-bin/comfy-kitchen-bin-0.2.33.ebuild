# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=no
PYTHON_COMPAT=( python3_{12..13} )

inherit distutils-r1

DESCRIPTION="Fast diffusion-inference kernel library (RoPE + FP8/FP4 quant, binary wheel)"
HOMEPAGE="https://pypi.org/project/comfy-kitchen/"
# No sdist. cuda selects the host architecture's abi3 CUDA/Triton wheel;
# otherwise install the portable eager/Triton wheel. Per-arch URLs protect
# arm64 imports. verified 2026-09-09
SRC_URI="
	cuda? (
		amd64? ( https://files.pythonhosted.org/packages/5f/e1/324966117ea9254ece8dbba0e970a92ec8a33535cbf289a6326d386fdf31/comfy_kitchen-${PV}-cp312-abi3-manylinux_2_27_x86_64.manylinux_2_28_x86_64.whl )
		arm64? ( https://files.pythonhosted.org/packages/72/90/bfbfceb2ea1efd8f9ca6ad1473bffbc2fb50872bb7cfe8611a8541d8f1b3/comfy_kitchen-${PV}-cp312-abi3-manylinux_2_26_aarch64.manylinux_2_28_aarch64.whl )
	)
	!cuda? ( https://files.pythonhosted.org/packages/ed/af/7effaeade6a7edfd73440971b71b014cb940e967b564ce488852a22176d8/comfy_kitchen-${PV}-py3-none-any.whl )
"
S="${WORKDIR}"

# Wheel LICENSE and classifier specify Apache-2.0. verified 2026-07-01
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
IUSE="cuda"
RESTRICT="bindist mirror strip"

QA_PREBUILT="usr/lib/python3.*/site-packages/comfy_kitchen/*"

# ComfyUI unconditionally uses apply_rope; the package also supplies FP8/FP4.

src_unpack() {
	cp "${DISTDIR}/${A}" "${WORKDIR}/" || die
}

src_compile() { :; }

python_install() {
	${EPYTHON} -m installer --destdir="${D}" "${WORKDIR}/${A}" || die
	python_optimize
}
