# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=no
DISTUTILS_EXT=1
PYTHON_COMPAT=( python3_{12..15} )

inherit distutils-r1

DESCRIPTION="PyTorch VRAM allocator with on-demand weight offloading (binary wheel)"
HOMEPAGE="https://pypi.org/project/comfy-aimdo/"
# No sdist. cuda selects the host architecture's abi3 wheel; otherwise install
# the portable no-op allocator. Per-arch URLs protect arm64. verified 2026-09-09
SRC_URI="
	cuda? (
		amd64? ( https://files.pythonhosted.org/packages/5d/18/807dd84d80469c9620928429911b9ff04c699e8b47204423a8804ac3f09d/comfy_aimdo-${PV}-cp39-abi3-manylinux2014_x86_64.manylinux_2_17_x86_64.whl )
		arm64? ( https://files.pythonhosted.org/packages/8c/53/751aae9e7635b3921647579fdca2d7f29c5bc3e8081743fef9dea1fdf36d/comfy_aimdo-${PV}-cp39-abi3-manylinux2014_aarch64.manylinux_2_17_aarch64.whl )
	)
	!cuda? ( https://files.pythonhosted.org/packages/be/52/3ae1892775f0138af1c0cc27341cf073e0890731f0c68848e8831738f9c2/comfy_aimdo-${PV}-py3-none-any.whl )
"
S="${WORKDIR}"

# Wheel LICENSE is GPL-3.0; PyPI omits it. verified 2026-06-16
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
IUSE="cuda"
RESTRICT="bindist mirror strip"

QA_PREBUILT="usr/lib/python3.*/site-packages/comfy_aimdo/*"

# ComfyUI hard-imports this module. The CUDA wheel needs its driver/runtime;
# the fallback imports without GPU offloading.
BDEPEND="$(python_gen_cond_dep '
	dev-python/installer[${PYTHON_USEDEP}]
')"

src_unpack() {
	cp "${DISTDIR}/${A}" "${WORKDIR}/" || die
}

src_compile() { :; }

python_install() {
	${EPYTHON} -m installer --destdir="${D}" "${WORKDIR}/${A}" || die
	python_optimize
}
