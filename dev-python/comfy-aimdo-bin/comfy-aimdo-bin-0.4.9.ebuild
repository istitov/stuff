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
	cuda? ( https://files.pythonhosted.org/packages/e4/97/3e9fdb27eba447dde17852d80b4294a8a4b1442c8a886c33634db5ad4008/comfy_aimdo-${PV}-cp39-abi3-manylinux2010_x86_64.manylinux2014_x86_64.manylinux_2_12_x86_64.manylinux_2_17_x86_64.whl )
	!cuda? ( https://files.pythonhosted.org/packages/22/c5/74784992c566926b16fd4ec3f9285e104516882758363f46864c39f9d3c3/comfy_aimdo-${PV}-py3-none-any.whl )
"
S="${WORKDIR}"

# PyPI metadata omits the license; the wheel's bundled LICENSE is GPL-3.0.
# verified 2026-06-15
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="-* ~amd64"
IUSE="+cuda"
RESTRICT="bindist mirror strip"

QA_PREBUILT="usr/lib/python3.*/site-packages/comfy_aimdo/*"

# ComfyUI 0.24.x hard-imports comfy_aimdo at module load (execution.py,
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
