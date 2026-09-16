# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=no
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

DESCRIPTION="Fast diffusion-inference kernel library (RoPE + FP8/FP4 quant, binary wheel)"
HOMEPAGE="https://pypi.org/project/comfy-kitchen/"
# No sdist. cuda selects the host architecture's abi3 CUDA/Triton wheel;
# otherwise install the portable eager/Triton wheel. Per-arch URLs protect
# arm64 imports. verified 2026-09-09
SRC_URI="
	cuda? (
		amd64? ( https://files.pythonhosted.org/packages/28/0f/c30f26d33bfa2685433a7d3993d438dcff9f6d97f0b8b531f9a6793562d2/comfy_kitchen-${PV}-cp312-abi3-manylinux_2_27_x86_64.manylinux_2_28_x86_64.whl )
		arm64? ( https://files.pythonhosted.org/packages/eb/52/f48e3818f87d2bfab4f04a6461b0b4a0d6b4d0179a6825bd4270d300c05d/comfy_kitchen-${PV}-cp312-abi3-manylinux_2_26_aarch64.manylinux_2_28_aarch64.whl )
	)
	!cuda? ( https://files.pythonhosted.org/packages/71/6a/d8ae9d4c6938606b5fd0003dc0d4a3d274cb9d5b54045c5c46c3fb5499eb/comfy_kitchen-${PV}-py3-none-any.whl )
"
S="${WORKDIR}"

# Wheel LICENSE and classifier specify Apache-2.0. verified 2026-07-01
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
IUSE="cuda"
RESTRICT="bindist mirror strip"

QA_PREBUILT="usr/lib/python3.*/site-packages/comfy_kitchen/*"

BDEPEND="$(python_gen_cond_dep '
	dev-python/installer[${PYTHON_USEDEP}]
')"

# ComfyUI unconditionally uses apply_rope; the package also supplies FP8/FP4.

src_unpack() {
	cp "${DISTDIR}/${A}" "${WORKDIR}/" || die
}

src_compile() { :; }

python_install() {
	${EPYTHON} -m installer --destdir="${D}" "${WORKDIR}/${A}" || die
	python_optimize
}
