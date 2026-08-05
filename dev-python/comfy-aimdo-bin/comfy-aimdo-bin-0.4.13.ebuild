# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=no
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

DESCRIPTION="PyTorch VRAM allocator with on-demand weight offloading (binary wheel)"
HOMEPAGE="https://pypi.org/project/comfy-aimdo/"
# No sdist upstream. USE=cuda installs the cp39-abi3 x86_64 manylinux CUDA wheel
# (NVIDIA, on-demand GPU offloading); without cuda the py3-none-any pure-python
# wheel -- importable everywhere but a no-op allocator (CPU/ROCm fallback).
SRC_URI="
	cuda? ( https://files.pythonhosted.org/packages/a5/ea/ca02387a76cc30fdc0df3e7574199c81f5805b622b835473e76001bae82d/comfy_aimdo-${PV}-cp39-abi3-manylinux2010_x86_64.manylinux2014_x86_64.manylinux_2_12_x86_64.manylinux_2_17_x86_64.whl )
	!cuda? ( https://files.pythonhosted.org/packages/22/68/2e2c45204f7be352b584c26d7d3ec403a1a02c0b663dc97acf51ebef658c/comfy_aimdo-${PV}-py3-none-any.whl )
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
