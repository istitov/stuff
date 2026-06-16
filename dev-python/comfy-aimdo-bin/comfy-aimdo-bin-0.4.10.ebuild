# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=no
PYTHON_COMPAT=( python3_{12..13} )

inherit distutils-r1

DESCRIPTION="PyTorch VRAM allocator with on-demand weight offloading (binary wheel)"
HOMEPAGE="https://pypi.org/project/comfy-aimdo/"
# No sdist upstream. USE=cuda installs the cp39-abi3 x86_64 manylinux CUDA wheel
# (NVIDIA, on-demand GPU offloading); without cuda the py3-none-any pure-python
# wheel -- importable everywhere but a no-op allocator (CPU/ROCm fallback).
SRC_URI="
	cuda? ( https://files.pythonhosted.org/packages/3e/63/29035f15a32c1e31723585c452c7416d6c3c00f92469e2a923a35500df49/comfy_aimdo-${PV}-cp39-abi3-manylinux2010_x86_64.manylinux2014_x86_64.manylinux_2_12_x86_64.manylinux_2_17_x86_64.whl )
	!cuda? ( https://files.pythonhosted.org/packages/68/f4/9fc884854191a0d347e3b5bb185d68ea8099228ccb5b3116dd8aa43839e5/comfy_aimdo-${PV}-py3-none-any.whl )
"
S="${WORKDIR}"

# PyPI metadata omits the license; the wheel's bundled LICENSE is GPL-3.0.
# verified 2026-06-16
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="-* ~amd64"
IUSE="+cuda"
RESTRICT="bindist mirror strip"

QA_PREBUILT="usr/lib/python3.*/site-packages/comfy_aimdo/*"

# ComfyUI hard-imports comfy_aimdo at module load (execution.py,
# model_management.py, model_patcher.py, pinned_memory.py), so the package is
# mandatory. The cuda wheel needs the NVIDIA driver + CUDA 12.8+ runtime at
# import; the py3-none-any fallback imports anywhere (no GPU offloading).

src_unpack() {
	cp "${DISTDIR}/${A}" "${WORKDIR}/" || die
}

src_compile() { :; }

src_install() {
	python_foreach_impl install_wheel
}

install_wheel() {
	${EPYTHON} -m installer --destdir="${D}" "${WORKDIR}/${A}" || die
	python_optimize
}
