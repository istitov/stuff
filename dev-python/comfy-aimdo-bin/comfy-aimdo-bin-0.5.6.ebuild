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
		amd64? ( https://files.pythonhosted.org/packages/0e/31/1b997a83947c56a9cb30398e5ea04bfca553cd1385528a923a3702920984/comfy_aimdo-${PV}-cp39-abi3-manylinux2014_x86_64.manylinux_2_17_x86_64.whl )
		arm64? ( https://files.pythonhosted.org/packages/49/0b/a878152f2a091d9370a6a5554de8807da556de70531f938bea2159c6a7ef/comfy_aimdo-${PV}-cp39-abi3-manylinux2014_aarch64.manylinux_2_17_aarch64.whl )
	)
	!cuda? ( https://files.pythonhosted.org/packages/9a/56/4b81638c327e437ba12be826e5a9012960ec51f74a405003142c29960c6c/comfy_aimdo-${PV}-py3-none-any.whl )
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
