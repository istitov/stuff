# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=no
DISTUTILS_EXT=1
PYTHON_COMPAT=( python3_{12..15} )

inherit distutils-r1

DESCRIPTION="PyTorch VRAM allocator with on-demand weight offloading (binary wheel)"
HOMEPAGE="https://pypi.org/project/comfy-aimdo/"
# No sdist upstream. USE=cuda installs the cp39-abi3 x86_64 manylinux CUDA wheel
# (NVIDIA, on-demand GPU offloading); without cuda the py3-none-any pure-python
# wheel -- importable everywhere but a no-op allocator (CPU/ROCm fallback).
SRC_URI="
	cuda? ( https://files.pythonhosted.org/packages/0f/fc/6c3c1ade49d53a4d1945e42f03e57b38583a55be5a13c32dc83e82e7134f/comfy_aimdo-${PV}-cp39-abi3-manylinux2010_x86_64.manylinux2014_x86_64.manylinux_2_12_x86_64.manylinux_2_17_x86_64.whl )
	!cuda? ( https://files.pythonhosted.org/packages/41/3b/f9304fad30b394aca05216b4a695c01119703e37bd5a81bec2ee0f034ed4/comfy_aimdo-${PV}-py3-none-any.whl )
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

python_install() {
	${EPYTHON} -m installer --destdir="${D}" "${WORKDIR}/${A}" || die
	python_optimize
}
