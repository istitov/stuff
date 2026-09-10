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
# the portable no-op allocator. Per-arch URLs fix arm64 imports. verified 2026-09-09
SRC_URI="
	cuda? (
		amd64? ( https://files.pythonhosted.org/packages/44/b2/5b60dd92c1368ac07fe07b33ff14b6eb6940203b803f3051d78a6ad5c297/comfy_aimdo-${PV}-cp39-abi3-manylinux2010_x86_64.manylinux2014_x86_64.manylinux_2_12_x86_64.manylinux_2_17_x86_64.whl )
		arm64? ( https://files.pythonhosted.org/packages/c6/9b/4e163e39d38f73c1b096eeb7f329280aa3deda35bed40865aa3e7b10b44a/comfy_aimdo-${PV}-cp39-abi3-manylinux2014_aarch64.manylinux_2_17_aarch64.whl )
	)
	!cuda? ( https://files.pythonhosted.org/packages/c6/f3/9afaba10383d33d72ccef2b973587930cb4c1eb9d36bc260d7b1cd5f53ab/comfy_aimdo-${PV}-py3-none-any.whl )
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

src_unpack() {
	cp "${DISTDIR}/${A}" "${WORKDIR}/" || die
}

src_compile() { :; }

python_install() {
	${EPYTHON} -m installer --destdir="${D}" "${WORKDIR}/${A}" || die
	python_optimize
}
