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
# arm64 imports. verified 2026-09-30
SRC_URI="
	cuda? (
		amd64? ( https://files.pythonhosted.org/packages/5d/40/1871ee8c58eeef8d15cbf49a461eba0775303f2d9eb34c11af7c29e455c1/comfy_kitchen-${PV}-cp312-abi3-manylinux_2_27_x86_64.manylinux_2_28_x86_64.whl )
		arm64? ( https://files.pythonhosted.org/packages/48/51/5944dd2e8b78c475173eb4afcaa46c07f0b5c68df2f7d6cd94823017aa5c/comfy_kitchen-${PV}-cp312-abi3-manylinux_2_26_aarch64.manylinux_2_28_aarch64.whl )
	)
	!cuda? ( https://files.pythonhosted.org/packages/9c/2e/1c6c621a1cd2ba89ae12fe99e095faa50986c0e6485461170732adfcfa6d/comfy_kitchen-${PV}-py3-none-any.whl )
"
S="${WORKDIR}"

# Wheel LICENSE and classifier specify Apache-2.0. verified 2026-09-30
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
